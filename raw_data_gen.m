% -*- coding: utf-8 -*-
%
% @File    :   raw_data_gen.m
% @Time    :   2025/04/24 18:52:15
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function raw_data_struct = raw_data_gen(PAR_STRUCT,LDPC_CONFIG)
raw_data_struct.packet_size = 1;               % number of sub frames in the initial packet
raw_data_struct.code_block_num = 1;            % the number of code blocks in the initial subframe
encode_length = 64800;         % LDPCcodeword length(DVB-S2 long code specification)

% calculate subframe size and maximum subframe number
subframe_size = [PAR_STRUCT.k_bit * PAR_STRUCT.data_len * PAR_STRUCT.ofdm_subframe_num 1];               % calculate subframe length
max_subframes = ceil(PAR_STRUCT.total_bits ./ subframe_size(1));         % total number of required subframes(rounded up)

% Determine number of code block and number of subframes/packet
if subframe_size(1) == encode_length               % the subframe size is equal to the code block length
    raw_data_struct.code_block_num = 1;
    raw_data_struct.packet_size = 1;
elseif subframe_size(1) > encode_length            % subframe size  > code block length
    [raw_data_struct.code_block_num, raw_data_struct.packet_size] = rat(subframe_size(1)./ encode_length,1e-1);
elseif subframe_size(1) < encode_length            % subframe size < code block length
    [raw_data_struct.packet_size, raw_data_struct.code_block_num] = rat(encode_length ./ subframe_size(1),1e-1);
end

% ensure sufficient data capacity
while raw_data_struct.code_block_num * encode_length >= subframe_size(1) * raw_data_struct.packet_size
    raw_data_struct.packet_size = raw_data_struct.packet_size + 1;
    if (rem(raw_data_struct.code_block_num,2) == 0) && (rem(raw_data_struct.packet_size,2) == 0) &&...
        raw_data_struct.code_block_num * encode_length <= subframe_size(1) * raw_data_struct.packet_size
        raw_data_struct.packet_size = raw_data_struct.packet_size ./ 2;
        raw_data_struct.code_block_num = raw_data_struct.code_block_num ./ 2;
    end
end

% calculate the number of padding bits and packets
pad_bits = zeros((subframe_size(1) * raw_data_struct.packet_size - raw_data_struct.code_block_num * ...
encode_length),1);                                  % calculate padding bits
raw_data_struct.packet_num = round(max_subframes ./ raw_data_struct.packet_size);       % total package
raw_data_struct.packet_num(~raw_data_struct.packet_num) = 1;                            % number of packages must be at least 1

% Generate Random Input Data
rng("shuffle"); % randomize random number seeds
raw_data_struct.bin_data = [];
raw_data_struct.uncode_raw_data = [];
for q = 1:raw_data_struct.code_block_num
    data_bits = randi([0,1],[encode_length * PAR_STRUCT.code_rate,1]);   % generating information bits
    raw_data_struct.uncode_raw_data = [raw_data_struct.uncode_raw_data;data_bits];            % stitching raw data
    code_temp = ldpcEncode(data_bits,LDPC_CONFIG.encode_config);
    raw_data_struct.bin_data = [raw_data_struct.bin_data;code_temp]; % perform LDPC encoding
end
padded_data_in = [raw_data_struct.bin_data; pad_bits]; % adding padding bits
raw_data_struct.encode_raw_data = randintrlv(padded_data_in,PAR_STRUCT.intr_seed);
end