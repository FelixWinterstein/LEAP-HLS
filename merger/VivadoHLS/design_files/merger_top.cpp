
#include "merger_top.h"
#include "dyn_mem_alloc.h"


#ifdef PARALLEL_VERSION


pointer_type sorted_insert(volatile data_record *data_bus, volatile pointer_type *flist, pointer_type *next_free_location, pointer_type queue, int key,unsigned int bank)
{
	// this directive must be here to enable simultaneous execution of all 4 sorted_insert loops
	// (even if a wrapper function for the loop nest is used)
	#pragma HLS function_instantiate variable=bank

	pointer_type result;

	pointer_type new_record = malloc<pointer_type>(flist,next_free_location);
	data_record new_record_rec;
	
	new_record_rec.k = key;
	new_record_rec.n = 0;
	//data_record_type_to_bus(new_record_rec, new_record, data_bus);
    data_bus[new_record] = new_record_rec;

	if (queue == 0) {
		result = new_record;
	} else {
		pointer_type l, prev;
		data_record l_rec;

		int tmp_key;
		pointer_type tmp_n;
		prev = 0;
		l = queue;

		//bus_to_data_record(data_bus, l, &l_rec);
        l_rec = data_bus[l];

		pointer_type loop_n;
		int loop_k;
		loop_n = l_rec.n;
		loop_k = l_rec.k;


		sorted_insert_label3:while (loop_n != 0 && loop_k <= key) {

			#pragma HLS pipeline II=11

            prev = l;
            tmp_n = l_rec.n;
            tmp_key = l_rec.k;
            l = tmp_n;

            //bus_to_data_record(data_bus, l, &l_rec);
            l_rec = data_bus[l];

            loop_n = l_rec.n;
            loop_k = l_rec.k;
        }


        if (loop_k <= key) { // insert new record after last element
        	l_rec.n = new_record;
        	l_rec.k = loop_k;
        	//data_record_type_to_bus(l_rec, l, data_bus);
            data_bus[l] = l_rec;

        } else {
            if (prev == 0) { // current element = first element?
                new_record_rec.n = queue;
                new_record_rec.k = key;
                //data_record_type_to_bus(new_record_rec, new_record, data_bus);
                data_bus[new_record] = new_record_rec;

                queue = new_record;
            } else {
            	data_record prev_rec;

            	//bus_to_data_record(data_bus, prev, &prev_rec);
                prev_rec = data_bus[prev];

            	pointer_type prev_n;
            	int prev_k;
            	prev_n = prev_rec.n;
            	prev_k = prev_rec.k;

            	prev_rec.n = new_record;
            	prev_rec.k = prev_k;
            	//data_record_type_to_bus(prev_rec, prev, data_bus);
                data_bus[prev] = prev_rec;

                new_record_rec.n = l;
                new_record_rec.k = key;
                //data_record_type_to_bus(new_record_rec, new_record, data_bus);
                data_bus[new_record] = new_record_rec;
            }
        }

        result = queue;

	}

	return result;
}


int delete_smallest(volatile data_record *data_bus_0,
					volatile data_record *data_bus_1,
					volatile data_record *data_bus_2,
					volatile data_record *data_bus_3,
					volatile pointer_type *flist_0,
					volatile pointer_type *flist_1,
					volatile pointer_type *flist_2,
					volatile pointer_type *flist_3,
					pointer_type *next_free_location_0,
					pointer_type *next_free_location_1,
					pointer_type *next_free_location_2,
					pointer_type *next_free_location_3,
					pointer_type *queue)
{

	data_record q_rec;
	pointer_type tmp;

    int min_k = MAX_K;
    uint min_idx;

    delete_smallest_label0:for (uint p=0; p<4; p++) {

		#pragma HLS expression_balance

    	pointer_type q;

    	if (queue[p] != 0) {
    		switch (p) {
    		case 0:
    			//bus_to_data_record(data_bus_0, queue[0], &q_rec);
                q_rec = data_bus_0[queue[0]];
    			break;
    		case 1:
    			//bus_to_data_record(data_bus_1, queue[1], &q_rec);
                q_rec = data_bus_1[queue[1]];
    			break;
    		case 2:
    			//bus_to_data_record(data_bus_2, queue[2], &q_rec);
                q_rec = data_bus_2[queue[2]];
    			break;
    		case 3:
    			//bus_to_data_record(data_bus_3, queue[3], &q_rec);
                q_rec = data_bus_3[queue[3]];
    			break;
    		}

    		pointer_type next;
    		int key;
    		next = q_rec.n;
    		key = q_rec.k;

    		if (key < min_k) {
    			min_k =key;
    			min_idx = p;
    		}
    	}
    }

    pointer_type next;
    int key;

    switch (min_idx) {
    case 0:
        tmp = queue[0];
        //bus_to_data_record(data_bus_0, tmp, &q_rec);
        q_rec = data_bus_0[tmp];
        next = q_rec.n;
        key = q_rec.k;
        queue[0] = next;
        free<pointer_type>(flist_0, next_free_location_0, tmp);
        break;
    case 1:
        tmp = queue[1];
        //bus_to_data_record(data_bus_1, tmp, &q_rec);
        q_rec = data_bus_1[tmp];
        next = q_rec.n;
        key = q_rec.k;
        //get_fields(*q_ptr, &key, &next);
        queue[1] = next;
        free<pointer_type>(flist_1, next_free_location_1, tmp);
        break;
    case 2:
        tmp = queue[2];
        //bus_to_data_record(data_bus_2, tmp, &q_rec);       
        q_rec = data_bus_2[tmp];
        next = q_rec.n;
        key = q_rec.k;
        //get_fields(*q_ptr, &key, &next);
        queue[2] = next;
        free<pointer_type>(flist_2, next_free_location_2, tmp);
        break;
    case 3:
        tmp = queue[3];
        //bus_to_data_record(data_bus_3, tmp, &q_rec);
        q_rec = data_bus_3[tmp];
        next = q_rec.n;
        key = q_rec.k;
        //get_fields(*q_ptr, &key, &next);
        queue[3] = next;
        free<pointer_type>(flist_3, next_free_location_3, tmp);
        break;
    }

    return min_k;
}

pointer_type sorted_insert_wrapper(volatile data_record *data_bus, volatile pointer_type *flist, pointer_type *next_free_location, uint n, pointer_type queue, volatile int *val_r, uint bank)
{
	// this directve is the crucial one that enables simultaneous execution of all 4 sorted_insert loops !!!
	#pragma HLS function_instantiate variable=bank

	pointer_type result=queue;
	for(pointer_type i=0; i<n; i++) {
		result = sorted_insert(data_bus, flist, next_free_location, result,val_r[i],bank);
	}
	return result;
}


//top level entity
void merger_top(uint n,
				volatile data_record *data_bus_1,
				volatile data_record *data_bus_2,
				volatile data_record *data_bus_3,
				volatile data_record *data_bus_4,
				volatile pointer_type *freelist_bus_1,
				volatile pointer_type *freelist_bus_2,
				volatile pointer_type *freelist_bus_3,
				volatile pointer_type *freelist_bus_4,
				volatile int *val_r1,
				volatile int *val_r2,
				volatile int *val_r3,
				volatile int *val_r4,
				volatile int *val_w)
{



	#pragma HLS INTERFACE ap_bus port=data_bus_1
	#pragma HLS INTERFACE ap_bus port=data_bus_2
	#pragma HLS INTERFACE ap_bus port=data_bus_3
	#pragma HLS INTERFACE ap_bus port=data_bus_4

	#pragma HLS INTERFACE ap_bus port=freelist_bus_1
	#pragma HLS INTERFACE ap_bus port=freelist_bus_2
	#pragma HLS INTERFACE ap_bus port=freelist_bus_3
	#pragma HLS INTERFACE ap_bus port=freelist_bus_4

    #pragma HLS data_pack variable=data_bus_1
    #pragma HLS data_pack variable=data_bus_2
    #pragma HLS data_pack variable=data_bus_3
    #pragma HLS data_pack variable=data_bus_4

	/*
	#pragma HLS resource core=AXI4M variable=data_bus_1
	#pragma HLS resource core=AXI4M variable=data_bus_2
	#pragma HLS resource core=AXI4M variable=data_bus_3
	#pragma HLS resource core=AXI4M variable=data_bus_4
	*/

	#pragma HLS interface ap_fifo port=val_r1 depth=16
	#pragma HLS interface ap_fifo port=val_r2 depth=16
	#pragma HLS interface ap_fifo port=val_r3 depth=16
	#pragma HLS interface ap_fifo port=val_r4 depth=16
	#pragma HLS interface ap_fifo port=val_w depth=16
	//#pragma HLS interface ap_fifo port=debug_out depth=256


    pointer_type next_free_location_1 = 1;
    pointer_type next_free_location_2 = 1;
    pointer_type next_free_location_3 = 1;
    pointer_type next_free_location_4 = 1;

	pointer_type queue_array[4];
	#pragma HLS array_partition variable=queue_array complete

	merger_top_label0:for (uint p=0; p<4; p++) {
		#pragma HLS unroll
		queue_array[p] = 0;
	}

	queue_array[0] = sorted_insert_wrapper(data_bus_1, freelist_bus_1, &next_free_location_1, n, queue_array[0], val_r1, 0);
	queue_array[1] = sorted_insert_wrapper(data_bus_2, freelist_bus_2, &next_free_location_2, n, queue_array[1], val_r2, 1);
	queue_array[2] = sorted_insert_wrapper(data_bus_3, freelist_bus_3, &next_free_location_3, n, queue_array[2], val_r3, 2);
	queue_array[3] = sorted_insert_wrapper(data_bus_4, freelist_bus_4, &next_free_location_4, n, queue_array[3], val_r4, 3);


	pointer_type i = 0;
	while ( (queue_array[0] != 0) || (queue_array[1] != 0) || (queue_array[2] != 0) || (queue_array[3] != 0) ) {
		val_w[i] = delete_smallest( data_bus_1,
									data_bus_2,
									data_bus_3,
									data_bus_4,
									freelist_bus_1,
									freelist_bus_2,
									freelist_bus_3,
									freelist_bus_4,
									&next_free_location_1,
									&next_free_location_2,
									&next_free_location_3,
									&next_free_location_4,
									queue_array);
		#ifndef __SYNTHESIS__
		printf("%d ", val_w[i] );
		#endif

		i++;
	}

}

#else



pointer_type sorted_insert(volatile data_record *data_bus, volatile pointer_type *flist, pointer_type *next_free_location, pointer_type queue, int key)
{

	pointer_type result;

	pointer_type new_record = malloc<pointer_type>(flist,next_free_location);
	data_record new_record_rec;

	new_record_rec.k = key;
	new_record_rec.n = NULL_PTR;

	data_bus[new_record] = new_record_rec;

	if (queue == NULL_PTR) {
		result = new_record;
	} else {
		pointer_type l, prev;
		data_record l_rec;

		int tmp_key;
		pointer_type tmp_n;
		prev = NULL_PTR;
		l = queue;
		l_rec = data_bus[l];

		pointer_type loop_n;
		int loop_k;
		loop_n = l_rec.n;
		loop_k = l_rec.k;

		sorted_insert_label3:while (loop_n != NULL_PTR && loop_k <= key) {

			#pragma HLS pipeline II=11

			prev = l;
			tmp_n = l_rec.n;
			tmp_key = l_rec.k;

			l = tmp_n;
			l_rec = data_bus[l];

			loop_n = l_rec.n;
			loop_k = l_rec.k;

        }


		if (loop_k <= key) { // insert new record after last element
			l_rec.n = new_record;
			l_rec.k = loop_k;

			data_bus[l] = l_rec;

		} else {
			if (prev == NULL_PTR) { // current element = first element?
				new_record_rec.n = queue;
				new_record_rec.k = key;
				data_bus[new_record] = new_record_rec;
				queue = new_record;
			} else {
				data_record prev_rec;

				prev_rec = data_bus[prev];
				pointer_type prev_n;
				int prev_k;
				prev_n = prev_rec.n;
				prev_k = prev_rec.k;

				prev_rec.n = new_record;
				prev_rec.k = prev_k;

				data_bus[prev] = prev_rec;
				new_record_rec.n = l;
				new_record_rec.k = key;

				data_bus[new_record] = new_record_rec;

			}
		}

        result = queue;

	}

	return result;
}


int delete_smallest(volatile data_record *data_bus, volatile pointer_type *flist, pointer_type *next_free_location, pointer_type *queue)
{

	#pragma HLS inline

	pointer_type tmp;

    int min_k = MAX_K;
    uint min_idx;

    delete_smallest_label0:for (uint p=0; p<4; p++) {
		#pragma HLS unroll
		#pragma HLS expression_balance

    	pointer_type q = queue[p];

    	if (q != NULL_PTR) {

    		data_record q_rec;

    		q_rec = data_bus[q];

    		if (q_rec.k < min_k) {
    			min_k = q_rec.k;
    			min_idx = p;
    		}
    	}
    }

    tmp = queue[min_idx];

	data_record q_rec;

	q_rec = data_bus[queue[min_idx]];

    queue[min_idx] = q_rec.n;

    free<pointer_type>(flist, next_free_location, tmp);

    return min_k;
}



//top level entity
void merger_top(uint n,
				volatile data_record *data_bus_1,
				volatile pointer_type *freelist_bus_1,
				volatile int *val_r1,
				volatile int *val_r2,
				volatile int *val_r3,
				volatile int *val_r4,
				volatile int *val_w)
{


	#pragma HLS INTERFACE ap_bus port=data_bus_1

	#pragma HLS data_pack variable=data_bus_1

	#pragma HLS INTERFACE ap_bus port=freelist_bus_1

	#pragma HLS interface ap_fifo port=val_r1 depth=16
	#pragma HLS interface ap_fifo port=val_r2 depth=16
	#pragma HLS interface ap_fifo port=val_r3 depth=16
	#pragma HLS interface ap_fifo port=val_r4 depth=16
	#pragma HLS interface ap_fifo port=val_w depth=16

	pointer_type next_free_location_1 = 1;


	pointer_type queue_array[4];
	#pragma HLS array_partition variable=queue_array complete


	merger_top_label0:for (int p=0; p<4; p++) {
		#pragma HLS unroll
		queue_array[p] = NULL_PTR;
	}


	for(uint i=0; i<n; i++) {
		queue_array[0] = sorted_insert(data_bus_1, freelist_bus_1, &next_free_location_1, queue_array[0], val_r1[i]);
		queue_array[1] = sorted_insert(data_bus_1, freelist_bus_1, &next_free_location_1, queue_array[1], val_r2[i]);
		queue_array[2] = sorted_insert(data_bus_1, freelist_bus_1, &next_free_location_1, queue_array[2], val_r3[i]);
		queue_array[3] = sorted_insert(data_bus_1, freelist_bus_1, &next_free_location_1, queue_array[3], val_r4[i]);
		#ifndef __SYNTHESIS__
		//printf("%d ", queue_array[1].VAL);
		#endif
	}



	pointer_type i = 0;
	while ( (queue_array[0] != NULL_PTR) || (queue_array[1] != NULL_PTR) || (queue_array[2] != NULL_PTR) || (queue_array[3] != NULL_PTR) ) {
		//#pragma HLS pipeline II=11
		val_w[i] = delete_smallest(data_bus_1, freelist_bus_1, &next_free_location_1,queue_array);
		#ifndef __SYNTHESIS__
		printf("%d ", val_w[i]);
		#endif
		i++;
	}

}





#endif







