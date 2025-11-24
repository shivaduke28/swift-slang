#include <utility>
#import "SLComponentType.h"
#import "SLError.h"
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

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

@end
