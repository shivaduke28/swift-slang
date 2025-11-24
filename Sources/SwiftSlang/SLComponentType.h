#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLSession;
@class SLBlob;

/// A wrapper for slang::IComponentType
/// Represents a component that can be linked and compiled.
@interface SLComponentType : NSObject

/// Link this component type to produce a linked program.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return A linked SLComponentType, or nil if an error occurred.
- (nullable SLComponentType *)linkWithError:(NSError *_Nullable *_Nullable)error;

/// Get the compiled code for a specific target.
/// @param targetIndex The index of the target.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return The compiled code as NSData, or nil if an error occurred.
- (nullable NSData *)getTargetCode:(NSInteger)targetIndex
                             error:(NSError *_Nullable *_Nullable)error;

/// Get the compiled code for a specific entry point on a specific target.
/// @param entryPointIndex The index of the entry point.
/// @param targetIndex The index of the target.
/// @param error If an error occurs, upon return contains an NSError object that describes the problem.
/// @return The compiled code as NSData, or nil if an error occurred.
- (nullable NSData *)getEntryPointCode:(NSInteger)entryPointIndex
                           targetIndex:(NSInteger)targetIndex
                                 error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
