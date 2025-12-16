#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a user-defined attribute on a shader variable.
/// For example: [range(0.0, 1.0, "Intensity")]
@interface SLUserAttribute : NSObject

/// The name of the attribute (e.g., "range").
@property (nonatomic, readonly) NSString *name;

/// The number of arguments passed to the attribute.
@property (nonatomic, readonly) NSUInteger argumentCount;

/// Float argument values (indexed by argument position).
/// Returns nil for non-float arguments.
@property (nonatomic, readonly) NSArray<NSNumber *> *floatArguments;

/// String argument values (indexed by argument position).
/// Returns nil for non-string arguments.
@property (nonatomic, readonly) NSArray<NSString *> *stringArguments;

- (instancetype)initWithName:(NSString *)name
               floatArguments:(NSArray<NSNumber *> *)floatArguments
              stringArguments:(NSArray<NSString *> *)stringArguments;

@end

NS_ASSUME_NONNULL_END
