import XCTest
import SwiftSlang

/// Compile-time benchmark. Not part of the normal suite: run with
/// -only-testing:SwiftSlangTests/CompileBenchmarkTests and read the median from the log.
final class CompileBenchmarkTests: XCTestCase {

    static let pbrSource = """
    interface IBRDF {
        float3 evaluate(float3 n, float3 l, float3 v, float3 albedo, float roughness, float metallic);
    }

    struct CookTorrance : IBRDF {
        float distribution(float nh, float roughness) {
            float a = roughness * roughness;
            float a2 = a * a;
            float d = nh * nh * (a2 - 1.0) + 1.0;
            return a2 / (3.14159265 * d * d);
        }
        float geometry(float nv, float nl, float roughness) {
            float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
            float gv = nv / (nv * (1.0 - k) + k);
            float gl = nl / (nl * (1.0 - k) + k);
            return gv * gl;
        }
        float3 fresnel(float vh, float3 f0) {
            return f0 + (1.0 - f0) * pow(1.0 - vh, 5.0);
        }
        float3 evaluate(float3 n, float3 l, float3 v, float3 albedo, float roughness, float metallic) {
            float3 h = normalize(l + v);
            float nl = max(dot(n, l), 0.0);
            float nv = max(dot(n, v), 0.0);
            float nh = max(dot(n, h), 0.0);
            float vh = max(dot(v, h), 0.0);
            float3 f0 = lerp(float3(0.04), albedo, metallic);
            float3 spec = distribution(nh, roughness) * geometry(nv, nl, roughness) * fresnel(vh, f0)
                / max(4.0 * nv * nl, 0.001);
            float3 kd = (1.0 - fresnel(vh, f0)) * (1.0 - metallic);
            return (kd * albedo / 3.14159265 + spec) * nl;
        }
    }

    struct Lambert : IBRDF {
        float3 evaluate(float3 n, float3 l, float3 v, float3 albedo, float roughness, float metallic) {
            return albedo * max(dot(n, l), 0.0) / 3.14159265;
        }
    }

    struct Light { float3 position; float intensity; float3 color; float radius; };

    struct MaterialParams {
        float4 baseColor;
        float roughness;
        float metallic;
        float normalScale;
        float occlusionStrength;
        float3 emissive;
        int lightCount;
        Light lights[4];
    };

    uniform MaterialParams params;
    Texture2D albedoMap;
    Texture2D normalMap;
    Texture2D metallicRoughnessMap;
    Texture2D occlusionMap;
    Texture2D emissiveMap;
    SamplerState linearSampler;

    struct PSInput {
        float4 position : SV_Position;
        float3 worldPos : WORLDPOS;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv : TEXCOORD0;
    };

    float3 shade<B : IBRDF>(B brdf, PSInput input, float3 n, float3 v, float3 albedo, float roughness, float metallic) {
        float3 result = 0;
        for (int i = 0; i < params.lightCount; i++) {
            Light light = params.lights[i];
            float3 toLight = light.position - input.worldPos;
            float dist2 = max(dot(toLight, toLight), 0.0001);
            float atten = light.intensity / dist2 * saturate(1.0 - dist2 / (light.radius * light.radius));
            result += brdf.evaluate(n, normalize(toLight), v, albedo, roughness, metallic) * light.color * atten;
        }
        return result;
    }

    [shader("fragment")]
    float4 fragMain(PSInput input) : SV_Target {
        float4 albedoSample = albedoMap.Sample(linearSampler, input.uv) * params.baseColor;
        float3 nTex = normalMap.Sample(linearSampler, input.uv).xyz * 2.0 - 1.0;
        nTex.xy *= params.normalScale;
        float3 n = normalize(input.normal);
        float3 t = normalize(input.tangent.xyz);
        float3 b = cross(n, t) * input.tangent.w;
        float3 worldN = normalize(t * nTex.x + b * nTex.y + n * nTex.z);
        float2 mr = metallicRoughnessMap.Sample(linearSampler, input.uv).bg;
        float metallic = mr.x * params.metallic;
        float roughness = clamp(mr.y * params.roughness, 0.04, 1.0);
        float ao = lerp(1.0, occlusionMap.Sample(linearSampler, input.uv).r, params.occlusionStrength);
        float3 v = normalize(-input.worldPos);
        float3 color = shade(CookTorrance(), input, worldN, v, albedoSample.rgb, roughness, metallic);
        color += shade(Lambert(), input, worldN, v, albedoSample.rgb, roughness, metallic) * 0.1;
        color *= ao;
        color += emissiveMap.Sample(linearSampler, input.uv).rgb * params.emissive;
        return float4(color, albedoSample.a);
    }
    """

    func testCompileBenchmark() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let iterations = 30
        var samples: [Double] = []

        for i in 0..<iterations {
            let targetDesc = SLTargetDesc(format: .metal, profile: profile)
            let sessionDesc = SLSessionDesc()
            sessionDesc.targets = [targetDesc]
            let session = try globalSession.createSession(with: sessionDesc)

            let start = DispatchTime.now()
            let module = try session.loadModule(fromSourceString: "Bench\(i)", path: "<inline>", source: Self.pbrSource)
            let entryPoint = try module.findEntryPoint(byName: "fragMain")
            let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
            let linked = try composite.link()
            let code = try linked.getTargetCode(0)
            let end = DispatchTime.now()
            XCTAssertGreaterThan(code.count, 0)
            samples.append(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000)
        }

        let sorted = samples.sorted()
        let median = sorted[sorted.count / 2]
        let mean = samples.reduce(0, +) / Double(samples.count)
        print("BENCH slang=\(globalSession.buildTagString()) median=\(String(format: "%.2f", median))ms mean=\(String(format: "%.2f", mean))ms min=\(String(format: "%.2f", sorted.first!))ms max=\(String(format: "%.2f", sorted.last!))ms n=\(iterations)")
    }
}
