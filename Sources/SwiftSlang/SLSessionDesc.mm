#import "SLSessionDesc.h"

@implementation SLTargetDesc

- (instancetype)initWithFormat:(SLCompileTargetType)format profile:(int32_t)profile {
    self = [super init];
    if (self) {
        _format = format;
        _profile = profile;
    }
    return self;
}

@end

@implementation SLSessionDesc

- (instancetype)init {
    self = [super init];
    if (self) {
        _targets = @[];
        _searchPaths = @[];
        _preprocessorMacros = @{};
    }
    return self;
}

@end
