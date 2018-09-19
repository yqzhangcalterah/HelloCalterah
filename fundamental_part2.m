void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
SimParam_Ls->ULSimParam.ModuMod[0] = (int8)*(double*)mxGetData(mxGetField(prhs[0],0,"ModScheme0"));
for(i=0; i<SimParam_Ls->ULSimParam.RxNum; i++)
    {
        pMxArr = mxGetCell(prhs[1], i);
        size_n = mxGetN(pMxArr);  //sym num
        size_m = mxGetM(pMxArr); //sc num
        pfReTemp[i] = (double*)mxGetPr(pMxArr);
        pfImTemp[i] = (double*)mxGetPi(pMxArr);
}
 
 
for(i=0; i<SimParam_Ls->ULSimParam.RxNum; i++)
    {
        pfImTemp1[i]= (double *)malloc(sizeof(double)*57344);   //57344 = 4096 * 14
    }

    pTmpDoubleRe = (double*)mxGetPr(prhs[3]); 
    if(UETxPortNum>12)
    {
    mexErrMsgTxt("In gnb_rx_pusch_che_ls_mex,UETxPortNum>12,notice memory out\n");
    }
    else
    {
        for(i=0; i<UETxPortNum; i++)
        {
        UETxPort[i]= (int8)pTmpDoubleRe[i];
        SimParam_Ls->DMRS_port[i] = UETxPort[i];
        }
    }
    for(i=0; i<SimParam_Ls->ULSimParam.RxNum; i++)
    {
        for(j=0;j<size_n;j++)
        {
            pcsRxData[i][j] = (cmplx_frN *)malloc(size_m*sizeof(cmplx_frN));
            if (pcsRxData[i][j]==NULL)
            {
                mexErrMsgTxt("pcfRxData malloc?§°???");
            }
            else
            {
            memset(pcsRxData[i][j], 0, (size_m)*sizeof(cmplx_frN));
            }
        }
    }

    for(i=0; i<SimParam_Ls->ULSimParam.RxNum; i++)
    {
        for(j=0;j<size_n;j++)       //ofdm sym num
        {
            for (k = 0; k < size_m; k++)   //sc num
            {
              pfImTemp1[i][j * FftSize + k] = (pfImTemp[i]==NULL)?(double)0.0:(double)pfImTemp[i][j * FftSize + k];
              pcsRxData[i][j][k] = cmplx_t_2_cmplx_frN(compose_f(pfReTemp[i][j * FftSize + k],pfImTemp1[i][j * FftSize + k]));      
            }
        }
    }
 
for (i = 0; i < SimParam_Ls->ULSimParam.RxNum; i++)
    {
        for (j = 0; j < MAX_ULTX_NUM; j++)
        {
            for (k = 0; k < RS_NUM_PER_TTI_UL; k++)
            {
                pcsHData[i][j][k] = (cmplx_frN *)malloc(MAX_RSNUM_PER_RB * MAXRBNUM * sizeof(cmplx_frN));
                memset(pcsHData[i][j][k], 0, MAX_RSNUM_PER_RB * MAXRBNUM * sizeof(cmplx_frN));
            }
        }
    }

    //added start
    for(j=0;j<MAXSYMNUM;j++)
    {
        pMxArr = mxGetCell(prhs[4], j);
        col_n = mxGetN(pMxArr);  //col num  RB_num
        row_m = mxGetM(pMxArr); //row num  rx_ant_num
        pTmpDoubleRe = (double*)mxGetPr(pMxArr);
        for(i=0;i<row_m;i++)
        {
         for(k=0;k<col_n;k++)
        {
          SimParam_Ls->agcdata[j][i][k]= (int8)(pTmpDoubleRe[k*row_m+i]);
        }
        }
    }
 
gnb_rx_pusch_che_ls_fxp(&(SimParam_Ls->ULSimParam),pcsRxData,pcsHData,UETxPort,UETxPortNum,Ncs,&rs_rbstart,SimParam_Ls->agcdata);
 
然后就是 编译了
 
}
 
eval(['mex(''-v'',''-DULTEST_PRINTFLAG=1'',''-DWIN64'',''-DNT'',''-D_USRDLL'',''-DMY_FXP_FLAG'',''-g'',',FileStr,',''-outdir'',''./MexFold'')']);
    else
        eval(['mex(''-v'',''-DULTEST_PRINTFLAG=1'',''-DWIN64'',''-DNT'',''-D_USRDLL'',''-DMY_FXP_FLAG'',''-O'',',FileStr,',''-outdir'',''./MexFold'')']);
 