#include "../Slang/include/slang.h"

#import "SLVariableLayoutReflection.h"
#import "SLVariableReflection.h"
#import "SLTypeLayout.h"
#import "SLParameterCategoryInternal.h"

@interface SLVariableReflection ()
- (instancetype)initWithVariableReflectionPtr:(slang::VariableReflection*)ptr;
@end

@interface SLTypeLayout ()
- (instancetype)initWithTypeLayoutPtr:(slang::TypeLayoutReflection*)typeLayoutPtr;
@end

@interface SLVariableLayoutReflection () {
    slang::VariableLayoutReflection* _variableLayout;
}
@end

@implementation SLVariableLayoutReflection

- (instancetype)initWithVariableLayoutReflectionPtr:(slang::VariableLayoutReflection*)ptr {
    self = [super init];
    if (self) {
        _variableLayout = ptr;
    }
    return self;
}

- (nullable SLVariableReflection *)getVariable {
    if (!_variableLayout) return nil;
    slang::VariableReflection* variable = _variableLayout->getVariable();
    if (!variable) return nil;
    return [[SLVariableReflection alloc] initWithVariableReflectionPtr:variable];
}

- (nullable NSString *)getName {
    if (!_variableLayout) return nil;
    const char* name = _variableLayout->getName();
    if (!name) return nil;
    return [NSString stringWithUTF8String:name];
}

- (nullable SLTypeLayout *)getTypeLayout {
    if (!_variableLayout) return nil;
    slang::TypeLayoutReflection* typeLayout = _variableLayout->getTypeLayout();
    if (!typeLayout) return nil;
    return [[SLTypeLayout alloc] initWithTypeLayoutPtr:typeLayout];
}

- (SLParameterCategory)getCategory {
    if (!_variableLayout) return SLParameterCategoryNone;
    return fromSlangParameterCategory(_variableLayout->getCategory());
}

- (NSUInteger)getOffset:(SLParameterCategory)category {
    if (!_variableLayout) return 0;
    return (NSUInteger)_variableLayout->getOffset(toSlangParameterCategory(category));
}

- (unsigned int)getBindingIndex {
    if (!_variableLayout) return 0;
    return _variableLayout->getBindingIndex();
}

- (unsigned int)getBindingSpace {
    if (!_variableLayout) return 0;
    return _variableLayout->getBindingSpace();
}

@end
