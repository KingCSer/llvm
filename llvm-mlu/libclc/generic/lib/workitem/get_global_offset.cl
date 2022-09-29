//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <clc/clc.h>
#include <spirv/spirv.h>

_CLC_DEF _CLC_OVERLOAD size_t get_global_offset(uint dim) {
  switch (dim) {
    case 0:  return __spirv_GlobalOffset_x();
    case 1:  return __spirv_GlobalOffset_y();
    case 2:  return __spirv_GlobalOffset_z();
    default: return 0;
  }
}
