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
/// Returns 0 for non-float arguments.
@property (nonatomic, readonly) NSArray<NSNumber *> *floatArguments;

/// Int argument values (indexed by argument position).
/// Bool values (true/false) are represented as 1/0.
/// Returns 0 for non-int arguments.
@property (nonatomic, readonly) NSArray<NSNumber *> *intArguments;

/// String argument values (indexed by argument position).
/// Returns empty string for non-string arguments.
@property (nonatomic, readonly) NSArray<NSString *> *stringArguments;

- (instancetype)initWithName:(NSString *)name
              floatArguments:(NSArray<NSNumber *> *)floatArguments
                intArguments:(NSArray<NSNumber *> *)intArguments
             stringArguments:(NSArray<NSString *> *)stringArguments;

@end

NS_ASSUME_NONNULL_END
