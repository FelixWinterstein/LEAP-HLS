/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: dyn_mem_alloc.h
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#ifndef _DYN_MEM_ALLOC_H_
#define _DYN_MEM_ALLOC_H_

#define NULL_PTR 0


template <class address_type>
address_type malloc(volatile address_type* flist, address_type* next_free_location)
{
    #pragma HLS inline
    address_type address = *next_free_location;
    *next_free_location = flist[(uint)address];

    return address;
}

template <class address_type>
void free(volatile address_type* flist, address_type* next_free_location, address_type address)
{
    #pragma HLS inline
    flist[(uint)address] = *next_free_location;
    *next_free_location = address;
}


#endif
