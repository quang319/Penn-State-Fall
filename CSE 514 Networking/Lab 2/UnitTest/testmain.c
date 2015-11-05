#include <stdio.h>

#define LINKCHANGES 1 
/* ******************************************************************
Lab 2: implementing distributed, asynchronous, distance vector routing.

THIS IS THE MAIN ROUTINE.  IT SHOULD NOT BE TOUCHED AT ALL BY STUDENTS!

**********************************************************************/


/* a rtpkt is the packet sent from one routing update process to
   another via the call tolayer3() */
struct rtpkt {
  int sourceid;       /* id of sending router sending this pkt */
  int destid;         /* id of router to which pkt being sent 
                         (must be an immediate neighbor) */
  int mincost[4];    /* min cost to node 0 ... 3 */
  };

int TRACE = 1;             /* for my debugging */
int YES = 1;
int NO = 0;

creatertpkt( initrtpkt, srcid, destid, mincosts)
struct rtpkt *initrtpkt;
int srcid;
int destid;
int mincosts[];

{
  int i;
  initrtpkt->sourceid = srcid;
  initrtpkt->destid = destid;
  for (i=0; i<4; i++)
    initrtpkt->mincost[i] = mincosts[i];
}  


/*****************************************************************
***************** NETWORK EMULATION CODE STARTS BELOW ***********
The code below emulates the layer 2 and below network environment:
  - emulates the tranmission and delivery (with no loss and no
    corruption) between two physically connected nodes
  - calls the initializations routines rtinit0, etc., once before
    beginning emulation

THERE IS NOT REASON THAT ANY STUDENT SHOULD HAVE TO READ OR UNDERSTAND
THE CODE BELOW.  YOU SHOLD NOT TOUCH, OR REFERENCE (in your code) ANY
OF THE DATA STRUCTURES BELOW.  If you're interested in how I designed
the emulator, you're welcome to look at the code - but again, you should have
to, and you defeinitely should not have to modify
******************************************************************/

struct event {
   float evtime;           /* event time */
   int evtype;             /* event type code */
   int eventity;           /* entity where event occurs */
   struct rtpkt *rtpktptr; /* ptr to packet (if any) assoc w/ this event */
   struct event *prev;
   struct event *next;
 };
struct event *evlist = NULL;   /* the event list */

/* possible events: */
#define  FROM_LAYER2     2
#define  LINK_CHANGE     10

float clocktime = 0.000;


//main()
//{
//
//   rtinit0();
//}

