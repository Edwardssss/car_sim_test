% -*- coding: utf-8 -*-
%
% @File    :   car_sim_test.m
% @Time    :   2025/04/22 15:56:23
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss


%% ����ͨ�ŷ���
%% Ԥ����

clc,clear,clf;
%% �龰����

% ��ȡ������ʻ����
[allData, scenario, sensor] = car_scenario_file();
% designer_handle = drivingScenarioDesigner("car_scenario_file.mat");
%% �ź����

M = 64;                             % Delay��(ʱ�������)
N = 256;                            % Doppler��(���ز�����)
df = 50e3;                          % Ƶ����ļ��(Hz),��LTEϵͳ�����ز������ͬ����Ƶ�׷ֱ���
fc = 5.9e9;                         % ��Ƶ(5.9GHz,��ѭIEEE 802.11p��׼)
mod_level = 16;                     % M-QAM�׵���
ofdm_subframe_num = M;              % OFDM�ӷ�����
k_bit = log2(mod_level);            % ÿ���ű�����
pad_len = 10;                       % ��䳤��,Ӧ�����ŵ�������ӳ��Եֿ��ྶ����
EbN0_dB = 0:1:30;                   % �����(dB)
cp_size = 0.1;                      % ѭ��ǰ׺�����֡�ĳ���
cp_len = floor(cp_size * N);        % ѭ��ǰ׺����
code_rate = 2 / 4;                  % ������
max_iter = 10;                      % LDPC����������������
total_bits = 1e6;                   % �ܹ������bit��Ϣ��
pilot_spacing = 8;                  % ��Ƶ���(ÿ8�����ز�һ����Ƶ)
guard_size = 12;                    % �������ز�����
data_len = N - guard_size;          % ��Ϣλ����
intr_seed = 4831;                   % �����֯������
B = N * df;                         % �źŴ���
max_v = 40;                         % �������ٶ�(m/s)
c = physconst("LightSpeed");        % ����
max_doppler_shift = max_v * fc / c; % ��������Ƶ��
range_min = c / (N * df);           % ����ֱ���(m)
doppler_min = df / M;               % ������Ƶ�Ʒֱ���(Hz)
v_min = doppler_min * c / fc;       % �ٶȷֱ���(m/s)
otfs_frame_time = M / df;           % һ��֡����(s)
chan_time = 1 / (max_v * fc / c);   % �ŵ����ʱ��(s)
antenna_tx_gain = 3;                % ������������(dBi)
antenna_rx_gain = 3;                % ������������(dBi)
tx_power = 10;                      % ����̨���书��(dbm)
tx_NF = 10;                         % ����̨ϵͳ����ϵ��(dB)
rx_NF = 10;                         % ����̨ϵͳ����ϵ��(dB)
sinusoids_num = 32;                 % Jakes�ŵ���ģ�������Ҳ�����
Tem_scenario = 290;                 % �����¶�(K)
k = physconst("Boltzmann");         % ������������
snr = EbN0_dB + 10 * log10(code_rate * k_bit) + 10 * log10(data_len / N); % �����

fprintf("����ֱ���:%.2f m\n�ٶȷֱ���:%.2f m/s �� %.2f km/h \n֡����:%.4f ms\n�ŵ����ʱ��:%.4f ms", ...
    range_min,v_min,v_min * 3.6,otfs_frame_time * 1e3,chan_time * 1e3);
%%
% ����֡���ȵ����ŵ����ʱ�䣬����Ĭ����һ��֡��ʱ���ڣ��ŵ����Լ�������

% % ���ɵ�Ƶ��������
% pilot_bin = floor(N / 2) + 1;
% test_matrix = zeros(M,N); % �������ž���
% test_matrix(1,pilot_bin) = exp(1i * pi / 4); % ����һ����״��Ƶ�ź��������ŵ�����
%% ��������

% ��һ�ַ���������
%%
% �ŵ�����
% �Ȼ�ȡ������ͽ��ջ���λ��(�������RSU����,���ջ���Ego car�󳵶�)
% Ego carλ��
ego_car_pos = scenario.Actors(1).Position;
ego_car_rx_pos = ego_car_pos + [0 0 1.5]; % ���������ڳ���1.5m��
% RSUλ��
rsu_pos = scenario.Actors(4).Position;
rsu_tx_pos = rsu_pos + [0 0 5]; % ����������RSU 5m�߶�
% ��ȡ������������λ��
other_car_pos = scenario.Actors(2).Position;
truck_pos = scenario.Actors(3).Position;
bike_pos = scenario.Actors(5).Position;
% ��һ�δ���·��(rsu-ego rsu-othercar rsu-truck rsu-bike)
straight_signal_path = [euc_distance(ego_car_rx_pos,rsu_tx_pos),euc_distance(other_car_pos,rsu_tx_pos),...
    euc_distance(truck_pos,rsu_tx_pos),euc_distance(bike_pos,rsu_tx_pos)];
% �ܴ���·��(rsu-ego rsu-othercar+othercar-ego rsu-truck+truck-ego rsu-bike+bike-ego)(m)
real_path = [straight_signal_path(1) + euc_distance(ego_car_rx_pos,ego_car_rx_pos),...
    straight_signal_path(2) + euc_distance(ego_car_rx_pos,other_car_pos),...
    straight_signal_path(3) + euc_distance(ego_car_rx_pos,truck_pos),...
    straight_signal_path(4) + euc_distance(ego_car_rx_pos,bike_pos)];
% ����˶��ٶ�(��Ego carΪ��׼)
total_v = [-25,-5,-40,-20];
% �ܴ���ʱ��(s)
real_delay = [real_path(1) / c real_path(2) / c real_path(3) / c real_path(4) / c];
% ��ͬ·��(���Ƿ�����)�ķ���˥��(dB)
reflect_deacy = [0 0 0 -11.4];
% ��ͬ·�������ɿռ�˥��(dB)
pathloss_list = [-free_pathloss_cal(real_path(1),fc) -free_pathloss_cal(real_path(2),fc) ...
    -free_pathloss_cal(real_path(3),fc) -free_pathloss_cal(real_path(4),fc)];
% ����·������˥��(dB)
total_fad_list = [reflect_deacy(1) + pathloss_list(1),...
    reflect_deacy(2) + pathloss_list(2),...
    reflect_deacy(3) + pathloss_list(3),...
    reflect_deacy(4) + pathloss_list(4)];
% % ϵͳ������(dbm)
% heat_noise = 10 * log10(Tem_scenario * k * B * 1e3);
% % �շ�ϵͳӲ������(������ + ����ϵ��)
% sys_hardware_noise = heat_noise + tx_NF + rx_NF;
% % ��ͬ·���ĵ��﹦��(dbm)
% rx_power = [tx_power + antenna_rx_gain + antenna_tx_gain + pathloss_list(1) + reflect_deacy(1),...
%     tx_power + antenna_rx_gain + antenna_tx_gain + pathloss_list(2) + reflect_deacy(2),...
%     tx_power + antenna_rx_gain + antenna_tx_gain + pathloss_list(3) + reflect_deacy(3),...
%     tx_power + antenna_rx_gain + antenna_tx_gain + pathloss_list(4) + reflect_deacy(4)];
%%
% ԭʼ�ź�����
parity_check_matrix = dvbs2ldpc(code_rate); % ����LDPC�����żУ�����
% LDPC���������
ldpc_encoder_config = ldpcEncoderConfig(parity_check_matrix);
ldpc_decoder_config = ldpcDecoderConfig(parity_check_matrix);
code_word_length = size(parity_check_matrix,2); % �����볤
disp(ldpc_encoder_config);
disp(ldpc_decoder_config);
%%
% ������
ofdm_err = zeros(length(EbN0_dB),3);
c_ofdm_err = zeros(length(EbN0_dB),3);
otfs_err = zeros(length(EbN0_dB),3);
c_otfs_err = zeros(length(EbN0_dB),3);
code_err = zeros(1,3);
uncode_err = zeros(1,3);

uncode_error_rate = comm.ErrorRate('ResetInputPort',true);
code_error_rate = comm.ErrorRate('ResetInputPort',true);
%%
% ����ԭʼ����
[encode_raw_data,uncode_raw_data,bin_data,packet_size,packet_num,code_block_num] = ...
    raw_signal_gen(k_bit,data_len,total_bits,code_rate,ofdm_subframe_num,ldpc_encoder_config,intr_seed);
no_coded_bits = size(parity_check_matrix,2);
% ���������ྶ�ŵ�˥��ģ��
tx_signal_size = zeros((N + cp_len),ofdm_subframe_num); % �ŵ���С
rayleigh_chan = comm.RayleighChannel(...
    "AveragePathGains",total_fad_list,...
    "FadingTechnique","Sum of sinusoids",...
    "NumSinusoids",sinusoids_num,...
    "SampleRate",B,...
    "MaximumDopplerShift",max_doppler_shift,...
    "NormalizePathGains",true,...
    "PathDelays",real_delay,...
    "InitialTime",0);
disp(rayleigh_chan);
% [multipath_chan_impulse,raw_impulse] = multipath_chan(fc,cp_size,df,tx_signal_size,max_v,real_delay,total_fad_list);
[multipath_chan_impulse,raw_impulse] = multipath_chan(fc,cp_size,df,tx_signal_size,max_v,real_delay,total_fad_list);
% ��˹�������ŵ�
awgn_chan = comm.AWGNChannel('NoiseMethod','Variance','VarianceSource','Input port');
disp(awgn_chan);
%%
% M-QAM����
qam_tx = qammod(encode_raw_data,mod_level,"InputType","bit","UnitAveragePower",true);
parallel_tx = reshape(qam_tx,[data_len,ofdm_subframe_num * packet_size]); % ת��Ϊ��������
% ������1����ӱ���
guardband_tx = [zeros(1,ofdm_subframe_num * packet_size); parallel_tx];
% �������ط��������11���������
guardband_tx = [guardband_tx(1:(data_len/2),:); ...
    zeros(guard_size - 1,ofdm_subframe_num * packet_size);...
    guardband_tx((data_len / 2) + 1:end,:)];
%%
% OFDM����
frame_buffer = guardband_tx; % ����δ���ƻ�����
tx_frame_buffer = []; % ���ͻ�����
for w = 1:packet_size
    ofdm_tx = ofdm_mod(frame_buffer(:,1:ofdm_subframe_num),N,cp_len,ofdm_subframe_num);
    frame_buffer(:,1:ofdm_subframe_num) = []; % ɾȥ�ѵ��Ƶ��ź�
    tx_frame_buffer = [tx_frame_buffer;ofdm_tx]; % ��ӵ����ͻ�����
end
%%
ofdm_waitbar = waitbar(0,"OFDM����������...");
% ÿ������ȷ���һ��
for m = 1:length(EbN0_dB)
    % ÿ����������ݰ������з���
    for p = 1:packet_num
        rx_frame_buffer = []; % ���ý��ջ�����
        for u = 1:packet_size
            % ��֡��ȡ�ź�
            tx_signal = tx_frame_buffer(((u - 1) * numel(ofdm_tx) + 1):u * numel(ofdm_tx));
            % �źž����ŵ�
            faded_signal = zeros(size(tx_signal)); % ˥�����ź�
            for i = 1:size(tx_signal,1)
                for j = 1:size(tx_signal,2)
                    faded_signal(i,j) = tx_signal(i,j) .* multipath_chan_impulse(i,j);
                end
            end
            
            % ��˹�������ŵ�
            release(awgn_chan);
            power_dB(u) = 10 * log10(var(faded_signal));            % ���㷢�Ͷ��źŹ���
            noise_var = 10 .^ (0.1 * (power_dB(u) - snr(m)));       % ������ȼ�����������
            rx_signal = awgn_chan(faded_signal,noise_var);          % �źž�����˹�������ŵ�
            
            % �ŵ�����
            [equalise_signal,chan_est] = chan_equaliser(rx_signal,faded_signal,tx_signal,...
                ofdm_subframe_num,pilot_spacing);
            if EbN0_dB(m) == 5
                chan_est_15 = chan_est;
            end
            % OFDM���
            rx_subframe = ofdm_demod(equalise_signal,cp_len,ofdm_subframe_num);    % OFDM���
            rx_frame_buffer = [rx_frame_buffer';rx_subframe']';                    % �򻺳����洢�������
        end
        % ȥ���������
        parallel_rx = rx_frame_buffer;
        parallel_rx((data_len / 2) + 1:(data_len / 2) + guard_size - 1,:) = []; % ȥ�������ط��ı������
        parallel_rx(1:1,:) = [];                                                % ȥ������1���ı������
        qam_rx_signal = reshape(parallel_rx,[numel(parallel_rx),1]);            % ��������ת����
        
        % δ�������ݵĽ��
        uncode_demod_signal = qamdemod(qam_rx_signal,mod_level,...
            'OutputType','bit','UnitAveragePower',true);                          % QAM���
        uncode_data_out = randdeintrlv(uncode_demod_signal,intr_seed);            % �⽻֯
        uncode_data_out(numel(bin_data) + 1:end) = [];                            % ȥ�����λ
        uncode_err = uncode_error_rate(bin_data,uncode_data_out,0);               % ͳ������
        
        % �ѱ������ݵĽ��
        power_dB(u) = 10 * log10(var(qam_rx_signal));                   % �����źŹ���
        noise_var = 10 .^ (0.1 * (power_dB(u) - (EbN0_dB(m) + ...
            10 * log10(code_rate * k_bit) - 10 * log10(sqrt(data_len)))));  % ������������
        code_demod_signal = qamdemod(qam_rx_signal,mod_level,'OutputType', ...
            'approxllr','UnitAveragePower',true,'NoiseVariance',noise_var); % QAM���
        code_data_out = randdeintrlv(code_demod_signal,intr_seed);          % �⽻֯����
        code_data_out(numel(bin_data) + 1:end) = [];                        % ȥ�����λ
        
        data_bits_out = []; % ����������
        data_out_buffer = code_data_out; % ���뻺����
        for q = 1:code_block_num
            data_bits_out = [data_bits_out;ldpcDecode(data_out_buffer(1:no_coded_bits),...
                ldpc_decoder_config,max_iter)];       % �������벢д�����������
            data_out_buffer(1:no_coded_bits) = [];    % ɾ���Ѿ�����Ľ��
        end
        data_bits_out = double(data_bits_out);                             % ת��Ϊ˫����
        code_err = code_error_rate(uncode_raw_data,data_bits_out,0);       % �ռ�������
    end
    % �洢��������
    ofdm_err(m,:) = uncode_err;
    c_ofdm_err(m,:) = code_err;
    uncode_err = uncode_error_rate(bin_data,uncode_data_out,1);
    code_err = code_error_rate(uncode_raw_data,data_bits_out,1);
    
    waitbar(m / length(EbN0_dB),ofdm_waitbar); % ���½�����
end
close(ofdm_waitbar); % �رս�����
%%
% ���ز�����
frame_buffer = guardband_tx;
tx_frame_buffer = [];
for w = 1:packet_size
    otfs_tx = ISFFT(frame_buffer(:,1:ofdm_subframe_num));
    ofdm_tx = ofdm_mod(otfs_tx,N,cp_len,ofdm_subframe_num);
    frame_buffer(:, 1:ofdm_subframe_num) = [];
    tx_frame_buffer = [tx_frame_buffer;ofdm_tx];
end
%%
otfs_waitbar = waitbar(0,"OTFS����������...");
for m = 1:length(EbN0_dB)
    
    for p = 1:packet_num
        rx_frame_buffer = [];
        
        for u = 1:packet_size
            
            tx_signal = tx_frame_buffer(((u - 1) * numel(ofdm_tx) + 1):u * numel(ofdm_tx));
            
            faded_signal = zeros(size(tx_signal));
            for i = 1:size(tx_signal,1)
                for j = 1:size(tx_signal,2)
                    faded_signal(i,j) = tx_signal(i,j) .* multipath_chan_impulse(i,j);
                end
            end
            
            release(awgn_chan);
            power_dB(u) = 10 * log10(var(faded_signal));
            noise_var = 10 .^ (0.1 * (power_dB(u) - snr(m)));
            rx_signal = awgn_chan(faded_signal,noise_var);
            
            equalise_signal = chan_equaliser(rx_signal,faded_signal,tx_signal,ofdm_subframe_num,pilot_spacing);
            
            otfs_rx = ofdm_demod(equalise_signal,cp_len,ofdm_subframe_num);
            rx_subframe = SFFT(otfs_rx);
            rx_frame_buffer = [rx_frame_buffer';rx_subframe']';
        end
        
        parallel_rx = rx_frame_buffer;
        parallel_rx((data_len / 2) + 1:(data_len / 2) + guard_size - 1,:) = [];
        parallel_rx(1:1,:) = [];
        qam_rx = reshape(parallel_rx,[numel(parallel_rx),1]);
        
        % δ����
        uncode_demod_signal = qamdemod(qam_rx,mod_level,'OutputType','bit','UnitAveragePower',true);
        uncode_data_out = randdeintrlv(uncode_demod_signal,intr_seed);
        uncode_data_out(numel(bin_data) + 1:end) = [];
        uncode_err = uncode_error_rate(bin_data,uncode_data_out,0);
        % �ѱ���
        power_dB(u) = 10 * log10(var(qam_rx));
        noise_var = 10 .^ (0.1 * (power_dB(u) - (EbN0_dB(m) + 10 * log10(code_rate *...
            k_bit) - 10 * log10(sqrt(data_len)))));
        code_demod_signal = qamdemod(qam_rx,mod_level,'OutputType', 'approxllr','UnitAveragePower',true,'NoiseVariance',noise_var);
        code_data_out = randdeintrlv(code_demod_signal,intr_seed);
        code_data_out(numel(bin_data) + 1:end) = [];
        
        data_bits_out = [];
        data_out_buffer = code_data_out;
        for q = 1:code_block_num
            data_bits_out = [data_bits_out;ldpcDecode(data_out_buffer(1:no_coded_bits),...
                ldpc_decoder_config,max_iter)];
            data_out_buffer(1:no_coded_bits) = [];
        end
        data_bits_out = double(data_bits_out);
        code_err = code_error_rate(uncode_raw_data,data_bits_out,0);
        
    end
    otfs_err(m,:) = uncode_err;
    c_otfs_err(m,:) = code_err;
    uncode_err = uncode_error_rate(bin_data,uncode_data_out,1);
    code_err = code_error_rate(uncode_raw_data,data_bits_out,1);
    
    waitbar(m / length(EbN0_dB),otfs_waitbar); % ���½�����
end
close(otfs_waitbar);
%%
% ����һ�θ���һ�γ���������һ���ŵ�������һ��ͨ�����֪Ч��
% �˴���д���������ͨ�Ÿ�֪�߼�
% scenario.advance; % ��������
%% �����ͼ

% ��ͼ
figure;
semilogy(EbN0_dB,ofdm_err(:,1),'-g');
hold on;
semilogy(EbN0_dB,otfs_err(:,1),'-r');
semilogy(EbN0_dB,c_ofdm_err(:,1) + 1 / total_bits,'--g');
semilogy(EbN0_dB,c_otfs_err(:,1) + 1 / total_bits,'--r');
axis on
legend("OFDM","OTFS","C-OFDM","C-OTFS");
xlabel("Eb/N0"),ylabel("������");

legend(["OFDM", "OTFS", "C-OFDM", "C-OTFS"],...
    "Position", [0.1585 0.1428 0.1768, 0.1464])

xlim("auto")
ylim("auto")
% �ŵ���Ӧ��ͼ
figure;
mesh(1:281,0:63,abs(SFFT(raw_impulse)));
figure;
imagesc(1:281,0:63,abs(SFFT(raw_impulse)));
figure;
mesh(1:281,0:63,abs(SFFT(chan_est_15)'));
figure;
imagesc(1:281,0:63,abs(SFFT(chan_est_15)'));
%% �������

mat_filename = sprintf("%d_num_SNR_result",length(EbN0_dB));
save(mat_filename,"EbN0_dB","ofdm_err","c_ofdm_err","otfs_err","c_otfs_err",...
    "raw_impulse","chan_est_15","max_iter");