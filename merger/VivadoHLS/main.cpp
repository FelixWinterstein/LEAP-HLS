
#include "mem_test_top.h"

int main () {

	int data_in[32];
	int data_out[32];

	int mem[1024];

	for (int i=0; i<32; i++)
		data_in[i] = i;



	mem_test_top(data_in, mem, data_out);

	for (int i=0; i<32; i++)
		printf("%d\n", data_out[i]);


	return 0;
}
