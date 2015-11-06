#include <stdio.h>

extern struct rtpkt {
  int sourceid;       /* id of sending router sending this pkt */
  int destid;         /* id of router to which pkt being sent 
                         (must be an immediate neighbor) */
  int mincost[4];    /* min cost to node 0 ... 3 */
  };

extern int TRACE;
extern int YES;
extern int NO;

static int connectcosts3[4] = { 7,  999,  2, 0 };
static int neighbors[2] = {0,2};
static int node = 3;


struct distance_table 
{
  int costs[4][4];
} dt3;


static void send2Neighbors();
/* students to write the following two routines, and maybe some others */

void rtinit3() 
{
  int i,j;
  for (i = 0; i < 4; ++i)
  {
    for (j = 0; j < 4; ++j)
    {
      if (i == 3)
      {
        dt3.costs[i][j] = connectcosts3[j];
      }
      else
      {
        dt3.costs[i][j] = 999;
      }
    }
  }
  // if (TRACE == 1)
  //   printdt2(&dt3);

  send2Neighbors();
}


void rtupdate3(struct rtpkt *rcvdpkt)
{
  

  int i,j,k, changedFlg = 0;

  int source = rcvdpkt -> sourceid;
  for (i = 0; i < 4; i++)
  {
    dt3.costs[source][i] = rcvdpkt -> mincost[i];
  }

  for (j = 0; j < 4; j++)
  {
    for (k = 0; k < 4; k++)
    {
      if (dt3.costs[node][j] > (dt3.costs[node][k] + dt3.costs[k][j]))
      {
        dt3.costs[node][j] = dt3.costs[node][k] + dt3.costs[k][j];
        changedFlg = 1;
      }
    }
  }

  // inform all the neighbors if our mindist table has changed
  if (changedFlg != 0)
    send2Neighbors();

  if (TRACE == 1)
    printdt2(&dt3);



}


printdt3(struct distance_table *dtptr)
{
  printf("             via     \n");
  printf("   D3 |    0     2 \n");
  printf("  ----|-----------\n");
  printf("     0|  %3d   %3d\n",dtptr->costs[0][0], dtptr->costs[0][2]);
  printf("dest 1|  %3d   %3d\n",dtptr->costs[1][0], dtptr->costs[1][2]);
  printf("     2|  %3d   %3d\n",dtptr->costs[2][0], dtptr->costs[2][2]);

}


void getTable3(struct distance_table *result)
{
  *result = dt3;
} 

static void send2Neighbors()
{
  struct rtpkt pktToSend[sizeof(neighbors)/4];
  int i,j;

  for (i = 0; i< (sizeof(neighbors)/4);i++ )
  {
    pktToSend[i].sourceid = node;
    pktToSend[i].destid = neighbors[i];
    for (j =0; j < 4; j++)
    {
      pktToSend[i].mincost[j] = dt3.costs[node][j];
    }
    tolayer2(pktToSend[i]);
  }

}



