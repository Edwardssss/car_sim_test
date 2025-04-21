function  [encode_raw_data,uncode_raw_data,bin_data,packet_size,...
    packet_num,code_block_num] = raw_signal_gen(k_bit,data_len,...
    total_bits,code_rate,ofdm_subframe_num,ldpc_encoder_config,intr_seed)
%RAW_SIGNAL_GEN 原始信号生成

% encode_raw_data LDPC编码后的数据
% uncode_raw_data LDPC编码前的数据
% bin_data        原始二进制数据
% packet_size     数据包大小
% packet_num      所需数据包的个数
% code_block_num  

% k_bit                      每符号比特数
% data_len                   数据位长度
% total_bits                 总比特数
% code_rate                  编码率
% ofdm_subframe_num          OFDM子载波数目
% ldpc_encoder_config        ldpc编码器

packet_size = 1;               % 初始包中的子帧数
code_block_num = 1;            % 初始子帧中码块数
encode_length = 64800;         % LDPC码字长度(DVB-S2长码规范)

% 计算子帧大小与最大子帧数
subframe_size = [k_bit * data_len * ofdm_subframe_num 1];               % 计算子帧长度
max_subframes = ceil(total_bits ./ subframe_size(1));         % 所需子帧总数(向上取整)

% Determine number of code block and number of subframes/packet
if subframe_size(1) == encode_length               % 子帧大小等于码块长度
    code_block_num = 1;
    packet_size = 1;
    
elseif subframe_size(1) > encode_length            % 子帧大小 > 码块长度
    [code_block_num, packet_size] = rat(subframe_size(1)./ encode_length,1e-1);
    
elseif subframe_size(1) < encode_length            % 子帧大小 < 码块长度
    [packet_size, code_block_num] = rat(encode_length ./ subframe_size(1),1e-1);
end   

% 确保数据容量足够
while code_block_num * encode_length >= subframe_size(1) * packet_size
    packet_size = packet_size + 1;
    if (rem(code_block_num,2) == 0) && (rem(packet_size,2) == 0) &&...
            code_block_num * encode_length <= subframe_size(1) * packet_size
        packet_size = packet_size ./ 2;
        code_block_num = code_block_num ./ 2;
    end
end 

% 计算填充比特与包数量
pad_bits = zeros((subframe_size(1) * packet_size - code_block_num * ...
    encode_length),1);                                  % 计算填充比特
packet_num = round(max_subframes ./ packet_size);       % 总包数
packet_num(~packet_num) = 1;                            % 包数至少为1

% Generate Random Input Data
rng("shuffle");                              % 随机化随机数种子
bin_data = [];
uncode_raw_data = [];
for q = 1:code_block_num
    data_bits = randi([0,1],[encode_length * code_rate,1]);   % 生成信息比特
    uncode_raw_data = [uncode_raw_data;data_bits];            % 拼接原始数据
    code_temp = ldpcEncode(data_bits,ldpc_encoder_config);
    bin_data = [bin_data;code_temp];           % 进行LDPC编码
end
paddedData_in = [bin_data; pad_bits];                         % 添加填充比特
encode_raw_data = randintrlv(paddedData_in,intr_seed);        % 随机交织
end