% -*- coding: utf-8 -*-
%
% @File    :   sig_demod.m
% @Time    :   2025/04/25 00:43:29
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function [uncode_data_out,data_bits_out] = sig_demod(rx_frame_buffer,PAR_STRUCT,RAW_DATA_STRUCT,LDPC_CONFIG,ERROR_STRUCT,var_par,test_mod)
if nargin == 1
    test_mod = "Eb/N0";
end
% removes the guard interval
parallel_rx = rx_frame_buffer;
parallel_rx((PAR_STRUCT.data_len / 2) + 1:(PAR_STRUCT.data_len / 2) + PAR_STRUCT.guard_size - 1,:) = []; % 去掉其他地方的保护间隔
parallel_rx(1:1,:) = [];                                                % 去掉索引1处的保护间隔
qam_rx_signal = reshape(parallel_rx,[numel(parallel_rx),1]);            % 并行数据转串行
if test_mod == "Eb/N0"
    % demodulation of uncoded data
    uncode_demod_signal = qamdemod(qam_rx_signal,PAR_STRUCT.mod_level,...
        'OutputType','bit','UnitAveragePower',true);                          % QAM解调
    uncode_data_out = randdeintrlv(uncode_demod_signal,PAR_STRUCT.intr_seed);            % 解交织
    uncode_data_out(numel(RAW_DATA_STRUCT.bin_data) + 1:end) = [];                            % 去除填充位
    ERROR_STRUCT.uncode_err = uncode_error_rate(RAW_DATA_STRUCT.bin_data,uncode_data_out,0);               % 统计误码
    
    % demodulation of encoded data
    power_dB(u) = 10 * log10(var(qam_rx_signal));                   % 计算信号功率
    noise_var = 10 .^ (0.1 * (power_dB(u) - (PAR_STRUCT.EbN0_dB(var_par) + ...
        10 * log10(PAR_STRUCT.code_rate * PAR_STRUCT.k_bit) - 10 * log10(sqrt(PAR_STRUCT.data_len)))));  % 计算噪声功率
    code_demod_signal = qamdemod(qam_rx_signal,PAR_STRUCT.mod_level,'OutputType', ...
        'approxllr','UnitAveragePower',true,'NoiseVariance',noise_var); % QAM解调
    code_data_out = randdeintrlv(code_demod_signal,PAR_STRUCT.intr_seed);          % 解交织数据
    code_data_out(numel(RAW_DATA_STRUCT.bin_data) + 1:end) = [];                        % 去除填充位
    
    data_bits_out = []; % 译码输出结果
    data_out_buffer = code_data_out; % 译码缓冲区
    for q = 1:RAW_DATA_STRUCT.code_block_num
        data_bits_out = [data_bits_out;ldpcDecode(data_out_buffer(1:LDPC_CONFIG.no_coded_bits),...
            LDPC_CONFIG.ldpc_decoder_config,PAR_STRUCT.max_iter)];       % 数据译码并写入输出缓冲区
        data_out_buffer(1:LDPC_CONFIG.no_coded_bits) = [];    % 删除已经译码的结果
    end
    data_bits_out = double(data_bits_out);                             % 转换为双精度
    ERROR_STRUCT.code_err = code_error_rate(RAW_DATA_STRUCT.uncode_raw_data,data_bits_out,0);       % 收集误码结果
end
end