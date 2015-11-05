/*
 * File:   newcunittest1.c
 * Author: quang
 *
 * Created on Nov 5, 2015, 1:07:11 AM
 */

#include <stdio.h>
#include <stdlib.h>
#include <CUnit/Basic.h>
#include "node0.h"

/*
 * CUnit Test Suite
 */

struct distance_table 
{
  int costs[4][4];
} dt0;

int init_suite(void) {
    return 0;
}

int clean_suite(void) {
    return 0;
}

void Test_ValidInit() {
    int expectedResult = { {0,1,3,7}, {999,999,999,999}, {999,999,999,999}, {999,999,999,999}};
    int i, j;
    rtinit0();
    struct distance_table result = getTable();

    for (i = 0; i < 4; ++i)
    {
        for (j = 0; j < 4; ++j)
        {
          CU_ASSERT_EQUAL(result.costs[i][j], expectedResult[i][j]);
        }
    }

}

void test2() {
    CU_ASSERT(2 * 2 == 5);
}

int main() {
    CU_pSuite pSuite = NULL;

    /* Initialize the CUnit test registry */
    if (CUE_SUCCESS != CU_initialize_registry())
        return CU_get_error();

    /* Add a suite to the registry */
    pSuite = CU_add_suite("newcunittest1", init_suite, clean_suite);
    if (NULL == pSuite) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Add the tests to the suite */
    if ((NULL == CU_add_test(pSuite, "Test_ValidInit", Test_ValidInit)) ||
            (NULL == CU_add_test(pSuite, "test2", test2))) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Run all tests using the CUnit Basic interface */
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}
