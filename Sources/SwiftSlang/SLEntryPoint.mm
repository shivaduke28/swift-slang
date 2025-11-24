#include <utility>
#include "../Slang/include/slang.h"
#include "../Slang/include/slang-com-ptr.h"

#import "SLEntryPoint.h"

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

- (slang::IComponentType *)asComponentType {
    return static_cast<slang::IComponentType *>(_entryPoint.get());
}

@end
