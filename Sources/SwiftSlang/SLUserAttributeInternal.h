#pragma once

#include "../Slang/include/slang.h"
#import "SLUserAttribute.h"

/// Create an SLUserAttribute from a single slang::UserAttribute.
static inline SLUserAttribute* _Nullable createUserAttribute(slang::UserAttribute* _Nullable attr) {
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

/// Collect user-defined attributes from a slang::VariableReflection.
static inline NSArray<SLUserAttribute*>* _Nonnull collectUserAttributes(slang::VariableReflection* _Nullable variable) {
    if (!variable) return @[];

    unsigned int attrCount = variable->getUserAttributeCount();
    if (attrCount == 0) return @[];

    NSMutableArray<SLUserAttribute*>* attributes = [NSMutableArray arrayWithCapacity:attrCount];

    for (unsigned int i = 0; i < attrCount; i++) {
        SLUserAttribute* userAttr = createUserAttribute(variable->getUserAttributeByIndex(i));
        if (userAttr) {
            [attributes addObject:userAttr];
        }
    }

    return [attributes copy];
}
