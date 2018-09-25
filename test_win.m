clc;clear;
fs=80;
t=0:1/(200):1.5;
% x = cos(2*pi*fs*t);  %nTs = n*0.005
x = cos(2*pi*fs*t)+0.02*cos(2*pi*50*t);
% Y = wgn(1, length(x), 3, 'real');
x1 = x;%+Y;
x=x1(10:265);
L=length(x);  
win1=chebwin(L);
win2=boxcar(L);
s2 = x.*win1.';
figure(1)
subplot(2,1,1);
s1=(20*log10(abs(fft(x,256))));
plot(s1)
k2= find(abs(fft(x,256))==max(abs(fft(x,256))))

est_fs1 = 200/256*(k2-1)
subplot(2,1,2);
s2=20*log10((abs(fft(s2,256))));
plot(s2);
k1= find(abs(fft(s2,256))==max(abs(fft(s2,256))))
est_fs2 = 200/256*(k1-1)
