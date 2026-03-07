#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLComponentType.h"
#import "SLShaderParameter.h"
#import "SLUserAttribute.h"
#import "SLError.h"

/// Collect user-defined attributes from a variable reflection.
static NSArray<SLUserAttribute*>* collectUserAttributes(slang::VariableReflection* variable) {
    if (!variable) return @[];

    unsigned int attrCount = variable->getUserAttributeCount();
    if (attrCount == 0) return @[];

    NSMutableArray<SLUserAttribute*>* attributes = [NSMutableArray arrayWithCapacity:attrCount];

    for (unsigned int i = 0; i < attrCount; i++) {
        slang::UserAttribute* attr = variable->getUserAttributeByIndex(i);
        if (!attr) continue;

        const char* attrNameStr = attr->getName();
        if (!attrNameStr) continue;
        NSString* attrName = [NSString stringWithUTF8String:attrNameStr];

        uint32_t argCount = attr->getArgumentCount();
        NSMutableArray<NSNumber*>* floatArgs = [NSMutableArray arrayWithCapacity:argCount];
        NSMutableArray<NSNumber*>* intArgs = [NSMutableArray arrayWithCapacity:argCount];
        NSMutableArray<NSString*>* stringArgs = [NSMutableArray arrayWithCapacity:argCount];

        for (uint32_t j = 0; j < argCount; j++) {
            // Try to get float value
            float floatValue = 0.0f;
            int intValue = 0;
            if (SLANG_SUCCEEDED(attr->getArgumentValueFloat(j, &floatValue))) {
                [floatArgs addObject:@(floatValue)];
                [intArgs addObject:@(0)];
                [stringArgs addObject:@""];
            } else if (SLANG_SUCCEEDED(attr->getArgumentValueInt(j, &intValue))) {
                [floatArgs addObject:@(0.0f)];
                [intArgs addObject:@(intValue)];
                [stringArgs addObject:@""];
            } else {
                // Try to get string value
                size_t strLen = 0;
                const char* strValue = attr->getArgumentValueString(j, &strLen);
                if (strValue && strLen > 0) {
                    [floatArgs addObject:@(0.0f)];
                    [intArgs addObject:@(0)];
                    [stringArgs addObject:[NSString stringWithUTF8String:strValue]];
                } else {
                    [floatArgs addObject:@(0.0f)];
                    [intArgs addObject:@(0)];
                    [stringArgs addObject:@""];
                }
            }
        }

        SLUserAttribute* userAttr = [[SLUserAttribute alloc] initWithName:attrName
                                                            floatArguments:floatArgs
                                                              intArguments:intArgs
                                                           stringArguments:stringArgs];
        [attributes addObject:userAttr];
    }

    return [attributes copy];
}

static void collectParameterForCategory(
    slang::VariableLayoutReflection* varLayout,
    slang::ParameterCategory category,
    NSString* name,
    NSArray<SLUserAttribute*>* userAttributes,
    NSMutableArray<SLShaderParameter*>* outParameters
) {
    switch (category) {
        case slang::ParameterCategory::ShaderResource: {
            size_t offset = varLayout->getOffset(SLANG_PARAMETER_CATEGORY_SHADER_RESOURCE);
            SLShaderParameter* param = [[SLShaderParameter alloc] initWithName:name
                                                                      category:SLParameterCategoryShaderResource
                                                                  bindingIndex:(NSUInteger)offset
                                                                userAttributes:userAttributes];
            [outParameters addObject:param];
            break;
        }
        case slang::ParameterCategory::SamplerState: {
            size_t offset = varLayout->getOffset(SLANG_PARAMETER_CATEGORY_SAMPLER_STATE);
            SLShaderParameter* param = [[SLShaderParameter alloc] initWithName:name
                                                                      category:SLParameterCategorySamplerState
                                                                  bindingIndex:(NSUInteger)offset
                                                                userAttributes:userAttributes];
            [outParameters addObject:param];
            break;
        }
        case slang::ParameterCategory::ConstantBuffer: {
            size_t offset = varLayout->getOffset(SLANG_PARAMETER_CATEGORY_CONSTANT_BUFFER);
            SLShaderParameter* param = [[SLShaderParameter alloc] initWithName:name
                                                                      category:SLParameterCategoryConstantBuffer
                                                                  bindingIndex:(NSUInteger)offset
                                                                userAttributes:userAttributes];
            [outParameters addObject:param];
            break;
        }
        case slang::ParameterCategory::Uniform: {
            size_t offset = varLayout->getOffset(SLANG_PARAMETER_CATEGORY_UNIFORM);
            SLShaderParameter* param = [[SLShaderParameter alloc] initWithName:name
                                                                      category:SLParameterCategoryUniform
                                                                  bindingIndex:(NSUInteger)offset
                                                                userAttributes:userAttributes];
            [outParameters addObject:param];
            break;
        }
        case slang::ParameterCategory::Mixed: {
            unsigned int catCount = varLayout->getCategoryCount();
            for (unsigned int i = 0; i < catCount; i++) {
                slang::ParameterCategory subCat = varLayout->getCategoryByIndex(i);
                collectParameterForCategory(varLayout, subCat, name, userAttributes, outParameters);
            }
            break;
        }
        default:
            break;
    }
}

static void collectParametersFromVariableLayout(
    slang::VariableLayoutReflection* varLayout,
    NSString* name,
    NSMutableArray<SLShaderParameter*>* outParameters
) {
    if (!varLayout) return;

    // Collect user attributes from the variable
    NSArray<SLUserAttribute*>* userAttributes = collectUserAttributes(varLayout->getVariable());

    collectParameterForCategory(varLayout, varLayout->getCategory(), name, userAttributes, outParameters);
}

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

        const char* nameStr = param->getVariable()->getName();
        if (!nameStr) continue;
        NSString* name = [NSString stringWithUTF8String:nameStr];

        collectParametersFromVariableLayout(param, name, parameters);
    }

    return [parameters copy];
}

@end
