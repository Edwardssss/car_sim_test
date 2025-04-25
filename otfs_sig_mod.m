% -*- coding: utf-8 -*-
%
% @File    :   otfs_sig_mod.m
% @Time    :   2025/04/25 09:57:45
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function otfs_sig_mod(RAW_DATA_STRUCT,PAR_STRUCT,guard_tx)
frame_buffer = guard_tx;
tx_frame_buffer = [];
for w = 1:RAW_DATA_STRUCT.packet_size
    otfs_tx = ISFFT(frame_buffer(:,1:PAR_STRUCT.ofdm_subframe_num));
    ofdm_tx = ofdm_mod(otfs_tx,PAR_STRUCT.N,PAR_STRUCT.cp_len,PAR_STRUCT.ofdm_subframe_num);
    frame_buffer(:, 1:PAR_STRUCT.ofdm_subframe_num) = [];
    tx_frame_buffer = [tx_frame_buffer;ofdm_tx];
end
end