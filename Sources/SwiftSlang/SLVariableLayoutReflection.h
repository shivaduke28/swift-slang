#import <Foundation/Foundation.h>
#import "SLShaderParameter.h"

NS_ASSUME_NONNULL_BEGIN

@class SLVariableReflection;
@class SLTypeLayout;

/// A wrapper for slang::VariableLayoutReflection.
/// Provides variable layout information such as offset, binding index, and type layout.
@interface SLVariableLayoutReflection : NSObject

/// Corresponds to VariableLayoutReflection::getVariable()
- (nullable SLVariableReflection *)getVariable;

/// Corresponds to VariableLayoutReflection::getName()
- (nullable NSString *)getName;

/// Corresponds to VariableLayoutReflection::getTypeLayout()
- (nullable SLTypeLayout *)getTypeLayout;

/// Corresponds to VariableLayoutReflection::getCategory()
- (SLParameterCategory)getCategory;

/// Corresponds to VariableLayoutReflection::getOffset(SlangParameterCategory)
- (NSUInteger)getOffset:(SLParameterCategory)category;

/// Corresponds to VariableLayoutReflection::getBindingIndex()
- (unsigned int)getBindingIndex;

/// Corresponds to VariableLayoutReflection::getBindingSpace()
- (unsigned int)getBindingSpace;

@end

NS_ASSUME_NONNULL_END
