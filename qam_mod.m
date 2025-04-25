% -*- coding: utf-8 -*-
%
% @File    :   qam_mod.m
% @Time    :   2025/04/24 19:59:37
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function [qam_tx_signal,guard_tx] = qam_mod(RAW_DATA_STRUCT,PAR_STRUCT)
% M-QAM
qam_tx = qammod(RAW_DATA_STRUCT.encode_raw_data,PAR_STRUCT.mod_level,"InputType","bit","UnitAveragePower",true);
parallel_tx = reshape(qam_tx,[PAR_STRUCT.data_len,PAR_STRUCT.ofdm_subframe_num * RAW_DATA_STRUCT.packet_size]); % 转换为并行数据
% add protection at index 1
guard_tx = [zeros(1,PAR_STRUCT.ofdm_subframe_num * RAW_DATA_STRUCT.packet_size); parallel_tx];
% add the remaining guard intervals elsewhere
qam_tx_signal = [guard_tx(1:(PAR_STRUCT.data_len/2),:); ...
    zeros(PAR_STRUCT.guard_size - 1,PAR_STRUCT.ofdm_subframe_num * RAW_DATA_STRUCT.packet_size);...
    guard_tx((PAR_STRUCT.data_len / 2) + 1:end,:)];
end