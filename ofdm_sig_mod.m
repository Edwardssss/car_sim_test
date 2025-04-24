% -*- coding: utf-8 -*-
%
% @File    :   ofdm_sig_mod.m
% @Time    :   2025/04/25 00:43:35
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function [ofdm_tx,tx_frame_buffer] = ofdm_sig_mod(qam_tx_signal,ofdm_subframe_num,packet_size)
    frame_buffer = qam_tx_signal; % send buffer
    tx_frame_buffer = [];
    for w = 1:packet_size
        ofdm_tx = ofdm_mod(frame_buffer(:,1:ofdm_subframe_num),N,cp_len,ofdm_subframe_num);
        frame_buffer(:,1:ofdm_subframe_num) = []; % 删去已调制的信号
        tx_frame_buffer = [tx_frame_buffer;ofdm_tx]; % 添加到发送缓冲区
    end
end
