#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A wrapper for slang::TypeLayoutReflection
/// Provides type layout information such as size and element type layout.
@interface SLTypeLayout : NSObject

/// The byte size of this type (using Uniform parameter category).
@property (nonatomic, readonly) NSUInteger size;

/// The element type layout for buffer/array types (e.g., the T in RWStructuredBuffer<T>).
/// Returns nil if not applicable.
@property (nonatomic, readonly, nullable) SLTypeLayout *elementTypeLayout;

@end

NS_ASSUME_NONNULL_END
