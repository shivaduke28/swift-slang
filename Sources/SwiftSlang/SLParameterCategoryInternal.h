#pragma once

#include "../Slang/include/slang.h"
#import "SLShaderParameter.h"

/// Maps SLParameterCategory to SlangParameterCategory.
static inline SlangParameterCategory toSlangParameterCategory(SLParameterCategory category) {
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
static inline SLParameterCategory fromSlangParameterCategory(slang::ParameterCategory category) {
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
