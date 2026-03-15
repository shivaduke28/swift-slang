#include "../Slang/include/slang.h"

#import "SLTypeReflection.h"
#import "SLVariableReflection.h"

@interface SLVariableReflection ()
- (instancetype)initWithVariableReflectionPtr:(slang::VariableReflection*)ptr;
@end

@interface SLTypeReflection () {
    slang::TypeReflection* _typeReflection;
}
@end

@implementation SLTypeReflection

- (instancetype)initWithTypeReflectionPtr:(slang::TypeReflection*)ptr {
    self = [super init];
    if (self) {
        _typeReflection = ptr;
    }
    return self;
}

- (SLTypeKind)getKind {
    if (!_typeReflection) return SLTypeKindNone;
    return (SLTypeKind)_typeReflection->getKind();
}

- (nullable NSString *)getName {
    if (!_typeReflection) return nil;
    const char* name = _typeReflection->getName();
    if (!name) return nil;
    return [NSString stringWithUTF8String:name];
}

- (unsigned int)getFieldCount {
    if (!_typeReflection) return 0;
    return _typeReflection->getFieldCount();
}

- (nullable SLVariableReflection *)getFieldByIndex:(unsigned int)index {
    if (!_typeReflection) return nil;
    slang::VariableReflection* field = _typeReflection->getFieldByIndex(index);
    if (!field) return nil;
    return [[SLVariableReflection alloc] initWithVariableReflectionPtr:field];
}

- (unsigned int)getRowCount {
    if (!_typeReflection) return 0;
    return _typeReflection->getRowCount();
}

- (unsigned int)getColumnCount {
    if (!_typeReflection) return 0;
    return _typeReflection->getColumnCount();
}

- (SLScalarType)getScalarType {
    if (!_typeReflection) return SLScalarTypeNone;
    return (SLScalarType)_typeReflection->getScalarType();
}

- (SLResourceShape)getResourceShape {
    if (!_typeReflection) return SLResourceShapeNone;
    return (SLResourceShape)_typeReflection->getResourceShape();
}

- (SLResourceAccess)getResourceAccess {
    if (!_typeReflection) return SLResourceAccessNone;
    return (SLResourceAccess)_typeReflection->getResourceAccess();
}

- (nullable SLTypeReflection *)getElementType {
    if (!_typeReflection) return nil;
    slang::TypeReflection* elementType = _typeReflection->getElementType();
    if (!elementType) return nil;
    return [[SLTypeReflection alloc] initWithTypeReflectionPtr:elementType];
}

- (NSUInteger)getElementCount {
    if (!_typeReflection) return 0;
    return (NSUInteger)_typeReflection->getElementCount();
}

@end
