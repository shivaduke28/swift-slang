#include <vector>
#include <string>
#include "../Slang/include/slang.h"

#import "SLGlobalSession.h"
#import "SLSession.h"
#import "SLSessionDesc.h"

// Error domain for Slang errors
NSString *const SlangErrorDomain = @"com.slang.error";

@interface SLGlobalSession ()
@property (nonatomic, assign) slang::IGlobalSession *globalSession;
@end

// Forward declare internal interface
@interface SLSession ()
- (instancetype)initWithSession:(slang::ISession *)session;
@end

@implementation SLGlobalSession

- (void)dealloc {
    if (_globalSession) {
        _globalSession->release();
        _globalSession = nullptr;
    }
}

+ (nullable instancetype)createWithError:(NSError *_Nullable *_Nullable)error {
    SLGlobalSession *instance = [[SLGlobalSession alloc] init];

    slang::IGlobalSession *globalSession = nullptr;
    SlangResult result = slang::createGlobalSession(&globalSession);

    if (SLANG_FAILED(result) || globalSession == nullptr) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to create global session"}];
        }
        return nil;
    }

    instance.globalSession = globalSession;
    return instance;
}

- (nullable SLSession *)createSessionWithDesc:(SLSessionDesc *)desc
                                           error:(NSError *_Nullable *_Nullable)error {
    if (!_globalSession) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Global session is not initialized"}];
        }
        return nil;
    }

    // Build target descriptors
    std::vector<slang::TargetDesc> targets;
    for (SLTargetDesc *targetDesc in desc.targets) {
        slang::TargetDesc target = {};
        target.structureSize = sizeof(slang::TargetDesc);
        target.format = static_cast<SlangCompileTarget>(targetDesc.format);
        target.profile = static_cast<SlangProfileID>(targetDesc.profile);
        targets.push_back(target);
    }

    // Build search paths
    std::vector<const char *> searchPaths;
    std::vector<std::string> searchPathStrings; // Keep strings alive
    for (NSString *path in desc.searchPaths) {
        searchPathStrings.push_back([path UTF8String]);
        searchPaths.push_back(searchPathStrings.back().c_str());
    }

    // Build preprocessor macros
    std::vector<slang::PreprocessorMacroDesc> macros;
    std::vector<std::string> macroNames;
    std::vector<std::string> macroValues;
    for (NSString *name in desc.preprocessorMacros) {
        NSString *value = desc.preprocessorMacros[name];
        macroNames.push_back([name UTF8String]);
        macroValues.push_back([value UTF8String]);
        slang::PreprocessorMacroDesc macro = {};
        macro.name = macroNames.back().c_str();
        macro.value = macroValues.back().c_str();
        macros.push_back(macro);
    }

    // Create session description
    slang::SessionDesc sessionDesc = {};
    sessionDesc.structureSize = sizeof(slang::SessionDesc);
    sessionDesc.targets = targets.data();
    sessionDesc.targetCount = static_cast<SlangInt>(targets.size());
    sessionDesc.searchPaths = searchPaths.data();
    sessionDesc.searchPathCount = static_cast<SlangInt>(searchPaths.size());
    sessionDesc.preprocessorMacros = macros.data();
    sessionDesc.preprocessorMacroCount = static_cast<SlangInt>(macros.size());

    slang::ISession *session = nullptr;
    SlangResult result = _globalSession->createSession(sessionDesc, &session);

    if (SLANG_FAILED(result) || session == nullptr) {
        if (error) {
            *error = [NSError errorWithDomain:SlangErrorDomain
                                         code:result
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to create session"}];
        }
        return nil;
    }

    return [[SLSession alloc] initWithSession:session];
}

- (int32_t)findProfile:(NSString *)name {
    if (!_globalSession) {
        return -1;
    }
    return _globalSession->findProfile([name UTF8String]);
}

- (NSString *)buildTagString {
    if (!_globalSession) {
        return @"";
    }
    const char *tag = _globalSession->getBuildTagString();
    return tag ? [NSString stringWithUTF8String:tag] : @"";
}

@end
