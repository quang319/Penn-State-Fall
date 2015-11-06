/*
 * File:   Test_Node3.c
 * Author: quang
 *
 * Created on Nov 5, 2015, 6:03:11 PM
 */

#include <stdio.h>
#include <stdlib.h>
#include <CUnit/Basic.h>

/*
 * CUnit Test Suite
 */

struct distance_table
{
  int costs[4][4];
};

struct rtpkt {
  int sourceid;       /* id of sending router sending this pkt */
  int destid;         /* id of router to which pkt being sent 
                         (must be an immediate neighbor) */
  int mincost[4];    /* min cost to node 0 ... 3 */
  }packets[3];

int init_suite(void) {

    // Setting up packet 0
    packets[0].sourceid = 0;
    packets[0].destid = 3;
    int value1 [4] = {0,1,3,7};
    int i;
    for (i = 0; i < 4; i++)
    {
        packets[0].mincost[i] = value1[i];
    }

    // Setting up packet 1
    packets[1].sourceid = 1;
    packets[1].destid = 3;
    int value2 [4] = {1,0,1,999};
    for (i = 0; i < 4; i++)
    {
        packets[1].mincost[i] = value2[i];
    }

    // Setting up packet 3
    packets[2].sourceid = 2;
    packets[2].destid = 3;
    int value3 [4] = {3,1,0,2};
    for (i = 0; i < 4; i++)
    {
        packets[2].mincost[i] = value3[i];
    }

    return 0;
}

int clean_suite(void) {
    return 0;
}

void testInit3() {

    int expectedResult[4][4] = { {999,999,999,999}, {999,999,999,999}, {999,999,999,999}, {7,999,2,0}};
    int i, j;
    rtinit3();
    struct distance_table result;
    getTable3(&result);

    for (i = 0; i < 4; ++i)
    {
        for (j = 0; j < 4; ++j)
        {
            if (result.costs[i][j] != expectedResult[i][j])
                CU_ASSERT(0);
        }
    }
}

void testAllPermutation3() {
    int permutation[6][3] = { {0,1,2}, {0,2,1}, {1,0,2}, {1,2,0}, {2,0,1}, {2,1,0}};
    int expectedResult[4][4] = { {0,1,3,7}, {1,0,1,999}, {3,1,0,2}, {5,3,2,0}};
    int i, j, k, l;
    rtinit3();

    for (k = 0; k < 6; k++)
    {
        for (l = 0; l < 3; l++)
        {
            int index = permutation[k][l];
            rtupdate3(&packets[index]);
        }

        // Get the resulting table and make sure it is right
        struct distance_table result;
        getTable3(&result);

        for (i = 0; i < 4; ++i)
        {
            for (j = 0; j < 4; ++j)
            {
                if (result.costs[i][j] != expectedResult[i][j])
                {
                    if ((i == 3) && (j == 0))
                    {
                        if (result.costs[i][j] != 4)
                            CU_ASSERT(0);
                    }
                    else
                        CU_ASSERT(0);
                }
            }
        }
    } 
}


int main() {
    CU_pSuite pSuite = NULL;

    /* Initialize the CUnit test registry */
    if (CUE_SUCCESS != CU_initialize_registry())
        return CU_get_error();

    /* Add a suite to the registry */
    pSuite = CU_add_suite("Test_Node3", init_suite, clean_suite);
    if (NULL == pSuite) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Add the tests to the suite */
    if ((NULL == CU_add_test(pSuite, "testInit3", testInit3)) ||
        (NULL == CU_add_test(pSuite, "testAllPermutation3", testAllPermutation3))) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Run all tests using the CUnit Basic interface */
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}