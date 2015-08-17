/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: bus_interface.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include "bus_interface.h"
#include "ap_utils.h"


void data_record_type_to_bus(data_record in, uint address, volatile bus_type *bus)
{
	#pragma HLS inline

	bus_type tmp;

	tmp.value.range(31,0) = in.k;
	tmp.value.range(63,32) = in.n;

	bus[address] = tmp;

}


void bus_to_data_record(volatile bus_type *bus, uint address, data_record *out)
{
	#pragma HLS inline

	bus_type tmp;
	tmp.value = bus[address].value;


	out->k = tmp.value.range(31,0);
	out->n = tmp.value.range(63,32);
}






