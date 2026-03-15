#include "../Slang/include/slang.h"

#import "SLTypeLayout.h"
#import "SLTypeReflection.h"
#import "SLVariableLayoutReflection.h"

@interface SLTypeReflection ()
- (instancetype)initWithTypeReflectionPtr:(slang::TypeReflection*)ptr;
@end

@interface SLVariableLayoutReflection ()
- (instancetype)initWithVariableLayoutReflectionPtr:(slang::VariableLayoutReflection*)ptr;
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

@interface SLTypeLayout () {
    slang::TypeLayoutReflection* _typeLayout;
}
@end

@implementation SLTypeLayout

- (instancetype)initWithTypeLayoutPtr:(slang::TypeLayoutReflection*)typeLayoutPtr {
    self = [super init];
    if (self) {
        _typeLayout = typeLayoutPtr;
    }
    return self;
}

- (NSUInteger)size {
    if (!_typeLayout) return 0;
    return (NSUInteger)_typeLayout->getSize(SLANG_PARAMETER_CATEGORY_UNIFORM);
}

- (nullable SLTypeLayout *)elementTypeLayout {
    if (!_typeLayout) return nil;
    slang::TypeLayoutReflection* elementLayout = _typeLayout->getElementTypeLayout();
    if (!elementLayout) return nil;
    return [[SLTypeLayout alloc] initWithTypeLayoutPtr:elementLayout];
}

- (nullable SLTypeReflection *)getType {
    if (!_typeLayout) return nil;
    slang::TypeReflection* type = _typeLayout->getType();
    if (!type) return nil;
    return [[SLTypeReflection alloc] initWithTypeReflectionPtr:type];
}

- (SLTypeKind)getKind {
    if (!_typeLayout) return SLTypeKindNone;
    return (SLTypeKind)_typeLayout->getKind();
}

- (NSUInteger)getSize:(SLParameterCategory)category {
    if (!_typeLayout) return 0;
    return (NSUInteger)_typeLayout->getSize(toSlangParameterCategory(category));
}

- (NSUInteger)getStride:(SLParameterCategory)category {
    if (!_typeLayout) return 0;
    return (NSUInteger)_typeLayout->getStride(toSlangParameterCategory(category));
}

- (int32_t)getAlignment:(SLParameterCategory)category {
    if (!_typeLayout) return 0;
    return _typeLayout->getAlignment(toSlangParameterCategory(category));
}

- (unsigned int)getFieldCount {
    if (!_typeLayout) return 0;
    return _typeLayout->getFieldCount();
}

- (nullable SLVariableLayoutReflection *)getFieldByIndex:(unsigned int)index {
    if (!_typeLayout) return nil;
    slang::VariableLayoutReflection* field = _typeLayout->getFieldByIndex(index);
    if (!field) return nil;
    return [[SLVariableLayoutReflection alloc] initWithVariableLayoutReflectionPtr:field];
}

@end
