    clc;clear;
    fc = 76 * 1e+9;   %wave A
    fc_2 = 76.2*1e+9; %wave B
    Fs = 25 * 1e+6;
    B  = 675 * 1e+6;
    Tr = 65 * 1e-6;
    Td = 10 * 1e-6;
    Tu = 50 * 1e-6;
    Ts = 1/Fs;
    nchirps = 256;
    B_A_ratio = 1/2;
    pattern = zeros(1,nchirps);
%   pattern(1:1:nchirps)=1;  %%mean all a
     pattern(1:2:nchirps)=1; %%mean abab
%     pattern(1:3:nchirps)=1; %%mean abbabba
    over_sampling = 2;
    nsamples_per_chirp = ceil(Tr * Fs) * over_sampling;
    n = nsamples_per_chirp * nchirps;
    phi_Tr = fc * Tr + B / 2 * (Td+Tu);
    phi_Tr2 = fc_2 * Tr + B / 2 * (Td+Tu);
    deltaT = Ts / over_sampling;
    nsamples = n;
    phase0 = zeros(1,n);
     phase0 = FMCWPhaseGenerator_run_transmit(0,0,phase0,false,deltaT,Tr,Tu,Td,phi_Tr,fc,B,fc_2,pattern,phi_Tr2);
    R = 10;
    v = 0;
    sample_start =  Fs*20*1e-6;
    sample_discard_start = Fs*45*1e-6;
    NUM_FFT_N = 512;
    NUM_FFT_L = 256;
    ant_num = 1;
    range_gate =18;
    radian_dif = 0;
[check_phase,check_phase2,need_phase,outphase] = FMCWPhaseGenerator_run(R,v,phase0,true,deltaT,Tr,Tu,Td,phi_Tr,fc,B,fc_2,pattern,phi_Tr2);
outdata = sin(outphase);
alps_data_t = reshape(outdata, [nsamples_per_chirp, nchirps,ant_num] );
alps_data_t = alps_data_t(1:over_sampling:nsamples_per_chirp,:,ant_num);  %%here omit AFE over_sampling factor
alps_data_t = alps_data_t(sample_start:sample_start+NUM_FFT_N-1,:,ant_num);
 [radian_dif, deg_dif]=compute_angle(alps_data_t,NUM_FFT_N,NUM_FFT_L,ant_num,range_gate,pattern);
power_dif = alps_receiver(alps_data_t,NUM_FFT_N,NUM_FFT_L,ant_num,range_gate,0,radian_dif)
function [check_phase,check_phase2,need_phase,phase] = FMCWPhaseGenerator_run(R,v,phase0,diff,deltaT,Tr,Tu,Td,phi_Tr,fc,B,fc_2,pattern,phi_Tr2)
      num = 0;
      num_e = 0;
      num_o = 0;
      LIGHTSPEED=299792458.0;
      nchirps = length(pattern);
      nsamples = length(phase0)/nchirps;
    for i = 1:nchirps
       for mm=1:nsamples 
          t = ((i-1)*nsamples+(mm-1))*deltaT;
          tau = 2*(R+v*t)/LIGHTSPEED;
          k = floor((t-tau)/Tr);
          tt = t - tau - k * Tr;
          ph = 0;
          if(pattern(i)==1)
            if (tt <= Tu) 
            ph = fc * tt + B/2/Tu * tt * tt + k * phi_Tr;
            elseif (tt <= Tu+Td) 
            tt = tt - Tu;
            ph = (fc + B) * tt - B / 2 / Td * tt * tt + fc * Tu + B * Tu / 2 + k * phi_Tr;
            else 
            tt = tt-(Tu+Td);
            ph = fc * tt + fc * (Td + Tu) + B * (Td+Tu) / 2 + k * phi_Tr;
            end
            if (diff)
            phase((i-1)*nsamples+mm) = ph * 2 * pi - phase0((i-1)*nsamples+mm);
            else
            phase((i-1)*nsamples+mm) = ph * 2 * pi;
            end
         else  %%end if (pattern(i)==1)
            if (tt <= Tu) 
            ph = fc_2 * tt + B/2/Tu * tt * tt + k * phi_Tr2;
            elseif (tt <= Tu+Td) 
            tt = tt - Tu;
            ph = (fc_2 + B) * tt - B / 2 / Td * tt * tt + fc_2 * Tu + B * Tu / 2 + k * phi_Tr2;
            else 
            tt = tt-(Tu+Td);
            ph = fc_2 * tt + fc_2 * (Td + Tu) + B * (Td+Tu) / 2 + k * phi_Tr2;
            end
        
        if (diff)
            phase((i-1)*nsamples+mm) = ph * 2 * pi - phase0((i-1)*nsamples+mm);
        else
            phase((i-1)*nsamples+mm) = ph * 2 * pi;
        end
             
          end
         %%added get some phase value
         
         if (diff)
         if(tt<=Tu)
             num = num+1;
             need_phase(num) = ph+phase0((i-1)*nsamples+mm)/2*pi;
             if(pattern(i)==1)
                 num_e = num_e + 1;
                 check_phase(num_e) = -fc * tau - B/2/Tu *(tau)*(2*tt-tau);
             else
                 num_o = num_o + 1;
                 check_phase2(num_o) = -fc_2 * tau - B/2/Tu *(tau)*(2*tt-tau); 
             end
         end
         end
         %%added get some phase value end
          
          
       end
    end
     
end


function phase = FMCWPhaseGenerator_run_transmit(R,v,phase0,diff,deltaT,Tr,Tu,Td,phi_Tr,fc,B,fc_2,pattern,phi_Tr2)
      num = 0;
      num_e = 0;
      num_o = 0;
      LIGHTSPEED=299792458.0;
      nchirps = length(pattern);
      nsamples = length(phase0)/nchirps;
    for i = 1:nchirps
       for mm=1:nsamples 
          t = ((i-1)*nsamples+(mm-1))*deltaT;
          tau = 2*(R+v*t)/LIGHTSPEED;
          k = floor((t-tau)/Tr);
          tt = t - tau - k * Tr;
          ph = 0;
          if(pattern(i)==1)
            if (tt <= Tu) 
            ph = fc * tt + B/2/Tu * tt * tt + k * phi_Tr;
            elseif (tt <= Tu+Td) 
            tt = tt - Tu;
            ph = (fc + B) * tt - B / 2 / Td * tt * tt + fc * Tu + B * Tu / 2 + k * phi_Tr;
            else 
            tt = tt-(Tu+Td);
            ph = fc * tt + fc * (Td + Tu) + B * (Td+Tu) / 2 + k * phi_Tr;
            end
            if (diff)
            phase((i-1)*nsamples+mm) = ph * 2 * pi - phase0((i-1)*nsamples+mm);
            else
            phase((i-1)*nsamples+mm) = ph * 2 * pi;
            end
         else  %%end if (pattern(i)==1)
            if (tt <= Tu) 
            ph = fc_2 * tt + B/2/Tu * tt * tt + k * phi_Tr2;
            elseif (tt <= Tu+Td) 
            tt = tt - Tu;
            ph = (fc_2 + B) * tt - B / 2 / Td * tt * tt + fc_2 * Tu + B * Tu / 2 + k * phi_Tr2;
            else 
            tt = tt-(Tu+Td);
            ph = fc_2 * tt + fc_2 * (Td + Tu) + B * (Td+Tu) / 2 + k * phi_Tr2;
            end
        
        if (diff)
            phase((i-1)*nsamples+mm) = ph * 2 * pi - phase0((i-1)*nsamples+mm);
        else
            phase((i-1)*nsamples+mm) = ph * 2 * pi;
        end
             
          end 
       end
    end
     
end
function retv=gen_vectors(phi,theta,xs,ys,ant_scalar,scalar)  %
v0 = cos(phi) * sin(theta);
v1 = sin(phi);
len = lenth(xs);
retv = zeros(1,len);
    for m = 1:len 
        tmp = xs(m) * v0 + ys(m) * v1;
        tmp = tmp * 2 * pi;
        retv(m) = (cos(tmp)+1i*sin(tmp)) * scalar * ant_scalar(m);
    end
end




