//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <clc/clc.h>
#include <spirv/spirv.h>

_CLC_DEF _CLC_OVERLOAD size_t get_group_id(uint dim) {
  switch (dim) {
    case 0:  return __spirv_WorkgroupId_x();
    case 1:  return __spirv_WorkgroupId_y();
    case 2:  return __spirv_WorkgroupId_z();
    default: return 0;
  }
}
