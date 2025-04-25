% -*- coding: utf-8 -*-
%
% @File    :   otfs_sim.m
% @Time    :   2025/04/25 10:33:22
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss
function otfs_sim(RAW_DATA_STRUCT,PAR_STRUCT,PATH_STRUCT,var_par,test_mod,ofdm_tx,awgn_chan)
if nargin == 1
    test_mod = "Eb/N0";
end
rx_frame_buffer = [];
if test_mod == "Eb/N0"

for u = 1:RAW_DATA_STRUCT.packet_size
    faded_signal = multi_fad(u,tx_frame_buffer,ofdm_tx,PATH_STRUCT.chan_impulse);
    rx_signal = add_noise(u,var_par,awgn_chan,snr,faded_signal,test_mod);
    equalize_signal = chan_equalizer(rx_signal,faded_signal,PAR_STRUCT.ofdm_subframe_num,PAR_STRUCT.pilot_spacing);
    otfs_rx = ofdm_demod(equalize_signal,PAR_STRUCT.cp_len,PAR_STRUCT.ofdm_subframe_num);
    rx_subframe = SFFT(otfs_rx);
    rx_frame_buffer = [rx_frame_buffer';rx_subframe']';
end

parallel_rx = rx_frame_buffer;
parallel_rx((data_len / 2) + 1:(data_len / 2) + guard_size - 1,:) = [];
parallel_rx(1:1,:) = [];
qam_rx = reshape(parallel_rx,[numel(parallel_rx),1]);

% 未编码
uncode_demod_signal = qamdemod(qam_rx,mod_level,'OutputType','bit','UnitAveragePower',true);
uncode_data_out = randdeintrlv(uncode_demod_signal,intr_seed);
uncode_data_out(numel(bin_data) + 1:end) = [];
uncode_err = uncode_error_rate(bin_data,uncode_data_out,0);
% 已编码
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
end