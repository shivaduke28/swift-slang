#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol for types that can be converted to a Slang component type.
/// This mirrors slang::IComponentType in the C++ API.
/// Both SLModule and SLEntryPoint conform to this protocol.
@protocol SLComponentTypeConvertible <NSObject>
@end

NS_ASSUME_NONNULL_END
