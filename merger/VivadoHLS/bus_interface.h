/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: bus_interface.h
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include "merger_top.h"


void data_record_type_to_bus(data_record in, uint address, volatile bus_type *bus);
void bus_to_data_record(volatile bus_type *bus, uint address, data_record *out);
