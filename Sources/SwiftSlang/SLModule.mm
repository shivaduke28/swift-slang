#include "../Slang/include/slang.h"

#import "SLModule.h"
#import "SLEntryPoint.h"
#import "SLComponentType.h"

extern NSString *const SlangErrorDomain;

@interface SLModule ()
@property (nonatomic, assign) slang::IModule *module;
@end

@interface SLEntryPoint ()
- (instancetype)initWithEntryPoint:(slang::IEntryPoint *)entryPoint;
@end

@implementation SLModule

- (instancetype)initWithModule:(slang::IModule *)module {
    self = [super init];
    if (self) {
        _module = module;
    }
    return self;
}

- (void)dealloc {
    if (_module) {
        _module->release();
        _module = nullptr;
    }
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

    slang::IEntryPoint *entryPoint = nullptr;
    SlangResult result = _module->findEntryPointByName([name UTF8String], &entryPoint);

    if (SLANG_FAILED(result) || entryPoint == nullptr) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Entry point '%@' not found", name]}];
        }
        return nil;
    }

    return [[SLEntryPoint alloc] initWithEntryPoint:entryPoint];
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

    slang::IEntryPoint *entryPoint = nullptr;
    SlangResult result = _module->getDefinedEntryPoint(static_cast<SlangInt32>(index), &entryPoint);

    if (SLANG_FAILED(result) || entryPoint == nullptr) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to get entry point"}];
        }
        return nil;
    }

    return [[SLEntryPoint alloc] initWithEntryPoint:entryPoint];
}

@end

// Make SLModule conform to component type functionality
@implementation SLModule (ComponentType)

- (slang::IComponentType *)asComponentType {
    return static_cast<slang::IComponentType *>(_module);
}

@end
