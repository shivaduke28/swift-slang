#import "SLShaderParameter.h"

@implementation SLShaderParameter

- (instancetype)initWithName:(NSString *)name
                    category:(SLParameterCategory)category
                bindingIndex:(NSUInteger)bindingIndex {
    self = [super init];
    if (self) {
        _name = [name copy];
        _category = category;
        _bindingIndex = bindingIndex;
    }
    return self;
}

- (NSString *)description {
    NSString *categoryStr;
    switch (_category) {
        case SLParameterCategoryNone:
            categoryStr = @"None";
            break;
        case SLParameterCategoryConstantBuffer:
            categoryStr = @"ConstantBuffer";
            break;
        case SLParameterCategoryShaderResource:
            categoryStr = @"ShaderResource";
            break;
        case SLParameterCategorySamplerState:
            categoryStr = @"SamplerState";
            break;
        case SLParameterCategoryUniform:
            categoryStr = @"Uniform";
            break;
        default:
            categoryStr = @"Unknown";
            break;
    }
    return [NSString stringWithFormat:@"SLShaderParameter(name=%@, category=%@, bindingIndex=%lu)",
            _name, categoryStr, (unsigned long)_bindingIndex];
}

@end
