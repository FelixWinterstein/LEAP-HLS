/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: stack.h
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#ifndef STACK_H
#define STACK_H

#include "filtering_algorithm_top.h"

void init_stack(uint *stack_pointer);
uint push(node_pointer u, centre_list_pointer c, centre_index_type k,  bool d, uint *stack_pointer, stack_record_type* stack_array);
uint push(node_pointer u, centre_list_pointer c, centre_index_type k,  bool d, uint *stack_pointer, volatile stack_record_type* stack_array);
uint pop(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, stack_record_type* stack_array);
uint pop(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, volatile stack_record_type* stack_array);
uint lookahead(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, stack_record_type* stack_array);
uint lookahead(node_pointer *u, centre_list_pointer *c, centre_index_type *k, bool *d, uint *stack_pointer, volatile stack_record_type* stack_array);


#endif
