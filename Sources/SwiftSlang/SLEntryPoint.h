#import <Foundation/Foundation.h>
#import "SLComponentTypeConvertible.h"

NS_ASSUME_NONNULL_BEGIN

@class SLBlob;
@class SLUserAttribute;

/// Stage type for shader entry points.
/// These values correspond to SlangStage in slang.h.
typedef NS_ENUM(int32_t, SLShaderStage) {
    SLShaderStageNone = 0,
    SLShaderStageVertex = 1,
    SLShaderStageHull = 2,
    SLShaderStageDomain = 3,
    SLShaderStageGeometry = 4,
    SLShaderStageFragment = 5,
    SLShaderStageCompute = 6,
    SLShaderStageRayGeneration = 7,
    SLShaderStageIntersection = 8,
    SLShaderStageAnyHit = 9,
    SLShaderStageClosestHit = 10,
    SLShaderStageMiss = 11,
    SLShaderStageCallable = 12,
    SLShaderStageMesh = 13,
    SLShaderStageAmplification = 14,
    SLShaderStageDispatch = 15,
};

/// A wrapper for slang::IEntryPoint
/// Represents an entry point in a Slang module.
@interface SLEntryPoint : NSObject <SLComponentTypeConvertible>

/// Get the name of this entry point.
@property (nonatomic, readonly) NSString *name;

/// Get the stage of this entry point.
@property (nonatomic, readonly) SLShaderStage stage;

/// User-defined attributes on this entry point (e.g., [dispatch(1, 1, 1)]).
@property (nonatomic, readonly) NSArray<SLUserAttribute *> *userAttributes;

/// Compute thread group size from [numthreads(X, Y, Z)].
/// Returns {0, 0, 0} for non-compute entry points.
@property (nonatomic, readonly) NSArray<NSNumber *> *computeThreadGroupSize;

@end

NS_ASSUME_NONNULL_END
