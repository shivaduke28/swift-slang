import XCTest
import SwiftSlang

final class SwiftSlangTests: XCTestCase {

    // MARK: - Basic

    func testGlobalSessionCreation() throws {
        let globalSession = try SLGlobalSession.create()
        XCTAssertNotNil(globalSession)
        let buildTag = globalSession.buildTagString()
        XCTAssertFalse(buildTag.isEmpty)
    }

    func testBasicCompile() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [shader("vertex")]
        float4 vertexMain(float3 position : POSITION) : SV_Position {
            return float4(position, 1.0);
        }
        """
        let module = try session.loadModule(fromSourceString: "TestShader", path: "<inline>", source: source)
        let entryPoint = try module.findEntryPoint(byName: "vertexMain")
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let metalCode = try linked.getTargetCode(0)
        XCTAssertGreaterThan(metalCode.count, 0)
    }

    // MARK: - TypeReflection

    func testScalarTypeReflection() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        uniform float scalarParam;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(scalarParam, 0, 0, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let uniformParam = params.first { $0.name == "scalarParam" }
        XCTAssertNotNil(uniformParam)
        let typeLayout = try XCTUnwrap(uniformParam?.typeLayout)
        let type = try XCTUnwrap(typeLayout.getType())
        XCTAssertEqual(type.getKind(), .scalar)
        XCTAssertEqual(type.getScalarType(), .float32)
    }

    func testVectorTypeReflection() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        uniform float3 colorParam;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(colorParam, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let uniformParam = params.first { $0.name == "colorParam" }
        let typeLayout = try XCTUnwrap(uniformParam?.typeLayout)
        let type = try XCTUnwrap(typeLayout.getType())
        XCTAssertEqual(type.getKind(), .vector)
        XCTAssertEqual(type.getScalarType(), .float32)
        XCTAssertEqual(type.getElementCount(), 3)
    }

    func testMatrixTypeReflection() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        uniform float4x4 matParam;
        [shader("vertex")]
        float4 vertMain(float3 pos : POSITION) : SV_Position { return mul(matParam, float4(pos, 1)); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let uniformParam = params.first { $0.name == "matParam" }
        let typeLayout = try XCTUnwrap(uniformParam?.typeLayout)
        let type = try XCTUnwrap(typeLayout.getType())
        XCTAssertEqual(type.getKind(), .matrix)
        XCTAssertEqual(type.getRowCount(), 4)
        XCTAssertEqual(type.getColumnCount(), 4)
        XCTAssertEqual(type.getScalarType(), .float32)
    }

    // MARK: - Struct & TypeLayout

    func testStructReflection() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        struct MyParams { float intensity; float3 color; int mode; };
        uniform MyParams params;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(params.color * params.intensity, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let shaderParams = try linked.getShaderParameters(0)

        let param = shaderParams.first { $0.name == "params" || $0.name == "data" }
        XCTAssertNotNil(param)

        let typeLayout = try XCTUnwrap(param?.typeLayout)
        let structType = try XCTUnwrap(typeLayout.getType())
        XCTAssertEqual(structType.getKind(), .struct)
        XCTAssertEqual(structType.getName(), "MyParams")
        XCTAssertEqual(structType.getFieldCount(), 3)

        let field0 = try XCTUnwrap(structType.getFieldBy(0))
        XCTAssertEqual(field0.getName(), "intensity")
        let field0Type = try XCTUnwrap(field0.getType())
        XCTAssertEqual(field0Type.getKind(), .scalar)
        XCTAssertEqual(field0Type.getScalarType(), .float32)

        let field1 = try XCTUnwrap(structType.getFieldBy(1))
        XCTAssertEqual(field1.getName(), "color")
        let field1Type = try XCTUnwrap(field1.getType())
        XCTAssertEqual(field1Type.getKind(), .vector)
        XCTAssertEqual(field1Type.getElementCount(), 3)

        let field2 = try XCTUnwrap(structType.getFieldBy(2))
        XCTAssertEqual(field2.getName(), "mode")
        let field2Type = try XCTUnwrap(field2.getType())
        XCTAssertEqual(field2Type.getScalarType(), .int32)
    }

    func testTypeLayoutStrideAndAlignment() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        struct MyData { float a; float b; };
        uniform MyData data;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(data.a, data.b, 0, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let shaderParams = try linked.getShaderParameters(0)

        let param = shaderParams.first { $0.name == "params" || $0.name == "data" }
        let typeLayout = try XCTUnwrap(param?.typeLayout)

        XCTAssertEqual(typeLayout.getFieldCount(), 2)
        XCTAssertEqual(typeLayout.size, 8)
        XCTAssertEqual(typeLayout.getStride(.uniform), 8)
        XCTAssertGreaterThan(typeLayout.getAlignment(.uniform), 0)

        let field0Layout = try XCTUnwrap(typeLayout.getFieldBy(0))
        XCTAssertEqual(field0Layout.getName(), "a")
        XCTAssertEqual(field0Layout.getOffset(.uniform), 0)

        let field1Layout = try XCTUnwrap(typeLayout.getFieldBy(1))
        XCTAssertEqual(field1Layout.getName(), "b")
        XCTAssertEqual(field1Layout.getOffset(.uniform), 4)
    }

    // MARK: - User Attributes

    func testUserAttributes() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [__AttributeUsage(_AttributeTargets.Var)]
        struct rangeAttribute { float minVal; float defaultVal; float maxVal; };

        [range(0.0, 0.5, 1.0)]
        uniform float intensity;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(intensity, 0, 0, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let uniformParam = params.first { $0.name == "intensity" }
        XCTAssertNotNil(uniformParam)
        XCTAssertGreaterThan(uniformParam!.userAttributes.count, 0)

        let rangeAttr = uniformParam!.userAttributes.first { $0.name == "range" }
        XCTAssertNotNil(rangeAttr)
        XCTAssertEqual(rangeAttr!.argumentCount, 3)
        XCTAssertEqual(rangeAttr!.floatArguments[0].floatValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(rangeAttr!.floatArguments[1].floatValue, 0.5, accuracy: 0.001)
        XCTAssertEqual(rangeAttr!.floatArguments[2].floatValue, 1.0, accuracy: 0.001)
    }

    func testUserAttributeViaVariableReflection() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [__AttributeUsage(_AttributeTargets.Var)]
        struct colorAttribute { int enabled; };

        struct MyParams { [color(1)] float3 tint; };
        uniform MyParams params;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(params.tint, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let shaderParams = try linked.getShaderParameters(0)

        let param = shaderParams.first { $0.name == "params" || $0.name == "data" }
        let typeLayout = try XCTUnwrap(param?.typeLayout)

        // Access field via TypeLayout → VariableLayoutReflection → VariableReflection
        XCTAssertEqual(typeLayout.getFieldCount(), 1)
        let tintFieldLayout = try XCTUnwrap(typeLayout.getFieldBy(0))
        let tintVariable = try XCTUnwrap(tintFieldLayout.getVariable())
        XCTAssertEqual(tintVariable.getName(), "tint")
        XCTAssertEqual(tintVariable.getUserAttributeCount(), 1)

        let colorAttr = try XCTUnwrap(tintVariable.getUserAttribute(by: 0))
        XCTAssertEqual(colorAttr.name, "color")
        XCTAssertEqual(colorAttr.argumentCount, 1)
        XCTAssertEqual(colorAttr.intArguments[0].intValue, 1)
    }

    // MARK: - Default Values

    func testDefaultValues() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        struct Params { float brightness = 0.75; int count = 3; };
        uniform Params params;
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(params.brightness, 0, 0, float(params.count)); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let shaderParams = try linked.getShaderParameters(0)

        let param = shaderParams.first { $0.name == "params" || $0.name == "data" }
        let typeLayout = try XCTUnwrap(param?.typeLayout)
        let structType = try XCTUnwrap(typeLayout.getType())

        let brightnessField = try XCTUnwrap(structType.getFieldBy(0))
        XCTAssertEqual(brightnessField.getName(), "brightness")
        XCTAssertTrue(brightnessField.hasDefaultValue())
        let floatVal = try XCTUnwrap(brightnessField.getDefaultValueFloat())
        XCTAssertEqual(floatVal.floatValue, 0.75, accuracy: 0.001)

        let countField = try XCTUnwrap(structType.getFieldBy(1))
        XCTAssertEqual(countField.getName(), "count")
        XCTAssertTrue(countField.hasDefaultValue())
        let intVal = try XCTUnwrap(countField.getDefaultValueInt())
        XCTAssertEqual(intVal.int64Value, 3)
    }

    // MARK: - Resource Types

    func testTextureAndSamplerParameters() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        Texture2D myTexture;
        SamplerState mySampler;
        [shader("fragment")]
        float4 fragMain(float2 uv : TEXCOORD) : SV_Target { return myTexture.Sample(mySampler, uv); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let texParam = params.first { $0.name == "myTexture" }
        XCTAssertNotNil(texParam)
        XCTAssertEqual(texParam!.category, .shaderResource)

        let samplerParam = params.first { $0.name == "mySampler" }
        XCTAssertNotNil(samplerParam)
        XCTAssertEqual(samplerParam!.category, .samplerState)

        let texTypeLayout = try XCTUnwrap(texParam?.typeLayout)
        let texType = try XCTUnwrap(texTypeLayout.getType())
        XCTAssertEqual(texType.getKind(), .resource)
        XCTAssertEqual(texType.getResourceShape(), .texture2D)
        XCTAssertEqual(texType.getResourceAccess(), .read)
    }

    // MARK: - Preprocessor Macros

    func testPreprocessorMacroAffectsCompilation() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)

        let source = """
        uniform float intensity;
        [shader("fragment")]
        float4 fragMain() : SV_Target {
        #ifdef USE_RED
            return float4(intensity, 0, 0, 1);
        #else
            return float4(0, 0, intensity, 1);
        #endif
        }
        """

        // With USE_RED defined
        let sessionDescWithMacro = SLSessionDesc()
        sessionDescWithMacro.targets = [targetDesc]
        sessionDescWithMacro.preprocessorMacros = ["USE_RED": "1"]
        let sessionWith = try globalSession.createSession(with: sessionDescWithMacro)
        let moduleWith = try sessionWith.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let epWith = try moduleWith.entryPoint(at: 0)
        let compositeWith = try sessionWith.createCompositeComponentType(with: moduleWith, entryPoints: [epWith])
        let linkedWith = try compositeWith.link()
        let codeWith = try linkedWith.getTargetCode(0)

        // Without USE_RED defined
        let sessionDescWithout = SLSessionDesc()
        sessionDescWithout.targets = [targetDesc]
        let sessionWithout = try globalSession.createSession(with: sessionDescWithout)
        let moduleWithout = try sessionWithout.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let epWithout = try moduleWithout.entryPoint(at: 0)
        let compositeWithout = try sessionWithout.createCompositeComponentType(with: moduleWithout, entryPoints: [epWithout])
        let linkedWithout = try compositeWithout.link()
        let codeWithout = try linkedWithout.getTargetCode(0)

        // Both should compile successfully but produce different Metal code
        XCTAssertGreaterThan(codeWith.count, 0)
        XCTAssertGreaterThan(codeWithout.count, 0)
        XCTAssertNotEqual(codeWith, codeWithout)
    }

    func testMultiplePreprocessorMacros() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        sessionDesc.preprocessorMacros = [
            "RESOLUTION_X": "1920",
            "RESOLUTION_Y": "1080",
            "SCALE": "2",
        ]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [shader("fragment")]
        float4 fragMain() : SV_Target {
            float x = RESOLUTION_X;
            float y = RESOLUTION_Y;
            float s = SCALE;
            return float4(x, y, s, 1);
        }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let metalCode = try linked.getTargetCode(0)
        XCTAssertGreaterThan(metalCode.count, 0)
    }

    func testPreprocessorMacroWithValue() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        sessionDesc.preprocessorMacros = ["CHANNEL_COUNT": "3"]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        uniform float values[CHANNEL_COUNT];
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(values[0], values[1], values[2], 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.entryPoint(at: 0)
        let composite = try session.createCompositeComponentType(with: module, entryPoints: [entryPoint])
        let linked = try composite.link()
        let params = try linked.getShaderParameters(0)

        let valuesParam = params.first { $0.name == "values" }
        XCTAssertNotNil(valuesParam)
        let typeLayout = try XCTUnwrap(valuesParam?.typeLayout)
        let type = try XCTUnwrap(typeLayout.getType())
        XCTAssertEqual(type.getKind(), .array)
        XCTAssertEqual(type.getElementCount(), 3)
    }

    // MARK: - Entry Point

    func testComputeEntryPoint() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [shader("compute")]
        [numthreads(8, 4, 1)]
        void computeMain(uint3 tid : SV_DispatchThreadID) {}
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        let entryPoint = try module.findEntryPoint(byName: "computeMain")
        XCTAssertEqual(entryPoint.stage, .compute)

        let threadGroupSize = entryPoint.computeThreadGroupSize
        XCTAssertEqual(threadGroupSize.count, 3)
        XCTAssertEqual(threadGroupSize[0].intValue, 8)
        XCTAssertEqual(threadGroupSize[1].intValue, 4)
        XCTAssertEqual(threadGroupSize[2].intValue, 1)
    }

    func testMultipleEntryPoints() throws {
        let globalSession = try SLGlobalSession.create()
        let profile = globalSession.findProfile("sm_5_0")
        let targetDesc = SLTargetDesc(format: .metal, profile: profile)
        let sessionDesc = SLSessionDesc()
        sessionDesc.targets = [targetDesc]
        let session = try globalSession.createSession(with: sessionDesc)

        let source = """
        [shader("vertex")]
        float4 vertMain(float3 pos : POSITION) : SV_Position { return float4(pos, 1); }
        [shader("fragment")]
        float4 fragMain() : SV_Target { return float4(1, 0, 0, 1); }
        """
        let module = try session.loadModule(fromSourceString: "Test", path: "<inline>", source: source)
        XCTAssertEqual(module.entryPointCount, 2)

        let vertEntry = try module.findEntryPoint(byName: "vertMain")
        XCTAssertEqual(vertEntry.stage, .vertex)

        let fragEntry = try module.findEntryPoint(byName: "fragMain")
        XCTAssertEqual(fragEntry.stage, .fragment)
    }
}
