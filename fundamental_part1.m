% ������Ƶ�������Ľӿ�
% ���ݷ��Ⱦ���ֵ��Χ�����ֵ8230����Ӧ-50dbm�źţ���Сֵ82����Ӧ-90dbm��������
% 1.       ��Ƶǰ��
%% ����ƽ�����ʣ�����������rfDataTemp������Ŀ�꣨�������
rssi = zeros(RxNum,1);
    for iRx=1:RxNum
        data_rssi = rfDataTemp(iRx,:).*conj(rfDataTemp(iRx,:));
        pos = data_rssi>0.01;    % rssiֻͳ�����źź��������ʴ���0.01(20db��Ӧ����������)�ĵط�
        valid_rssi = data_rssi(pos);
        len = length(valid_rssi);
        rssi(iRx) = sum(valid_rssi)/len; % (s*s^H)/Len
    end
    max_rssi = max(rssi);
   % ���źŽ�������
    % ��rf��ADC������������ݶ���Q(16,1),����ʶ�Ӧ��ֵΪ8230����Ӧ-50dbm��������-90dbm�������������Ϊ40db
    rfdata_max = 8230; %
    rfdata_min = 82; %
    rfdata_max_flt = rfdata_max/32768.0;
    rssi_maxref = rfdata_max_flt*rfdata_max_flt;
    s_pow = -50;%dbm �����
    noise_pow = -114+10*log10(273); %dbm ����������
    Txsignal_pow = noise_pow + SimParamRF.IdealTxSNR;%dbm ���㷢���źŹ���
    Rxsignal_pow = 10*log10(10^(noise_pow/10)+10^(Txsignal_pow/10));%dbm ��������źŹ���
    agc_db = Rxsignal_pow-s_pow; % ��rfDataBuf����������Ľ����źŹ�����Ҫ������ֵ
    % -8,-20,-32 ���źŵ�ƽ��rssi��������rssi_maxref��agc_db��λ�ã����е͵����ڹ۲����fft������snr
    rssi_ref = rssi_maxref*10^(agc_db/10);%
    % ���ź�rssi������ �ο�rssi_ref ��Ҫ������ϵ��
    rf_factor = sqrt(max_rssi/rssi_ref) ;
    % �����ݷ��Ƚ��е���
    rfDataTemp = rfDataTemp./(rf_factor); %�������Ϊ RF����Ӧ���ڶ������
 
 
% �ܽ᣺���������Ҫ�ļ�����Ҫ�Ķ����������dbm������ʶ�Ӧ�Ķ���ֵ�����롢���˹��ʡ�
%  
% ����Ƶ�����ڶ�������Ժ󣬽��� A/D���������Ʒ���
Nadc = 16;
rfDataTemp = round(rfDataTemp .* 2^(Nadc-1)) ; % Q(Nadc,1)
   Realdata = real(rfDataTemp);
    Imagdata = imag(rfDataTemp);
    
Realdata(Realdata>32767) = 32767;
Imagdata(Imagdata>32767) = 32767;
    Realdata(Realdata<-1*32768) = -1*32768; 
    Imagdata(Imagdata<-1*32768) = -1*32768;
% ���Ʒ��Ⱥ����¹����ź�
    rfDataTemp = Realdata + Imagdata.*1i; %�޷������¹����źţ�������л������㣬��һ������ľ��Ƕ���ֵ
    %
    rfDataTemp = rfDataTemp ./ 2^(Nadc-1); % Q(Nadc,1) �л������������
    
rfDataBuf = rfDataTemp;
 
% 2.       ͳ�����������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%error 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mse = 10*log10((mean(mean(abs(cell2mat(CsiRsFreqPortDataFxp)-cell2mat(CsiRsFreqPortData))))/mean(mean(abs(cell2mat(CsiRsFreqPortData)))))^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%error2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%yang yan
function [snr_db]=cal_quantized_snr(dataflt,datafxp,matType)
if (matType == 0)
    data_s = dataflt;
    data_y = datafxp;
    [m,n] = size(data_s);
    data_s = reshape(data_s,1,m*n);
    data_y = reshape(data_y,1,m*n);
elseif (matType == 1)
    data_s = cell2mat(dataflt);
    data_y = cell2mat(datafxp);
    [m,n] = size(data_s);
    data_s = reshape(data_s,1,m*n);
    data_y = reshape(data_y,1,m*n);
elseif (matType == 2)
    data_s = dataflt;
    data_y = datafxp;
    [m,n,k] = size(data_s);
    data_s = reshape(data_s,1,m*n*k);
    data_y = reshape(data_y,1,m*n*k);  
else
    disp(' error matType');
end

% data_y = data_s + noise
error = data_y - data_s;
pow_error = real(error*error');
pow_sinal = real(data_s*data_s');
if pow_error > 0
    snr_db = 10*log10(pow_sinal/pow_error);
elseif pow_error < 0
    disp(' error in cal_quantized_snr');
    snr_db = -100;
else
    snr_db = 1000;
end  
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot error%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%way 1%%%%%%%%%
function plot_error_SNR(result,true_value,fignum,cmx_flg)

Detectdata_Int=result;  
Detectdata_flt = true_value;
%%%%%%%%%%------------------
Detectdata_flt_use1 = find(abs(real(Detectdata_flt))>1e-6);
if(1==cmx_flg)
Detectdata_flt_use2 = find(abs(imag(Detectdata_flt))>1e-6);
else
Detectdata_flt_use2 =Detectdata_flt_use1;
end
Detectdata_flt_use = intersect(Detectdata_flt_use1,Detectdata_flt_use2);

Detectdata_flt = Detectdata_flt(Detectdata_flt_use);
Detectdata_Int = Detectdata_Int(Detectdata_flt_use);

cond_data = abs(Detectdata_flt-Detectdata_Int)./abs(Detectdata_flt);
cond_data_db = -20 * log10(cond_data);
% if(mean(cond_data_db)
mm=find(cond_data_db==Inf);
temp_la=cond_data_db;
for la = 1:length(mm)
    temp_la(mm(la))=0;
end
meandb=sum(temp_la)/(length(cond_data_db)-length(mm));
fprintf('stage %d,meandb %f\n',fignum,meandb);    
k=find(cond_data_db<20);
look_db = cond_data_db(k);
look_data = [Detectdata_flt(k) Detectdata_Int(k)]
Inf_or_not = isfinite(cond_data_db);
left_edge = min(cond_data_db.*Inf_or_not);
right_edge = max(cond_data_db.*Inf_or_not);
step_factor = 1;
step = 0.5*step_factor;   %????????��???
edges = left_edge:step:right_edge;

len = length(cond_data);
n_cond_data = histc(cond_data_db, edges);
c_cond_data = cumsum(n_cond_data);
figurenumber = fignum;

% -----------------Data cdf---------------------------
% figurenumber = figurenumber+1;
figure(figurenumber);
plot(edges, c_cond_data/len,'r');
grid on;
ylabel('CDF');
xlabel('Error SNR(dB)');
% XX = 'case12  ';
% titlename = strcat('CDF distribution of',XX);
% title(titlename);
end
 
