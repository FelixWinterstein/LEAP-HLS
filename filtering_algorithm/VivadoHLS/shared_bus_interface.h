/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: bus_interface.h
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

/*
 * The data width of LEAP coherent scratchpads for shared memory access is limited to 64 bits.
 * As opposed to private scratchpads which can have an arbitrary bitwidth, we must split the shared memory access
 * into 64bit chunks. This is done by the functions 'centre_type_to_bus' and 'bus_to_centre_type'.
 */

#include "filtering_algorithm_top.h"
#include "filtering_algorithm_util.h"


void centre_type_to_bus(centre_type in, uint address, volatile bus_type3 *bus);
void bus_to_centre_type(volatile bus_type3 *bus, uint address, centre_type *out);


