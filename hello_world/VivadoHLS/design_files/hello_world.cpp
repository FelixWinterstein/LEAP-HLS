/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: hello_world.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

#include "hello_world.h"


void hello_world(volatile int *bus0, volatile int *bus1)
{
	#pragma HLS INTERFACE ap_bus port=bus0
	#pragma HLS INTERFACE ap_bus port=bus1


	// internal block RAM
	int buffer[256];

	// read from bus0
	for (int i=0; i<256; i++)
		buffer[i] = bus0[i];

	// write to bus1
	for (int i=0; i<256; i++)
		bus1[i] = buffer[i]*buffer[i];


}
