% -*- coding: utf-8 -*-
%
% @File    :   impulse_cal.m
% @Time    :   2025/04/24 23:39:26
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss
function H = impulse_cal(M,N,L,Ts,Ti,T,hi,K_ratio,delta_f,Vi,rician_index)
n = zeros(1,N);                % delay_Doppler rows (doppler)
m = zeros(1,M);                % delay_Doppler cols (delay)
H = transpose(n) .* m;         % Create matrix
for i=1:M
    for j=1:N
        for x=1:L
            % Define terms of model
            exp_rician = (-2 * 1i * (pi)) * ((i + M / 2) .* delta_f .*...
                Ti(rician_index) - Vi(rician_index) .* (j) .* Ts);
            expTerm_other = (-2 * 1i * (pi)) * ((i + M / 2) .* delta_f .*...
                Ti(x) - Vi(x) .* (j) .* Ts);
            hiPrime = hi(x) * (1 + 1i * (pi) .* Vi(x) .* T);
            % 生成信道冲激响应
            H(j, i) = H(j, i) + sqrt(K_ratio / (K_ratio + 1)) * exp(exp_rician) +...
                sqrt(1 / (K_ratio + 1)) * exp(expTerm_other) * hiPrime;
        end
    end
end
end