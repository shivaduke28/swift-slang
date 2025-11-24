#include "../Slang/include/slang.h"

#import "SLEntryPoint.h"

@interface SLEntryPoint ()
@property (nonatomic, assign) slang::IEntryPoint *entryPoint;
@end

@implementation SLEntryPoint

- (instancetype)initWithEntryPoint:(slang::IEntryPoint *)entryPoint {
    self = [super init];
    if (self) {
        _entryPoint = entryPoint;
    }
    return self;
}

- (void)dealloc {
    if (_entryPoint) {
        _entryPoint->release();
        _entryPoint = nullptr;
    }
}

- (NSString *)name {
    if (!_entryPoint) {
        return @"";
    }

    // Get the function reflection to access the name
    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint);
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

    slang::IComponentType *componentType = static_cast<slang::IComponentType *>(_entryPoint);
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
    return static_cast<slang::IComponentType *>(_entryPoint);
}

@end
