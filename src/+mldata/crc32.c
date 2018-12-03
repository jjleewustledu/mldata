/* CRC32.C is a MEX file implementing "Fast CRC algorithm?" from
 * https://stackoverflow.com/questions/27939882/fast-crc-algorithm .  The accepted answer is an algorithm 
 * provided by Mark Adler.
 *
 * Here is a short CRC32 using either the Castagnoli polynomial (same one as used by the Intel crc32 instruction), 
 * or the Ethernet polynomial (same one as used in zip, gzip, etc.).  The initial crc value should be zero. 
 * The routine can be called successively with chunks of the data to update the CRC.  You can unroll the inner loop 
 * for speed, though your compiler might do that for you anyway.
 *
 * The calling syntax is:
 *		[crc_out] = crc32(crc, buf)
 *
 * Compile with mex -R2018a crc32.c
 *
 */
#include <math.h>
#include "mex.h"
#include "matrix.h"
#include <stddef.h>
#include <stdint.h>

/* CRC-32C (iSCSI) polynomial in reversed bit order. */
#define POLY 0x82f63b78

/* CRC-32 (Ethernet, ZIP, etc.) polynomial in reversed bit order. */
/* #define POLY 0xedb88320 */

static uint32_t crc32c(
        uint32_t crc,
        const unsigned char *buf,
        size_t len )
{
    int k;

    crc = ~crc;
    while (len--) {
        crc ^= *buf++;
        for (k = 0; k < 8; k++)
            crc = crc & 1 ? (crc >> 1) ^ POLY : crc >> 1;
    }
    return ~crc;
}

void mexFunction( 
          int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )     
{ 
    uint32_t *pcout; 
    uint32_t *pc;
    const unsigned char *pb;

    /* Check for proper number of arguments */
    if (nrhs != 2) { 
	    mexErrMsgIdAndTxt( "MATLAB:crc32:invalidNumInputs",
                "Input arguments crc and buf are required."); 
    } else if (nlhs > 1) {
	    mexErrMsgIdAndTxt( "MATLAB:crc32:maxlhs",
                "Too many output arguments."); 
    } 

    /* Assign pointers to the various parameters */ 
    pc = mxGetUint32s(prhs[0]); 
    pb = mxGetUint8s( prhs[1]);

    /* Do the actual computations in a subroutine */
    // *pcout = crc32c(*pc, pb, *mxGetDimensions(prhs[1]));
    // mxSetUint32s(plhs[0], pcout);
    return;
}

