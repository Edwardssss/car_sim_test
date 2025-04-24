% -*- coding: utf-8 -*-
%
% @File    :   ldpc_init.m
% @Time    :   2025/04/24 18:51:55
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function LDPC_config = ldpc_init(code_rate)
    parity_matrix = dvbs2ldpc(code_rate); % parity check matrix
    % 编译码对象
    LDPC_config.encode_config = ldpcEncoderConfig(parity_matrix);
    LDPC_config.decode_config = ldpcDecoderConfig(parity_matrix);
    LDPC_config.no_coded_bits = size(parity_check_matrix,2);
end