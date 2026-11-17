#include "../Slang/include/slang.h"

#import "SLProgramLayout.h"
#import "SLTypeLayout.h"
#import "SLVariableLayoutReflection.h"

@interface SLTypeLayout ()
- (instancetype)initWithTypeLayoutPtr:(slang::TypeLayoutReflection*)typeLayoutPtr;
@end

@interface SLVariableLayoutReflection ()
- (instancetype)initWithVariableLayoutReflectionPtr:(slang::VariableLayoutReflection*)ptr;
@end

@interface SLProgramLayout () {
    slang::ProgramLayout* _programLayout;
    // The layout is owned by the component type, so keep it alive.
    id _owner;
}
@end

@implementation SLProgramLayout

- (instancetype)initWithProgramLayoutPtr:(slang::ProgramLayout*)ptr owner:(id)owner {
    self = [super init];
    if (self) {
        _programLayout = ptr;
        _owner = owner;
    }
    return self;
}

- (unsigned int)getParameterCount {
    if (!_programLayout) return 0;
    return _programLayout->getParameterCount();
}

- (nullable SLVariableLayoutReflection *)getParameterByIndex:(unsigned int)index {
    if (!_programLayout) return nil;
    slang::VariableLayoutReflection* param = _programLayout->getParameterByIndex(index);
    if (!param) return nil;
    return [[SLVariableLayoutReflection alloc] initWithVariableLayoutReflectionPtr:param];
}

- (nullable SLTypeLayout *)getGlobalParamsTypeLayout {
    if (!_programLayout) return nil;
    slang::TypeLayoutReflection* typeLayout = _programLayout->getGlobalParamsTypeLayout();
    if (!typeLayout) return nil;
    return [[SLTypeLayout alloc] initWithTypeLayoutPtr:typeLayout];
}

- (nullable SLVariableLayoutReflection *)getGlobalParamsVarLayout {
    if (!_programLayout) return nil;
    slang::VariableLayoutReflection* varLayout = _programLayout->getGlobalParamsVarLayout();
    if (!varLayout) return nil;
    return [[SLVariableLayoutReflection alloc] initWithVariableLayoutReflectionPtr:varLayout];
}

@end
