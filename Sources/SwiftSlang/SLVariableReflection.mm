#include "../Slang/include/slang.h"

#import "SLVariableReflection.h"
#import "SLTypeReflection.h"
#import "SLUserAttribute.h"

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
    if (!attr) return nil;

    const char* attrNameStr = attr->getName();
    if (!attrNameStr) return nil;
    NSString* attrName = [NSString stringWithUTF8String:attrNameStr];

    uint32_t argCount = attr->getArgumentCount();
    NSMutableArray<NSNumber*>* floatArgs = [NSMutableArray arrayWithCapacity:argCount];
    NSMutableArray<NSNumber*>* intArgs = [NSMutableArray arrayWithCapacity:argCount];
    NSMutableArray<NSString*>* stringArgs = [NSMutableArray arrayWithCapacity:argCount];

    for (uint32_t j = 0; j < argCount; j++) {
        float floatValue = 0.0f;
        int intValue = 0;
        if (SLANG_SUCCEEDED(attr->getArgumentValueFloat(j, &floatValue))) {
            [floatArgs addObject:@(floatValue)];
            [intArgs addObject:@(0)];
            [stringArgs addObject:@""];
        } else if (SLANG_SUCCEEDED(attr->getArgumentValueInt(j, &intValue))) {
            [floatArgs addObject:@(0.0f)];
            [intArgs addObject:@(intValue)];
            [stringArgs addObject:@""];
        } else {
            size_t strLen = 0;
            const char* strValue = attr->getArgumentValueString(j, &strLen);
            if (strValue && strLen > 0) {
                [floatArgs addObject:@(0.0f)];
                [intArgs addObject:@(0)];
                [stringArgs addObject:[NSString stringWithUTF8String:strValue]];
            } else {
                [floatArgs addObject:@(0.0f)];
                [intArgs addObject:@(0)];
                [stringArgs addObject:@""];
            }
        }
    }

    return [[SLUserAttribute alloc] initWithName:attrName
                                  floatArguments:floatArgs
                                    intArguments:intArgs
                                 stringArguments:stringArgs];
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
