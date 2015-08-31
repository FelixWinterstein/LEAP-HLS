/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: privateSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

#include <stdio.h>
#include <sstream>
#include "awb/provides/stats_service.h"
#include "awb/rrr/client_stub_MEMPERFRRR.h"
#include "awb/provides/connected_application.h"


using namespace std;

// constructor                                                                                                                      
CONNECTED_APPLICATION_CLASS::CONNECTED_APPLICATION_CLASS(VIRTUAL_PLATFORM vp)
  
{
    clientStub = new MEMPERFRRR_CLIENT_STUB_CLASS(NULL);
}

// destructor                                                                                                                       
CONNECTED_APPLICATION_CLASS::~CONNECTED_APPLICATION_CLASS()
{
}

// init                                                                                                                             
void
CONNECTED_APPLICATION_CLASS::Init()
{
}

// main                                                                                                                             
int
CONNECTED_APPLICATION_CLASS::Main()
{



    stringstream filename;
    cout << "Starting test" << endl;

 
    OUT_TYPE_RunTest result0 = clientStub->RunTest(0, // working set 
                                                  1); // cmd (processing)

    STATS_SERVER_CLASS::GetInstance()->DumpStats();
    STATS_SERVER_CLASS::GetInstance()->EmitFile();


    STARTER_SERVICE_SERVER_CLASS::GetInstance()->End(0);
  
    return 0;
}
