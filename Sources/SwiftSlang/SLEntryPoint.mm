#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLEntryPoint.h"
#import "SLUserAttribute.h"

@interface SLEntryPoint () {
    Slang::ComPtr<slang::IEntryPoint> _entryPoint;
}
@end

@implementation SLEntryPoint

- (instancetype)initWithEntryPointPtr:(Slang::ComPtr<slang::IEntryPoint>)entryPointPtr {
    self = [super init];
    if (self) {
        _entryPoint = std::move(entryPointPtr);
    }
    return self;
}

- (NSString *)name {
    if (!_entryPoint) {
        return @"";
    }

    // Get the function reflection to access the name
    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint.get());
    slang::ProgramLayout *layout = componentType->getLayout();
    if (layout && layout->getEntryPointCount() > 0) {
        slang::EntryPointReflection *reflection = layout->getEntryPointByIndex(0);
        if (reflection) {
            const char *name = reflection->getName();
            return name ? [NSString stringWithUTF8String:name] : @"";
        }
    }
    return @"";
}

- (SLShaderStage)stage {
    if (!_entryPoint) {
        return SLShaderStageNone;
    }

    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint.get());
    slang::ProgramLayout *layout = componentType->getLayout();
    if (layout && layout->getEntryPointCount() > 0) {
        slang::EntryPointReflection *reflection = layout->getEntryPointByIndex(0);
        if (reflection) {
            return static_cast<SLShaderStage>(reflection->getStage());
        }
    }
    return SLShaderStageNone;
}

- (NSArray<SLUserAttribute *> *)userAttributes {
    if (!_entryPoint) return @[];

    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint.get());
    slang::ProgramLayout *layout = componentType->getLayout();
    if (!layout || layout->getEntryPointCount() == 0) return @[];

    slang::EntryPointReflection *reflection = layout->getEntryPointByIndex(0);
    if (!reflection) return @[];

    slang::FunctionReflection *func = reflection->getFunction();
    if (!func) return @[];

    unsigned int attrCount = func->getUserAttributeCount();
    if (attrCount == 0) return @[];

    NSMutableArray<SLUserAttribute *> *attributes = [NSMutableArray arrayWithCapacity:attrCount];
    for (unsigned int i = 0; i < attrCount; i++) {
        slang::Attribute *attr = func->getUserAttributeByIndex(i);
        if (!attr) continue;

        const char *attrNameStr = attr->getName();
        if (!attrNameStr) continue;
        NSString *attrName = [NSString stringWithUTF8String:attrNameStr];

        uint32_t argCount = attr->getArgumentCount();
        NSMutableArray<NSNumber *> *floatArgs = [NSMutableArray arrayWithCapacity:argCount];
        NSMutableArray<NSNumber *> *intArgs = [NSMutableArray arrayWithCapacity:argCount];
        NSMutableArray<NSString *> *stringArgs = [NSMutableArray arrayWithCapacity:argCount];

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
                const char *strValue = attr->getArgumentValueString(j, &strLen);
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

        SLUserAttribute *userAttr = [[SLUserAttribute alloc] initWithName:attrName
                                                            floatArguments:floatArgs
                                                              intArguments:intArgs
                                                           stringArguments:stringArgs];
        [attributes addObject:userAttr];
    }

    return [attributes copy];
}

- (NSArray<NSNumber *> *)computeThreadGroupSize {
    if (!_entryPoint) return @[@0, @0, @0];

    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint.get());
    slang::ProgramLayout *layout = componentType->getLayout();
    if (!layout || layout->getEntryPointCount() == 0) return @[@0, @0, @0];

    slang::EntryPointReflection *reflection = layout->getEntryPointByIndex(0);
    if (!reflection) return @[@0, @0, @0];

    SlangUInt sizes[3] = {0, 0, 0};
    reflection->getComputeThreadGroupSize(3, sizes);
    return @[@(sizes[0]), @(sizes[1]), @(sizes[2])];
}

- (slang::IComponentType *)asComponentType {
    return static_cast<slang::IComponentType *>(_entryPoint.get());
}

@end
