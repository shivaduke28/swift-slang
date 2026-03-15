import XCTest
import SwiftSlang

final class SwiftSlangTests: XCTestCase {

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

        let shaderSource = """
        [shader("vertex")]
        float4 vertexMain(float3 position : POSITION) : SV_Position {
            return float4(position, 1.0);
        }
        """

        let module = try session.loadModule(
            fromSourceString: "TestShader",
            path: "<inline>",
            source: shaderSource
        )
        XCTAssertEqual(module.name, "TestShader")

        let entryPoint = try module.findEntryPoint(byName: "vertexMain")
        XCTAssertEqual(entryPoint.name, "vertexMain")
        XCTAssertEqual(entryPoint.stage, .vertex)

        let composite = try session.createCompositeComponentType(
            with: module,
            entryPoints: [entryPoint]
        )

        let linked = try composite.link()

        let metalCode = try linked.getTargetCode(0)
        XCTAssertGreaterThan(metalCode.count, 0)
    }
}
