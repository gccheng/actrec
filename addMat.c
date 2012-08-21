#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *matA = prhs[0];
    mxArray *matB = prhs[1];
    
    int rowLen = mxGetN(matA);
    int colLen = mxGetM(matA);
    
    plhs[0] = mxCreateDoubleMatrix(colLen, rowLen, mxREAL);
    
    double *outArray = mxGetPr(plhs[0]);
    double *valA = mxGetPr(matA);
    double *valB = mxGetPr(matB);
    
    int i,j;
    for (i=0; i<rowLen; ++i)
    {
        for (j=0; j<colLen; ++j)
        {
             outArray[(i*colLen)+j] = valA[(i*colLen)+j] + valB[(i*colLen)+j];
        }
    }
}
