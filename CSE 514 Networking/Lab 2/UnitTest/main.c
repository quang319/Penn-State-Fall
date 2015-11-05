/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.c
 * Author: quang
 *
 * Created on November 5, 2015, 12:35 AM
 */

#include <stdio.h>
#include <stdlib.h>
struct rtpkt {
  int sourceid;       /* id of sending router sending this pkt */
  int destid;         /* id of router to which pkt being sent 
                         (must be an immediate neighbor) */
  int mincost[4];    /* min cost to node 0 ... 3 */
  };

/*
 * 
 */
int main(int argc, char** argv) {

    return (EXIT_SUCCESS);
}

