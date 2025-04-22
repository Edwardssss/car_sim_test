function demod_signal = ofdm_demod(mod_signal,cp_len,ofdm_subframe_num)
%OFDM_DEMOD OFDM解调
% 串行数据转并行
parallel_rx = reshape(mod_signal, numel(mod_signal)/ofdm_subframe_num, ofdm_subframe_num);
% 移除循环前缀
parallel_rx(1:(cp_len),:) = [];
% FFT处理
demod_signal =  fft(parallel_rx,[],2);
end