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

#define N 128
#define K 4
#define P 4
#define STDDEV 0.75



// main                                                                                                                             
int
CONNECTED_APPLICATION_CLASS::Main()
{

   char cwd[1024];
   if (getcwd(cwd, sizeof(cwd)) != NULL)
       printf("Current working dir: %s\n", cwd);


    stringstream filename;
    cout << "Starting test" << endl;

    char cntrFileName[1024];
    sprintf(cntrFileName,"initial_centres_N%d_K%d_D%d_s%.2f_%d.hex",N,K,3,STDDEV,1);

    FILE *cntrFile = fopen(cntrFileName, "r");

    long long initial_centres[K];

    if (cntrFile ) {
    
        for (int i=0; i<K; i++) {
            long long d;
            char c;
            fscanf(cntrFile, "%llx", &d);       
            printf("init cntr(%d): val = %llx\n",i,d);
            initial_centres[i] = d;
        }

        fclose(cntrFile);
    } else {
        printf("ERROR: Could not open %s\n",cntrFileName);
    }

    for (int i=0; i<K; i++) {
        OUT_TYPE_RunTest result0 = clientStub->RunTest( initial_centres[i], // cntr
                                                        2*N-1-1-(P-1),  // n
                                                        K-1, // k
                                                        2); // cmd (init)
    }

    OUT_TYPE_RunTest result1 = clientStub->RunTest(0, // cntr
                                                  2*N-1-1-(P-1),  // n
                                                  K-1, // k
                                                  1); // cmd (processing)

    /*
    OUT_TYPE_RunTest result2 = clientStub->RunTest(0, // cntr
                                                  2*N-1-1-(P-1),  // n
                                                  K-1, // k
                                                  0); // cmd (finish)
    */

    filename << "cache" << ".stats";
    STATS_SERVER_CLASS::GetInstance()->DumpStats();
    STATS_SERVER_CLASS::GetInstance()->EmitFile();
    STATS_SERVER_CLASS::GetInstance()->ResetStatValues();


    //STARTER_DEVICE_SERVER_CLASS::GetInstance()->End(0);
    STARTER_SERVICE_SERVER_CLASS::GetInstance()->End(0);
  
    return 0;
}
