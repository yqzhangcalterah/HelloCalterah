function power_dif = alps_receiver(data_frame,NUM_FFT_N,NUM_FFT_L,ant_num,range_gate,carlibrate_flag,radian_dif)
win_row_vec = chebwin(NUM_FFT_N, 80);
sum_win_row_vec = win_row_vec' * win_row_vec / length(win_row_vec);
win_row_vec = win_row_vec ./ sqrt(sum_win_row_vec);
win_row_ary = repmat(win_row_vec, 1, NUM_FFT_L);

win_col_vec = chebwin(NUM_FFT_L, 80);
sum_win_col_vec = win_col_vec' * win_col_vec / length(win_col_vec);
win_col_vec = win_col_vec ./ sqrt(sum_win_col_vec);
win_col_ary = repmat(win_col_vec, 1, NUM_FFT_N)';
data_win_2d = ones(NUM_FFT_N, NUM_FFT_L, ant_num);
for anten = 1:ant_num
    data_win_2d(:,:,anten) = data_frame(:,:,anten).*win_row_ary.*win_col_ary;
end
%%%%%%%%%%%%%%%%%%%%%%%%%receiver
% fft2d 
 data_fft_2d = ones(NUM_FFT_N, NUM_FFT_L, ant_num);
 for anten = 1:ant_num
%       data_fft_2d(:,:,anten) = fft2(data_win_2d(:,:,anten), NUM_FFT_N, NUM_FFT_L);
%my fft2
 nntemp = fft(data_win_2d(:,:,anten),NUM_FFT_N);
 %%calibration start
 if(carlibrate_flag==1)
 nntemp(:,2:2:NUM_FFT_L)=nntemp(:,2:2:NUM_FFT_L).*exp(-1i*radian_dif(anten));
 end
 %%calibration end
 data_fft_2d(:,:,anten) = fft(nntemp,NUM_FFT_L,2);
 end
 %% SISO combine
 data_power = zeros(NUM_FFT_N, NUM_FFT_L);
 for anten = 1:ant_num
    data_power = abs(data_fft_2d(:,:,anten)).^2 + data_power;
 end
 data_power  = data_power / ant_num;
 data_power_db = 10*log10(data_power);
 cfar_comb = data_power_db(1:256,:);
 mesh(cfar_comb(:,:));view([0,0,90]);
 xlabel('p index');
 ylabel('range gate');
%  title('FFT 2D ');
%%%%%%%%%%%%%%%%%%%

target_idx = range_gate;
%  figure(2)
%  plot(cfar_comb(1,:));

idx =[1 NUM_FFT_L/2+1];
win_size = 7;
search_num = 2;
for snum =1:search_num
 center = idx(snum);
 move = 2;
 noise = 0;
  for staticn = 1:win_size
      noise = noise+cfar_comb(target_idx,mod(center+move+staticn,NUM_FFT_L));
      noise = noise+cfar_comb(target_idx,mod(center-move-staticn,NUM_FFT_L));
  end
  noise = noise/(win_size*2);
  power_dif(snum) = cfar_comb(target_idx,center) - noise
end

%%added for music start
if 0
vlocity_gate = 15;
neighbor = 1;
idx = zeros(1,neighbor);  %%store all neighbor information
for ll=1:neighbor
    nn=1;
    if (ll<=floor(neighbor/2)+1)
       nn = nn - ll;
    else
        nn = ll - (floor(neighbor/2)+1);
    end
    nn
    temp = vlocity_gate + nn;
    if(temp<1)
       temp = temp + NUM_FFT_L;  
    elseif temp>NUM_FFT_L
        temp = temp - NUM_FFT_L;
    end
     idx(ll)= temp;
end
%%pick neighbor
music_in = zeros(ant_num,neighbor);
music_in_hold = zeros(ant_num,neighbor);
for ll=1:neighbor
    for anten = 1:ant_num
music_in(anten,ll)=data_fft_2d(target_idx,idx(ll),anten);
    end
end
%%%´ò×®
% music_in(1,1)=-0.0344744-1i*0.00867123;
% music_in(2,1)=-0.0240458+1i*0.02703;
% music_in(3,1)=0.0118977+1i*0.0342168;
% music_in(4,1)=0.0355504+1i*0.00521775;

music_in(1,1)=0.00785665-1i*0.0821646;
music_in(2,1)=-0.0335696-1i*0.0704109;
music_in(3,1)=-0.058303-1i*0.038851;
music_in(4,1)=-0.0560882-1i*0.0026756;
music_in(5,1)=-0.0334675+1i*0.0181703;
music_in(6,1)=-0.00993061+1i*0.0156926;
music_in(7,1)=-0.000119882-1i*0.00375596;
music_in(8,1)=-0.0139763-1i*0.0210175;


%%get common scalar and minum scaler and preprocess
common_scalars = zeros(1,neighbor);
for ll=1:neighbor
    common_scalars(ll)=1000;
    for anten = 1:ant_num
        scaler_r = floor(log2(1/abs(real(music_in(anten,ll)))));
        scaler_i = floor(log2(1/abs(imag(music_in(anten,ll)))));
        if(scaler_r>scaler_i)
            scaler_temp = scaler_i;
        else
            scaler_temp = scaler_r;
        end
        if(common_scalars(ll)>scaler_temp)
            common_scalars(ll) = scaler_temp;
        end
    end
end
for ll=1:neighbor
    music_in_hold(:,ll)= music_in(:,ll).* (2^common_scalars(ll));
end
 common_scalar = min(common_scalars);
%% compute corr matrix(r,smooth,get average,rotate U2)
temp_R = music_in_hold*music_in_hold';
sub_array_size = 4;
J_2 = [0 1;1 0];
J_3 = [0 0 1;0 1 0;1 0 0];
J_4 = [0 0 0 1;0 0 1 0;0 1 0 0;1 0 0 0];
% forward_R = zeros(sub_array_size,sub_array_size);
smooth =1; %1 FB; 2 Forward; 3 backword 
forward_count = 0;

    for smooth_time =1:ant_num
        if((sub_array_size+(smooth_time-1))<=ant_num)
     forward_R = temp_R(smooth_time:sub_array_size+(smooth_time-1),smooth_time:sub_array_size+(smooth_time-1))
     forward_count = forward_count +1;
     forward(:,:,forward_count)=forward_R;
     if(sub_array_size == 2)
         J = J_2;
     end
     if(sub_array_size == 3)
         J = J_3;
     end
     if (sub_array_size == 4)
          J = J_4;
     end
     backward_R =  J*conj(forward_R)*J
     backward(:,:,forward_count)=backward_R;
        end
    end
  
  average_R = zeros(sub_array_size,sub_array_size);  
 if(smooth ==2)
     for num= 1:forward_count
        average_R=average_R+forward(:,:,num);
     end
     scale = ceil(log2(forward_count));
 elseif(smooth ==3)
     for num= 1:forward_count
        average_R=average_R+backward(:,:,num);
     end
     scale = ceil(log2(forward_count));
 elseif(smooth ==1)
     for num= 1:forward_count
     average_R=average_R+forward(:,:,num);
     average_R=average_R+backward(:,:,num);
     end
     scale = ceil(log2(forward_count*2));
 end
average_R= average_R/(2^scale)
corr_out_hw=rotateU2(average_R,sub_array_size);
corr_out=rotateU(average_R,sub_array_size);
error_ru = (corr_out_hw - corr_out)

% corr_out_hw=[3.33926e-07  -3.34006e-07  0.000219541  -0.000219847;...  
% -3.34006e-07  8.10896e-07  5.09354e-05  -5.06577e-05;...  
% 0.000219541  5.09354e-05  0.999916  -0.999957;...  
% -0.000219847  -5.06577e-05  -0.999957  1];  
[VV,DD]=my_evd(corr_out_hw,sub_array_size)
[V,D] = eig(corr_out_hw)


%%added for music end
end

end