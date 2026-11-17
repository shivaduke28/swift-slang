#import <Foundation/Foundation.h>

/// Parameter category for shader resources.
/// Raw values are identical to SlangParameterCategory in slang.h.
typedef NS_ENUM(NSInteger, SLParameterCategory) {
    SLParameterCategoryNone = 0,
    /// The parameter occupies more than one category.
    /// Use getCategoryCount / getCategoryByIndex: to enumerate them.
    SLParameterCategoryMixed = 1,
    SLParameterCategoryConstantBuffer = 2,
    SLParameterCategoryShaderResource = 3,
    SLParameterCategoryUnorderedAccess = 4,
    SLParameterCategoryVaryingInput = 5,
    SLParameterCategoryVaryingOutput = 6,
    SLParameterCategorySamplerState = 7,
    SLParameterCategoryUniform = 8,
    SLParameterCategoryDescriptorTableSlot = 9,
    SLParameterCategorySpecializationConstant = 10,
    SLParameterCategoryPushConstantBuffer = 11,
    SLParameterCategoryRegisterSpace = 12,
    SLParameterCategoryGenericResource = 13,
    SLParameterCategoryRayPayload = 14,
    SLParameterCategoryHitAttributes = 15,
    SLParameterCategoryCallablePayload = 16,
    SLParameterCategoryShaderRecord = 17,
    SLParameterCategoryExistentialTypeParam = 18,
    SLParameterCategoryExistentialObjectParam = 19,
    SLParameterCategorySubElementRegisterSpace = 20,
    SLParameterCategoryInputAttachmentIndex = 21,
    SLParameterCategoryMetalArgumentBufferElement = 22,
    SLParameterCategoryMetalAttribute = 23,
    SLParameterCategoryMetalPayload = 24,

    // Aliases for Metal-specific categories.
    SLParameterCategoryMetalBuffer = SLParameterCategoryConstantBuffer,
    SLParameterCategoryMetalTexture = SLParameterCategoryShaderResource,
    SLParameterCategoryMetalSampler = SLParameterCategorySamplerState,
};
