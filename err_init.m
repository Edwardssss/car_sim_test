% -*- coding: utf-8 -*-
%
% @File    :   err_init.m
% @Time    :   2025/04/24 18:52:04
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function err_struct = err_init(sim_length)
    err_struct.ofdm_err = zeros(sim_length,3);
    err_struct.c_ofdm_err = zeros(sim_length,3);
    err_struct.otfs_err = zeros(sim_length,3);
    err_struct.c_otfs_err = zeros(sim_length,3);
    err_struct.code_err = zeros(1,3);
    err_struct.uncode_err = zeros(1,3);

    err_struct.uncode_error_rate = comm.ErrorRate('ResetInputPort',true);
    err_struct.code_error_rate = comm.ErrorRate('ResetInputPort',true);
end