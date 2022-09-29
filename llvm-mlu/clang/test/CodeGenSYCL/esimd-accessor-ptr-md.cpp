// RUN: %clang_cc1 -fsycl-is-device \
// RUN:   -internal-isystem %S/Inputs -triple spir64-unknown-unknown-sycldevice \
// RUN:   -disable-llvm-passes -emit-llvm %s -o - | FileCheck %s

// This test checks
// 1) Proper 'kernel_arg_accessor_ptr' metadata is generated by the FE for
//    ESIMD kernels.
// 2) __init_esimd function is used to initialize the accessor rather than
//    __init.

#include "sycl.hpp"

using namespace cl::sycl;

void test(int val) {
  queue q;
  q.submit([&](handler &h) {
    cl::sycl::accessor<int, 1, cl::sycl::access::mode::read_write> accessorA;
    cl::sycl::accessor<int, 1, cl::sycl::access::mode::read> accessorB;

    h.single_task<class esimd_kernel>(
        [=]() __attribute__((sycl_explicit_simd)) {
          accessorA.use(val);
          accessorB.use();
        });
  });

  // --- Name
  // CHECK-LABEL: define {{.*}}spir_kernel void @_ZTSZZ4testiENKUlRN2cl4sycl7handlerEE_clES2_E12esimd_kernel(
  // --- Attributes
  // CHECK: {{.*}} !kernel_arg_accessor_ptr ![[ACC_PTR_ATTR:[0-9]+]] !sycl_explicit_simd !{{[0-9]+}} {{.*}}{
  // --- init_esimd call is expected instead of __init:
  // CHECK:   call spir_func void @{{.*}}__init_esimd{{.*}}(%"{{.*}}sycl::accessor" addrspace(4)* {{[^,]*}} %{{[0-9]+}}, i32 addrspace(1)* %{{[0-9]+}})
  // CHECK-LABEL: }
  // CHECK: ![[ACC_PTR_ATTR]] = !{i1 true, i1 false, i1 true}
}
