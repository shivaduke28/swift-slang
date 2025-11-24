#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLBlob;

/// Stage type for shader entry points
typedef NS_ENUM(int32_t, SLShaderStage) {
    SLShaderStageNone = 0,
    SLShaderStageVertex,
    SLShaderStageHull,
    SLShaderStageDomain,
    SLShaderStageGeometry,
    SLShaderStageFragment,
    SLShaderStageCompute,
    SLShaderStageRayGeneration,
    SLShaderStageIntersection,
    SLShaderStageAnyHit,
    SLShaderStageClosestHit,
    SLShaderStageMiss,
    SLShaderStageCallable,
    SLShaderStageMesh,
    SLShaderStageAmplification,
};

/// A wrapper for slang::IEntryPoint
/// Represents an entry point in a Slang module.
@interface SLEntryPoint : NSObject

/// Get the name of this entry point.
@property (nonatomic, readonly) NSString *name;

/// Get the stage of this entry point.
@property (nonatomic, readonly) SLShaderStage stage;

@end

NS_ASSUME_NONNULL_END
