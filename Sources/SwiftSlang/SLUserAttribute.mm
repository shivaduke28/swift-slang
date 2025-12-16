#import "SLUserAttribute.h"

@implementation SLUserAttribute

- (instancetype)initWithName:(NSString *)name
               floatArguments:(NSArray<NSNumber *> *)floatArguments
              stringArguments:(NSArray<NSString *> *)stringArguments {
    self = [super init];
    if (self) {
        _name = [name copy];
        _floatArguments = [floatArguments copy];
        _stringArguments = [stringArguments copy];
        _argumentCount = MAX(floatArguments.count, stringArguments.count);
    }
    return self;
}

@end
