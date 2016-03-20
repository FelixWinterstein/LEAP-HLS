

#ifndef _MERGER_TOP_H_
#define _MERGER_TOP_H_

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include "ap_int.h"

#define PARALLEL_VERSION // use this to toggle between the serial and parallelized (P=4) implementation



typedef unsigned int pointer_type;

#define MAX_K INT_MAX
//#define P 4 // currently P=4 is hard-coded



struct data_record
{
	int k;
	pointer_type n;
    data_record() { }
    data_record volatile & operator=(data_record const &a) volatile
    { k=a.k; n=a.n; return *this; }
    data_record & operator=(data_record const volatile &a)
    { k=a.k; n=a.n; return *this; }
    data_record & operator=(data_record const &a)
    { k=a.k; n=a.n; return *this; }
};

#ifndef PARALLEL_VERSION

void merger_top(uint n,
		volatile data_record *data_bus_1,
		volatile pointer_type *freelist_bus_1,
		volatile int *val_r1,
		volatile int *val_r2,
		volatile int *val_r3,
		volatile int *val_r4,
		volatile int *val_w);

#else

void merger_top(uint n,
				volatile data_record *data_bus_0,
				volatile data_record *data_bus_1,
				volatile data_record *data_bus_2,
				volatile data_record *data_bus_3,
				volatile pointer_type *freelist_bus_0,
				volatile pointer_type *freelist_bus_1,
				volatile pointer_type *freelist_bus_2,
				volatile pointer_type *freelist_bus_3,
				volatile int *val_r0,
				volatile int *val_r1,
				volatile int *val_r2,
				volatile int *val_r3,
				volatile int *val_w0);

#endif




#endif
