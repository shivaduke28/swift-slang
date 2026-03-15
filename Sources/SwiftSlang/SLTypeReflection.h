#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLVariableReflection;

/// Corresponds to slang::TypeReflection::Kind
typedef NS_ENUM(NSInteger, SLTypeKind) {
    SLTypeKindNone = 0,
    SLTypeKindStruct,
    SLTypeKindArray,
    SLTypeKindMatrix,
    SLTypeKindVector,
    SLTypeKindScalar,
    SLTypeKindConstantBuffer,
    SLTypeKindResource,
    SLTypeKindSamplerState,
    SLTypeKindTextureBuffer,
    SLTypeKindShaderStorageBuffer,
    SLTypeKindParameterBlock,
    SLTypeKindGenericTypeParameter,
    SLTypeKindInterface,
    SLTypeKindOutputStream,
    SLTypeKindMeshOutput,
    SLTypeKindSpecialized,
    SLTypeKindFeedback,
    SLTypeKindPointer,
    SLTypeKindDynamicResource,
    SLTypeKindEnum,
};

/// Corresponds to slang::TypeReflection::ScalarType
typedef NS_ENUM(NSInteger, SLScalarType) {
    SLScalarTypeNone = 0,
    SLScalarTypeVoid,
    SLScalarTypeBool,
    SLScalarTypeInt32,
    SLScalarTypeUInt32,
    SLScalarTypeInt64,
    SLScalarTypeUInt64,
    SLScalarTypeFloat16,
    SLScalarTypeFloat32,
    SLScalarTypeFloat64,
    SLScalarTypeInt8,
    SLScalarTypeUInt8,
    SLScalarTypeInt16,
    SLScalarTypeUInt16,
};

/// Corresponds to SlangResourceShape
typedef NS_ENUM(NSUInteger, SLResourceShape) {
    SLResourceShapeBaseShapeMask = 0x0F,
    SLResourceShapeNone = 0x00,
    SLResourceShapeTexture1D = 0x01,
    SLResourceShapeTexture2D = 0x02,
    SLResourceShapeTexture3D = 0x03,
    SLResourceShapeTextureCube = 0x04,
    SLResourceShapeTextureBuffer = 0x05,
    SLResourceShapeStructuredBuffer = 0x06,
    SLResourceShapeByteAddressBuffer = 0x07,
    SLResourceShapeUnknown = 0x08,
    SLResourceShapeAccelerationStructure = 0x09,
    SLResourceShapeTextureSubpass = 0x0A,
    SLResourceShapeExtShapeMask = 0x1F0,
    SLResourceShapeTextureFeedbackFlag = 0x10,
    SLResourceShapeTextureShadowFlag = 0x20,
    SLResourceShapeTextureArrayFlag = 0x40,
    SLResourceShapeTextureMultisampleFlag = 0x80,
    SLResourceShapeTextureCombinedFlag = 0x100,
    SLResourceShapeTexture1DArray = 0x41,
    SLResourceShapeTexture2DArray = 0x42,
    SLResourceShapeTextureCubeArray = 0x44,
    SLResourceShapeTexture2DMultisample = 0x82,
    SLResourceShapeTexture2DMultisampleArray = 0xC2,
    SLResourceShapeTextureSubpassMultisample = 0x8A,
};

/// Corresponds to SlangResourceAccess
typedef NS_ENUM(NSUInteger, SLResourceAccess) {
    SLResourceAccessNone = 0,
    SLResourceAccessRead,
    SLResourceAccessReadWrite,
    SLResourceAccessRasterOrdered,
    SLResourceAccessAppend,
    SLResourceAccessConsume,
    SLResourceAccessWrite,
    SLResourceAccessFeedback,
    SLResourceAccessUnknown = 0x7FFFFFFF,
};

/// A wrapper for slang::TypeReflection.
/// Provides type information such as kind, name, scalar type, and struct fields.
@interface SLTypeReflection : NSObject

/// Corresponds to TypeReflection::getKind()
- (SLTypeKind)getKind;

/// Corresponds to TypeReflection::getName()
- (nullable NSString *)getName;

/// Corresponds to TypeReflection::getFieldCount()
/// Only meaningful when getKind == SLTypeKindStruct.
- (unsigned int)getFieldCount;

/// Corresponds to TypeReflection::getFieldByIndex()
/// Only meaningful when getKind == SLTypeKindStruct.
- (nullable SLVariableReflection *)getFieldByIndex:(unsigned int)index;

/// Corresponds to TypeReflection::getRowCount()
/// Only meaningful for matrix types.
- (unsigned int)getRowCount;

/// Corresponds to TypeReflection::getColumnCount()
/// Only meaningful for matrix types.
- (unsigned int)getColumnCount;

/// Corresponds to TypeReflection::getScalarType()
- (SLScalarType)getScalarType;

/// Corresponds to TypeReflection::getResourceShape()
- (SLResourceShape)getResourceShape;

/// Corresponds to TypeReflection::getResourceAccess()
- (SLResourceAccess)getResourceAccess;

/// Corresponds to TypeReflection::getElementType()
/// Returns the element type for array/vector types.
- (nullable SLTypeReflection *)getElementType;

/// Corresponds to TypeReflection::getElementCount()
/// Returns the number of elements for array/vector types.
- (NSUInteger)getElementCount;

@end

NS_ASSUME_NONNULL_END
