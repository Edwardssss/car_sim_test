% -*- coding: utf-8 -*-
%
% @File    :   awgn_init.m
% @Time    :   2025/04/24 19:57:41
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function awgn_chan = awgn_init()
    awgn_chan = comm.AWGNChannel('NoiseMethod','Variance','VarianceSource','Input port');
end