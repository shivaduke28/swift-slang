#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLVariableLayoutReflection;
@class SLTypeLayout;

/// A wrapper for slang::ProgramLayout (slang::ShaderReflection).
/// Obtained from -[SLComponentType getLayout:error:].
/// Keeps the component type it was obtained from alive.
@interface SLProgramLayout : NSObject

/// Corresponds to ProgramLayout::getParameterCount()
- (unsigned int)getParameterCount;

/// Corresponds to ProgramLayout::getParameterByIndex()
- (nullable SLVariableLayoutReflection *)getParameterByIndex:(unsigned int)index;

/// Corresponds to ProgramLayout::getGlobalParamsTypeLayout()
- (nullable SLTypeLayout *)getGlobalParamsTypeLayout;

/// Corresponds to ProgramLayout::getGlobalParamsVarLayout()
- (nullable SLVariableLayoutReflection *)getGlobalParamsVarLayout;

@end

NS_ASSUME_NONNULL_END
