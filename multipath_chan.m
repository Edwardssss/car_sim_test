function [chan_impulse,raw_impulse] = multipath_chan(fc,cp_size,delta_f,raw_signal,max_v,real_delay,path_gain)
%MULTIPATH_CHAN 多径信道生成

% Create N x M channel matrix
[N, M]= size(raw_signal');                                     % Size of inSig is used to create channel model
n = zeros(1,N);                                          % delay_Doppler rows (doppler)
m = zeros(1,M);                                          % delay_Doppler cols (delay)
H = transpose(n) .* m;                                     % Create matrix

rng shuffle; % 随机化种子
L = length(real_delay); % 路径数目
% fd = round(max_v * fc / physconst('lightspeed'));

[rician_loss,rician_index] = max(path_gain);
other_loss = (sum(path_gain) - rician_loss) / (L - 1);
K_ratio = 10 .^ ((rician_loss - other_loss) / 10);

fd = round(max_v * fc / physconst('lightspeed'));

Vi = zeros(1,L);
for l = 0:L - 1
    Vi(l + 1) = fd * cos((2 * pi * l) / (L - 1));
end

T = 1 / delta_f;
Ts = (1 + cp_size) / delta_f;     % OFDM符号时间
Ti = real_delay;
hi = path_gain;


for m=1:M
    for n=1:N
        for x=1:L
            % Define terms of model
            expRician = (-2 * 1i * (pi)) * ((m + M / 2) .* delta_f .*...
                Ti(rician_index) - Vi(rician_index) .* (n) .* Ts);
            expTerm_other = (-2 * 1i * (pi)) * ((m + M / 2) .* delta_f .*...
                Ti(x) - Vi(x) .* (n) .* Ts);
            hiPrime = hi(x) * (1 + 1i * (pi) .* Vi(x) .* T);
            % 生成信道冲激响应
            H(n, m) = H(n, m) + sqrt(K_ratio / (K_ratio + 1)) * exp(expRician) +...
                sqrt(1 / (K_ratio + 1)) * exp(expTerm_other) * hiPrime;
        end
    end
end
raw_impulse = H;
chan_impulse = reshape(H',[n*m,1]);
end

