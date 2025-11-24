#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLModule;
@class SLBlob;
@class SLComponentType;
@class SLEntryPoint;

/// A wrapper for slang::ISession
/// A session provides a scope for code that is loaded and compiled.
@interface SLSession : NSObject

/// Load a module by name (as if using `import`).
/// @param moduleName The name of the module to load.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A new SLModule instance, or nil if an error occurred.
- (nullable SLModule *)loadModule:(NSString *)moduleName
                               error:(NSError *_Nullable *_Nullable)error;

/// Load a module from source code.
/// @param moduleName The name to give the module.
/// @param path The path to use for error messages.
/// @param source The source code as NSData.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A new SLModule instance, or nil if an error occurred.
- (nullable SLModule *)loadModuleFromSourceWithName:(NSString *)moduleName
                                                  path:(NSString *)path
                                                source:(NSData *)source
                                                 error:(NSError *_Nullable *_Nullable)error;

/// Create a composite component type from a module and entry points.
/// This is used to link a module with its entry points for code generation.
/// @param module The module to include.
/// @param entryPoints Array of entry points to include.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A composite component type, or nil if an error occurred.
- (nullable SLComponentType *)createCompositeComponentTypeWithModule:(SLModule *)module
                                                            entryPoints:(NSArray<SLEntryPoint *> *)entryPoints
                                                                  error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
