function mod_signal = ofdm_mod(raw_data,N,cp_len,ofdm_subframe_num)
%OFDM_MOD OFDM调制函数

cyclic_prefix_start  = N - cp_len;

% IFFT运算
ifft_subcarrier = ifft(raw_data,[],2);

% 为每个子载波寻找循环前缀
cyclic_prefix_data = zeros(cp_len,ofdm_subframe_num);

for i=1:cp_len
    for j=1:ofdm_subframe_num
        cyclic_prefix_data(i,j) = ifft_subcarrier(i + cyclic_prefix_start,j);
    end
end

% 添加循环前缀
appended_cp = vertcat(cyclic_prefix_data, ifft_subcarrier);

% 序列化输出信号
mod_signal = reshape(appended_cp,[numel(appended_cp),1]);
end

