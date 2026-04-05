#import <Foundation/Foundation.h>
#import "SLShaderParameter.h"
#import "SLTypeReflection.h"

NS_ASSUME_NONNULL_BEGIN

@class SLVariableLayoutReflection;

/// A wrapper for slang::TypeLayoutReflection.
/// Provides type layout information such as size, stride, alignment, and fields.
@interface SLTypeLayout : NSObject

/// The byte size of this type (using Uniform parameter category).
@property (nonatomic, readonly) NSUInteger size;

/// The element type layout for buffer/array types (e.g., the T in RWStructuredBuffer<T>).
/// Returns nil if not applicable.
@property (nonatomic, readonly, nullable) SLTypeLayout *elementTypeLayout;

/// Corresponds to TypeLayoutReflection::getType()
- (nullable SLTypeReflection *)getType;

/// Corresponds to TypeLayoutReflection::getKind()
- (SLTypeKind)getKind;

/// Corresponds to TypeLayoutReflection::getSize(SlangParameterCategory)
- (NSUInteger)getSize:(SLParameterCategory)category;

/// Corresponds to TypeLayoutReflection::getStride(SlangParameterCategory)
- (NSUInteger)getStride:(SLParameterCategory)category;

/// Corresponds to TypeLayoutReflection::getAlignment(SlangParameterCategory)
- (int32_t)getAlignment:(SLParameterCategory)category;

/// Corresponds to TypeLayoutReflection::getFieldCount()
- (unsigned int)getFieldCount;

/// Corresponds to TypeLayoutReflection::getFieldByIndex()
- (nullable SLVariableLayoutReflection *)getFieldByIndex:(unsigned int)index;

/// Corresponds to TypeLayoutReflection::getResourceResultType()
/// Returns the element type for resource types (e.g., float4 in RWTexture2D<float4>).
- (nullable SLTypeReflection *)getResourceResultType;

@end

NS_ASSUME_NONNULL_END
