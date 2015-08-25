/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: build_kdTree.cpp
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string>
#include <math.h>
#include "build_kdTree.h"


#define mytype short int


//define stack data structure
stack_record_type bt_stack_array[N]; //STACK_SIZE=N

void make_data_points_file_name(char *result, uint n, uint k, uint d, double std_dev, bool hex)
{
	if (!hex)
		sprintf(result,"data_points_N%d_K%d_D%d_s%.2f.mat",n,k,d,std_dev);
	else
		sprintf(result,"../../../../golden_ref/data_points_N%d_K%d_D%d_s%.2f.hex",n,k,d,std_dev);
}

void make_initial_centres_file_name(char *result, uint n, uint k, uint d, double std_dev, uint index, bool hex)
{
	if (!hex)
		sprintf(result,"initial_centres_N%d_K%d_D%d_s%.2f_%d.mat",n,k,d,std_dev,index);
	else
		sprintf(result,"../../../../golden_ref/initial_centres_N%d_K%d_D%d_s%.2f_%d.hex",n,k,d,std_dev,index);
}



void make_tree_data_file_name(char *result, uint n, uint k, uint d, double std_dev, bool hex)
{
	if (!hex)
		sprintf(result,"../../../../golden_ref/tree_data_N%d_K%d_D%d_s%.2f.mat",n,k,d,std_dev);
	else
		sprintf(result,"../../../../golden_ref/tree_data_N%d_K%d_D%d_s%.2f.hex",n,k,d,std_dev);
}


void make_tree_data_file_name_bin(char *result, uint n, uint k, uint d, double std_dev)
{
	sprintf(result,"../../../../golden_ref/tree_data_N%d_K%d_D%d_s%.2f.dat",n,k,d,std_dev);
	printf("Writing to %s\n",result);
}

void make_tree_addr_file_name_bin(char *result, uint n, uint k, uint d, double std_dev)
{
	sprintf(result,"../../../../golden_ref/tree_data_N%d_K%d_D%d_s%.2f.dat",n,k,d,std_dev);
	printf("Writing to %s\n",result);
}



// read input file
bool read_data_points(uint n, uint k, double std_dev, data_type* points, uint* index)
{

    FILE *fp;
    char filename[256];
    make_data_points_file_name(filename,n,k,D,std_dev,false);
    fp=fopen(filename, "r");

    if (fp == 0) {
        printf("failed to open file\n");
        return false;
    }
    char tmp[16];

    for (uint j=0; j<D; j++) {
        for (uint i=0;i<n;i++) {

            if (fgets(tmp,16,fp) == 0) {
                fclose(fp);
                return false;
            } else {
                //printf("%s\n",tmp);
                //points[i].value[j]=(mytype)atoi(tmp); // assume coord_type==short int
                coord_type b;
                b.VAL = (mytype)atoi(tmp); // assume coord_type==short int
                set_coord_type_vector_item(&points[i].value, b, j);
            }
            /*
            coord_type b;
            b.VAL = j*10; // assume coord_type==short int
            set_coord_type_vector_item(&points[i].value, b, j);
            */
        }
    }

    for (uint i=0;i<n;i++) {
        *(index+i) = i;
    }

    fclose(fp);

    return true;
}

// read input file
bool read_initial_centres(uint n, uint k, double std_dev, data_type *initial_centre_positions, uint* centr_idx)
{

    FILE *fp;
    char filename[256];
    make_initial_centres_file_name(filename,n,k,D,std_dev,FILE_INDEX,false);
    fp=fopen(filename, "r");
    if (fp == 0) {
        printf("failed to open file\n");
        return false;
    }
    char tmp[16];

    for (uint j=0; j<D; j++) {
		for (uint i=0;i<k;i++) {

            if (fgets(tmp,16,fp) == 0) {
                fclose(fp);
                return false;
            } else {
                //printf("%s\n",tmp);
                //initial_centre_positions[i].value[j] = (mytype)atoi(tmp); // assume coord_type==short int
                coord_type b;
                b.VAL = (mytype)atoi(tmp); // assume coord_type==short int
                set_coord_type_vector_item(&initial_centre_positions[i].value, b, j);
            }
        }
    }

    fclose(fp);

    return true;
}


bool write_initial_centres(uint n, uint k, double std_dev, data_type *initial_centre_positions)
{
	// verilog hex format

    FILE *fp;
    char filename[256];
    make_initial_centres_file_name(filename,n,k,D,std_dev,FILE_INDEX,true);
    fp=fopen(filename, "w");
    if (fp == 0) {
        printf("failed to open file for writing\n");
        return false;
    }

    for (uint j=0; j<k; j++) {
		std::string str = initial_centre_positions[j].value.toStringUnsigned(16);
		str.erase(0,2);
    	fprintf(fp,"%s\n",str.c_str());
    }

    fclose(fp);

    return true;
}



// find min/max in one dimension
void find_min_max(data_type* points, uint *idx, uint index, uint dim, uint n, coord_type *ret_min, coord_type *ret_max)
{
    coord_type min = get_coord(points,idx,index,dim);
    coord_type max = get_coord(points,idx,index,dim);
    coord_type tmp;
    // inefficient way of searching the min/max
    for (int i=0; i<n; i++) {
        tmp = get_coord(points,idx,index+i,dim);
        if (tmp < min) {
            min = tmp;
        }
        if (tmp >= max) {
            max = tmp;
        }
    }
    *ret_min = min;
    *ret_max = max;
}


// bounding box is characterised by two points: low and high corner
void compute_bounding_box(data_type* points, uint *idx, uint index, uint n, data_type *bnd_lo, data_type *bnd_hi)
{
    coord_type max;
    coord_type min;
    for (uint i=0;i<D;i++) {
        find_min_max(points,idx,index,i,n,&min,&max);
        set_coord_type_vector_item(&bnd_lo->value, min, i);
        set_coord_type_vector_item(&bnd_hi->value, max, i);
    }
}


/*
* The splitting routine is essentially a median search,
* i.e. finding the median and split the array about it.
* There are several algorithms for the median search
* (an overview is given at http://ndevilla.free.fr/median/median/index.html):
* - AHU (1)
* - WIRTH (2)
* - QUICKSELECT (3)
* - TORBEN (4)
* (1) and (2) are essentially the same in recursive and non recursive versions.
* (2) is among the fastest in sequential programs.
* (3) is similar to what quicksort uses and is as fast as (2).
* Both (2) and (3) require permuting array elements.
* (4) is significantly slower but only reads the array without modifying it.
* The implementation below is a simplified version of (2).
*/

void split_bounding_box(data_type* points, uint *idx, uint index, uint n, data_type *bnd_lo, data_type *bnd_hi, uint *n_lo, uint *cdim, coord_type *cval)
{
    // search for dimension with longest egde
    coord_type longest_egde = get_coord_type_vector_item(bnd_hi->value,0) - get_coord_type_vector_item(bnd_lo->value,0);
    uint dim = 0;

    for (uint d=0; d<D; d++) {
        coord_type tmp = get_coord_type_vector_item(bnd_hi->value,d) - get_coord_type_vector_item(bnd_lo->value,d);
        if (longest_egde < tmp) {
            longest_egde = tmp;
            dim = d;
        }
    }

    *cdim = dim;

    coord_type ideal_threshold = (get_coord_type_vector_item(bnd_hi->value,dim) + get_coord_type_vector_item(bnd_lo->value,dim)) / 2;
    coord_type min,max;

    find_min_max(points,idx,index,dim,n,&min,&max);

    coord_type threshold = ideal_threshold;

    if (ideal_threshold < min) {
        threshold = min;
    } else if (ideal_threshold > max) {
        threshold = max;
    }

    *cval = threshold;

    // Wirth's method
    int l = 0;
    int r = n-1;

    for(;;) {                                // partition points[0..n-1]
        while (l < n && get_coord(points,idx,l+index,dim) < threshold) {
            l++;
        }
        while (r >= 0 && get_coord(points,idx,r+index,dim) >= threshold) {
            r--;
        }
        if (l > r) break; // avoid this
        coord_swap(idx,index,l,r);
        l++; r--;
    }

    uint br1 = l;                        // now: data_points[0..br1-1] < threshold <= data_points[br1..n-1]
    r = n-1;
    for(;;) {                                // partition pa[br1..n-1] about threshold
        while (l < n && get_coord(points,idx,l+index,dim) <= threshold) {
            l++;
        }
        while (r >= br1 && get_coord(points,idx,r+index,dim) > threshold) {
            r--;
        }
        if (l > r) break; // avoid this
        coord_swap(idx,index,l,r);
        l++; r--;
    }
    uint br2 = l;                        // now: points[br1..br2-1] == threshold < points[br2..n-1]
    if (ideal_threshold < min) *n_lo = 0+1;
    else if (ideal_threshold > max) *n_lo = n-1;
    else if (br1 > n/2) *n_lo = br1;
    else if (br2 < n/2) *n_lo = br2;
    else *n_lo = n/2;
}




// setup the basic properties of a tree node
void setup_tree_node(uint idx, uint n, data_type bnd_lo, data_type bnd_hi, kdTree_type *u)
{
    // compute cell mid point
    data_type tmp_mid;
    for (uint d=0;d<D;d++) {
        coord_type tmp1 = get_coord_type_vector_item(bnd_lo.value, d);
        coord_type tmp2 = get_coord_type_vector_item(bnd_hi.value, d);
        coord_type tmp3 = (tmp1+tmp2) / 2;
        set_coord_type_vector_item(&tmp_mid.value,tmp3,d);
    }

    data_type_ext wgtCentDummy;
    coord_type_ext sumsqDummy;

    // set the basic stuff (everything but the sums)
    set_kd_tree_type_items(	u,
    						idx,
    						wgtCentDummy,
    						tmp_mid,
    						bnd_hi,
    						bnd_lo,
    						sumsqDummy,
    						(coord_type_ext)n,
    						NULL_PTR,
    						NULL_PTR);
    /*
    u->midPoint = tmp_mid;
    u->count = (coord_type)n; // a bit dirty
    u->bnd_lo = bnd_lo;
    u->bnd_hi = bnd_hi;
    u->idx = idx;
    u->left = NULL_PTR;
    u->right = NULL_PTR;
    */
}


// build up a kd-tree from a set of data points
node_pointer buildkdTree(data_type* points, uint *idx, uint index, uint n, data_type *bnd_lo, data_type *bnd_hi, node_pointer root_offset, kdTree_type *heap)
{
    uint debug_counter = 0;
    uint debug_leaf_counter = 0;
    uint debug_int_counter = 0;

    //define stack data structure
    //stack_record_type bt_stack_array[N]; //STACK_SIZE=N
    uint bt_stack_pointer;

    init_stack(&bt_stack_pointer);

    //node_pointer freelist[HEAP_SIZE];
    //node_pointer next_free_location;

    //init_allocator<node_pointer>(freelist, &next_free_location, HEAP_SIZE-1);
    //node_pointer rel_int_node_addr  = (0 & ~(1<<(NODE_POINTER_BITWIDTH-1))) + root_offset;
    //node_pointer rel_leaf_node_addr = (0 | (1<<(NODE_POINTER_BITWIDTH-1))) + root_offset;
    node_pointer node_addr = (root_offset+1);

    //node_pointer root = malloc<node_pointer>(freelist, &next_free_location);
    //kdTree_ptr root_ptr = make_pointer<kdTree_type>(heap, (uint)root);
    node_pointer root = node_addr; //rel_int_node_addr;
    kdTree_type *root_ptr = make_pointer<kdTree_type>(heap, (uint)root);
    //rel_int_node_addr++;
    node_addr++;

    debug_int_counter++;

    setup_tree_node(index, n, *bnd_lo, *bnd_hi, root_ptr);

    uint stack_length = push(root, 0, 0, false, &bt_stack_pointer, bt_stack_array);

    while (stack_length != 0) {
        debug_counter++;
        // fetch head of stack
        node_pointer u;
        centre_list_pointer dummy_c;
        centre_index_type dummy_k;
        bool dummy_d;
        stack_length = pop(&u, &dummy_c, &dummy_k, &dummy_d, &bt_stack_pointer, bt_stack_array);
        kdTree_type *u_ptr = make_pointer<kdTree_type>(heap, (uint)u);

        data_type_ext dummy_wgtCent;
        data_type dummy_midPoint;
        data_type bnd_lo;
        data_type bnd_hi;
        coord_type_ext dummy_sumsq;
        coord_type_ext c_count;
        node_pointer u_left;
        node_pointer u_right;
        uint indx;
        get_kd_tree_type_items(*u_ptr,
        					   &indx,
        					   &dummy_wgtCent,
        					   &dummy_midPoint,
        					   &bnd_hi,
        					   &bnd_lo,
        					   &dummy_sumsq,
        					   &c_count,
        					   &u_left,
        					   &u_right);

        uint count = (uint)c_count;

        if (count>1) { // not a leaf node!

            // split point set
            uint cdim;
            coord_type cval;
            uint n_lo;
            split_bounding_box(points, idx, indx, count, &bnd_lo, &bnd_hi, &n_lo, &cdim, &cval);

            // create new children
            node_pointer left_child;
            node_pointer right_child;

            left_child = node_addr;
            node_addr++;

            right_child = node_addr;
            node_addr++;

            /*
            if (n_lo == 1) {
                left_child = rel_leaf_node_addr;
                rel_leaf_node_addr++;
                debug_leaf_counter++;
            } else {
                left_child = rel_int_node_addr;
                rel_int_node_addr++;
                debug_int_counter++;
            }
            if (count-n_lo == 1) {
                right_child = rel_leaf_node_addr;
                rel_leaf_node_addr++;
                debug_leaf_counter++;
            } else {
                right_child = rel_int_node_addr;
                rel_int_node_addr++;
                debug_int_counter++;
            }
			*/
            kdTree_type *left_child_ptr = make_pointer<kdTree_type>(heap, (uint)left_child);
            kdTree_type *right_child_ptr = make_pointer<kdTree_type>(heap, (uint)right_child);

            // link parent and children
            //u_ptr->left = left_child;
            //u_ptr->right = right_child;


            set_kd_tree_type_items(	u_ptr,
            						indx,
            						dummy_wgtCent,
            						dummy_midPoint,
            						bnd_hi,
            						bnd_lo,
            						dummy_sumsq,
            						c_count,
            						left_child,
            						right_child);


            // update bounding box
            data_type new_bnd_hi = bnd_hi;
            data_type new_bnd_lo = bnd_lo;

            set_coord_type_vector_item(&new_bnd_hi.value,cval,cdim);
            set_coord_type_vector_item(&new_bnd_lo.value,cval,cdim);

            // setup children
            setup_tree_node(indx,n_lo,bnd_lo,new_bnd_hi,left_child_ptr);
            setup_tree_node(indx+n_lo,count-n_lo,new_bnd_lo,bnd_hi,right_child_ptr);

            // push children onto stack
            stack_length = push(right_child,0,0,false,&bt_stack_pointer, bt_stack_array);
            stack_length = push(left_child,0,0,false,&bt_stack_pointer, bt_stack_array);
        }

    }

    update_sums(root, points, idx, heap);
    scale_sums(root,heap);

    return root;
}


void dot_product_tb(data_type_ext p1,data_type_ext p2, coord_type_ext *r)
{
    coord_type_ext tmp = 0;
    for (uint d=0;d<D;d++) {
        tmp += get_coord_type_vector_item(p1.value,d)*get_coord_type_vector_item(p2.value,d);
    }
    *r = tmp;
}


// updates the wgtCent and sum_sq fields of every node
// problem: this requires post-order traversal
void update_sums(node_pointer root, data_type* points, uint *idx, kdTree_type *heap)
{
    //define stack data structure
    //stack_record_type bt_stack_array[N]; //STACK_SIZE=N
    uint bt_stack_pointer;

    // re-init stack
    init_stack(&bt_stack_pointer);

    uint counter = 1;

    node_pointer prev = NULL_PTR;
    kdTree_type *prev_ptr;

    uint stack_length = push(root,0,0,false,&bt_stack_pointer, bt_stack_array);

    while (stack_length != 0) {

        // fetch head of stack (without removing it)
        node_pointer curr;
        centre_list_pointer dummy_c;
        centre_index_type dummy_k;
        bool dummy_d;
        lookahead(&curr, &dummy_c, &dummy_k, &dummy_d, &bt_stack_pointer, bt_stack_array);
        kdTree_type *curr_ptr = make_pointer<kdTree_type>(heap, (uint)curr);

        if (prev != NULL_PTR)
            prev_ptr = make_pointer<kdTree_type>(heap, (uint)prev);

        uint curr_indx;
        data_type_ext curr_wgtCent;
        data_type curr_midPoint;
        data_type curr_bnd_lo;
        data_type curr_bnd_hi;
        coord_type_ext curr_sum_sq;
        coord_type_ext curr_count;
        node_pointer curr_left;
        node_pointer curr_right;
        get_kd_tree_type_items(*curr_ptr,
        					   &curr_indx,
        					   &curr_wgtCent,
        					   &curr_midPoint,
        					   &curr_bnd_hi,
        					   &curr_bnd_lo,
        					   &curr_sum_sq,
        					   &curr_count,
        					   &curr_left,
        					   &curr_right);

        uint prev_indx;
        data_type_ext prev_wgtCent;
        data_type prev_midPoint;
        data_type prev_bnd_lo;
        data_type prev_bnd_hi;
        coord_type_ext prev_sum_sq;
        coord_type_ext prev_count;
        node_pointer prev_left;
        node_pointer prev_right;
        get_kd_tree_type_items(*prev_ptr,
        					   &prev_indx,
        					   &prev_wgtCent,
        					   &prev_midPoint,
        					   &prev_bnd_hi,
        					   &prev_bnd_lo,
        					   &prev_sum_sq,
        					   &prev_count,
        					   &prev_left,
        					   &prev_right);

        //is prev parent of curr?
        if ( (prev == NULL_PTR) || (prev_left == curr) || (prev_right == curr)) {
            if (curr_left != NULL_PTR) {
                stack_length = push(curr_left,0,0,false,&bt_stack_pointer, bt_stack_array);
            } else if (curr_right != NULL_PTR) {
                stack_length = push(curr_right,0,0,false,&bt_stack_pointer, bt_stack_array);
            }
        } else if (curr_left == prev) {
            if (curr_right != NULL_PTR) {
                stack_length = push(curr_right, 0,0,false, &bt_stack_pointer, bt_stack_array);
            }
        } else {
            // remove curr from stack (could be a dummy read as well)
            node_pointer dummy;
            stack_length = pop(&curr, &dummy_c, &dummy_k, &dummy_d, &bt_stack_pointer, bt_stack_array);

            data_type_ext tmp_wgtCent;
            coord_type_ext tmp_sum_sq;

            node_pointer lc = curr_left;
            node_pointer rc = curr_right;
            kdTree_type *lc_ptr = make_pointer<kdTree_type>(heap, (uint)lc);
            kdTree_type *rc_ptr = make_pointer<kdTree_type>(heap, (uint)rc);

            uint lc_indx;
            data_type_ext lc_wgtCent;
            data_type lc_midPoint;
            data_type lc_bnd_lo;
            data_type lc_bnd_hi;
            coord_type_ext lc_sum_sq;
            coord_type_ext lc_count;
            node_pointer lc_left;
            node_pointer lc_right;
            get_kd_tree_type_items(*lc_ptr,
            					   &lc_indx,
            					   &lc_wgtCent,
            					   &lc_midPoint,
            					   &lc_bnd_hi,
            					   &lc_bnd_lo,
            					   &lc_sum_sq,
            					   &lc_count,
            					   &lc_left,
            					   &lc_right);

            uint rc_indx;
            data_type_ext rc_wgtCent;
            data_type rc_midPoint;
            data_type rc_bnd_lo;
            data_type rc_bnd_hi;
            coord_type_ext rc_sum_sq;
            coord_type_ext rc_count;
            node_pointer rc_left;
            node_pointer rc_right;
            get_kd_tree_type_items(*rc_ptr,
            					   &rc_indx,
            					   &rc_wgtCent,
            					   &rc_midPoint,
            					   &rc_bnd_hi,
            					   &rc_bnd_lo,
            					   &rc_sum_sq,
            					   &rc_count,
            					   &rc_left,
            					   &rc_right);

            if ( (lc == NULL_PTR) && (rc == NULL_PTR) ) { //leaf node?
                tmp_wgtCent = conv_short_to_long(points[idx[curr_indx]]);
                dot_product_tb(tmp_wgtCent,tmp_wgtCent,&tmp_sum_sq);
            } else if ( (lc != NULL_PTR) && (rc == NULL_PTR) ) {
                tmp_wgtCent = lc_wgtCent;
                tmp_sum_sq = lc_sum_sq;
            } else if ( (lc == NULL_PTR) && (rc != NULL_PTR) ) {
                tmp_wgtCent = rc_wgtCent;
                tmp_sum_sq = rc_sum_sq;
            } else {
                for (uint d=0; d<D; d++) {
                    coord_type_ext tmp = get_coord_type_vector_ext_item(lc_wgtCent.value,d) + get_coord_type_vector_ext_item(rc_wgtCent.value,d);
                    set_coord_type_vector_ext_item(&tmp_wgtCent.value,tmp,d);
                }
                tmp_sum_sq = lc_sum_sq + rc_sum_sq;
            }
            curr_wgtCent = tmp_wgtCent;
            curr_sum_sq = tmp_sum_sq;

            set_kd_tree_type_items(curr_ptr,
            					   curr_indx,
            					   curr_wgtCent,
            					   curr_midPoint,
            					   curr_bnd_hi,
            					   curr_bnd_lo,
            					   curr_sum_sq,
            					   curr_count,
            					   curr_left,
            					   curr_right);


            //printf("%d %d, %d\n",curr_ptr->count,curr_ptr->sum_sq,counter++);
        }

        // update prev
        prev = curr;
    }
}


// traverse the tree in pre-order and scale the sum_sq-field of each tree node
void scale_sums(node_pointer root, kdTree_type *heap)
{
    //define stack data structure
    //stack_record_type bt_stack_array[N]; //STACK_SIZE=N
    uint bt_stack_pointer;

    // re-init stack
    init_stack(&bt_stack_pointer);

    uint stack_length = push(root, 0,0, false, &bt_stack_pointer, bt_stack_array);

    while (stack_length != 0) {

        // fetch head of stack
        node_pointer u;
        centre_list_pointer dummy_c;
        centre_index_type dummy_k;
        bool dummy_d;
        stack_length = pop(&u, &dummy_c, &dummy_k, &dummy_d, &bt_stack_pointer, bt_stack_array);
        kdTree_type *u_ptr = make_pointer<kdTree_type>(heap, (uint)u);

        uint u_indx;
        data_type_ext u_wgtCent;
        data_type u_midPoint;
        data_type u_bnd_lo;
        data_type u_bnd_hi;
        coord_type_ext u_sum_sq;
        coord_type_ext u_count;
        node_pointer u_left;
        node_pointer u_right;
        get_kd_tree_type_items(*u_ptr,
        					   &u_indx,
        					   &u_wgtCent,
        					   &u_midPoint,
        					   &u_bnd_hi,
        					   &u_bnd_lo,
        					   &u_sum_sq,
        					   &u_count,
        					   &u_left,
        					   &u_right);

        u_sum_sq = u_sum_sq >> MUL_FRACTIONAL_BITS;
        //for (uint d=0; d<D; d++) {
        //    u_ptr->wgtCent.value[d] /= 1;
        //}

        set_kd_tree_type_items(u_ptr,
        					   u_indx,
        					   u_wgtCent,
        					   u_midPoint,
        					   u_bnd_hi,
        					   u_bnd_lo,
        					   u_sum_sq,
        					   u_count,
        					   u_left,
        					   u_right);


        if ((u_left != NULL_PTR) || (u_right != NULL_PTR)) {

            node_pointer left_child = u_left;
            node_pointer right_child = u_right;
            //kdTree_ptr left_child_ptr = make_pointer<kdTree_type>(heap, (uint)left_child);
            //kdTree_ptr right_child_ptr = make_pointer<kdTree_type>(heap, (uint)right_child);

            // push children onto stack
            stack_length = push(right_child, 0,0, false, &bt_stack_pointer, bt_stack_array);
            stack_length = push(left_child, 0,0, false, &bt_stack_pointer, bt_stack_array);
        }
    }
}


// write all fields of a tree node into a file
void write_tree_node_to_file(kdTree_type u, node_pointer idx, FILE *fp)
{
    uint dummy_indx;
    data_type_ext u_wgtCent;
    data_type u_midPoint;
    data_type u_bnd_lo;
    data_type u_bnd_hi;
    coord_type_ext u_sum_sq;
    coord_type_ext u_count;
    node_pointer u_left;
    node_pointer u_right;
    get_kd_tree_type_items(u,
    					   &dummy_indx,
    					   &u_wgtCent,
    					   &u_midPoint,
    					   &u_bnd_hi,
    					   &u_bnd_lo,
    					   &u_sum_sq,
    					   &u_count,
    					   &u_left,
    					   &u_right);

	kdTree_type tmp_u;

	set_kd_tree_type_items(	&tmp_u,
							(uint)idx,
							u_wgtCent,
							u_midPoint,
							u_bnd_hi,
							u_bnd_lo,
							u_sum_sq,
							u_count,
							u_left,
							u_right);



	// verilog hex format
	std::string str = tmp_u.value.to_string(16,false);
	str.erase(0,2);

	fprintf(fp,"%s\n",str.c_str());


	/*

    fprintf(fp,"%d ",(uint)idx);
    fprintf(fp,"%d ",(uint)u_left);
    fprintf(fp,"%d ",(uint)u_right);
    fprintf(fp,"%d ",(int)u_count);
    fprintf(fp,"%d ",(int)u_sum_sq);

    for (uint d=0; d<D; d++) {
        fprintf(fp,"%d ",(int)get_coord_type_vector_item(u_bnd_lo.value,d));
    }
    for (uint d=0; d<D; d++) {
        fprintf(fp,"%d ",(int)get_coord_type_vector_item(u_bnd_hi.value,d));
    }
    for (uint d=0; d<D; d++) {
        fprintf(fp,"%d ",(int)get_coord_type_vector_item(u_midPoint.value,d));
    }
    for (uint d=0; d<D-1; d++) {
        fprintf(fp,"%d ",(int)get_coord_type_vector_ext_item(u_wgtCent.value,d));
    }
    fprintf(fp,"%d\n",(int)get_coord_type_vector_ext_item(u_wgtCent.value,D-1));

    */
}


// write all fields of a tree node into a .dat file
void write_tree_node_to_file_bin(kdTree_type u, node_pointer idx, FILE *fp)
{
    uint dummy_indx;
    data_type_ext u_wgtCent;
    data_type u_midPoint;
    data_type u_bnd_lo;
    data_type u_bnd_hi;
    coord_type_ext u_sum_sq;
    coord_type_ext u_count;
    node_pointer u_left;
    node_pointer u_right;
    get_kd_tree_type_items(u,
    					   &dummy_indx,
    					   &u_wgtCent,
    					   &u_midPoint,
    					   &u_bnd_hi,
    					   &u_bnd_lo,
    					   &u_sum_sq,
    					   &u_count,
    					   &u_left,
    					   &u_right);

	kdTree_type tmp_u;

	set_kd_tree_type_items(	&tmp_u,
							(uint)idx,
							u_wgtCent,
							u_midPoint,
							u_bnd_hi,
							u_bnd_lo,
							u_sum_sq,
							u_count,
							u_left,
							u_right);


	for (uint i=0; i<TREE_NODE_BITWIDTH/8; i++) {
		uint lo = i*sizeof(char)*8;
		uint hi = (i+1)*sizeof(char)*8-1;

		unsigned char c = (unsigned char)tmp_u.value.range(hi,lo);
		putc(c,fp);
	}

	for (uint i=TREE_NODE_BITWIDTH/8; i<512/8; i++) {
		putc(0,fp);
	}

}



// traverse the kd-tree in pre-order and write the tree node data to a file
void readout_tree(bool write2file, uint n, uint k, double std_dev, node_pointer root, kdTree_type *heap, uint offset, uint partition, kdTree_type *image, node_pointer *image_addr)
{

    //define stack data structure
    //stack_record_type bt_stack_array[N]; //STACK_SIZE=N

    uint bt_stack_pointer;

    // re-init stack
    init_stack(&bt_stack_pointer);

    uint stack_length = push(root, 0,0, false, &bt_stack_pointer, bt_stack_array);
    uint counter = offset;

    FILE *fp;
    FILE *fp_bin;

    if (write2file==true) {

        char filename[1024];
        char filename_bin[1024];
        make_tree_data_file_name(filename,n,k,D,std_dev,true);
        make_tree_data_file_name_bin(filename_bin,n,k,D,std_dev);
        if (partition == 0) {
            fp = fopen(filename, "w");
        	fp_bin = fopen(filename_bin, "wb");
        } else {
            fp = fopen(filename, "a");
            fp_bin = fopen(filename_bin, "ab");
        }
    }


	// write root into address 0 (FIXME: find out why this is necessary)
    kdTree_type *root_ptr = make_pointer<kdTree_type>(heap, (uint)root);
    uint root_indx;
    data_type_ext root_wgtCent;
    data_type root_midPoint;
    data_type root_bnd_lo;
    data_type root_bnd_hi;
    coord_type_ext root_sum_sq;
    coord_type_ext root_count;
    node_pointer root_left;
    node_pointer root_right;
    get_kd_tree_type_items(*root_ptr,
    					   &root_indx,
    					   &root_wgtCent,
    					   &root_midPoint,
    					   &root_bnd_hi,
    					   &root_bnd_lo,
    					   &root_sum_sq,
    					   &root_count,
    					   &root_left,
    					   &root_right);


    while (stack_length != 0) {

        // fetch head of stack
        node_pointer u;
        centre_list_pointer dummy_c;
        centre_index_type dummy_k;
        bool dummy_d;
        stack_length = pop(&u, &dummy_c, &dummy_k, &dummy_d, &bt_stack_pointer, bt_stack_array);
        kdTree_type *u_ptr = make_pointer<kdTree_type>(heap, (uint)u);

        uint u_indx;
        data_type_ext u_wgtCent;
        data_type u_midPoint;
        data_type u_bnd_lo;
        data_type u_bnd_hi;
        coord_type_ext u_sum_sq;
        coord_type_ext u_count;
        node_pointer u_left;
        node_pointer u_right;
        get_kd_tree_type_items(*u_ptr,
        					   &u_indx,
        					   &u_wgtCent,
        					   &u_midPoint,
        					   &u_bnd_hi,
        					   &u_bnd_lo,
        					   &u_sum_sq,
        					   &u_count,
        					   &u_left,
        					   &u_right);

        u = u + (node_pointer)partition*DRAM_REGION_SIZE;

        kdTree_type tmp_u;

        set_kd_tree_type_items(&tmp_u,
        					   u,
        					   u_wgtCent,
        					   u_midPoint,
        					   u_bnd_hi,
        					   u_bnd_lo,
        					   u_sum_sq,
        					   u_count,
        					   u_left,
        					   u_right);

        image_addr[counter] = u;
        image[counter] = tmp_u;

        if (write2file==true) {
            write_tree_node_to_file(*u_ptr, u, fp);
            write_tree_node_to_file_bin(*u_ptr,u,fp_bin);
        }

        counter++;

        if ((u_left != NULL_PTR) || (u_right != NULL_PTR)) {

            node_pointer left_child = u_left;
            node_pointer right_child = u_right;

            // push children onto stack
            stack_length = push(right_child, 0,0, false, &bt_stack_pointer, bt_stack_array);
            stack_length = push(left_child, 0,0, false, &bt_stack_pointer, bt_stack_array);
        }
    }

    /*
    for (uint i=0; i<5; i++) {
		image_addr[counter] = 0;
		image[counter] = *root_ptr;
	    if (write2file==true) {
	        write_tree_node_to_file(*root_ptr, 0, fp);
	    }
		counter++;
    }
	*/

    //readout_heapimage<node_pointer,kdTree_type>(heap, image, heapsize);


    if (write2file==true) {

        fclose(fp);
        fclose(fp_bin);
    }

}

