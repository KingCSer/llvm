#ifndef CLC_AS_TYPE
#define CLC_AS_TYPE

#define as_char(x) __builtin_astype(x, char)
#define as_schar(x) __builtin_astype(x, schar)
#define as_uchar(x) __builtin_astype(x, uchar)
#define as_short(x) __builtin_astype(x, short)
#define as_ushort(x) __builtin_astype(x, ushort)
#define as_int(x) __builtin_astype(x, int)
#define as_uint(x) __builtin_astype(x, uint)
#define as_long(x) __builtin_astype(x, long)
#define as_ulong(x) __builtin_astype(x, ulong)
#define as_float(x) __builtin_astype(x, float)

#define as_char2(x) __builtin_astype(x, char2)
#define as_schar2(x) __builtin_astype(x, schar2)
#define as_uchar2(x) __builtin_astype(x, uchar2)
#define as_short2(x) __builtin_astype(x, short2)
#define as_ushort2(x) __builtin_astype(x, ushort2)
#define as_int2(x) __builtin_astype(x, int2)
#define as_uint2(x) __builtin_astype(x, uint2)
#define as_long2(x) __builtin_astype(x, long2)
#define as_ulong2(x) __builtin_astype(x, ulong2)
#define as_float2(x) __builtin_astype(x, float2)

#define as_char3(x) __builtin_astype(x, char3)
#define as_schar3(x) __builtin_astype(x, schar3)
#define as_uchar3(x) __builtin_astype(x, uchar3)
#define as_short3(x) __builtin_astype(x, short3)
#define as_ushort3(x) __builtin_astype(x, ushort3)
#define as_int3(x) __builtin_astype(x, int3)
#define as_uint3(x) __builtin_astype(x, uint3)
#define as_long3(x) __builtin_astype(x, long3)
#define as_ulong3(x) __builtin_astype(x, ulong3)
#define as_float3(x) __builtin_astype(x, float3)

#define as_char4(x) __builtin_astype(x, char4)
#define as_schar4(x) __builtin_astype(x, schar4)
#define as_uchar4(x) __builtin_astype(x, uchar4)
#define as_short4(x) __builtin_astype(x, short4)
#define as_ushort4(x) __builtin_astype(x, ushort4)
#define as_int4(x) __builtin_astype(x, int4)
#define as_uint4(x) __builtin_astype(x, uint4)
#define as_long4(x) __builtin_astype(x, long4)
#define as_ulong4(x) __builtin_astype(x, ulong4)
#define as_float4(x) __builtin_astype(x, float4)

#define as_char8(x) __builtin_astype(x, char8)
#define as_schar8(x) __builtin_astype(x, schar8)
#define as_uchar8(x) __builtin_astype(x, uchar8)
#define as_short8(x) __builtin_astype(x, short8)
#define as_ushort8(x) __builtin_astype(x, ushort8)
#define as_int8(x) __builtin_astype(x, int8)
#define as_uint8(x) __builtin_astype(x, uint8)
#define as_long8(x) __builtin_astype(x, long8)
#define as_ulong8(x) __builtin_astype(x, ulong8)
#define as_float8(x) __builtin_astype(x, float8)

#define as_char16(x) __builtin_astype(x, char16)
#define as_schar16(x) __builtin_astype(x, schar16)
#define as_uchar16(x) __builtin_astype(x, uchar16)
#define as_short16(x) __builtin_astype(x, short16)
#define as_ushort16(x) __builtin_astype(x, ushort16)
#define as_int16(x) __builtin_astype(x, int16)
#define as_uint16(x) __builtin_astype(x, uint16)
#define as_long16(x) __builtin_astype(x, long16)
#define as_ulong16(x) __builtin_astype(x, ulong16)
#define as_float16(x) __builtin_astype(x, float16)

#ifdef cl_khr_fp64
#define as_double(x) __builtin_astype(x, double)
#define as_double2(x) __builtin_astype(x, double2)
#define as_double3(x) __builtin_astype(x, double3)
#define as_double4(x) __builtin_astype(x, double4)
#define as_double8(x) __builtin_astype(x, double8)
#define as_double16(x) __builtin_astype(x, double16)
#endif

#ifdef cl_khr_fp16
#define as_half(x) __builtin_astype(x, half)
#define as_half2(x) __builtin_astype(x, half2)
#define as_half3(x) __builtin_astype(x, half3)
#define as_half4(x) __builtin_astype(x, half4)
#define as_half8(x) __builtin_astype(x, half8)
#define as_half16(x) __builtin_astype(x, half16)
#endif

#ifdef __CLC_HAS_FLOAT16
#define as_float16_t(x) __builtin_astype(x, __clc_float16_t)
#define as_vec2_float16_t(x) __builtin_astype(x, __clc_vec2_float16_t)
#define as_vec3_float16_t(x) __builtin_astype(x, __clc_vec3_float16_t)
#define as_vec4_float16_t(x) __builtin_astype(x, __clc_vec4_float16_t)
#define as_vec8_float16_t(x) __builtin_astype(x, __clc_vec8_float16_t)
#define as_vec16_float16_t(x) __builtin_astype(x, __clc_vec16_float16_t)
#endif

#endif // CLC_AS_TYPE
