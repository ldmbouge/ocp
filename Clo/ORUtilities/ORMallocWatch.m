//
//  ORMallocWatch.m
//  Clo
//
//  Created by Laurent Michel on 1/3/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORMallocWatch.h"

#include <stdlib.h>
#include <unistd.h>
#include <malloc/malloc.h>
#include <stdarg.h>
#include <mach/vm_map.h>

extern void _simple_vdprintf(int, const char *, va_list);
inline void nomalloc_printf(const char *format, ...)
{
   va_list ap;
   va_start(ap, format);
   _simple_vdprintf(STDOUT_FILENO, format, ap);
   va_end(ap);
}

void *(*system_malloc)(malloc_zone_t *zone, size_t size);
void *(*system_valloc)(malloc_zone_t *zone, size_t size);
void *(*system_calloc)(malloc_zone_t *zone, size_t size,size_t cnt);
void *(*system_realloc)(malloc_zone_t* zone,void* ptr,size_t size);
void (*system_free)(malloc_zone_t *zone, void *ptr);
void (*system_free_definite_size)(malloc_zone_t * zone, void *ptr , size_t sz);

static long nbBytes = 0;
static long peakBytes = 0;

void * my_malloc(malloc_zone_t *zone, size_t size)
{
   void *ptr = system_malloc(zone, size);
   size_t als = malloc_size(ptr);
   nbBytes += als;
   peakBytes = nbBytes > peakBytes ? nbBytes : peakBytes;
   //printf("%p = malloc(zone=%p, size=%lu sizea=%lu now=%ld peak=%ld)\n", ptr, zone,size, als,nbBytes,peakBytes);
   return ptr;
}

void * my_valloc(malloc_zone_t *zone, size_t size)
{
   void *ptr = system_valloc(zone, size);
   size_t als = malloc_size(ptr);
   nbBytes += als;
   peakBytes = nbBytes > peakBytes ? nbBytes : peakBytes;
   //printf("%p = malloc(zone=%p, size=%lu sizea=%lu now=%ld peak=%ld)\n", ptr, zone,size, als,nbBytes,peakBytes);
   return ptr;
}

void *my_realloc(malloc_zone_t* zone,void* ptr,size_t size)
{
   size_t oldsz = malloc_size(ptr);
   void* nPtr = system_realloc(zone,ptr,size);
   size_t newsz = malloc_size(nPtr);
   nbBytes += newsz - oldsz;
   return nPtr;
}

void * my_calloc(malloc_zone_t *zone, size_t cnt,size_t size)
{
   void* ptr = system_calloc(zone,cnt,size);
   size_t als = malloc_size(ptr);
   nbBytes += als;
   peakBytes = nbBytes > peakBytes ? nbBytes : peakBytes;
   return ptr;
}

void my_free(malloc_zone_t *zone, void *ptr)
{
   size_t toFree = malloc_size(ptr);
   nbBytes -= toFree;
   //printf("free(zone=%p, ptr=%p  toFree=%lu  now=%ld peak=%ld)\n", zone, ptr,toFree,nbBytes,peakBytes);
   system_free(zone, ptr);
}

void my_free_definite_size(malloc_zone_t * zone, void *ptr , size_t sz)
{
   nbBytes -= sz;
   //printf("free_definite_size(zone=%p, ptr=%p  toFree=%lu  now=%ld peak=%ld)\n", zone, ptr,sz,nbBytes,peakBytes);
   system_free_definite_size(zone, ptr,sz);
}

void mallocWatch()
{
   size_t  protect_size = sizeof(malloc_zone_t);
   malloc_zone_t *zone = malloc_default_zone();
   system_malloc = zone->malloc;
   system_valloc = zone->valloc;
   system_calloc = zone->calloc;
   system_realloc = zone->realloc;
   system_free = zone->free;  // ignoring atomicity/caching
   system_free_definite_size = zone->free_definite_size;
   
   if(zone->version >= 8) {
      vm_protect(mach_task_self(), (uintptr_t)zone, protect_size, 0, VM_PROT_READ | VM_PROT_WRITE);//remove the write protection
   }
   zone->malloc = my_malloc;
   zone->valloc = my_valloc;
   zone->calloc = my_calloc;
   zone->realloc = my_realloc;
   zone->free = my_free;
   zone->free_definite_size = my_free_definite_size;
   if(zone->version==8) {
      vm_protect(mach_task_self(), (uintptr_t)zone, protect_size, 0, VM_PROT_READ);//put the write protection back
   }
}

NSString* mallocReport()
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"using: %ld peak:%ld",nbBytes,peakBytes];
   return buf;
}
