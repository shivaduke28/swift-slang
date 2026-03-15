#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLTypeReflection;
@class SLUserAttribute;

/// A wrapper for slang::VariableReflection.
/// Provides variable information such as name, type, user attributes, and default values.
@interface SLVariableReflection : NSObject

/// Corresponds to VariableReflection::getName()
- (nullable NSString *)getName;

/// Corresponds to VariableReflection::getType()
- (nullable SLTypeReflection *)getType;

/// Corresponds to VariableReflection::getUserAttributeCount()
- (unsigned int)getUserAttributeCount;

/// Corresponds to VariableReflection::getUserAttributeByIndex()
- (nullable SLUserAttribute *)getUserAttributeByIndex:(unsigned int)index;

/// Corresponds to VariableReflection::hasDefaultValue()
- (BOOL)hasDefaultValue;

/// Corresponds to VariableReflection::getDefaultValueInt()
/// Returns nil if no default int value is available.
- (nullable NSNumber *)getDefaultValueInt;

/// Corresponds to VariableReflection::getDefaultValueFloat()
/// Returns nil if no default float value is available.
- (nullable NSNumber *)getDefaultValueFloat;

@end

NS_ASSUME_NONNULL_END
