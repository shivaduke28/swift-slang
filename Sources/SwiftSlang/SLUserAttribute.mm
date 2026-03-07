#import "SLUserAttribute.h"

@implementation SLUserAttribute

- (instancetype)initWithName:(NSString *)name
              floatArguments:(NSArray<NSNumber *> *)floatArguments
                intArguments:(NSArray<NSNumber *> *)intArguments
             stringArguments:(NSArray<NSString *> *)stringArguments {
    self = [super init];
    if (self) {
        _name = [name copy];
        _floatArguments = [floatArguments copy];
        _intArguments = [intArguments copy];
        _stringArguments = [stringArguments copy];
        _argumentCount = MAX(MAX(floatArguments.count, intArguments.count), stringArguments.count);
    }
    return self;
}

@end
