#include <vector>
#include <string>
#include <atomic>
#include "../Slang/include/slang.h"

#import "SLSession.h"
#import "SLModule.h"
#import "SLEntryPoint.h"
#import "SLComponentType.h"

extern NSString *const SlangErrorDomain;

@interface SLSession ()
@property (nonatomic, assign) slang::ISession *session;
@end

// Forward declare internal interfaces
@interface SLModule ()
- (instancetype)initWithModule:(slang::IModule *)module;
- (slang::IComponentType *)asComponentType;
@end

@interface SLEntryPoint ()
- (slang::IComponentType *)asComponentType;
@end

@interface SLComponentType ()
- (instancetype)initWithComponentType:(slang::IComponentType *)componentType;
@end

@implementation SLSession

- (instancetype)initWithSession:(slang::ISession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)dealloc {
    if (_session) {
        _session->release();
        _session = nullptr;
    }
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

    slang::IBlob *diagnosticsBlob = nullptr;
    slang::IModule *module = _session->loadModule([moduleName UTF8String], &diagnosticsBlob);

    if (module == nullptr) {
        NSString *diagnostics = @"Unknown error";
        if (diagnosticsBlob) {
            diagnostics = [NSString stringWithUTF8String:(const char *)diagnosticsBlob->getBufferPointer()];
            diagnosticsBlob->release();
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    if (diagnosticsBlob) {
        diagnosticsBlob->release();
    }

    return [[SLModule alloc] initWithModule:module];
}

- (nullable SLModule *)loadModuleFromSourceWithName:(NSString *)moduleName
                                                  path:(NSString *)path
                                                source:(NSData *)source
                                                 error:(NSError *_Nullable *_Nullable)error {
    if (!_session) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Session is not initialized"}];
        }
        return nil;
    }

    // Create a blob from the source data
    slang::IBlob *sourceBlob = nullptr;
    // We need to create a blob - for now we'll use a simple approach
    // by using the session's loadModuleFromSource method directly

    slang::IBlob *diagnosticsBlob = nullptr;

    // Create a string blob wrapper
    class DataBlob : public slang::IBlob {
    public:
        DataBlob(const void* data, size_t size) : m_data(data), m_size(size), m_refCount(1) {}

        SLANG_NO_THROW const void* SLANG_MCALL getBufferPointer() override { return m_data; }
        SLANG_NO_THROW size_t SLANG_MCALL getBufferSize() override { return m_size; }

        SLANG_NO_THROW SlangResult SLANG_MCALL queryInterface(SlangUUID const& uuid, void** outObject) override {
            SlangUUID blobGuid = slang::IBlob::getTypeGuid();
            SlangUUID unknownGuid = ISlangUnknown::getTypeGuid();
            if (memcmp(&uuid, &blobGuid, sizeof(SlangUUID)) == 0 ||
                memcmp(&uuid, &unknownGuid, sizeof(SlangUUID)) == 0) {
                *outObject = this;
                addRef();
                return SLANG_OK;
            }
            return SLANG_E_NO_INTERFACE;
        }
        SLANG_NO_THROW uint32_t SLANG_MCALL addRef() override { return ++m_refCount; }
        SLANG_NO_THROW uint32_t SLANG_MCALL release() override {
            uint32_t count = --m_refCount;
            if (count == 0) delete this;
            return count;
        }

    private:
        const void* m_data;
        size_t m_size;
        std::atomic<uint32_t> m_refCount;
    };

    DataBlob *blob = new DataBlob(source.bytes, source.length);

    slang::IModule *module = _session->loadModuleFromSource(
        [moduleName UTF8String],
        [path UTF8String],
        blob,
        &diagnosticsBlob
    );

    blob->release();

    if (module == nullptr) {
        NSString *diagnostics = @"Unknown error";
        if (diagnosticsBlob) {
            diagnostics = [NSString stringWithUTF8String:(const char *)diagnosticsBlob->getBufferPointer()];
            diagnosticsBlob->release();
        }
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: diagnostics}];
        }
        return nil;
    }

    if (diagnosticsBlob) {
        diagnosticsBlob->release();
    }

    return [[SLModule alloc] initWithModule:module];
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

    slang::IComponentType *composite = nullptr;
    slang::IBlob *diagnosticsBlob = nullptr;
    SlangResult result = _session->createCompositeComponentType(
        componentTypes.data(),
        static_cast<SlangInt>(componentTypes.size()),
        &composite,
        &diagnosticsBlob
    );

    if (SLANG_FAILED(result) || composite == nullptr) {
        NSString *diagnostics = @"Failed to create composite component type";
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

    return [[SLComponentType alloc] initWithComponentType:composite];
}

@end
