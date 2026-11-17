#pragma once

#include "../Slang/include/slang.h"
#import "SLParameterCategory.h"

// SLParameterCategory shares its raw values with SlangParameterCategory,
// so the conversions are plain casts.

/// Maps SLParameterCategory to SlangParameterCategory.
static inline SlangParameterCategory toSlangParameterCategory(SLParameterCategory category) {
    return static_cast<SlangParameterCategory>(category);
}

/// Maps slang::ParameterCategory to SLParameterCategory.
static inline SLParameterCategory fromSlangParameterCategory(slang::ParameterCategory category) {
    return static_cast<SLParameterCategory>(category);
}
