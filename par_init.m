% -*- coding: utf-8 -*-
%
% @File    :   par_init.m
% @Time    :   2025/04/24 11:02:42
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

%% Parameter Initialization
function sim_struct = par_init()
sim_struct.M = 64;                             % Delay(number of symbols in time domain)
sim_struct.N = 256;                            % Doppler(number of subcarriers)
sim_struct.df = 50e3;                          % interval of subcarrier frequencies(Hz),same subcarrier spacing as LTE system's spectral resolution
sim_struct.fc = 5.9e9;                         % carrier frequency(5.9GHz,IEEE 802.11p standard)
sim_struct.mod_level = 16;                     % M-QAM
sim_struct.ofdm_subframe_num = M;              % OFDM subsymbol number
sim_struct.k_bit = log2(mod_level);            % number of bits per symbol
sim_struct.pad_len = 10;                       % the padding length(should be greater than the maximum delay of the channel to resist multipath interference)
sim_struct.EbN0_dB = 0:1:30;                   % Eb/N0(dB)
sim_struct.const_EbN0_dB = 10;                 % const Eb/N0(dB)
sim_struct.cp_size = 0.1;                      % cyclic prefix relative to frame length
sim_struct.cp_len = floor(cp_size * N);        % cyclic prefix length
sim_struct.code_rate = 2 / 4;                  % coding rate
sim_struct.max_iter = 10;                      % maximum number of iterations for decoding ldpc codes
sim_struct.total_bits = 1e6;                   % total amount of bits transmitted
sim_struct.pilot_spacing = 8;                  % pilot interval(one pilot per 8 subcarriers)
sim_struct.guard_size = 12;                    % number of protected subcarriers
sim_struct.data_len = N - guard_size;          % information bit length
sim_struct.intr_seed = 4831;                   % random interleaving seed
sim_struct.B = N * df;                         % signal bandwidth
sim_struct.max_v = 40;                         % maximum relative velocity(m/s)
sim_struct.c = physconst("LightSpeed");        % speed of light
sim_struct.max_doppler_shift = max_v * fc / c; % maximum doppler shift
sim_struct.range_min = c / (N * df);           % range resolution(m)
sim_struct.doppler_min = df / M;               % doppler shift resolution(Hz)
sim_struct.v_min = doppler_min * c / fc;       % velocity resolution(m/s)
sim_struct.otfs_frame_time = M / df;           % one frame length(s)
sim_struct.chan_time = 1 / (max_v * fc / c);   % channel coherence time(s)
sim_struct.Tem_scenario = 290;                 % scene temperature (K)
sim_struct.k = physconst("Boltzmann");         % boltzmann constant
sim_struct.rsu_height = [0 0 5];               % rsu height
sim_struct.car_height = [0 0 1.5];             % vehicle antenna height
sim_struct.total_v = [-25,-5,-40,-20];         % object speed
sim_struct.reflect_decay = [0 0 0 -11.4];      % reflective surface attenuation
sim_struct.snr = EbN0_dB + 10 * log10(...
    code_rate * k_bit) + 10 * ...
    log10(data_len / N);            % snr
%% Output Result
fprintf("range resolution: %.2f m\n velocity resolution:%.2f m/s or %.2f km/h \n frame length:%.4f ms\n channel coherence time:%.4f ms", ...
    sim_struct.range_min,sim_struct.v_min,sim_struct.v_min * 3.6,sim_struct.otfs_frame_time * 1e3,sim_struct.chan_time * 1e3);
end