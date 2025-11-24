#include <vector>
#include <string>
#include <atomic>
#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLSession.h"
#import "SLModule.h"
#import "SLEntryPoint.h"
#import "SLComponentType.h"
#import "SLError.h"

@interface SLSession () {
    Slang::ComPtr<slang::ISession> _session;
}
@end

// Forward declare internal interfaces
@interface SLModule ()
- (instancetype)initWithModulePtr:(Slang::ComPtr<slang::IModule>)modulePtr;
- (slang::IComponentType *)asComponentType;
@end

@interface SLEntryPoint ()
- (slang::IComponentType *)asComponentType;
@end

@interface SLComponentType ()
- (instancetype)initWithComponentTypePtr:(Slang::ComPtr<slang::IComponentType>)componentTypePtr;
@end

@implementation SLSession

- (instancetype)initWithSessionPtr:(Slang::ComPtr<slang::ISession>)sessionPtr {
    self = [super init];
    if (self) {
        _session = std::move(sessionPtr);
    }
    return self;
}

- (nullable SLModule *)loadModule:(NSString *)moduleName
                               error:(NSError *_Nullable *_Nullable)error {
    if (!_session) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Session is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    Slang::ComPtr<slang::IModule> module;
    module = _session->loadModule([moduleName UTF8String], diagnosticsBlob.writeRef());

    if (!module) {
        NSString *diagnostics = @"Unknown error";
        if (diagnosticsBlob) {
            diagnostics = [NSString stringWithUTF8String:(const char *)diagnosticsBlob->getBufferPointer()];
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    return [[SLModule alloc] initWithModulePtr:std::move(module)];
}

- (nullable SLModule *)loadModuleFromSourceString:(NSString *)moduleName
                                             path:(NSString *)path
                                           source:(NSString *)source
                                            error:(NSError *_Nullable *_Nullable)error {
    if (!_session) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Session is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    Slang::ComPtr<slang::IModule> module;
    module = _session->loadModuleFromSourceString(
        [moduleName UTF8String],
        [path UTF8String],
        [source UTF8String],
        diagnosticsBlob.writeRef()
    );

    if (!module) {
        NSString *diagnostics = @"Unknown error";
        if (diagnosticsBlob) {
            diagnostics = [NSString stringWithUTF8String:(const char *)diagnosticsBlob->getBufferPointer()];
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    return [[SLModule alloc] initWithModulePtr:std::move(module)];
}

- (nullable SLComponentType *)createCompositeComponentTypeWithModule:(SLModule *)module
                                                            entryPoints:(NSArray<SLEntryPoint *> *)entryPoints
                                                                  error:(NSError *_Nullable *_Nullable)error {
    if (!_session) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Session is not initialized"}];
        }
        return nil;
    }

    // Build component types array: module + all entry points
    std::vector<slang::IComponentType *> componentTypes;
    componentTypes.push_back([module asComponentType]);

    for (SLEntryPoint *entryPoint in entryPoints) {
        componentTypes.push_back([entryPoint asComponentType]);
    }

    Slang::ComPtr<slang::IComponentType> composite;
    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    SlangResult result = _session->createCompositeComponentType(
        componentTypes.data(),
        static_cast<SlangInt>(componentTypes.size()),
        composite.writeRef(),
        diagnosticsBlob.writeRef()
    );

    if (SLANG_FAILED(result) || !composite) {
        NSString *diagnostics = @"Failed to create composite component type";
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

    return [[SLComponentType alloc] initWithComponentTypePtr:std::move(composite)];
}

- (nullable SLComponentType *)createCompositeComponentType:(NSArray<id<SLComponentTypeConvertible>> *)components
                                                     error:(NSError *_Nullable *_Nullable)error {
    if (!_session) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Session is not initialized"}];
        }
        return nil;
    }

    // Build component types array
    std::vector<slang::IComponentType *> componentTypes;

    for (id<SLComponentTypeConvertible> component in components) {
        if ([component isKindOfClass:[SLModule class]]) {
            componentTypes.push_back([(SLModule *)component asComponentType]);
        } else if ([component isKindOfClass:[SLEntryPoint class]]) {
            componentTypes.push_back([(SLEntryPoint *)component asComponentType]);
        }
    }

    Slang::ComPtr<slang::IComponentType> composite;
    Slang::ComPtr<slang::IBlob> diagnosticsBlob;
    SlangResult result = _session->createCompositeComponentType(
        componentTypes.data(),
        static_cast<SlangInt>(componentTypes.size()),
        composite.writeRef(),
        diagnosticsBlob.writeRef()
    );

    if (SLANG_FAILED(result) || !composite) {
        NSString *diagnostics = @"Failed to create composite component type";
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

    return [[SLComponentType alloc] initWithComponentTypePtr:std::move(composite)];
}

@end
