% -*- coding: utf-8 -*-
%
% @File    :   add_noise.m
% @Time    :   2025/04/25 00:07:22
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function rx_signal = add_noise(u,var_par,awgn_chan,snr,faded_signal,test_mod)
    if nargin == 1
        test_mod = "Eb/N0";
    end
    % gaussian white noise channel
    release(awgn_chan);
    power_dB(u) = 10 * log10(var(faded_signal));            % 计算发送端信号功率
    if test_mod == "Eb/N0"
        noise_var = 10 .^ (0.1 * (power_dB(u) - snr(var_par)));       % 用信噪比计算噪声功率
        rx_signal = awgn_chan(faded_signal,noise_var);
    end
end