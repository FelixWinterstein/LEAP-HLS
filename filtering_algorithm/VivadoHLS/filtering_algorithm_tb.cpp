/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: filtering_algorithm_tb.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "filtering_algorithm_top.h"
#include "filtering_algorithm_util.h"
#include "build_kdTree.h"


#define TREE_HEAP_SIZE_SIM 2*N       	// max size of simulated heap memory for the kd-tree (2*n tree nodes)

// memory for the input data (data points, tree, and initial centers)
kdTree_type bt_heap[TREE_HEAP_SIZE_SIM];
uint idx[N];
data_type data_points[N];
uint cntr_indices[K];
data_type initial_centre_positions[K];
kdTree_type tree_image[TREE_HEAP_SIZE_SIM];
node_pointer tree_image_addr[TREE_HEAP_SIZE_SIM];

// simulated disjoint heap regions
kdTree_type heap_0_0[TREE_HEAP_SIZE_SIM];
centre_index_type heap_0_1[TREE_HEAP_SIZE_SIM];
stack_record_type heap_0_2[TREE_HEAP_SIZE_SIM];
kdTree_type heap_1_0[TREE_HEAP_SIZE_SIM];
centre_index_type heap_1_1[TREE_HEAP_SIZE_SIM];
stack_record_type heap_1_2[TREE_HEAP_SIZE_SIM];
kdTree_type heap_2_0[TREE_HEAP_SIZE_SIM];
centre_index_type heap_2_1[TREE_HEAP_SIZE_SIM];
stack_record_type heap_2_2[TREE_HEAP_SIZE_SIM];
kdTree_type heap_3_0[TREE_HEAP_SIZE_SIM];
centre_index_type heap_3_1[TREE_HEAP_SIZE_SIM];
stack_record_type heap_3_2[TREE_HEAP_SIZE_SIM];

// we only need a small address space for the shared memory region
bus_type3 heap_coh_3[5*K];

// simulated lock acquire/release control
bool access_critical_region0;
bool access_critical_region1;
bool access_critical_region2;
bool access_critical_region3;

void make_clusters_out_file_name(char *result, uint n, uint k, uint d, double std_dev, bool hex)
{
	if (!hex)
		sprintf(result,"../../../../golden_ref/clusters_out_N%d_K%d_D%d_s%.2f.mat",n,k,d,std_dev);
	else
		sprintf(result,"../../../../golden_ref/clusters_out_N%d_K%d_D%d_s%.2f.hex",n,k,d,std_dev);
}

void make_distortion_out_file_name(char *result, uint n, uint k, uint d, double std_dev, bool hex)
{
	if (!hex)
		sprintf(result,"../../../../golden_ref/distortion_out_N%d_K%d_D%d_s%.2f.mat",n,k,d,std_dev);
	else
		sprintf(result,"../../../../golden_ref/distortion_out_N%d_K%d_D%d_s%.2f.hex",n,k,d,std_dev);
}

// recursively split the kd-tree into P sub-trees (P is parallelism degree)
void recursive_split(uint p,
                    uint n,
                    data_type bnd_lo,
                    data_type bnd_hi,
                    uint *idx,
                    uint index,
                    data_type *data_points,
                    uint *i,
                    uint *ofs,
                    node_pointer *root,
                    kdTree_type *heap,
                    kdTree_type *tree_image,
                    node_pointer *tree_image_addr,
                    uint n0,
                    uint k,
                    double std_dev)
{
    if (p==P) {
        printf("Sub-tree %d: %d data points\n",*i,n);
        node_pointer rt = buildkdTree(data_points, idx, index, n, &bnd_lo, &bnd_hi, 0, heap);
        root[*i] = rt;
        uint offset = *ofs;
        readout_tree(true, n0, k, std_dev, rt, heap, offset, *i, tree_image, tree_image_addr);
        *i = *i + 1;
        *ofs = *ofs + 2*n-1;
    } else {
        uint cdim;
        coord_type cval;
        uint n_lo;
        split_bounding_box(data_points, idx, index, n, &bnd_lo, &bnd_hi, &n_lo, &cdim, &cval);
        // update bounding box
        data_type new_bnd_hi = bnd_hi;
        data_type new_bnd_lo = bnd_lo;
        set_coord_type_vector_item(&new_bnd_hi.value,cval,cdim);
        set_coord_type_vector_item(&new_bnd_lo.value,cval,cdim);

        recursive_split(p*2, n_lo, bnd_lo, new_bnd_hi, idx, index, data_points,i,ofs,root, heap,tree_image,tree_image_addr,n0,k,std_dev);
        recursive_split(p*2, n-n_lo, new_bnd_lo, bnd_hi, idx, index+n_lo, data_points,i,ofs,root, heap,tree_image,tree_image_addr,n0,k,std_dev);
    }

}


int main()
{
	// select input data set (read form the .mat files in VivadoHLS/golden_ref)
    const uint n = 128;//32768;//16384;
    const uint k = 4;//256;//128;
    const double std_dev = 0.75;//0.15;//0.20;


    const uint l = 1;

    // read data points from file
    if (read_data_points(n,k,std_dev,data_points,idx) == false)
        return 1;

    // read intial centre from file (random placement
    if (read_initial_centres(n,k,std_dev,initial_centre_positions,cntr_indices) == false)
        return 1;

    // print initial centres
    printf("Initial centres\n");
    for (uint i=0; i<k; i++) {
        printf("%d: ",i);
        for (uint d=0; d<D-1; d++) {
            printf("%d ",get_coord_type_vector_item(initial_centre_positions[i].value, d).to_int());
        }
        printf("%d\n",get_coord_type_vector_item(initial_centre_positions[i].value, D-1).to_int());
    }

    write_initial_centres(n,k,std_dev,initial_centre_positions);

    // compute axis-aligned hyper rectangle enclosing all data points
    data_type bnd_lo, bnd_hi;
    uint index = 0;
    compute_bounding_box(data_points, idx, index, n, &bnd_lo, &bnd_hi);

    node_pointer root[P];

	uint z=0;
	uint ofs=0;

	// build P sub-trees
    recursive_split(1, n, bnd_lo, bnd_hi, idx, index, data_points, &z, &ofs, root, bt_heap,tree_image, tree_image_addr, n, k, std_dev);


    data_type clusters_out[K];
    coord_type_ext distortion_out[K];

    // run the clustering kernel
    filtering_algorithm_top(tree_image,
    						heap_0_0,
    						heap_0_1,
    						heap_0_2,
    						heap_coh_3,
    						&access_critical_region0,
    						heap_1_0,
    						heap_1_1,
    						heap_1_2,
							#if P>1
    						heap_coh_3,
							#else
    						NULL,
							#endif
    						&access_critical_region1,
    						heap_2_0,
    						heap_2_1,
    						heap_2_2,
							#if P>2
							heap_coh_3,
							#else
							NULL,
							#endif
							&access_critical_region2,
    						heap_3_0,
    						heap_3_1,
    						heap_3_2,
							#if P>3
							heap_coh_3,
							#else
							NULL,
							#endif
							&access_critical_region3,
    						initial_centre_positions, 2*n-1-1-(P-1), k-1, l, root, distortion_out, clusters_out);



    // print clustering result
    printf("New centres after clustering\n");

    for (uint i=0; i<k; i++) {
        printf("%d: ",i);
        for (uint d=0; d<D-1; d++) {
            printf("%d ",get_coord_type_vector_item(clusters_out[i].value, d).VAL);
        }
        printf("%d, ",get_coord_type_vector_item(clusters_out[i].value, D-1).VAL);

        printf("%lld\n",distortion_out[i].to_int64());

    }


    // write clustering results to file for comparison with the LEAP output
	char filename[256];
	make_clusters_out_file_name(filename,n,k,D,std_dev,true);
	FILE *fpclusters = fopen(filename, "w");

	make_distortion_out_file_name(filename,n,k,D,std_dev,true);
	FILE *fpdistortion = fopen(filename, "w");

	for (uint i=0; i<k; i++) {
		// verilog hex format
		std::string str = clusters_out[i].value.to_string(16,false);
		str.erase(0,2);
		fprintf(fpclusters,"%s\n",str.c_str());

		str = distortion_out[i].to_string(16,false);
		str.erase(0,2);
		fprintf(fpdistortion,"%s\n",str.c_str());
	}

	fclose(fpclusters);
	fclose(fpdistortion);

    return 0;
}
