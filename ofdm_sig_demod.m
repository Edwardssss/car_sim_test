% -*- coding: utf-8 -*-
%
% @File    :   ofdm_sig_demod.m
% @Time    :   2025/04/25 00:37:19
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss
function rx_subframe = ofdm_sig_demod(equalise_signal,cp_len,ofdm_subframe_num)
    % OFDM demodulation
    rx_subframe = ofdm_demod(equalise_signal,cp_len,ofdm_subframe_num);
end