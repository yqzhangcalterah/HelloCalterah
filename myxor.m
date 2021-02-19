clc;clear;
 state = uint32(hex2dec('deadbeaf'));
% state = uint32(hex2dec('0'));
 tap = uint32(hex2dec('c0000401'));
% state = uint32(hex2dec('aaaaaaaa'));  %for 0101 modul
% tap = uint32(hex2dec('a0000001'));
% state = uint32(hex2dec('55555555'));  %for 1010 modul
% tap = uint32(hex2dec('a0000001'));

register = bitget(state,32:-1:1) %bit0 : bit1: bit31
mask = bitget(tap,32:-1:1);
ret = zeros(1,256);
for l=1:256
   ret(l) = register(32); %mean bit 0
   temp = 0;
   for tt=1:32
   temp = temp + register(tt)*2^(32-tt);
   end
   state = temp;
    tmp = bitand(tap,state);                   %     T tmp = tap & state;
    new_tmp = bitget(tmp,32:-1:1)                    %     T sum = tmp & 0x1;
    backq = mod(sum(new_tmp) , 2);
    register(2:32)=register(1:31);
    register(1)=backq; % 把异或的值放在第一个寄存器的位置  
    register
end
fp = fopen('my_test_scram_seq','w');
for l=1:256
fprintf(fp,'%d\n',ret(l));
end
fclose(fp);


% function [seq]=mseq(coef)
% %***************************************************
% % 此函数用来生成m序列
% % coef为反馈系数向量
% % Author: FastestSnail
% % Date: 2017-10-03
% %***************************************************
% m=length(coef);
% len=2^m-1; % 得到最终生成的m序列的长度     
% backQ=0; % 对应寄存器运算后的值，放在第一个寄存器
% seq=zeros(1,len); % 给生成的m序列预分配
% registers = [1 zeros(1, m-2) 1]; % 给寄存器分配初始结果
% for i=1:len
%     seq(i)=registers(m);
%     backQ = mod(sum(coef.*registers) , 2); %特定寄存器的值进行异或运算，即相加后模2
%     registers(2:length(registers)) = registers(1:length(registers)-1); % 移位
%     registers(1)=backQ; % 把异或的值放在第一个寄存器的位置
% end
% end

