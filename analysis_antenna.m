clc;clear;
begin = -pi/3;
right = pi/3;

 x = 0:(right-begin)/360:359*(right-begin)/360;
 x = x-right;   %(-pi/2,pi/2]
 du_x = x*180/pi;

 ant_pos_equal = [0, 0.5, 1.01, 1.53 1.86 2.36 2.87 3.39];
 ant_comps_equal= [0.0, 14.98, 23.32, 13.7, 17.48, 31.38, 40, 32.06];
 ant_pos_unequal = [0, 0.61, 2.14, 3.15 -6.28   -5.67 -4.14   -3.13];
 ant_comps_unequal= [0.0, 12.71, 12.69, 13.28, -22.69, -10.57, -10.91, -9.85];
 use_eq = 0;
 num_chan = 4;
 use_win_flag = 0;  %%bfm window en; 1:add window,0:no window
 if(use_eq)
     ant_pos = ant_pos_equal ;
     ant_comps = ant_comps_equal;
 else
     ant_pos = ant_pos_unequal;
     ant_comps = ant_comps_unequal;
 end    
 cona = 2*pi*ant_pos; 
 I=zeros(num_chan,360);
 Q=zeros(num_chan,360);
 for r=1:num_chan
     for bin=1:360
     I(r,bin)=cos(cona(r)*sin(x(bin))+ant_comps(r)*pi/180);
     Q(r,bin)=sin(cona(r)*sin(x(bin))+ant_comps(r)*pi/180);
     end
 end
 
 win1=chebwin(num_chan,30); %%nvarray
 j = sqrt(-1);
 temp  = I + j*Q;  %bfm vector should be incident conj,why in fact isnot
 w = temp;  %method 1: sample in angle domain
 xx=repmat(win1,1,360);

 
  if(use_win_flag==1)
     for loop=1:360
        w(:,loop)= xx(:,loop).*w(:,loop);
     end
  end
 full_spectrum = zeros(360,1);
  for loop=1:360
    temp=sum(w(:,loop));
    full_spectrum(loop)=temp*conj(temp);
  end
 aux = full_spectrum/max(full_spectrum);
 aux_db = 10*log10((aux));
 plot(aux_db,'r')
 hold on
 %DBF spectrum of different Rx channels at 0 deg
 
%   plot(10*log10(full_spectrum),'r')

 x = chebwin(512,30);
% x=0:21
shift = 10;
y=zeros(1,length(x));
for idx=1:length(x)-shift
   y(idx+shift) =x(idx);
end
y(1:shift) = x(length(x)-shift+1:end);
mc = circshift(x,shift);
e=y-mc';