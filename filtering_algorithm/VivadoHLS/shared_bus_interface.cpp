/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: bus_interface.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include "shared_bus_interface.h"

/*
 * The data width of LEAP coherent scratchpads for shared memory access is limited to 64 bits.
 * As opposed to private scratchpads which can have an arbitrary bitwidth, we must split the shared memory access
 * into 64bit chunks. This is done by the functions 'centre_type_to_bus' and 'bus_to_centre_type'.
 */

void centre_type_to_bus(centre_type in, uint address, volatile bus_type3 *bus)
{
	#pragma HLS inline

	bus_type3 data;
	uint addr;

	for (uint d=0; d<D; d++) {
		#pragma HLS unroll
		data = (bus_type3)in.wgtCent.value.range((d+1)*COORD_BITWITDH_EXT-1,d*COORD_BITWITDH_EXT);
		my_wait();
		addr = address*WORDS_PER_CENTRE_TYPE;
		my_wait();
		addr = addr + d;
		my_wait();
		bus[addr] = data;
		my_wait();
	}

	data = (bus_type3)in.sum_sq;
	addr = address*WORDS_PER_CENTRE_TYPE;
	my_wait();
	addr = addr + D;
	my_wait();
	bus[addr] = data;
	my_wait();

	data = (bus_type3)in.count;
	addr = address*WORDS_PER_CENTRE_TYPE;
	my_wait();
	addr = addr + D+1;
	my_wait();
	bus[addr] = data;
	my_wait();


}

void bus_to_centre_type(volatile bus_type3 *bus, uint address, centre_type *out)
{
	#pragma HLS inline

	bus_type3 data;
	uint addr;

	for (uint d=0; d<D; d++) {
		#pragma HLS unroll
		addr = address*WORDS_PER_CENTRE_TYPE;
		my_wait();
		addr = addr + d;
		my_wait();
		data = bus[addr];
		my_wait();
		out->wgtCent.value((d+1)*COORD_BITWITDH_EXT-1,d*COORD_BITWITDH_EXT) = (coord_type_ext)data;
		my_wait();
	}

	addr = address*WORDS_PER_CENTRE_TYPE;
	my_wait();
	addr = addr + D;
	my_wait();
	data = bus[addr];
	my_wait();
	out->sum_sq = (coord_type_ext)data;

	addr = address*WORDS_PER_CENTRE_TYPE;
	my_wait();
	addr = addr + D+1;
	my_wait();
	data = bus[addr];
	my_wait();
	out->count = (coord_type_ext)data;

}

