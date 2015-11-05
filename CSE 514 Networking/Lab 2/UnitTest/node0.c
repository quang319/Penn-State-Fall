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

struct distance_table
{
  int costs[4][4];
} dt0;

int node = 0;

/* students to write the following two routines, and maybe some others */

void rtinit0() 
{
  int initCost [4] = {0,1,3,7};
  int i,j;
  for (i = 0; i < 4; ++i)
  {
    for (j = 0; j < 4; ++j)
    {
      if (i == 0)
      {
        dt0.costs[i][j] = initCost[j];
      }
      else
      {
        dt0.costs[i][j] = 999;
      }
    }
  }
    
}


void rtupdate0(struct rtpkt *rcvdpkt)
{
  int i,j,k, changedFlg = 0;

  int source = rcvdpkt -> sourceid;
  for (i = 0; i < 4; i++)
  {
    dt0.costs[source][i] = rcvdpkt -> mincost[i];
  }

  for (j = 0; j < 4; j++)
  {
    for (k = 0; k < 4; k++)
    {
      if (dt0.costs[node][j] > (dt0.costs[node][k] + dt0.costs[k][j]))
      {
        dt0.costs[node][j] = dt0.costs[node][k] + dt0.costs[k][j];
        changedFlg = 1;
      }
    }
  }

   
}


printdt0(struct distance_table *dtptr)  
{
  printf("                via     \n");
  printf("   D0 |    1     2    3 \n");
  printf("  ----|-----------------\n");
  printf("     1|  %3d   %3d   %3d\n",dtptr->costs[1][1],
	 dtptr->costs[1][2],dtptr->costs[1][3]);
  printf("dest 2|  %3d   %3d   %3d\n",dtptr->costs[2][1],
	 dtptr->costs[2][2],dtptr->costs[2][3]);
  printf("     3|  %3d   %3d   %3d\n",dtptr->costs[3][1],
	 dtptr->costs[3][2],dtptr->costs[3][3]);
}

linkhandler0(linkid, newcost)   
  int linkid, newcost;

/* called when cost from 0 to linkid changes from current value to newcost*/
/* You can leave this routine empty if you're an undergrad. If you want */
/* to use this routine, you'll need to change the value of the LINKCHANGE */
/* constant definition in prog3.c from 0 to 1 */
	
{
}

void getTable(struct distance_table *result)
{
  *result = dt0;
} 

