#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Code generation target format.
/// These values correspond to SlangCompileTarget in slang.h.
typedef NS_ENUM(int32_t, SLCompileTargetType) {
    SLCompileTargetUnknown = 0,
    SLCompileTargetNone = 1,
    SLCompileTargetGLSL = 2,
    SLCompileTargetGLSLVulkan = 3,              ///< Deprecated: just use SLCompileTargetGLSL
    SLCompileTargetGLSLVulkanOneDesc = 4,       ///< Deprecated
    SLCompileTargetHLSL = 5,
    SLCompileTargetSPIRV = 6,
    SLCompileTargetSPIRVAssembly = 7,
    SLCompileTargetDXBytecode = 8,
    SLCompileTargetDXBytecodeAssembly = 9,
    SLCompileTargetDXIL = 10,
    SLCompileTargetDXILAssembly = 11,
    SLCompileTargetCSource = 12,
    SLCompileTargetCPPSource = 13,
    SLCompileTargetHostExecutable = 14,
    SLCompileTargetShaderSharedLibrary = 15,
    SLCompileTargetShaderHostCallable = 16,
    SLCompileTargetCUDASource = 17,
    SLCompileTargetPTX = 18,
    SLCompileTargetCUDAObjectCode = 19,
    SLCompileTargetObjectCode = 20,
    SLCompileTargetHostCPPSource = 21,
    SLCompileTargetHostHostCallable = 22,
    SLCompileTargetCPPPyTorchBinding = 23,
    SLCompileTargetMetal = 24,
    SLCompileTargetMetalLib = 25,
    SLCompileTargetMetalLibAssembly = 26,
    SLCompileTargetHostSharedLibrary = 27,      ///< A shared library/Dll for host code
    SLCompileTargetWGSL = 28,                   ///< WebGPU shading language
    SLCompileTargetWGSLSPIRVAssembly = 29,      ///< SPIR-V assembly via WebGPU shading language
    SLCompileTargetWGSLSPIRV = 30,              ///< SPIR-V via WebGPU shading language
    SLCompileTargetHostVM = 31,                 ///< Bytecode for Slang VM
};

/// A wrapper for slang::TargetDesc
@interface SLTargetDesc : NSObject

@property (nonatomic, assign) SLCompileTargetType format;
@property (nonatomic, assign) int32_t profile;

- (instancetype)initWithFormat:(SLCompileTargetType)format profile:(int32_t)profile;

@end

/// A wrapper for slang::SessionDesc
@interface SLSessionDesc : NSObject

/// Code generation targets
@property (nonatomic, strong) NSArray<SLTargetDesc *> *targets;

/// Search paths for #include and import
@property (nonatomic, strong) NSArray<NSString *> *searchPaths;

/// Preprocessor macro definitions (key: name, value: definition)
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *preprocessorMacros;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
