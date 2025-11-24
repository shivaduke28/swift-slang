#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLModule.h"
#import "SLEntryPoint.h"
#import "SLComponentType.h"
#import "SLError.h"

@interface SLModule () {
    Slang::ComPtr<slang::IModule> _module;
}
@end

@interface SLEntryPoint ()
- (instancetype)initWithEntryPointPtr:(Slang::ComPtr<slang::IEntryPoint>)entryPointPtr;
@end

@implementation SLModule

- (instancetype)initWithModulePtr:(Slang::ComPtr<slang::IModule>)modulePtr {
    self = [super init];
    if (self) {
        _module = std::move(modulePtr);
    }
    return self;
}

- (NSString *)name {
    if (!_module) {
        return @"";
    }
    const char *name = _module->getName();
    return name ? [NSString stringWithUTF8String:name] : @"";
}

- (nullable NSString *)filePath {
    if (!_module) {
        return nil;
    }
    const char *path = _module->getFilePath();
    return path ? [NSString stringWithUTF8String:path] : nil;
}

- (NSInteger)entryPointCount {
    if (!_module) {
        return 0;
    }
    return _module->getDefinedEntryPointCount();
}

- (nullable SLEntryPoint *)findEntryPointByName:(NSString *)name
                                             error:(NSError *_Nullable *_Nullable)error {
    if (!_module) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Module is not initialized"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IEntryPoint> entryPoint;
    _module->findEntryPointByName([name UTF8String], entryPoint.writeRef());

    if (!entryPoint) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Entry point '%@' not found", name]}];
        }
        return nil;
    }

    return [[SLEntryPoint alloc] initWithEntryPointPtr:std::move(entryPoint)];
}

- (nullable SLEntryPoint *)entryPointAtIndex:(NSInteger)index
                                          error:(NSError *_Nullable *_Nullable)error {
    if (!_module) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Module is not initialized"}];
        }
        return nil;
    }

    if (index < 0 || index >= [self entryPointCount]) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Entry point index out of bounds"}];
        }
        return nil;
    }

    Slang::ComPtr<slang::IEntryPoint> entryPoint;
    SlangResult result = _module->getDefinedEntryPoint(static_cast<SlangInt32>(index), entryPoint.writeRef());

    if (SLANG_FAILED(result) || !entryPoint) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to get entry point"}];
        }
        return nil;
    }

    return [[SLEntryPoint alloc] initWithEntryPointPtr:std::move(entryPoint)];
}

@end

// Make SLModule conform to component type functionality
@implementation SLModule (ComponentType)

- (slang::IComponentType *)asComponentType {
    return static_cast<slang::IComponentType *>(_module.get());
}

@end
