#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLSession;
@class SLSessionDesc;

/// A wrapper for slang::IGlobalSession
/// The global session is the top-level object that manages the Slang compiler.
@interface SLGlobalSession : NSObject

/// Create a new global session with default settings.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A new SLGlobalSession instance, or nil if an error occurred.
+ (nullable instancetype)createWithError:(NSError *_Nullable *_Nullable)error;

/// Create a new session for loading and compiling code.
/// @param desc The session description.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A new SLSession instance, or nil if an error occurred.
- (nullable SLSession *)createSessionWithDesc:(SLSessionDesc *)desc
                                           error:(NSError *_Nullable *_Nullable)error;

/// Look up the internal ID of a profile by its name.
/// @param name The name of the profile (e.g., "glsl_450", "sm_6_0").
/// @return The profile ID, or -1 if not found.
- (int32_t)findProfile:(NSString *)name;

/// Get the build version tag string.
/// @return The build tag string (e.g., "v2025.22").
- (NSString *)buildTagString;

@end

NS_ASSUME_NONNULL_END
