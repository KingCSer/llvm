; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=hexagon < %s | FileCheck %s
target datalayout = "e-m:e-p:32:32:32-a:0-n16:32-i64:64:64-i32:32:32-i16:16:16-i1:8:8-f32:32:32-f64:64:64-v32:32:32-v64:64:64-v512:512:512-v1024:1024:1024-v2048:2048:2048"
target triple = "hexagon"

@g0 = external dso_local global <64 x i32>, align 128
@g1 = external hidden unnamed_addr constant [110 x i8], align 1
@g2 = external hidden unnamed_addr constant [102 x i8], align 1
@g3 = external hidden unnamed_addr constant [110 x i8], align 1

declare dso_local void @f0() #0

declare dso_local void @f1(i8*, ...) #0

; Function Attrs: nounwind readnone
declare <32 x i32> @llvm.hexagon.V6.vandqrt.128B(<128 x i1>, i32) #1

; Function Attrs: nounwind readnone
declare <128 x i1> @llvm.hexagon.V6.vandvrt.128B(<32 x i32>, i32) #1

; Function Attrs: nounwind readnone
declare <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32) #1

; Function Attrs: nounwind readnone
declare <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32>, i32, i32 immarg) #1

; Function Attrs: nounwind readnone
declare <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32>, <32 x i32>) #1

define dso_local void @f2() #0 {
; CHECK-LABEL: f2:
; CHECK:       // %bb.0: // %b0
; CHECK-NEXT:    {
; CHECK-NEXT:     r1:0 = combine(#2,##16843009)
; CHECK-NEXT:     allocframe(r29,#1536):raw
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     v1 = vsplat(r1)
; CHECK-NEXT:     r17:16 = combine(#-1,#1)
; CHECK-NEXT:     r29 = and(r29,#-256)
; CHECK-NEXT:     memd(r30+#-8) = r17:16
; CHECK-NEXT:    } // 8-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     v0 = vsplat(r16)
; CHECK-NEXT:     r2 = add(r29,#2048)
; CHECK-NEXT:     memd(r30+#-16) = r19:18
; CHECK-NEXT:    } // 8-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     q0 = vand(v0,r0)
; CHECK-NEXT:     r18 = ##-2147483648
; CHECK-NEXT:     vmem(r2+#-7) = v0
; CHECK-NEXT:    } // 128-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     v0 = vand(q0,r17)
; CHECK-NEXT:     r0 = ##g1
; CHECK-NEXT:     memd(r30+#-24) = r21:20
; CHECK-NEXT:    } // 8-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     r19 = ##g0+128
; CHECK-NEXT:     vmem(r2+#-6) = v0
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     v3:2.h = vadd(v0.ub,v1.ub)
; CHECK-NEXT:     r20 = ##g0
; CHECK-NEXT:     vmem(r29+#5) = v1
; CHECK-NEXT:    } // 128-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     vmem(r29+#6) = v2
; CHECK-NEXT:    } // 256-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     v31:30.uw = vrmpy(v3:2.ub,r18.ub,#0)
; CHECK-NEXT:     vmem(r29+#7) = v3
; CHECK-NEXT:    } // 256-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     vmem(r19+#0) = v31
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     call f1
; CHECK-NEXT:     vmem(r20+#0) = v30
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     r0 = add(r29,#2048)
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     v0 = vmem(r0+#-7)
; CHECK-NEXT:    } // 128-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.h = vadd(v0.ub,v0.ub)
; CHECK-NEXT:     r0 = ##g2
; CHECK-NEXT:     vmem(r29+#2) = v0.new
; CHECK-NEXT:    } // 256-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     vmem(r29+#3) = v1
; CHECK-NEXT:    } // 256-byte Folded Spill
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.uw = vrmpy(v1:0.ub,r17.ub,#0)
; CHECK-NEXT:     vmem(r19+#0) = v1.new
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     call f1
; CHECK-NEXT:     vmem(r20+#0) = v0
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     r0 = ##2147483647
; CHECK-NEXT:     v0 = vmem(r29+#2)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1 = vmem(r29+#3)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.uw = vrmpy(v1:0.ub,r0.ub,#1)
; CHECK-NEXT:     r0 = ##g3
; CHECK-NEXT:     vmem(r19+#0) = v1.new
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     call f1
; CHECK-NEXT:     vmem(r20+#0) = v0
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     v0 = vmem(r29+#6)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1 = vmem(r29+#7)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.uw = vrmpy(v1:0.ub,r18.ub,#1)
; CHECK-NEXT:     vmem(r19+#0) = v1.new
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     call f0
; CHECK-NEXT:     vmem(r20+#0) = v0
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     r0 = #0
; CHECK-NEXT:     v0 = vmem(r29+#6)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1 = vmem(r29+#7)
; CHECK-NEXT:    } // 256-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.uw = vrmpy(v1:0.ub,r0.ub,#1)
; CHECK-NEXT:     vmem(r19+#0) = v1.new
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     call f0
; CHECK-NEXT:     vmem(r20+#0) = v0
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     r0 = add(r29,#2048)
; CHECK-NEXT:     v1 = vmem(r29+#5)
; CHECK-NEXT:    } // 128-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v0 = vmem(r0+#-7)
; CHECK-NEXT:    } // 128-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.h = vadd(v0.ub,v1.ub)
; CHECK-NEXT:    }
; CHECK-NEXT:    {
; CHECK-NEXT:     v1:0.uw = vrmpy(v1:0.ub,r16.ub,#1)
; CHECK-NEXT:     r17:16 = memd(r30+#-8)
; CHECK-NEXT:     vmem(r19+#0) = v1.new
; CHECK-NEXT:    } // 8-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     r19:18 = memd(r30+#-16)
; CHECK-NEXT:     vmem(r20+#0) = v0
; CHECK-NEXT:    } // 8-byte Folded Reload
; CHECK-NEXT:    {
; CHECK-NEXT:     r21:20 = memd(r30+#-24)
; CHECK-NEXT:     r31:30 = dealloc_return(r30):raw
; CHECK-NEXT:    } // 8-byte Folded Reload
b0:
  %v0 = alloca <32 x i32>, align 128
  %v1 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 1)
  %v2 = call <128 x i1> @llvm.hexagon.V6.vandvrt.128B(<32 x i32> %v1, i32 16843009)
  %v3 = call <32 x i32> @llvm.hexagon.V6.vandqrt.128B(<128 x i1> %v2, i32 -1)
  store <32 x i32> %v3, <32 x i32>* %v0, align 128
  %v4 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 2)
  %v5 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> undef, <32 x i32> %v4)
  %v6 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v5, i32 -2147483648, i32 0)
  store <64 x i32> %v6, <64 x i32>* @g0, align 128
  call void (i8*, ...) @f1(i8* getelementptr inbounds ([110 x i8], [110 x i8]* @g1, i32 0, i32 0)) #2
  %v7 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 1)
  %v8 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> %v7, <32 x i32> undef)
  %v9 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v8, i32 -1, i32 0)
  store <64 x i32> %v9, <64 x i32>* @g0, align 128
  call void (i8*, ...) @f1(i8* getelementptr inbounds ([102 x i8], [102 x i8]* @g2, i32 0, i32 0)) #2
  %v10 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 1)
  %v11 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> %v10, <32 x i32> undef)
  %v12 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v11, i32 2147483647, i32 1)
  store <64 x i32> %v12, <64 x i32>* @g0, align 128
  call void (i8*, ...) @f1(i8* getelementptr inbounds ([110 x i8], [110 x i8]* @g3, i32 0, i32 0)) #2
  %v13 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 2)
  %v14 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> undef, <32 x i32> %v13)
  %v15 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v14, i32 -2147483648, i32 1)
  store <64 x i32> %v15, <64 x i32>* @g0, align 128
  call void @f0() #2
  %v16 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 2)
  %v17 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> undef, <32 x i32> %v16)
  %v18 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v17, i32 0, i32 1)
  store <64 x i32> %v18, <64 x i32>* @g0, align 128
  call void @f0() #2
  %v19 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 1)
  %v20 = call <32 x i32> @llvm.hexagon.V6.lvsplatw.128B(i32 2)
  %v21 = call <64 x i32> @llvm.hexagon.V6.vaddubh.128B(<32 x i32> %v19, <32 x i32> %v20)
  %v22 = call <64 x i32> @llvm.hexagon.V6.vrmpyubi.128B(<64 x i32> %v21, i32 1, i32 1)
  store <64 x i32> %v22, <64 x i32>* @g0, align 128
  ret void
}

attributes #0 = { nounwind "use-soft-float"="false" "target-cpu"="hexagonv66" "target-features"="+hvxv66,+hvx-length128b" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind optsize }
