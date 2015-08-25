/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: filtering_algorithm_util.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

#include <math.h>
#include "filtering_algorithm_util.h"


/* ****** helper functions *******/

void set_coord_type_vector_item(coord_type_vector *a, const coord_type b, const uint idx)
{
    #pragma HLS function_instantiate variable=idx
    a->range((idx+1)*COORD_BITWIDTH-1,idx*COORD_BITWIDTH) = b;
}


void set_coord_type_vector_ext_item(coord_type_vector_ext *a, const coord_type_ext b, const uint idx)
{
    #pragma HLS function_instantiate variable=idx
    a->range((idx+1)*COORD_BITWITDH_EXT-1,idx*COORD_BITWITDH_EXT) = b;
}


coord_type get_coord_type_vector_item(const coord_type_vector a, const uint idx)
{
    #pragma HLS function_instantiate variable=idx
    coord_type tmp= a.range((idx+1)*COORD_BITWIDTH-1,idx*COORD_BITWIDTH);
    return tmp;
}


coord_type_ext get_coord_type_vector_ext_item(const coord_type_vector_ext a, const uint idx)
{
    #pragma HLS function_instantiate variable=idx
    coord_type_ext tmp= a.range((idx+1)*COORD_BITWITDH_EXT-1,idx*COORD_BITWITDH_EXT);
    return tmp;
}


void set_kd_tree_type_items(kdTree_type *a,
							const uint idx,
							const data_type_ext wgtCent,
							const data_type midPoint,
							const data_type bnd_hi,
							const data_type bnd_lo,
							const coord_type_ext sum_sq,
							const coord_type_ext count,
							const node_pointer left,
							const node_pointer right)
{
	a->value.range(
				32+3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = idx;
	a->value.range(
			3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 3*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = wgtCent.value;
	a->value.range(
			3*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = midPoint.value;
	a->value.range(
			2*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 1*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = bnd_hi.value;
	a->value.range(
			1*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = bnd_lo.value;
	a->value.range(
			2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH) = sum_sq;
	a->value.range(
			COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*NODE_POINTER_BITWIDTH) = count;
	a->value.range(
			2*NODE_POINTER_BITWIDTH-1, NODE_POINTER_BITWIDTH) = left;
	a->value.range(
			1*NODE_POINTER_BITWIDTH-1, 0) = right;
}


void get_kd_tree_type_items(const kdTree_type a,
							uint *idx,
							data_type_ext *wgtCent,
							data_type *midPoint,
							data_type *bnd_hi,
							data_type *bnd_lo,
							coord_type_ext *sum_sq,
							coord_type_ext *count,
							node_pointer *left,
							node_pointer *right
							)
{
	*idx = a.value.range(
			32+3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	wgtCent->value = a.value.range(
			3*D*COORD_BITWIDTH+D*COORD_BITWITDH_EXT+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 3*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	midPoint->value = a.value.range(
			3*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	bnd_hi->value = a.value.range(
			2*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 1*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	bnd_lo->value = a.value.range(
			1*D*COORD_BITWIDTH+2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	*sum_sq = a.value.range(
			2*COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH);
	*count = a.value.range(
			COORD_BITWITDH_EXT+2*NODE_POINTER_BITWIDTH-1, 2*NODE_POINTER_BITWIDTH);
	*left = a.value.range(
			2*NODE_POINTER_BITWIDTH-1, NODE_POINTER_BITWIDTH);
	*right = a.value.range(
			1*NODE_POINTER_BITWIDTH-1, 0);
}


void set_stack_record_type_items(stack_record_type *a,
										const node_pointer u,
										const centre_list_pointer c,
										const centre_index_type k,
										const bool d)
{
	a->value.range(
				1+CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH) = d;
	a->value.range(
			CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH) = k;
	a->value.range(
			CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, NODE_POINTER_BITWIDTH) = c;
	a->value.range(
			1*NODE_POINTER_BITWIDTH-1, 0) = u;
}

void get_stack_record_type_items(const stack_record_type a,
										node_pointer *u,
										centre_list_pointer *c,
										centre_index_type *k,
										bool *d
										)
{
	*d = a.value.range(
			1+CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH);
	*k = a.value.range(
			CNTR_INDEX_BITWIDTH+CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH);
	*c = a.value.range(
			CNTR_LIST_INDEX_BITWIDTH+NODE_POINTER_BITWIDTH-1, NODE_POINTER_BITWIDTH);
	*u = a.value.range(
			1*NODE_POINTER_BITWIDTH-1, 0);
}



// conversion from data_type_ext to data_type
data_type conv_long_to_short(data_type_ext p)
{
    #pragma HLS inline
    data_type result;
    for (uint d=0; d<D; d++) {
        #pragma HLS unroll
        coord_type tmp = (coord_type)get_coord_type_vector_ext_item(p.value,d);
        set_coord_type_vector_item(&result.value,tmp,d);
    }
    return result;
}

// conversion from data_type to data_type_ext
data_type_ext conv_short_to_long(data_type p)
{
    #pragma HLS inline
    data_type_ext result;
    for (uint d=0; d<D; d++) {
        #pragma HLS unroll
        coord_type_ext tmp = (coord_type_ext)get_coord_type_vector_item(p.value,d);
        set_coord_type_vector_ext_item(&result.value,tmp,d);
    }
    return result;
}


void my_wait() {
	#pragma HLS inline
	#ifdef FORCE_PROTOCOL_REGION
	ap_wait();
	#endif
}


void wait_for_n_cycles(const uint n)
{
	#pragma HLS inline
	for (uint i=0; i<n; i++) {
		#pragma HLS unroll
		my_wait();
	}
}



mul_input_type saturate_mul_input(coord_type_ext val)
{
    #pragma HLS inline
    if (val > MUL_MAX_VAL) {
        val = MUL_MAX_VAL;
    } else if (val < MUL_MIN_VAL) {
        val = MUL_MIN_VAL;
    }
    return (mul_input_type)val;
}


// fixed-point multiplication with saturation and scaling
coord_type_ext fi_mul(coord_type_ext op1, coord_type_ext op2)
{
    #pragma HLS inline
    mul_input_type tmp_op1 = saturate_mul_input(op1);
    mul_input_type tmp_op2 = saturate_mul_input(op2);

    ap_int<2*(MUL_INTEGER_BITS+MUL_FRACTIONAL_BITS)> result_unscaled;
    result_unscaled = tmp_op1*tmp_op2;
    #pragma HLS resource variable=result_unscaled core=MulnS

    ap_int<2*(MUL_INTEGER_BITS+MUL_FRACTIONAL_BITS)> result_scaled;
    result_scaled = result_unscaled >> MUL_FRACTIONAL_BITS;
    coord_type_ext result;
    result = (coord_type_ext)result_scaled;
    return result;
}


// tree adder
coord_type_ext tree_adder(coord_type_ext *input_array)
{
    #pragma HLS inline

    for(uint j=0;j<ceil(log2(D));j++)
    {
        #pragma HLS unroll
        #pragma HLS dependence variable=input_array inter false
        if (j<ceil(log2(D))-1) {
            for(uint i = 0; i < uint(D/(1<<(j+1))); i++)
            {
                #pragma HLS unroll
                #pragma HLS dependence variable=input_array inter false
                coord_type_ext tmp1 = input_array[2*i];
                coord_type_ext tmp2 = input_array[2*i+1];
                coord_type_ext tmp3 = tmp1+tmp2;
                input_array[i] = tmp3;
            }
            if (D > uint(D/(1<<(j+1)))*(1<<(j+1)) ) {
                input_array[uint(D/(1<<(j+1)))] = input_array[uint(D/(1<<(j+1))-1)*2+2];
            }
        }
        if (j== ceil(log2(D))-1) {
            coord_type_ext tmp1 = input_array[0];
            coord_type_ext tmp2 = input_array[1];
            coord_type_ext tmp3 = tmp1+tmp2;
            input_array[0] = tmp3;
        }
    }
    return input_array[0];
}

// tree adder (overloaded function)
coord_type_ext tree_adder(coord_type_ext *input_array,const uint m)
{
	#pragma HLS inline

	for(uint j=0;j<ceil(log2(m));j++)
	{
			#pragma HLS unroll
			if (j<ceil(log2(m))-1) {
					for(uint i = 0; i < uint(m/(1<<(j+1))); i++)
					{
							#pragma HLS unroll
							coord_type_ext tmp1 = input_array[2*i];
							coord_type_ext tmp2 = input_array[2*i+1];
							coord_type_ext tmp3 = tmp1+tmp2;
							input_array[i] = tmp3;
							#pragma HLS resource variable=tmp3 core=AddSubnS
					}
					if (m > uint(m/(1<<(j+1)))*(1<<(j+1)) ) {
							input_array[uint(m/(1<<(j+1)))] = input_array[uint(m/(1<<(j+1))-1)*2+2];
					}
			}
			if (j== ceil(log2(m))-1) {
					coord_type_ext tmp1 = input_array[0];
					coord_type_ext tmp2 = input_array[1];
					coord_type_ext tmp3 = tmp1+tmp2;
					input_array[0] = tmp3;
					#pragma HLS resource variable=tmp3 core=AddSubnS
			}
	}
	return input_array[0];
}


// inner product of p1 and p2
void dot_product(data_type_ext p1,data_type_ext p2, coord_type_ext *r)
{
    #pragma HLS inline

    coord_type_ext tmp_mul_res[D];
    #pragma HLS array_partition variable=tmp_mul_res complete dim=0

    for (uint d=0;d<D;d++) {
        #pragma HLS unroll
        mul_input_type tmp_op1 = saturate_mul_input(get_coord_type_vector_ext_item(p1.value,d));
        mul_input_type tmp_op2 = saturate_mul_input(get_coord_type_vector_ext_item(p2.value,d));
        coord_type_ext tmp_mul = tmp_op1*tmp_op2;
        tmp_mul_res[d] = tmp_mul;
        #pragma HLS resource variable=tmp_mul core=MulnS
    }

    *r = tree_adder(tmp_mul_res);
}


// compute the Euclidean distance between p1 and p2
void compute_distance(data_type_ext p1, data_type_ext p2, coord_type_ext *dist)
{
    #pragma HLS inline

    data_type_ext tmp_p1 = p1;
    data_type_ext tmp_p2 = p2;
    coord_type_ext tmp_mul_res[D];

    for (uint d=0; d<D; d++) {
        #pragma HLS unroll
        coord_type_ext tmp_sub1 = get_coord_type_vector_ext_item(tmp_p1.value,d);
        coord_type_ext tmp_sub2 = get_coord_type_vector_ext_item(tmp_p2.value,d);
        coord_type_ext tmp = tmp_sub1 - tmp_sub2;
        coord_type_ext tmp_mul = fi_mul(tmp,tmp);
        tmp_mul_res[d] = tmp_mul;
        #pragma HLS resource variable=tmp_mul core=MulnS
    }

    *dist = tree_adder(tmp_mul_res);
}



// check whether any point of bounding box is closer to z than to z*
// this is a modified version of David Mount's code (http://www.cs.umd.edu/~mount/Projects/KMeans/ )
void tooFar_fi(data_type closest_cand, data_type cand, data_type bnd_lo, data_type bnd_hi, bool *too_far)
{
    #pragma HLS inline

    coord_type_ext boxDot;
    coord_type_ext ccDot;

    data_type_ext tmp_closest_cand  = conv_short_to_long(closest_cand);
    data_type_ext tmp_cand          = conv_short_to_long(cand);
    data_type_ext tmp_bnd_lo        = conv_short_to_long(bnd_lo);
    data_type_ext tmp_bnd_hi        = conv_short_to_long(bnd_hi);

    coord_type_ext tmp_mul_res[D];
    coord_type_ext tmp_mul_res2[D];

    for (uint d = 0; d<D; d++) {
        #pragma HLS unroll
        #pragma HLS dependence variable=tmp_mul_res inter false
        #pragma HLS dependence variable=tmp_mul_res2 inter false
        coord_type_ext tmp_sub_op1 =  get_coord_type_vector_ext_item(tmp_cand.value,d);
        coord_type_ext tmp_sub_op2 =  get_coord_type_vector_ext_item(tmp_closest_cand.value,d);
        coord_type_ext ccComp = tmp_sub_op1-tmp_sub_op2;
        coord_type_ext tmp_mul = fi_mul(ccComp,ccComp);
        tmp_mul_res[d] = tmp_mul;
        #pragma HLS resource variable=tmp_mul core=MulnS

        coord_type_ext tmp_diff2;
        coord_type_ext tmp_sub_op3;
        coord_type_ext tmp_sub_op4;
        if (ccComp > 0) {
            tmp_sub_op3 = get_coord_type_vector_ext_item(tmp_bnd_hi.value,d);
        }
        else {
            tmp_sub_op3 = get_coord_type_vector_ext_item(tmp_bnd_lo.value,d);
        }
        tmp_sub_op4 = get_coord_type_vector_ext_item(tmp_closest_cand.value,d);
        tmp_diff2 = tmp_sub_op3 - tmp_sub_op4;

        coord_type_ext tmp_mul2 = fi_mul(tmp_diff2,ccComp);
        tmp_mul_res2[d] = tmp_mul2;

        #pragma HLS resource variable=tmp_mul2 core=MulnS
    }

    ccDot = tree_adder(tmp_mul_res);
    boxDot = tree_adder(tmp_mul_res2);

    coord_type_ext tmp_boxDot = boxDot<<1;
    bool tmp_res;
    if (ccDot>tmp_boxDot) {
        tmp_res = true;
    } else {
        tmp_res = false;
    }

    *too_far = tmp_res;
}

