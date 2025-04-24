% -*- coding: utf-8 -*-
%
% @File    :   ofdm_sim.m
% @Time    :   2025/04/25 00:44:10
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function [uncode_data_out,data_bits_out] = ofdm_sim(PAR_STRUCT,ERROR_STRUCT,PATH_STRUCT,LDPC_CONFIG,RAW_DATA_STRUCT,ofdm_tx,tx_frame_buffer,awgn_chan,var_par,test_mod)
if nargin == 1
    test_mod = "Eb/N0";
end
rx_frame_buffer = []; % set receive buffer
for u = 1:RAW_DATA_STRUCT.packet_size
    faded_signal = multi_fad(u,tx_frame_buffer,ofdm_tx,PATH_STRUCT.chan_impulse);
    rx_signal = add_noise(u,var_par,awgn_chan,PAR_STRUCT.snr,faded_signal,test_mod);
    % channel equalization
    [equalize_signal,~] = chan_equalizer(rx_signal,faded_signal,...
        PAR_STRUCT.ofdm_subframe_num,PAR_STRUCT.pilot_spacing);
    rx_frame_buffer = [rx_frame_buffer';ofdm_sig_demod(equalize_signal,PAR_STRUCT.cp_len,PAR_STRUCT.ofdm_subframe_num)']'; % store demodulated data into buffer
end

[uncode_data_out,data_bits_out] = sig_demod(rx_frame_buffer,PAR_STRUCT,RAW_DATA_STRUCT,LDPC_CONFIG,ERROR_STRUCT,var_par,test_mod);

end