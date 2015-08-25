/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: filtering_algorithm_top.h
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

#ifndef FILTERING_ALGORITHM_TOP_H
#define FILTERING_ALGORITHM_TOP_H

// override default AP_INT_MAX_W=1024
//#define AP_INT_MAX_W 4096

#include <math.h>
#include "ap_int.h" // custom data types
#include "ap_shift_reg.h"
#include "ap_utils.h"


#define D 3         	// data dimensionality
#define N 8*32768     	// max number of data points
#define K 256       	// max number of centres

#define P 4     		// parallelism degree (currently, max P = 4!).


//#define CENTRE_BUFFER_ONCHIP  // if enabled, the center buffer is handled internally and the kernel does not access shared external memory

//#define VERBOSE				// more debug outputs in C simulation

#define FORCE_PROTOCOL_REGION	// enforce a strict I/O protocol for some code regions (this flag should be left enabled)

// shared memory bus width
#define DDR_BUS_WIDTH3 64
typedef ap_uint<DDR_BUS_WIDTH3> bus_type3;

#define COORD_BITWIDTH 16
#define COORD_BITWITDH_EXT 32
#define NODE_POINTER_BITWIDTH 32    // log2(2*N)
#define CNTR_INDEX_BITWIDTH 8       // log2(K)
#define CNTR_LIST_INDEX_BITWIDTH 32 // log2(N)


#define DRAM_REGION_SIZE (1<<30) // disjoint address spaces

// force register insertion in the generated RTL for some signals
//#define FORCE_REGISTERS

// pointer types to tree nodes and centre lists
typedef ap_uint<NODE_POINTER_BITWIDTH> node_pointer;
typedef ap_uint<CNTR_LIST_INDEX_BITWIDTH> centre_list_pointer;
typedef ap_uint<CNTR_INDEX_BITWIDTH> centre_index_type;



typedef unsigned int uint;
typedef ap_int<COORD_BITWIDTH> coord_type;
typedef ap_int<D*COORD_BITWIDTH> coord_type_vector;
typedef ap_int<COORD_BITWITDH_EXT> coord_type_ext;
typedef ap_int<D*COORD_BITWITDH_EXT> coord_type_vector_ext;

#define TREE_NODE_BITWIDTH (3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH+32)
#define STACK_RECORD_BITWIDTH (NODE_POINTER_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+CNTR_INDEX_BITWIDTH+1)

typedef ap_int<TREE_NODE_BITWIDTH> kdTree_type_val;
typedef ap_int<STACK_RECORD_BITWIDTH> stack_record_type_val;


// ... used for saturation
#define MAX_FIXED_POINT_VAL_EXT ((1<<(COORD_BITWITDH_EXT-1))-1)

//bit width definitions for multiplication
#define MUL_INTEGER_BITS 12
#define MUL_FRACTIONAL_BITS 6
#define MUL_MAX_VAL ((1<<(MUL_INTEGER_BITS+MUL_FRACTIONAL_BITS-1))-1)
#define MUL_MIN_VAL (-1*(1<<(MUL_INTEGER_BITS+MUL_FRACTIONAL_BITS-1)))
typedef ap_int<MUL_INTEGER_BITS+MUL_FRACTIONAL_BITS> mul_input_type;



// this should be always 1
#define FILE_INDEX 1


struct data_type {
    //coord_type value[D];
    coord_type_vector value;
    data_type() { }
    //data_type(data_type const volatile &a) { }
    data_type volatile & operator=(data_type const &a) volatile
    { value=a.value; return *this; }
    data_type & operator=(data_type const volatile &a)
    { value=a.value; return *this; }
    data_type & operator=(data_type const &a)
    { value=a.value; return *this; }
};

struct data_type_ext {
    //coord_type_ext value[D];
    coord_type_vector_ext value;
    data_type_ext() { }
    //data_type(data_type const volatile &a) { }
    data_type_ext volatile & operator=(data_type_ext const &a) volatile
    { value=a.value; return *this; }
    data_type_ext & operator=(data_type_ext const volatile &a)
    { value=a.value; return *this; }
    data_type_ext & operator=(data_type_ext const &a)
    { value=a.value; return *this; }
};


struct kdTree_type {
	kdTree_type_val value;
	kdTree_type() { }
	kdTree_type volatile & operator=(kdTree_type const &a) volatile
    {
		value = a.value;
		return *this;
    }
	kdTree_type & operator=(kdTree_type const volatile &a)
    {
		value = a.value;
		return *this;
    }
	kdTree_type & operator=(kdTree_type const &a)
    {
		value = a.value;
		return *this;
    }

};

struct centre_type {
    data_type_ext wgtCent; // sum of all points assigned to this centre
    coord_type_ext sum_sq; // sum of norm of all points assigned to this centre
    coord_type_ext count;
    centre_type() { }
    centre_type volatile & operator=(centre_type const &a) volatile
    { wgtCent=a.wgtCent; sum_sq=a.sum_sq; count=a.count; return *this; }
    centre_type & operator=(centre_type const volatile &a)
    { wgtCent=a.wgtCent; sum_sq=a.sum_sq; count=a.count; return *this; }
    centre_type & operator=(centre_type const &a)
    { wgtCent=a.wgtCent; sum_sq=a.sum_sq; count=a.count; return *this; }
};


// centre list idx heap
//typedef ap_uint<K*CNTR_INDEX_BITWIDTH> centre_index_set_type;
struct centre_heap_type {
	centre_index_type idx[K];
};


// stack
struct stack_record_type {
	stack_record_type_val value;
    stack_record_type volatile & operator=(const stack_record_type& a) volatile
    { value=a.value; return *this; }
    stack_record_type & operator=(const volatile stack_record_type& a)
    { value=a.value; return *this; }
    stack_record_type & operator=(const stack_record_type& a)
    { value=a.value; return *this; }
};


#define WORDS_PER_CENTRE_HEAP_TYPE K//#define WORDS_PER_STACK_RECORD 4
#define WORDS_PER_CENTRE_TYPE (D+2)



#ifdef FORCE_REGISTERS
template<class T>
T Reg(T in) {
        #pragma AP INLINE off
        #pragma AP INTERFACE port=return register
        return in;
}
#else
template<class T>
T Reg(T in) {
        #pragma AP INLINE
        return in;
}
#endif





void filtering_algorithm_top(   volatile kdTree_type *i_node_data,
								//volatile node_pointer *i_node_address,
								volatile kdTree_type *ddr_bus_0_0,
								volatile centre_index_type *ddr_bus_0_1,
								volatile stack_record_type *ddr_bus_0_2,
								volatile bus_type3 *ddr_bus_0_3,
								volatile bool *access_critical_region0,
								volatile kdTree_type *ddr_bus_1_0,
								volatile centre_index_type *ddr_bus_1_1,
								volatile stack_record_type *ddr_bus_1_2,
								volatile bus_type3 *ddr_bus_1_3,
								volatile bool *access_critical_region1,
								volatile kdTree_type *ddr_bus_2_0,
								volatile centre_index_type *ddr_bus_2_1,
								volatile stack_record_type *ddr_bus_2_2,
								volatile bus_type3 *ddr_bus_2_3,
								volatile bool *access_critical_region2,
								volatile kdTree_type *ddr_bus_3_0,
								volatile centre_index_type *ddr_bus_3_1,
								volatile stack_record_type *ddr_bus_3_2,
								volatile bus_type3 *ddr_bus_3_3,
								volatile bool *access_critical_region3,
								volatile centre_list_pointer *freelist_bus_0_1,
								volatile centre_list_pointer *freelist_bus_1_1,
								volatile centre_list_pointer *freelist_bus_2_1,
								volatile centre_list_pointer *freelist_bus_3_1,
                                volatile data_type *cntr_pos_init,
                                node_pointer n,
                                centre_index_type k,
                                uint l,
                                volatile node_pointer *root,
                                volatile coord_type_ext *distortion_out,
                                volatile data_type *clusters_out);




#endif  /* FILTERING_ALGORITHM_TOP_H */
