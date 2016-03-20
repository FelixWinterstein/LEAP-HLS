
#include "../design_files/merger_top.h"
#include <stdio.h>
#include <stdlib.h>

#define N 8192

int val0[N];
int val1[N];
int val2[N];
int val3[N];

int dout[4*N];

#ifndef PARALLEL_VERSION

// for C simulation
data_record data_mem_0[4*N*2];
pointer_type freelist_bus_0[4*N*2];

#else

// for C simulation
data_record data_mem_0[N*2];
data_record data_mem_1[N*2];
data_record data_mem_2[N*2];
data_record data_mem_3[N*2];
pointer_type freelist_bus_0[N*2];
pointer_type freelist_bus_1[N*2];
pointer_type freelist_bus_2[N*2];
pointer_type freelist_bus_3[N*2];

#endif


bool read_data_file(int n, int* data_1, int* data_2, int* data_3, int* data_4)
{
    FILE *fp;

    char filename[256];
    sprintf(filename,"%dx4_random_numbers.mat",n);

    fp=fopen(filename, "r");

    int i,j;

    for (j=0; j<4; j++) {
        for (i=0;i<n;i++) {
        	char tmp[16];
            if (fgets(tmp,16,fp) == 0) {
                fclose(fp);
                return false;
            } else {

				switch (j) {
				case 0:
					data_1[i]=atoi(tmp);
					break;
				case 1:
					data_2[i]=atoi(tmp);
					break;
				case 2:
					data_3[i]=atoi(tmp);
					break;
				default:
					data_4[i]=atoi(tmp);
					break;
				}

            }
        }
    }

    fclose(fp);

    return true;
}



template <class word_type>
void write_word_to_file (FILE *fp,word_type v)
{
	word_type v_tmp = v;

	for (uint i=0; i<sizeof(word_type); i++) {
		unsigned char c = (unsigned char) v_tmp & ((1<<(sizeof(char)*8))-1);
		putc(c, fp);
		v_tmp = v_tmp >> (sizeof(char)*8);
	}
}



template <class word_type>
bool write_data_file(int n, word_type* data_1, word_type* data_2, word_type* data_3, word_type* data_4)
{
    FILE *fp;

    char filename[256];
    sprintf(filename,"%dx%d_random_numbers.dat",n,4);

    fp=fopen(filename, "wb");
    if (fp == NULL)
		return false;

	for (uint i=0; i<n; i++) {
		write_word_to_file<word_type>(fp,data_1[i]);
		write_word_to_file<word_type>(fp,data_2[i]);
		write_word_to_file<word_type>(fp,data_3[i]);
		write_word_to_file<word_type>(fp,data_4[i]);
	}
	for (uint i=0; i<n; i++) {
		write_word_to_file<word_type>(fp,0);
		write_word_to_file<word_type>(fp,0);
		write_word_to_file<word_type>(fp,0);
		write_word_to_file<word_type>(fp,0);
	}

    fclose(fp);


    return true;
}


// write a binary initialization file for the freelist scratchpad memories (used by LEAP)
bool write_freelist_init_file(pointer_type n)
{
    FILE *fp;
    FILE *fp_hex;

    char filename[256];
    sprintf(filename,"freelist_initialization.dat");

    char filename_hex[256];
    sprintf(filename_hex,"freelist_initialization.hex");

    fp=fopen(filename, "wb");
    fp_hex=fopen(filename_hex, "w");

    if ((fp == NULL) || (fp_hex==NULL))
		return false;

	#ifdef PARALLEL_VERSION
		for (int p=0; p<4; p++) {
			for (pointer_type i=0; i<n; i++) {
				write_word_to_file<pointer_type>(fp,i+1);
			}
		}
	#else
		for (pointer_type i=0; i<n; i++) {
			write_word_to_file<pointer_type>(fp,i+1);
		}
	#endif

	for (pointer_type i=0; i<n; i++) {

		char intStr[256];
		sprintf(intStr,"%08x",i+1);
    	fprintf(fp_hex,"%s\n",intStr);
    }

    fclose(fp);
    fclose(fp_hex);

    return true;
}



int main () {

	srand (1);

	// generate 4 random input sample streams
	for (uint i=0; i<N; i++) {
		val0[i] = rand() % 65536;
		val1[i] = rand() % 65536;
		val2[i] = rand() % 65536;
		val3[i] = rand() % 65536;
	}

	// initialize the freelists used by the dynamic memory allocator (only in C simulation)
	#ifndef PARALLEL_VERSION
	for (pointer_type i=0; i<4*N*2; i++) {
		freelist_bus_0[i] = i+1;
	}
	#else
	for (pointer_type i=0; i<N*2; i++) {
		freelist_bus_0[i] = i+1;
		freelist_bus_1[i] = i+1;
		freelist_bus_2[i] = i+1;
		freelist_bus_3[i] = i+1;
	}
	#endif


	// write a freelist initialization file used by the dynamic memory allocator (in hardware)
	if (!write_freelist_init_file(262144)) // set this number to the maximum number of heap-allocated data records per partition
		return 1;

	printf("start run...\n");

	#ifndef PARALLEL_VERSION
	merger_top(	N,
				data_mem_0,
				freelist_bus_0,
				val0, val1, val2, val3, dout);
	#else
	merger_top(	N,
				data_mem_0,
				data_mem_1,
				data_mem_2,
				data_mem_3,
				freelist_bus_0,
				freelist_bus_1,
				freelist_bus_2,
				freelist_bus_3,
				val0, val1, val2, val3, dout);
	#endif

    printf("\ndone\n");

	return 0;
}
