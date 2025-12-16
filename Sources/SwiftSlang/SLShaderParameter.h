#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLUserAttribute;

/// Parameter category for shader resources.
/// These values correspond to SlangParameterCategory in slang.h.
typedef NS_ENUM(NSInteger, SLParameterCategory) {
    SLParameterCategoryNone = 0,
    SLParameterCategoryConstantBuffer,
    SLParameterCategoryShaderResource,
    SLParameterCategorySamplerState,
    SLParameterCategoryUniform,
};

/// Represents a shader parameter extracted from Slang reflection.
@interface SLShaderParameter : NSObject

/// The name of the parameter (e.g., "rgbTexture", "depthTexture").
@property (nonatomic, readonly) NSString *name;

/// The category of the parameter (Buffer, Texture, Sampler, etc.).
@property (nonatomic, readonly) SLParameterCategory category;

/// The binding index for Metal (e.g., [[texture(N)]] where N is bindingIndex).
@property (nonatomic, readonly) NSUInteger bindingIndex;

/// User-defined attributes on this parameter (e.g., [range(0.0, 1.0, "desc")]).
@property (nonatomic, readonly) NSArray<SLUserAttribute *> *userAttributes;

- (instancetype)initWithName:(NSString *)name
                    category:(SLParameterCategory)category
                bindingIndex:(NSUInteger)bindingIndex
              userAttributes:(NSArray<SLUserAttribute *> *)userAttributes;

@end

NS_ASSUME_NONNULL_END
