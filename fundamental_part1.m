% ？？射频到基带的接口
% 数据幅度绝对值范围：最大值8230，对应-50dbm信号，最小值82，对应-90dbm底噪声。
% 1.       射频前端
%% 计算平均功率，将浮点数据rfDataTemp调整到目标（额定）功率
rssi = zeros(RxNum,1);
    for iRx=1:RxNum
        data_rssi = rfDataTemp(iRx,:).*conj(rfDataTemp(iRx,:));
        pos = data_rssi>0.01;    % rssi只统计有信号和噪声功率大于0.01(20db对应的噪声功率)的地方
        valid_rssi = data_rssi(pos);
        len = length(valid_rssi);
        rssi(iRx) = sum(valid_rssi)/len; % (s*s^H)/Len
    end
    max_rssi = max(rssi);
   % 对信号进行缩放
    % 由rf的ADC传入基带的数据定标Q(16,1),额定功率对应的值为8230，对应-50dbm，底噪声-90dbm，因此量化区间为40db
    rfdata_max = 8230; %
    rfdata_min = 82; %
    rfdata_max_flt = rfdata_max/32768.0;
    rssi_maxref = rfdata_max_flt*rfdata_max_flt;
    s_pow = -50;%dbm 额定功率
    noise_pow = -114+10*log10(273); %dbm 底噪声功率
    Txsignal_pow = noise_pow + SimParamRF.IdealTxSNR;%dbm 折算发送信号功率
    Rxsignal_pow = 10*log10(10^(noise_pow/10)+10^(Txsignal_pow/10));%dbm 折算接收信号功率
    agc_db = Rxsignal_pow-s_pow; % 将rfDataBuf调整到折算的接收信号功率需要的缩放值
    % -8,-20,-32 将信号的平均rssi调整到比rssi_maxref低agc_db的位置，高中低挡用于观察后续fft的量化snr
    rssi_ref = rssi_maxref*10^(agc_db/10);%
    % 把信号rssi调整到 参考rssi_ref 需要的缩放系数
    rf_factor = sqrt(max_rssi/rssi_ref) ;
    % 对数据幅度进行调整
    rfDataTemp = rfDataTemp./(rf_factor); %可以理解为 RF数据应该在额定功率这
 
 
% 总结：这个步骤需要的几个重要的东西：额定功率dbm、额定功率对应的定点值，底噪、发端功率、
%  
% 当射频数据在额定功率这以后，进入 A/D量化和限制幅度
Nadc = 16;
rfDataTemp = round(rfDataTemp .* 2^(Nadc-1)) ; % Q(Nadc,1)
   Realdata = real(rfDataTemp);
    Imagdata = imag(rfDataTemp);
    
Realdata(Realdata>32767) = 32767;
Imagdata(Imagdata>32767) = 32767;
    Realdata(Realdata<-1*32768) = -1*32768; 
    Imagdata(Imagdata<-1*32768) = -1*32768;
% 限制幅度后重新构造信号
    rfDataTemp = Realdata + Imagdata.*1i; %限幅后重新构造信号，如果不切换到浮点，这一步输出的就是定点值
    %
    rfDataTemp = rfDataTemp ./ 2^(Nadc-1); % Q(Nadc,1) 切换到浮点数输出
    
rfDataBuf = rfDataTemp;
 
% 2.       统计量化信噪比
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
step = 0.5*step_factor;   %????????§???
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
 
