/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: main.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

#include "../design_files/hello_world.h"

int mem0[256];
int mem1[256];


template <class word_type>
void write_word_to_file (FILE *fp,word_type v)
{
	word_type v_tmp = v;

	for (int i=0; i<sizeof(word_type); i++) {
		unsigned char c = (unsigned char) v_tmp & ((1<<(sizeof(char)*8))-1);
		putc(c, fp);
		v_tmp = v_tmp >> (sizeof(char)*8);
	}
}


// write initialization files (.hex and binary .dat) for the scratchpad memories (used by LEAP)
bool write_init_file(int n, int *mem)
{
    FILE *fp;
    FILE *fp_hex;

    char filename[256];
    sprintf(filename,"initialization.dat");

    char filename_hex[256];
    sprintf(filename_hex,"initialization.hex");

    fp=fopen(filename, "wb");
    fp_hex=fopen(filename_hex, "w");

    if ((fp == NULL) || (fp_hex==NULL))
		return false;

	for (int i=0; i<n; i++) {
		write_word_to_file<int>(fp,mem[i]);
	}

	for (int i=0; i<n; i++) {

		char intStr[256];
		sprintf(intStr,"%08x",mem[i]);
    	fprintf(fp_hex,"%s\n",intStr);
    }

    fclose(fp);
    fclose(fp_hex);

    return true;
}


int main () {

	// only mem0 must be initialized
	for (int i=0; i<256; i++)
		mem0[i] = i;

	// write .hex and .dat initialization files
    write_init_file(256, mem0);

    // run kernel
	hello_world(mem0,mem1);

	// print results written to mem1
	for (int i=0; i<256; i++)
		printf("%d\n", mem1[i]);


	return 0;
}
