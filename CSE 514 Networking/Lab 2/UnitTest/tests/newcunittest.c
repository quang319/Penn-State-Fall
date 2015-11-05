/*
 * File:   newcunittest.c
 * Author: quang
 *
 * Created on Nov 5, 2015, 1:29:27 AM
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
  };

int init_suite(void) {
    return 0;
}

int clean_suite(void) {
    return 0;
}

//void rtinit0();
//distance_table getTable();

void testInit() {

    rtinit0();
    int expectedResult[4][4] = { {0,1,3,7}, {999,999,999,999}, {999,999,999,999}, {999,999,999,999}};
    int i, j;
    rtinit0();
    struct distance_table result;
    getTable(&result);

    for (i = 0; i < 4; ++i)
    {
        for (j = 0; j < 4; ++j)
        {
            if (result.costs[i][j] != expectedResult[i][j])
                CU_ASSERT(0);
        }
    }
}

void testOnePkg() {
    int expectedResult[4][4] = { {0,1,2,7}, {1,0,1,999}, {999,999,999,999}, {999,999,999,999}};
    int i, j;
    rtinit0();

    // Passsing packaget from 1
    struct rtpkt pkg;
    pkg.sourceid = 1;
    pkg.destid = 0;
    int value [4] = {1,0,1,999};
    for (i = 0; i < 4; i++)
    {
        pkg.mincost[i] = value[i];
    }
    rtupdate0(&pkg);

    // Get the resulting table and make sure it is right
    struct distance_table result;
    getTable(&result);

    for (i = 0; i < 4; ++i)
    {
        for (j = 0; j < 4; ++j)
        {
            if (result.costs[i][j] != expectedResult[i][j])
                CU_ASSERT(0);
        }
    }
}

void testTwoPkg() {
    int expectedResult[4][4] = { {0,1,2,4}, {1,0,1,999}, {3,1,0,2}, {999,999,999,999}};
    int i, j;
    rtinit0();

    // Passsing packaget from 1
    struct rtpkt pkg1;
    pkg1.sourceid = 1;
    pkg1.destid = 0;
    int value1 [4] = {1,0,1,999};
    for (i = 0; i < 4; i++)
    {
        pkg1.mincost[i] = value1[i];
    }
    rtupdate0(&pkg1);

    // Passsing packaget from 1
    struct rtpkt pkg2;
    pkg2.sourceid = 2;
    pkg2.destid = 0;
    int value2 [4] = {3,1,0,2};
    for (i = 0; i < 4; i++)
    {
        pkg2.mincost[i] = value2[i];
    }
    rtupdate0(&pkg2);

    // Get the resulting table and make sure it is right
    struct distance_table result;
    getTable(&result);

    for (i = 0; i < 4; ++i)
    {
        for (j = 0; j < 4; ++j)
        {
            if (result.costs[i][j] != expectedResult[i][j])
                CU_ASSERT(0);
        }
    }
}

int main() {
    CU_pSuite pSuite = NULL;

    /* Initialize the CUnit test registry */
    if (CUE_SUCCESS != CU_initialize_registry())
        return CU_get_error();

    /* Add a suite to the registry */
    pSuite = CU_add_suite("newcunittest", init_suite, clean_suite);
    if (NULL == pSuite) 
    {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Add the tests to the suite */
    if ((NULL == CU_add_test(pSuite, "testInit", testInit)  ||
        (NULL == CU_add_test(pSuite, "testOnePkg", testOnePkg)) ||
        (NULL == CU_add_test(pSuite, "testTwoPkg", testOnePkg)))) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* Run all tests using the CUnit Basic interface */
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}
