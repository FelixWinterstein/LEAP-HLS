/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: stack.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include "stack.h"
#include "filtering_algorithm_util.h"

void init_stack(uint *stack_pointer)
{
    #pragma HLS inline
    *stack_pointer = 0;

}


// push pointer to tree node pointer onto stack
uint push(node_pointer u, centre_list_pointer c, centre_index_type k,  bool d, uint *stack_pointer, stack_record_type* stack_array)
{
    uint tmp = *stack_pointer;

    stack_record_type data;
    set_stack_record_type_items(&data,u,c,k,d);

    stack_array[tmp] = data;

    tmp++;
    *stack_pointer=tmp;
    return tmp;
}

// push pointer to tree node pointer onto stack (overloaded function)
uint push(node_pointer u, centre_list_pointer c, centre_index_type k,  bool d, uint *stack_pointer, volatile stack_record_type* stack_array)
{
	#pragma HLS inline

    uint tmp = *stack_pointer;

    stack_record_type data;

    set_stack_record_type_items(&data,u,c,k,d);

    //printf("%s\n", data.value.toStringUnsigned(16).c_str());

    stack_array[tmp] = data;

    tmp++;
    *stack_pointer=tmp;
    return tmp;
}

// pop pointer to tree node pointer from stack
uint pop(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, stack_record_type* stack_array)
{
    uint tmp = *stack_pointer-1;

    stack_record_type data;
    data = stack_array[tmp];

    get_stack_record_type_items(data,u,c,k,d);

    *stack_pointer = tmp;
    return tmp;
}


// pop pointer to tree node pointer from stack (overloaded function)
uint pop(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, volatile stack_record_type* stack_array)
{
	#pragma HLS inline

    uint tmp = *stack_pointer-1;

    stack_record_type data;
    data = stack_array[tmp];

    get_stack_record_type_items(data,u,c,k,d);

    *stack_pointer = tmp;
    return tmp;
}


// look up head of node stack
uint lookahead(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, stack_record_type* stack_array)
{

	#pragma HLS inline
    uint tmp = *stack_pointer-1;

    stack_record_type data;
    data = stack_array[tmp];

    get_stack_record_type_items(data,u,c,k,d);

    return tmp;
}

// look up head of node stack (overloaded function)
uint lookahead(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, volatile stack_record_type* stack_array)
{
    uint tmp = *stack_pointer-1;

    stack_record_type data;
    data = stack_array[tmp];

    get_stack_record_type_items(data,u,c,k,d);

    return tmp;
}

