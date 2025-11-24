#import "SLComponentType.h"
#include "../Slang/include/slang.h"

extern NSString *const SlangErrorDomain;

@interface SLComponentType ()
@property (nonatomic, assign) slang::IComponentType *componentType;
@end

@implementation SLComponentType

- (instancetype)initWithComponentType:(slang::IComponentType *)componentType {
    self = [super init];
    if (self) {
        _componentType = componentType;
    }
    return self;
}

- (void)dealloc {
    if (_componentType) {
        _componentType->release();
        _componentType = nullptr;
    }
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

    slang::IComponentType *linkedProgram = nullptr;
    slang::IBlob *diagnosticsBlob = nullptr;
    SlangResult result = _componentType->link(&linkedProgram, &diagnosticsBlob);

    if (SLANG_FAILED(result) || linkedProgram == nullptr) {
        NSString *diagnostics = @"Failed to link program";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
            diagnosticsBlob->release();
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    if (diagnosticsBlob) {
        diagnosticsBlob->release();
    }

    SLComponentType *linked = [[SLComponentType alloc] init];
    linked.componentType = linkedProgram;
    return linked;
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

    slang::IBlob *codeBlob = nullptr;
    slang::IBlob *diagnosticsBlob = nullptr;
    SlangResult result = _componentType->getTargetCode(static_cast<SlangInt>(targetIndex), &codeBlob, &diagnosticsBlob);

    if (SLANG_FAILED(result) || codeBlob == nullptr) {
        NSString *diagnostics = @"Failed to get target code";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
            diagnosticsBlob->release();
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    if (diagnosticsBlob) {
        diagnosticsBlob->release();
    }

    NSData *data = [NSData dataWithBytes:codeBlob->getBufferPointer()
                                  length:codeBlob->getBufferSize()];
    codeBlob->release();
    return data;
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

    slang::IBlob *codeBlob = nullptr;
    slang::IBlob *diagnosticsBlob = nullptr;
    SlangResult result = _componentType->getEntryPointCode(
        static_cast<SlangInt>(entryPointIndex),
        static_cast<SlangInt>(targetIndex),
        &codeBlob,
        &diagnosticsBlob
    );

    if (SLANG_FAILED(result) || codeBlob == nullptr) {
        NSString *diagnostics = @"Failed to get entry point code";
        if (diagnosticsBlob) {
            const char *diagStr = (const char *)diagnosticsBlob->getBufferPointer();
            if (diagStr) {
                diagnostics = [NSString stringWithUTF8String:diagStr];
            }
            diagnosticsBlob->release();
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    if (diagnosticsBlob) {
        diagnosticsBlob->release();
    }

    NSData *data = [NSData dataWithBytes:codeBlob->getBufferPointer()
                                  length:codeBlob->getBufferSize()];
    codeBlob->release();
    return data;
}

@end
