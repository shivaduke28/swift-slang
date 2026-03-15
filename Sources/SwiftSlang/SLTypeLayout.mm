#include "../Slang/include/slang.h"

#import "SLTypeLayout.h"

@interface SLTypeLayout () {
    slang::TypeLayoutReflection* _typeLayout;
}
@end

@implementation SLTypeLayout

- (instancetype)initWithTypeLayoutPtr:(slang::TypeLayoutReflection*)typeLayoutPtr {
    self = [super init];
    if (self) {
        _typeLayout = typeLayoutPtr;
    }
    return self;
}

- (NSUInteger)size {
    if (!_typeLayout) return 0;
    return (NSUInteger)_typeLayout->getSize(SLANG_PARAMETER_CATEGORY_UNIFORM);
}

- (nullable SLTypeLayout *)elementTypeLayout {
    if (!_typeLayout) return nil;
    slang::TypeLayoutReflection* elementLayout = _typeLayout->getElementTypeLayout();
    if (!elementLayout) return nil;
    return [[SLTypeLayout alloc] initWithTypeLayoutPtr:elementLayout];
}

@end
