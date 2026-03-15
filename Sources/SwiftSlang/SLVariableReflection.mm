#include "../Slang/include/slang.h"

#import "SLVariableReflection.h"
#import "SLTypeReflection.h"
#import "SLUserAttributeInternal.h"

@interface SLTypeReflection ()
- (instancetype)initWithTypeReflectionPtr:(slang::TypeReflection*)ptr;
@end

@interface SLVariableReflection () {
    slang::VariableReflection* _variableReflection;
}
@end

@implementation SLVariableReflection

- (instancetype)initWithVariableReflectionPtr:(slang::VariableReflection*)ptr {
    self = [super init];
    if (self) {
        _variableReflection = ptr;
    }
    return self;
}

- (nullable NSString *)getName {
    if (!_variableReflection) return nil;
    const char* name = _variableReflection->getName();
    if (!name) return nil;
    return [NSString stringWithUTF8String:name];
}

- (nullable SLTypeReflection *)getType {
    if (!_variableReflection) return nil;
    slang::TypeReflection* type = _variableReflection->getType();
    if (!type) return nil;
    return [[SLTypeReflection alloc] initWithTypeReflectionPtr:type];
}

- (unsigned int)getUserAttributeCount {
    if (!_variableReflection) return 0;
    return _variableReflection->getUserAttributeCount();
}

- (nullable SLUserAttribute *)getUserAttributeByIndex:(unsigned int)index {
    if (!_variableReflection) return nil;
    slang::UserAttribute* attr = _variableReflection->getUserAttributeByIndex(index);
    return createUserAttribute(attr);
}

- (BOOL)hasDefaultValue {
    if (!_variableReflection) return NO;
    return _variableReflection->hasDefaultValue() ? YES : NO;
}

- (nullable NSNumber *)getDefaultValueInt {
    if (!_variableReflection) return nil;
    int64_t value = 0;
    SlangResult result = _variableReflection->getDefaultValueInt(&value);
    if (SLANG_FAILED(result)) return nil;
    return @(value);
}

- (nullable NSNumber *)getDefaultValueFloat {
    if (!_variableReflection) return nil;
    float value = 0.0f;
    SlangResult result = _variableReflection->getDefaultValueFloat(&value);
    if (SLANG_FAILED(result)) return nil;
    return @(value);
}

@end
