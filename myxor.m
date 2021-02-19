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
    register(1)=backq; % ������ֵ���ڵ�һ���Ĵ�����λ��  
    register
end
fp = fopen('my_test_scram_seq','w');
for l=1:256
fprintf(fp,'%d\n',ret(l));
end
fclose(fp);


% function [seq]=mseq(coef)
% %***************************************************
% % �˺�����������m����
% % coefΪ����ϵ������
% % Author: FastestSnail
% % Date: 2017-10-03
% %***************************************************
% m=length(coef);
% len=2^m-1; % �õ��������ɵ�m���еĳ���     
% backQ=0; % ��Ӧ�Ĵ���������ֵ�����ڵ�һ���Ĵ���
% seq=zeros(1,len); % �����ɵ�m����Ԥ����
% registers = [1 zeros(1, m-2) 1]; % ���Ĵ��������ʼ���
% for i=1:len
%     seq(i)=registers(m);
%     backQ = mod(sum(coef.*registers) , 2); %�ض��Ĵ�����ֵ����������㣬����Ӻ�ģ2
%     registers(2:length(registers)) = registers(1:length(registers)-1); % ��λ
%     registers(1)=backQ; % ������ֵ���ڵ�һ���Ĵ�����λ��
% end
% end

