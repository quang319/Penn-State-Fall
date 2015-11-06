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

static int connectcosts[4] = { 3,  1,  0, 2 };
static int neighbors[3] = {0,1,3};
static int node = 2;

struct distance_table 
{
  int costs[4][4];
} dt2;

static void send2Neighbors();

/* students to write the following two routines, and maybe some others */

void rtinit2() 
{
  int i,j;
  for (i = 0; i < 4; ++i)
  {
    for (j = 0; j < 4; ++j)
    {
      if (i == 2)
      {
        dt2.costs[i][j] = connectcosts[j];
      }
      else
      {
        dt2.costs[i][j] = 999;
      }
    }
  }

  // if (TRACE == 1)
  //   printdt2(&dt2);

  send2Neighbors();
}


void rtupdate2(struct rtpkt *rcvdpkt)
{
  

  int i,j,k, changedFlg = 0;

  int source = rcvdpkt -> sourceid;
  for (i = 0; i < 4; i++)
  {
    dt2.costs[source][i] = rcvdpkt -> mincost[i];
  }

  for (j = 0; j < 4; j++)
  {
    for (k = 0; k < 4; k++)
    {
      if (dt2.costs[node][j] > (dt2.costs[node][k] + dt2.costs[k][j]))
      {
        dt2.costs[node][j] = dt2.costs[node][k] + dt2.costs[k][j];
        changedFlg = 1;
      }
    }
  }

  // inform all the neighbors if our mindist table has changed
  if (changedFlg != 0)
    send2Neighbors();

  if (TRACE == 1)
    printdt2(&dt2);


}


printdt2(struct distance_table *dtptr)
{
  printf("                via     \n");
  printf("   D2 |    0     1    3 \n");
  printf("  ----|-----------------\n");
  printf("     0|  %3d   %3d   %3d\n",dtptr->costs[0][0],
	 dtptr->costs[0][1],dtptr->costs[0][3]);
  printf("dest 1|  %3d   %3d   %3d\n",dtptr->costs[1][0],
	 dtptr->costs[1][1],dtptr->costs[1][3]);
  printf("     3|  %3d   %3d   %3d\n",dtptr->costs[3][0],
	 dtptr->costs[3][1],dtptr->costs[3][3]);
}

void getTable2(struct distance_table *result)
{
  *result = dt2;
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
      pktToSend[i].mincost[j] = dt2.costs[node][j];
    }
    tolayer2(pktToSend[i]);
  }

}





