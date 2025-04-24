% -*- coding: utf-8 -*-
%
% @File    :   sim_top.m
% @Time    :   2025/04/24 10:39:36
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

% Top Level Document Of Synaesthesia Integrated Simulation
%% Pretreatment
clc,clear,clf;
%% Scene Settings
[~,sim_scenario,~] = car_scenario_file();
%% Parameter Initialization
PAR_STRUCT = par_init();
%% Path Parameter Return
PATH_STRUCT = scenario_read(sim_scenario,PAR_STRUCT.fc);
%% Raw Signal And Data Generation
LDPC_CONFIG = ldpc_init(PAR_STRUCT.code_rate);
ERROR_STRUCT = err_init(length(PAR_STRUCT.EbN0_dB));
RAW_DATA_STRUCT = raw_data_gen(PAR_STRUCT,LDPC_CONFIG);
MULTIPATH_STRUCT = multipath_init(PAR_STRUCT,PATH_STRUCT);
qam_tx_signal = qam_mod(RAW_DATA_STRUCT,PAR_STRUCT);
[ofdm_tx,tx_frame_buffer] = ofdm_sig_mod(qam_tx_signal,PAR_STRUCT.ofdm_subframe_num,RAW_DATA_STRUCT.packet_size);
%% OFDM Simulation
ofdm_waitbar = waitbar(0,"OFDM simulation in operation...");
for bit_energy_to_noise_energy = 1:length(PAR_STRUCT.EbN0_dB)
    for p = 1:RAW_DATA_STRUCT.packet_num
        [uncode_data_out,data_bits_out] = ofdm_sim(PAR_STRUCT,ERROR_STRUCT,PATH_STRUCT,LDPC_CONFIG,RAW_DATA_STRUCT,ofdm_tx,tx_frame_buffer,awgn_chan,bit_energy_to_noise_energy,"Eb/N0");
    end
    err_cal(ERROR_STRUCT,RAW_DATA_STRUCT,uncode_data_out,data_bits_out,bit_energy_to_noise_energy);
    waitbar(m / length(EbN0_dB),ofdm_waitbar);
end
close(ofdm_waitbar);
%% OTFS Simulation

