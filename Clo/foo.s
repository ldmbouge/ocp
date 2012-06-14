; ModuleID = 'block1.m'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.0.0"

%0 = type { i64, i64, i8*, i8* }
%1 = type <{ i8*, i32, i32, i32 (%struct.__block_literal_1*, i32)*, i8*, i32 }>
%2 = type opaque
%struct.NSConstantString = type { i32*, i32, i8*, i64 }
%struct.__block_descriptor = type { i64, i64 }
%struct.__block_literal_1 = type { i8**, i32, i32, i8**, %struct.__block_descriptor*, i32 }
%struct.__block_literal_generic = type { i8*, i32, i32, i8*, %struct.__block_descriptor* }
%struct.__method_list_t = type { i32, i32, [0 x %struct._objc_method] }
%struct._category_t = type { i8*, %struct._class_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct._objc_protocol_list*, %struct._prop_list_t* }
%struct._class_ro_t = type { i32, i32, i32, i8*, i8*, %struct.__method_list_t*, %struct._objc_protocol_list*, %struct._ivar_list_t*, i8*, %struct._prop_list_t* }
%struct._class_t = type { %struct._class_t*, %struct._class_t*, %struct._objc_cache*, i8* (i8*, i8*)**, %struct._class_ro_t* }
%struct._ivar_list_t = type { i32, i32, [0 x %struct._ivar_t] }
%struct._ivar_t = type { i64*, i8*, i8*, i32, i32 }
%struct._message_ref_t = type { i8*, i8* }
%struct._objc_cache = type opaque
%struct._objc_method = type { i8*, i8*, i8* }
%struct._objc_protocol_list = type { i64, [0 x %struct._protocol_t*] }
%struct._objc_super = type { i8*, i8* }
%struct._objc_typeinfo = type { i8**, i8*, %struct._class_t* }
%struct._prop_list_t = type { i32, i32, [0 x %struct._message_ref_t] }
%struct._prop_t = type { i8*, i8* }
%struct._protocol_t = type { i8*, i8*, %struct._objc_protocol_list*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct._prop_list_t*, i32, i32 }
%struct._super_message_ref_t = type { i8* (i8*, i8*)*, i8* }

@_NSConcreteStackBlock = external global i8*
@.str = private constant [9 x i8] c"i12@?0i8\00"
@__block_descriptor_tmp = internal constant %0 { i64 0, i64 40, i8* getelementptr inbounds ([9 x i8]* @.str, i32 0, i32 0), i8* null }
@__CFConstantStringClassReference = external global [0 x i32]
@.str1 = private constant [14 x i8] c"result is %d\0A\00"
@_unnamed_cfstring_ = private constant %struct.NSConstantString { i32* getelementptr inbounds ([0 x i32]* @__CFConstantStringClassReference, i32 0, i32 0), i32 1992, i8* getelementptr inbounds ([14 x i8]* @.str1, i32 0, i32 0), i64 13 }, section "__DATA,__cfstring"
@"\01L_OBJC_IMAGE_INFO" = internal constant [2 x i32] [i32 0, i32 16], section "__DATA, __objc_imageinfo, regular, no_dead_strip"
@llvm.used = appending global [1 x i8*] [i8* bitcast ([2 x i32]* @"\01L_OBJC_IMAGE_INFO" to i8*)], section "llvm.metadata"

define i32 @foo(i32 (i32)* %b) ssp {
  %1 = alloca i32 (i32)*, align 8
  store i32 (i32)* %b, i32 (i32)** %1, align 8
  %2 = load i32 (i32)** %1, align 8
  %3 = bitcast i32 (i32)* %2 to %struct.__block_literal_generic*
  %4 = getelementptr inbounds %struct.__block_literal_generic* %3, i32 0, i32 3
  %5 = bitcast %struct.__block_literal_generic* %3 to i8*
  %6 = load i8** %4
  %7 = bitcast i8* %6 to i32 (i8*, i32)*
  %8 = call i32 %7(i8* %5, i32 5)
  ret i32 %8
}

define i32 @main() ssp {
  %1 = alloca i32, align 4
  %y = alloca i32, align 4
  %z = alloca i32, align 4
  %2 = alloca %1, align 8
  store i32 0, i32* %1
  store i32 10, i32* %y, align 4
  %3 = getelementptr inbounds %1* %2, i32 0, i32 0
  store i8* bitcast (i8** @_NSConcreteStackBlock to i8*), i8** %3
  %4 = getelementptr inbounds %1* %2, i32 0, i32 1
  store i32 1073741824, i32* %4
  %5 = getelementptr inbounds %1* %2, i32 0, i32 2
  store i32 0, i32* %5
  %6 = getelementptr inbounds %1* %2, i32 0, i32 3
  store i32 (%struct.__block_literal_1*, i32)* @__main_block_invoke_0, i32 (%struct.__block_literal_1*, i32)** %6
  %7 = getelementptr inbounds %1* %2, i32 0, i32 5
  %8 = load i32* %y, align 4
  store i32 %8, i32* %7
  %9 = getelementptr inbounds %1* %2, i32 0, i32 4
  store i8* bitcast (%0* @__block_descriptor_tmp to i8*), i8** %9
  %10 = bitcast %1* %2 to i32 (i32)*
  %11 = call i32 @foo(i32 (i32)* %10)
  store i32 %11, i32* %z, align 4
  %12 = load i32* %z, align 4
  call void (%2*, ...)* @NSLog(%2* bitcast (%struct.NSConstantString* @_unnamed_cfstring_ to %2*), i32 %12)
  %13 = load i32* %1
  ret i32 %13
}

define internal i32 @__main_block_invoke_0(%struct.__block_literal_1* %.block_descriptor, i32 %x) ssp {
  %1 = alloca %struct.__block_literal_1*, align 8
  %2 = alloca i32, align 4
  store %struct.__block_literal_1* %.block_descriptor, %struct.__block_literal_1** %1, align 8
  store i32 %x, i32* %2, align 4
  %3 = load %struct.__block_literal_1** %1
  %4 = bitcast %struct.__block_literal_1* %3 to i8*
  %5 = getelementptr i8* %4, i64 32
  %6 = bitcast i8* %5 to i32*
  %7 = load i32* %6
  %8 = load i32* %2, align 4
  %9 = add nsw i32 %7, %8
  ret i32 %9
}

declare void @NSLog(%2*, ...)
