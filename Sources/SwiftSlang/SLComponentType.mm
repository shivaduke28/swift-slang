#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLComponentType.h"
#import "SLShaderParameter.h"
#import "SLError.h"

@interface SLComponentType () {
    Slang::ComPtr<slang::IComponentType> _componentType;
}
@end

@implementation SLComponentType

- (instancetype)initWithComponentTypePtr:(Slang::ComPtr<slang::IComponentType>)componentTypePtr {
    self = [super init];
    if (self) {
        _componentType = std::move(componentTypePtr);
    }
    return self;
}

- (nullable SLComponentType *)linkWithError:(NSError *_Nullable *_Nullable)error {
    if (!_componentType) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Component type is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IComponentType> linkedProgram;
    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    SlangResult result = _componentType->link(linkedProgram.writeRef(), diagnosticsBlob.writeRef());

    if (SLANG_FAILED(result) || !linkedProgram) {
        NSString *diagnostics = @"Failed to link program";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    return [[SLComponentType alloc] initWithComponentTypePtr:std::move(linkedProgram)];
}

- (nullable NSData *)getTargetCode:(NSInteger)targetIndex
                             error:(NSError *_Nullable *_Nullable)error {
    if (!_componentType) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Component type is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IBlob> codeBlob;
    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    SlangResult result = _componentType->getTargetCode(static_cast<SlangInt>(targetIndex), codeBlob.writeRef(), diagnosticsBlob.writeRef());

    if (SLANG_FAILED(result) || !codeBlob) {
        NSString *diagnostics = @"Failed to get target code";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    return [NSData dataWithBytes:codeBlob->getBufferPointer()
                          length:codeBlob->getBufferSize()];
}

- (nullable NSData *)getEntryPointCode:(NSInteger)entryPointIndex
                           targetIndex:(NSInteger)targetIndex
                                 error:(NSError *_Nullable *_Nullable)error {
    if (!_componentType) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Component type is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IBlob> codeBlob;
    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    SlangResult result = _componentType->getEntryPointCode(
        static_cast<SlangInt>(entryPointIndex),
        static_cast<SlangInt>(targetIndex),
        codeBlob.writeRef(),
        diagnosticsBlob.writeRef()
    );

    if (SLANG_FAILED(result) || !codeBlob) {
        NSString *diagnostics = @"Failed to get entry point code";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    return [NSData dataWithBytes:codeBlob->getBufferPointer()
                          length:codeBlob->getBufferSize()];
}

- (nullable NSArray<SLShaderParameter *> *)getShaderParameters:(NSInteger)targetIndex
                                                          error:(NSError *_Nullable *_Nullable)error {
    if (!_componentType) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Component type is not initialized"}];
        }
        return nil;
    }

    // Get program layout (reflection data)
    slang::ProgramLayout* layout = _componentType->getLayout(static_cast<SlangInt>(targetIndex), nullptr);
    if (!layout) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to get program layout"}];
        }
        return nil;
    }

    NSMutableArray<SLShaderParameter *> *parameters = [NSMutableArray array];
    unsigned paramCount = layout->getParameterCount();

    for (unsigned i = 0; i < paramCount; i++) {
        slang::VariableLayoutReflection* param = layout->getParameterByIndex(i);
        if (!param) continue;

        // Get parameter name
        const char* nameStr = param->getVariable()->getName();
        if (!nameStr) continue;
        NSString* name = [NSString stringWithUTF8String:nameStr];

        // Get parameter category
        slang::ParameterCategory slangCategory = param->getCategory();
        SLParameterCategory category = SLParameterCategoryNone;
        NSUInteger bindingIndex = 0;

        // Convert Slang category to SLParameterCategory
        switch (slangCategory) {
            case slang::ParameterCategory::ShaderResource:
                category = SLParameterCategoryShaderResource;
                bindingIndex = param->getOffset(SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE);
                break;
            case slang::ParameterCategory::SamplerState:
                category = SLParameterCategorySamplerState;
                bindingIndex = param->getOffset(SLANG_PARAMETER_CATEGORY_SAMPLER_STATE);
                break;
            case slang::ParameterCategory::ConstantBuffer:
                category = SLParameterCategoryConstantBuffer;
                bindingIndex = param->getOffset(SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER);
                break;
            case slang::ParameterCategory::Uniform:
                category = SLParameterCategoryUniform;
                bindingIndex = param->getOffset(SLANG_PARAMETER_CATEGORY_UNIFORM);
                break;
            case slang::ParameterCategory::Mixed:
                // Mixed category - iterate sub-categories and get offsets
                {
                    unsigned int catCount = param->getCategoryCount();
                    for (unsigned int j = 0; j < catCount; j++) {
                        slang::ParameterCategory subCat = param->getCategoryByIndex(j);

                        if (subCat == slang::ParameterCategory::ShaderResource) {
                            size_t texOffset = param->getOffset(SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE);
                            SLShaderParameter* texParam = [[SLShaderParameter alloc] initWithName:name
                                                                                         category:SLParameterCategoryShaderResource
                                                                                     bindingIndex:(NSUInteger)texOffset];
                            [parameters addObject:texParam];
                        } else if (subCat == slang::ParameterCategory::SamplerState) {
                            size_t samplerOffset = param->getOffset(SLANG_PARAMETER_CATEGORY_SAMPLER_STATE);
                            SLShaderParameter* samplerParam = [[SLShaderParameter alloc] initWithName:name
                                                                                             category:SLParameterCategorySamplerState
                                                                                         bindingIndex:(NSUInteger)samplerOffset];
                            [parameters addObject:samplerParam];
                        } else if (subCat == slang::ParameterCategory::ConstantBuffer) {
                            size_t bufOffset = param->getOffset(SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER);
                            SLShaderParameter* bufParam = [[SLShaderParameter alloc] initWithName:name
                                                                                         category:SLParameterCategoryConstantBuffer
                                                                                     bindingIndex:(NSUInteger)bufOffset];
                            [parameters addObject:bufParam];
                        }
                    }
                }
                continue;
            default:
                // Skip other categories
                continue;
        }

        SLShaderParameter* shaderParam = [[SLShaderParameter alloc] initWithName:name
                                                                        category:category
                                                                    bindingIndex:bindingIndex];
        [parameters addObject:shaderParam];
    }

    return [parameters copy];
}

@end
