% -*- coding: utf-8 -*-
%
% @File    :   err_cal.m
% @Time    :   2025/04/24 20:31:02
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function err_cal(ERROR_STRUCT,RAW_DATA_STRUCT,uncode_data_out,data_bits_out,var_par)
    ERROR_STRUCT.ofdm_err(var_par,:) = ERROR_STRUCT.uncode_err;
    ERROR_STRUCT.c_ofdm_err(var_par,:) = ERROR_STRUCT.code_err;
    ERROR_STRUCT.uncode_err = uncode_error_rate(RAW_DATA_STRUCT.bin_data,uncode_data_out,1);
    ERROR_STRUCT.code_err = code_error_rate(RAW_DATA_STRUCT.uncode_raw_data,data_bits_out,1);
end