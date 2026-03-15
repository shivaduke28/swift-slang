#include "../Slang/include/slang.h"

#import "SLVariableLayoutReflection.h"
#import "SLVariableReflection.h"
#import "SLTypeLayout.h"

@interface SLVariableReflection ()
- (instancetype)initWithVariableReflectionPtr:(slang::VariableReflection*)ptr;
@end

@interface SLTypeLayout ()
- (instancetype)initWithTypeLayoutPtr:(slang::TypeLayoutReflection*)typeLayoutPtr;
@end

/// Maps SLParameterCategory to SlangParameterCategory.
static SlangParameterCategory toSlangParameterCategory(SLParameterCategory category) {
    switch (category) {
        case SLParameterCategoryNone: return SLANG_PARAMETER_CATEGORY_NONE;
        case SLParameterCategoryConstantBuffer: return SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER;
        case SLParameterCategoryShaderResource: return SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE;
        case SLParameterCategorySamplerState: return SLANG_PARAMETER_CATEGORY_SAMPLER_STATE;
        case SLParameterCategoryUniform: return SLANG_PARAMETER_CATEGORY_UNIFORM;
        case SLParameterCategoryUnorderedAccess: return SLANG_PARAMETER_CATEGORY_UNORDERED_ACCESS;
        default: return SLANG_PARAMETER_CATEGORY_NONE;
    }
}

/// Maps slang::ParameterCategory to SLParameterCategory.
static SLParameterCategory fromSlangParameterCategory(slang::ParameterCategory category) {
    switch (category) {
        case slang::ParameterCategory::None: return SLParameterCategoryNone;
        case slang::ParameterCategory::ConstantBuffer: return SLParameterCategoryConstantBuffer;
        case slang::ParameterCategory::ShaderResource: return SLParameterCategoryShaderResource;
        case slang::ParameterCategory::SamplerState: return SLParameterCategorySamplerState;
        case slang::ParameterCategory::Uniform: return SLParameterCategoryUniform;
        case slang::ParameterCategory::UnorderedAccess: return SLParameterCategoryUnorderedAccess;
        default: return SLParameterCategoryNone;
    }
}

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
