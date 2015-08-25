/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: filtering_algorithm_top.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include "filtering_algorithm_top.h"
#include "filtering_algorithm_util.h"
#include "dyn_mem_alloc.h"
#include "stack.h"
#include "shared_bus_interface.h"


#ifndef __SYNTHESIS__
#include <stdio.h>
#include <stdlib.h>
#endif



// update the new centre positions after one outer clustering iteration
void update_centres(centre_type *centres_in,centre_index_type k, data_type *centres_positions_out)
{
    //#pragma HLS inline
    centre_update_loop: for (centre_index_type i=0; i<=k; i++) {
        #pragma HLS pipeline II=2

    	coord_type_ext tmp_count = centres_in[i].count;
        if ( tmp_count == 0 )
            tmp_count = 1;

        data_type_ext tmp_wgtCent = centres_in[i].wgtCent;
        data_type tmp_new_pos;
        for (uint d=0; d<D; d++) {
            #pragma HLS unroll
            coord_type_ext tmp_div_ext = (get_coord_type_vector_ext_item(tmp_wgtCent.value,d) / tmp_count); //let's see what it does with that...
            coord_type tmp_div = (coord_type) tmp_div_ext;
            #pragma HLS resource variable=tmp_div core=DivnS
            set_coord_type_vector_item(&tmp_new_pos.value,tmp_div,d);
        }
        centres_positions_out[i] = tmp_new_pos;
        if (i==k) {
            break;
        }
    }
}


void init_tree_node_memory(	volatile kdTree_type *i_node_data,
							node_pointer n,
							volatile kdTree_type *ddr_bus_0_0,
							volatile kdTree_type *ddr_bus_1_0,
							volatile kdTree_type *ddr_bus_2_0,
							volatile kdTree_type *ddr_bus_3_0
							)
{

	#pragma HLS inline

    init_nodes_loop: for (node_pointer i=0; i<=n; i++) {

        kdTree_type tmp_node;
        tmp_node = i_node_data[i];

        uint idx;
        data_type_ext dummy_wgtCent;
        data_type dummy_midPoint;
        data_type dummy_bnd_hi, dummy_bnd_lo;
        coord_type_ext dummy_sum_sq;
        coord_type_ext dummy_count;
        node_pointer dummy_left, dummy_right;
        get_kd_tree_type_items(	tmp_node,
        						&idx,
        						&dummy_wgtCent,
        						&dummy_midPoint,
        						&dummy_bnd_hi,
        						&dummy_bnd_lo,
        						&dummy_sum_sq,
        						&dummy_count,
        						&dummy_left,
        						&dummy_right);

        uint node_address = idx;

        uint region = uint(node_address) >> (uint(ceil(log2(DRAM_REGION_SIZE))));
        uint tmp_node_address = uint(node_address) & ((1<<uint(ceil(log2(DRAM_REGION_SIZE))))-1);

        uint tmp_addr = uint(tmp_node_address) ;

        switch (region) {
        case 0:
        	ddr_bus_0_0[tmp_addr] = tmp_node;
        	break;
		#if P>1
        case 1:
        	ddr_bus_1_0[tmp_addr] = tmp_node;
        	break;
		#endif
		#if P>2
        case 2:
        	ddr_bus_2_0[tmp_addr] = tmp_node;
        	break;
		#endif
		#if P>3
        case 3:
        	ddr_bus_3_0[tmp_addr] = tmp_node;
        	break;
		#endif
        }
    }
}


void init_centre_buffer(	centre_index_type k,
							volatile bus_type3 *ddr_bus_0_3,
							volatile bus_type3 *ddr_bus_1_3,
							volatile bus_type3 *ddr_bus_2_3,
							volatile bus_type3 *ddr_bus_3_3,
							volatile bool *access_critical_region0,
							volatile bool *access_critical_region1,
							volatile bool *access_critical_region2,
							volatile bool *access_critical_region3
							)
{

	#pragma HLS inline

    init_centre_buffer_loop0: for (centre_index_type i=0; i<=k; i++) {
    	// There seems to be a problem with Vivado's scheduler:
    	// We need "HLS protocol fixed" here because Vivado's scheduler may
    	// reorder access_critical_region0 and shared memory accesses (despite the volatile keyword)
    	// However, there are other code regions in this file which access the shared memory bus as well, but
    	// do not need/allow a fixed protocol region. The issue is currently being investigated.
        region0: {
			#ifdef FORCE_PROTOCOL_REGION
			#pragma HLS protocol fixed
			#endif

        	*access_critical_region0 = true;
        	my_wait();
        	centre_type tmp;
        	tmp.count = 0;
        	tmp.sum_sq = 0;
        	tmp.wgtCent.value = 0;
        	/*
        	 * The data width of LEAP coherent scratchpads for shared memory access is limited to 64 bits.
        	 * As opposed to private scratchpads which can have an arbitrary bitwidth, we must split the shared memory access
        	 * into 64bit chunks. This is done by the functions 'centre_type_to_bus' and 'bus_to_centre_type'.
        	 */
        	centre_type_to_bus(tmp, (uint)i, ddr_bus_0_3);
        	my_wait();
        	*access_critical_region0 = false;
        	my_wait();
			if (i==k) {
				break;
			}
        }
    }
}



//helper functions

template<uint par> void prune_centre_set(	volatile centre_index_type *bus,
											centre_list_pointer centre_set_in,
											centre_list_pointer centre_set_out,
											centre_index_type k,
											//centre_index_type *centre_indices_in,
											data_type (*centre_positions)[K],
											data_type u_bnd_hi,
											data_type u_bnd_lo,
											data_type z_star,
											//centre_index_type *centre_set_out,
											centre_index_type *k_out
											)
{
	#pragma HLS inline

    //copy candidates that survive pruning into new list
    centre_index_type new_k=(1<<CNTR_INDEX_BITWIDTH)-1;
    //centre_index_type new_k=0;
    centre_index_type tmp_new_idx=0;

    // determine whether a sub-tree will be pruned
    tooFar_loop: for (centre_index_type i=0; i<=k; i++) {
        //#pragma HLS pipeline II=1
        bool too_far;
        //centre_index_type tmp_index = centre_indices_in[i];
        uint addr_in = ((uint)centre_set_in)*WORDS_PER_CENTRE_HEAP_TYPE + (uint)i;
        centre_index_type tmp_index = bus[addr_in];

        data_type position = centre_positions[par][tmp_index];
        tooFar_fi(z_star, position, u_bnd_lo, u_bnd_hi, &too_far);
        if ( too_far==false ) {

        	uint addr_out =  ((uint)centre_set_out)*WORDS_PER_CENTRE_HEAP_TYPE + (uint)tmp_new_idx;
        	bus[addr_out] = tmp_index;
        	//centre_set_out[tmp_new_idx] = tmp_index;


			#ifdef VERBOSE
			#ifndef __SYNTHESIS__
			printf("%d ", tmp_index.VAL);
			#endif
			#endif

            tmp_new_idx++;
            new_k++;
        }
        if (i==k) {
            break;
        }
    }

    *k_out = new_k;
}

template<uint par> void minsearch(	volatile centre_index_type *bus,
									centre_list_pointer centre_set_in,
									centre_index_type k,
									//centre_index_type *centre_set,
									data_type_ext comp_point,
									data_type (*centre_positions)[K],
									centre_index_type *min_index,
									data_type *z_star
									//centre_index_type *centre_indices_out
									)
{
	#pragma HLS inline

	centre_index_type tmp_final_idx;
	data_type tmp_z_star;
	coord_type_ext tmp_min_dist;
	tmp_min_dist = (1<<(COORD_BITWITDH_EXT-1))-1;

	// find centre with smallest distance to z_star
	minsearch_loop: for (centre_index_type i=0; i<=k; i++) {
		//#pragma HLS pipeline II=1

		//centre_index_type tmp_index = centre_set[i];
        uint addr_in = ((uint)centre_set_in)*WORDS_PER_CENTRE_HEAP_TYPE + (uint)i;
        centre_index_type tmp_index = bus[addr_in];

		#ifdef VERBOSE
		#ifndef __SYNTHESIS__
		printf("%d ", tmp_index.VAL);
		#endif
		#endif

		coord_type_ext tmp_dist;
		data_type position = centre_positions[par][tmp_index];

		//tmp_centre_positions_2[i] = position;
		compute_distance(conv_short_to_long(position), comp_point, &tmp_dist);

		if ((tmp_dist < tmp_min_dist) ) {
			tmp_min_dist = tmp_dist;
			tmp_final_idx = tmp_index;
			tmp_z_star = position;
		}

		//centre_indices_out[i] = tmp_index;

		if (i==k) {
			break;
		}
	}

	#ifdef VERBOSE
	#ifndef __SYNTHESIS__
	printf(" # ");
	#endif
	#endif

	*z_star = tmp_z_star;
	*min_index = tmp_final_idx;
}

template<uint par> void calculate_distortion(data_type_ext u_wgtCent,
											coord_type_ext u_count,
											coord_type_ext u_sum_sq,
											data_type z_star,
											coord_type_ext *sum_sq_out)
{
	#pragma HLS inline
    // some scaling...
    data_type_ext tmp_wgtCent = u_wgtCent;
    for (uint d=0; d<D; d++) {
        #pragma HLS unroll
        coord_type_ext tmp = get_coord_type_vector_ext_item(tmp_wgtCent.value,d);
        tmp = tmp >> MUL_FRACTIONAL_BITS;
        set_coord_type_vector_ext_item(&tmp_wgtCent.value,tmp,d);
    }

    // z_star == tmp_centre_positions[idx_closest] !
    // update sum_sq of centre
    coord_type_ext tmp1_2, tmp2_2;
    data_type_ext tmp_z_star = conv_short_to_long(z_star);
    dot_product(tmp_z_star,tmp_wgtCent,&tmp1_2);
    dot_product(tmp_z_star,tmp_z_star ,&tmp2_2);
    coord_type_ext tmp1, tmp2;
    tmp1 = tmp1_2<<1;
    tmp2 = tmp2_2>>1;//>>MUL_FRACTIONAL_BITS;
    coord_type_ext tmp_count = u_count;
    coord_type_ext tmp2_sat = saturate_mul_input(tmp2);
    coord_type_ext tmp_count_sat = saturate_mul_input(tmp_count);
    coord_type_ext tmp3 = tmp2_sat*tmp_count_sat;
    coord_type_ext tmp_sum_sq1 = u_sum_sq+tmp3;
    coord_type_ext tmp_sum_sq = tmp_sum_sq1-tmp1;
    #pragma HLS resource variable=tmp3 core=MulnS
    *sum_sq_out = tmp_sum_sq;
}

template<uint par> void process_node(	volatile centre_index_type *bus,
										centre_list_pointer centre_set_in,
										centre_list_pointer centre_set_out,
										centre_index_type k,
										data_type_ext u_wgtCent,
										data_type u_midPoint,
										data_type u_bnd_hi,
										data_type u_bnd_lo,
										coord_type_ext u_sum_sq,
										coord_type_ext u_count,
										node_pointer u_left,
										node_pointer u_right,
										//centre_index_type *centre_set_data,
										data_type (*centre_positions)[K],
										centre_index_type *k_out,
										//centre_index_type *centre_indices_out,
										centre_index_type *final_centre_index,
										coord_type_ext *sum_sq_out,
										bool *dead_end )
{
	#pragma HLS inline
    centre_index_type tmp_k = k;

    centre_index_type tmp_centre_indices[K];

    bool tmp_deadend;
    centre_index_type tmp_final_centre_index;
    coord_type_ext tmp_sum_sq_out;
    centre_index_type tmp_k_out;

    // leaf node?
    data_type_ext comp_point;
    if ( (u_left == NULL_PTR) && (u_right == NULL_PTR) ) {
        comp_point = u_wgtCent;
    } else {
        comp_point = conv_short_to_long(u_midPoint);
    }


    centre_index_type tmp_final_idx;
    data_type z_star;

    minsearch<par>(	bus,
    				centre_set_in,
    				tmp_k,
    				//centre_set_data,
					comp_point,
					centre_positions,
					&tmp_final_idx,
					&z_star
					//tmp_centre_indices
					);

    centre_index_type new_k;
    prune_centre_set<par>( 	bus,
    						centre_set_in,
    						centre_set_out,
    						tmp_k,
							//tmp_centre_indices,
							centre_positions,
							u_bnd_hi,
							u_bnd_lo,
							z_star,
							//centre_indices_out,
							&new_k );

    coord_type_ext tmp_sum_sq;
    calculate_distortion<par>( u_wgtCent,
							u_count,
							u_sum_sq,
							z_star,
							&tmp_sum_sq);

    //bool tmp_deadend;
    if ((new_k == 0) || ( (u_left == NULL_PTR) && (u_right == NULL_PTR) )) {
        tmp_deadend = true;
    } else {
        tmp_deadend = false;
    }

    *k_out = new_k;
    *final_centre_index = tmp_final_idx;
    *sum_sq_out = tmp_sum_sq;
    *dead_end = tmp_deadend;

}


// main clustering kernel
template<uint par> void filter (node_pointer root,
						 volatile kdTree_type *ddr_bus_0, // tree nodes
						 volatile centre_index_type *ddr_bus_1, // centres
						 volatile stack_record_type *ddr_bus_2, // stack
						 volatile bus_type3 *ddr_bus_3, // centreRecords
						 volatile centre_list_pointer *freelist_bus_1, // freelist for centres
						 centre_index_type k,
						 data_type (*centre_positions)[K],
						 centre_type (*centres_out)[K],
						 volatile bool *access_critical_region)
{

	#ifndef __SYNTHESIS__
	uint visited_nodes = 0;
	uint allocated_centre_sets = 1;
	uint max_allocated_centre_sets = 1;
	#endif

	// centre buffer
	#ifdef CENTRE_BUFFER_ONCHIP
    centre_type centre_buffer[K];
    #pragma HLS resource variable=centre_buffer core=RAM_2P_LUTRAM


    // init centre buffer
    init_centre_buffer_loop: for(centre_index_type i=0; i<=k; i++) {
        //#pragma HLS pipeline II=1
    	centre_type tmp;
    	tmp.count = 0;
    	tmp.sum_sq = 0;
    	tmp.wgtCent.value = 0;

        centre_buffer[i] = tmp;

        if (i==k) {
            break;
        }
    }
	#endif


    // dynamic memory allocation
    centre_list_pointer centre_next_free_location = 1;

    // init dynamic memory allocator for centre lists scratchpad heap
    //init_allocator<centre_list_pointer>(freelist_bus_1, &centre_next_free_location, CENTRESET_HEAP_SIZE-2);


    // stack pointer
    uint stack_pointer;
    init_stack(&stack_pointer);
    uint node_stack_length;

    centre_list_pointer centre_list_idx;

    // new centre_list_idx
    centre_list_idx = malloc<centre_list_pointer>(freelist_bus_1, &centre_next_free_location);

	// write the malloc'ed data set to the first valid address
    init_centre_list_loop: for(centre_index_type i=0; i<=k; i++) {
        //#pragma HLS pipeline II=1
    	uint addr = ((uint)centre_list_idx*WORDS_PER_CENTRE_HEAP_TYPE) + (uint)i;
    	ddr_bus_1[addr] = i;

        if (i==k) {
            break;
        }
    }


	// push pointers to tree root node and first centre list onto the stack
	node_stack_length = push(root, centre_list_idx, k,  true, &stack_pointer, ddr_bus_2);


    // main tree search loop
    tree_search_loop: while (node_stack_length != 0) {


        // fetch head of stack
        node_pointer u;
		centre_list_pointer centre_set_in,centre_set_out;
		centre_index_type tmp_k;
		bool rdy_for_deletion;

        // fetch pointer to centre list
       	node_stack_length = pop(&u, &centre_set_in, &tmp_k, &rdy_for_deletion, &stack_pointer, ddr_bus_2);

       	// fetch current tree node
       	kdTree_type tmp_u;
		tmp_u = ddr_bus_0[uint(u)];

        uint dummy_idx;
        data_type_ext u_wgtCent;
        data_type u_midPoint;
        data_type u_bnd_lo;
        data_type u_bnd_hi;
        coord_type_ext u_sum_sq;
        coord_type_ext u_count;
        node_pointer u_left;
        node_pointer u_right;
        get_kd_tree_type_items(	tmp_u,
        						&dummy_idx,
        						&u_wgtCent,
        						&u_midPoint,
        						&u_bnd_hi,
        						&u_bnd_lo,
        						&u_sum_sq,
        						&u_count,
        						&u_left,
        						&u_right);


		#ifdef VERBOSE
		#ifndef __SYNTHESIS__
        printf("%d: %s ",visited_nodes,tmp_u.value.to_string(16,false).c_str());
        //printf("(%d, %d, %d); ",u_count.VAL, u_left.VAL, u_right.VAL);
		#endif

		#ifndef __SYNTHESIS__
        printf("R:[%d] ", centre_set_in.VAL);
		#endif
		#endif


        centre_set_out = malloc<centre_list_pointer>(freelist_bus_1, &centre_next_free_location);
		#ifndef __SYNTHESIS__
		allocated_centre_sets++;
		if (max_allocated_centre_sets < allocated_centre_sets)
			max_allocated_centre_sets = allocated_centre_sets;
		#endif

        centre_index_type tmp_k_out;
        centre_heap_type tmp_centre_indices_out;
        centre_index_type tmp_final_centre_index;
        coord_type_ext tmp_sum_sq_out;
        bool tmp_deadend;

        process_node<par>( 	ddr_bus_1,
							centre_set_in,
							centre_set_out,
							tmp_k,
							u_wgtCent,
							u_midPoint,
							u_bnd_hi,
							u_bnd_lo,
							u_sum_sq,
							u_count,
							u_left,
							u_right,
							//tmp_cntr_list_data.idx,
							centre_positions,
							&tmp_k_out,
							//tmp_centre_indices_out.idx,
							&tmp_final_centre_index,
							&tmp_sum_sq_out,
							&tmp_deadend );

        // free list that has been read twice
        if (rdy_for_deletion == true) {
        	// delete centre_set_in
            free<centre_list_pointer>(freelist_bus_1, &centre_next_free_location, centre_set_in);
			#ifndef __SYNTHESIS__
			allocated_centre_sets--;
			#endif
        }

        // write back
        // final decision whether sub-tree will be pruned
        if ( tmp_deadend == true ) {
			// delete centre_set_out
        	free<centre_list_pointer>(freelist_bus_1, &centre_next_free_location, centre_set_out);
			#ifndef __SYNTHESIS__
			allocated_centre_sets--;
			#endif

        	/*
        	 * The data width of LEAP coherent scratchpads for shared memory access is limited to 64 bits.
        	 * As opposed to private scratchpads which can have an arbitrary bitwidth, we must split the shared memory access
        	 * into 64bit chunks. This is done by the functions 'centre_type_to_bus' and 'bus_to_centre_type'.
        	 */
			update_function: {
				//#pragma HLS protocol fixed
				my_wait();
				*access_critical_region = true;
				my_wait();
				// weighted centroid of this centre
				#ifdef CENTRE_BUFFER_ONCHIP
				centre_type tmpCentreRecord = centre_buffer[tmp_final_centre_index];
				#else
				centre_type tmpCentreRecord;
				uint address = (uint)tmp_final_centre_index;
				bus_to_centre_type(ddr_bus_3, address, &tmpCentreRecord);
				#ifdef VERBOSE
				printf("\n[%d]Count ",par);
				for (centre_index_type i=0; i<=k; i++) {
					centre_type tmpCent;
					bus_to_centre_type(ddr_bus_3, (uint)i, &tmpCent);
					printf("%d ",tmpCent.count.VAL);
					if (i==k)
						break;
				}
				printf("\n");
				#endif
				#endif

				for (uint d=0; d<D; d++) {
					#pragma HLS unroll
					coord_type_ext tmp1 = get_coord_type_vector_ext_item(tmpCentreRecord.wgtCent.value,d);
					coord_type_ext tmp2 = get_coord_type_vector_ext_item(u_wgtCent.value,d);
					set_coord_type_vector_ext_item(&tmpCentreRecord.wgtCent.value,tmp1+tmp2,d);
					my_wait();
				}
				// update number of points assigned to centre
				coord_type_ext tmp1 =  u_count;
				coord_type_ext tmp2 =  tmpCentreRecord.count;
				tmpCentreRecord.count = tmp1 + tmp2;
				my_wait();
				coord_type_ext tmp3 =  tmp_sum_sq_out;
				coord_type_ext tmp4 =  tmpCentreRecord.sum_sq;
				tmpCentreRecord.sum_sq  = tmp3 + tmp4;
				my_wait();

				#ifdef CENTRE_BUFFER_ONCHIP
				centre_buffer[tmp_final_centre_index] = tmpCentreRecord;
				#else
				centre_type_to_bus(tmpCentreRecord, address, ddr_bus_3);
				#endif
				my_wait();
				*access_critical_region = false;
				my_wait();
			}

        } else {

            // allocate new centre list
            centre_index_type new_k = tmp_k_out;

            node_pointer left_child = u_left;
            node_pointer right_child = u_right;

			#ifdef VERBOSE
			#ifndef __SYNTHESIS__
			printf("W:[%d] ", centre_set_out.VAL);
			#endif
			#endif

			// push children onto stack
			node_stack_length = push(right_child, centre_set_out,new_k, true, &stack_pointer, ddr_bus_2);
			node_stack_length = push(left_child, centre_set_out,new_k, false, &stack_pointer, ddr_bus_2);

        }

		#ifdef VERBOSE
		#ifndef __SYNTHESIS__
		printf("\n");
		#endif
		#endif

		#ifndef __SYNTHESIS__
        visited_nodes++;
		#endif

    }


	#ifdef CENTRE_BUFFER_ONCHIP
    // readout centres
    read_out_centres_loop: for(centre_index_type i=0; i<=k; i++) {
        #pragma HLS pipeline II=1
    	centres_out[par][i] = centre_buffer[i];

        if (i==k) {
            break;
        }
    }
	#endif

	#ifndef __SYNTHESIS__
	printf("%d: visited nodes: %d\n",0,visited_nodes);
	printf("%d: max allocated centre sets: %d\n",0,max_allocated_centre_sets);
	#endif

}



// top-level function
void filtering_algorithm_top(   volatile kdTree_type *i_node_data,
								volatile kdTree_type *ddr_bus_0_0,
								volatile centre_index_type *ddr_bus_0_1,
								volatile stack_record_type *ddr_bus_0_2,
								volatile bus_type3 *ddr_bus_0_3,
								volatile bool *access_critical_region0,
								volatile kdTree_type *ddr_bus_1_0,
								volatile centre_index_type *ddr_bus_1_1,
								volatile stack_record_type *ddr_bus_1_2,
								volatile bus_type3 *ddr_bus_1_3,
								volatile bool *access_critical_region1,
								volatile kdTree_type *ddr_bus_2_0,
								volatile centre_index_type *ddr_bus_2_1,
								volatile stack_record_type *ddr_bus_2_2,
								volatile bus_type3 *ddr_bus_2_3,
								volatile bool *access_critical_region2,
								volatile kdTree_type *ddr_bus_3_0,
								volatile centre_index_type *ddr_bus_3_1,
								volatile stack_record_type *ddr_bus_3_2,
								volatile bus_type3 *ddr_bus_3_3,
								volatile bool *access_critical_region3,
								volatile centre_list_pointer *freelist_bus_0_1,
								volatile centre_list_pointer *freelist_bus_1_1,
								volatile centre_list_pointer *freelist_bus_2_1,
								volatile centre_list_pointer *freelist_bus_3_1,
                                volatile data_type *cntr_pos_init,
                                node_pointer n,
                                centre_index_type k,
                                uint l,
                                volatile node_pointer *root,
                                volatile coord_type_ext *distortion_out,
                                volatile data_type *clusters_out)
{
	// set up the axi bus interfaces
	#pragma HLS INTERFACE ap_bus port=ddr_bus_0_0
	#pragma HLS INTERFACE ap_bus port=ddr_bus_0_1
	#pragma HLS INTERFACE ap_bus port=ddr_bus_0_2
	#pragma HLS INTERFACE ap_bus port=ddr_bus_0_3

	#pragma HLS INTERFACE ap_bus port=ddr_bus_1_0
	#pragma HLS INTERFACE ap_bus port=ddr_bus_1_1
	#pragma HLS INTERFACE ap_bus port=ddr_bus_1_2
	#pragma HLS INTERFACE ap_bus port=ddr_bus_1_3

	#pragma HLS INTERFACE ap_bus port=ddr_bus_2_0
	#pragma HLS INTERFACE ap_bus port=ddr_bus_2_1
	#pragma HLS INTERFACE ap_bus port=ddr_bus_2_2
	#pragma HLS INTERFACE ap_bus port=ddr_bus_2_3

	#pragma HLS INTERFACE ap_bus port=ddr_bus_3_0
	#pragma HLS INTERFACE ap_bus port=ddr_bus_3_1
	#pragma HLS INTERFACE ap_bus port=ddr_bus_3_2
	#pragma HLS INTERFACE ap_bus port=ddr_bus_3_3

	#pragma HLS INTERFACE ap_bus port=freelist_bus_0_1
	#pragma HLS INTERFACE ap_bus port=freelist_bus_1_1
	#pragma HLS INTERFACE ap_bus port=freelist_bus_2_1
	#pragma HLS INTERFACE ap_bus port=freelist_bus_3_1


    // set the interface properties
    #pragma HLS interface ap_none register port=n
    #pragma HLS interface ap_none register port=k

	#pragma HLS interface ap_fifo port=i_node_data depth=16

    #pragma HLS interface ap_fifo port=cntr_pos_init depth=16
    #pragma HLS interface ap_fifo port=root depth=16
    #pragma HLS interface ap_fifo port=distortion_out depth=16
    #pragma HLS interface ap_fifo port=clusters_out depth=16

	init_tree_node_memory(i_node_data, n, ddr_bus_0_0, ddr_bus_1_0, ddr_bus_2_0, ddr_bus_3_0);

	#ifndef CENTRE_BUFFER_ONCHIP
	init_centre_buffer( k, ddr_bus_0_3, ddr_bus_1_3, ddr_bus_2_3, ddr_bus_3_3,
						access_critical_region0, access_critical_region1, access_critical_region2, access_critical_region3);
	#endif

	node_pointer root_array[P];
	#pragma HLS array_partition variable=root_array complete

	for (uint i=0; i<P; i++) {
		node_pointer root_t = root[i];
		node_pointer tmp_node_address = root_t;
		root_array[i] = tmp_node_address;
	}

    centre_type filt_centres_out[P][K];
    data_type centre_positions[P][K];
    data_type new_centre_positions[K];

	centre_type filt_centres_out_reduced[K];
	#pragma HLS data_pack variable=filt_centres_out_reduced

	#pragma HLS array_partition variable=centre_positions complete dim=1
	#pragma HLS array_partition variable=filt_centres_out complete dim=1


    for (uint i=0; i<=k; i++) {
    	data_type position;
        #pragma HLS pipeline II=1
    	position = cntr_pos_init[i];
    	new_centre_positions[i] = position;
    }


    // iterate over a constant number of outer clustering iterations
    it_loop: for (uint iterations=0; iterations<l; iterations++) {

        for (centre_index_type i=0; i<=k; i++) {
			#pragma HLS pipeline II=1
			data_type position;
			position.value = new_centre_positions[i].value;
			for (uint p=0; p<P; p++) {
				#pragma HLS unroll
				//#pragma HLS dependence variable=centre_positions inter false
				centre_positions[p][i] = position;
			}
            if (i==k) {
                break;
            }
        }

        // run the clustering kernels (tree traversal)
        filter<0>(root_array[0], ddr_bus_0_0, ddr_bus_0_1, ddr_bus_0_2, ddr_bus_0_3, freelist_bus_0_1, k, centre_positions, filt_centres_out, access_critical_region0);
		#if P>1
		filter<1>(root_array[1], ddr_bus_1_0, ddr_bus_1_1, ddr_bus_1_2, ddr_bus_1_3, freelist_bus_1_1, k, centre_positions, filt_centres_out, access_critical_region1);
		#endif
		#if P>2
        filter<2>(root_array[2], ddr_bus_2_0, ddr_bus_2_1, ddr_bus_2_2, ddr_bus_2_3, freelist_bus_2_1, k, centre_positions, filt_centres_out, access_critical_region2);
		#endif
		#if P>3
        filter<3>(root_array[3], ddr_bus_3_0, ddr_bus_3_1, ddr_bus_3_2, ddr_bus_3_3, freelist_bus_3_1, k, centre_positions, filt_centres_out, access_critical_region3);
		#endif



		#ifdef CENTRE_BUFFER_ONCHIP
        // if we have parallel tree searches, we need to perform a reduction after all units are done
			#if P>1
			for(centre_index_type i=0; i<=k; i++) {
				#pragma HLS pipeline II=1

				coord_type_ext arr_count[P];
				coord_type_ext arr_sum_sq[P];
				coord_type_vector_ext arr_wgtCent[P];
				#pragma HLS array_partition variable=arr_count complete
				#pragma HLS array_partition variable=arr_sum_sq complete
				#pragma HLS array_partition variable=arr_wgtCent complete

				for (uint p=0; p<P; p++) {
					#pragma HLS unroll
					#pragma HLS dependence variable=arr_count inter false
					#pragma HLS dependence variable=arr_sum_sq inter false
					#pragma HLS dependence variable=arr_wgtCent inter false
					arr_count[p] = ((coord_type_ext)filt_centres_out[p][i].count);
					arr_sum_sq[p] = (filt_centres_out[p][i].sum_sq);
					arr_wgtCent[p] = (filt_centres_out[p][i].wgtCent.value);
				}

				filt_centres_out_reduced[i].count = tree_adder(arr_count,P);
				filt_centres_out_reduced[i].sum_sq = tree_adder(arr_sum_sq,P);
				coord_type_vector_ext tmp_sum;
				for (uint d=0; d<D; d++) {
					#pragma HLS unroll
					coord_type_ext tmp_a[P];
					for (uint p=0; p<P; p++) {
						#pragma HLS unroll
						#pragma HLS dependence variable=tmp_a inter false
						tmp_a[p] = get_coord_type_vector_ext_item(arr_wgtCent[p],d);
					}
					coord_type_ext tmp = tree_adder(tmp_a,P);
					set_coord_type_vector_ext_item(&tmp_sum,tmp,d);
				}
				filt_centres_out_reduced[i].wgtCent.value = tmp_sum;

				if (i==k) {
					break;
				}
			}
			#else

			for(centre_index_type i=0; i<=k; i++) {
				#pragma HLS pipeline II=1

				filt_centres_out_reduced[i].count = filt_centres_out[0][i].count;
				filt_centres_out_reduced[i].sum_sq = filt_centres_out[0][i].sum_sq;
				filt_centres_out_reduced[i].wgtCent.value = filt_centres_out[0][i].wgtCent.value;

				if (i==k) {
					break;
				}
			}

			#endif
		#else

		*access_critical_region0 = true;

		for(centre_index_type i=0; i<=k; i++) {

			centre_type tmp;
			uint address = (uint)i;
			centre_type tmp0, tmp1;

        	/*
        	 * The data width of LEAP coherent scratchpads for shared memory access is limited to 64 bits.
        	 * As opposed to private scratchpads which can have an arbitrary bitwidth, we must split the shared memory access
        	 * into 64bit chunks. This is done by the functions 'centre_type_to_bus' and 'bus_to_centre_type'.
        	 */
			bus_to_centre_type(ddr_bus_0_3, address, &tmp);

			filt_centres_out_reduced[i] = tmp;

			if (i==k) {
				break;
			}
		}

		*access_critical_region0 = false;

		#endif

        // re-init centre positions
		update_centres(filt_centres_out_reduced, k, new_centre_positions);

    }


    // write clustering output: new cluster centres and distortion
    output_loop: for (centre_index_type i=0; i<=k; i++) {
        #pragma HLS pipeline II=1

		distortion_out[i] = filt_centres_out_reduced[i].sum_sq;
		clusters_out[i] = new_centre_positions[i];
        if (i==k) {
            break;
        }
    }
}

