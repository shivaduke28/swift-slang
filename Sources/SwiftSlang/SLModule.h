#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLEntryPoint;
@class SLBlob;

/// A wrapper for slang::IModule
/// Represents a compiled Slang module.
@interface SLModule : NSObject

/// Get the name of this module.
@property (nonatomic, readonly) NSString *name;

/// Get the file path of this module.
@property (nonatomic, readonly, nullable) NSString *filePath;

/// Find an entry point by name.
/// @param name The name of the entry point.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A SLEntryPoint instance, or nil if not found.
- (nullable SLEntryPoint *)findEntryPointByName:(NSString *)name
                                             error:(NSError *_Nullable *_Nullable)error;

/// Get the number of entry points in this module.
@property (nonatomic, readonly) NSInteger entryPointCount;

/// Get an entry point by index.
/// @param index The index of the entry point.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A SLEntryPoint instance, or nil if an error occurred.
- (nullable SLEntryPoint *)entryPointAtIndex:(NSInteger)index
                                          error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
