% -*- coding: utf-8 -*-
%
% @File    :   multipath_init.m
% @Time    :   2025/04/24 19:11:09
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function MULTIPATH_STRUCT = multipath_init(PAR_STRUCT,PATH_STRUCT)
tx_signal_size = zeros((PAR_STRUCT.N + PAR_STRUCT.cp_len),PAR_STRUCT.ofdm_subframe_num); % channel size
% Create N x M channel matrix
[N, M]= size(tx_signal_size'); % Size of inSig is used to create channel model



rng shuffle; % randomization seed
L = length(PATH_STRUCT.real_delay); % path number

[rician_loss,rician_index] = max(PAR_STRUCT.total_fad_list);
other_loss = (sum(PAR_STRUCT.total_fad_list) - rician_loss) / (L - 1);
K_ratio = 10 .^ ((rician_loss - other_loss) / 10);
Vi = zeros(1,L);

% Jakes Model
fd = round(PAR_STRUCT.max_v * PAR_STRUCT.fc / PAR_STRUCT.c);
for l = 0:L - 1
    Vi(l + 1) = fd * cos((2 * pi * l) / (L - 1));
end

% Jakes-like model
% fd = round(PAR_STRUCT.total_v * PAR_STRUCT.fc  / PAR_STRUCT.c);
% for l = 1:L
%     Vi(l) = fd(l);
% end

T = 1 / PAR_STRUCT.delta_f;
Ts = (1 + PAR_STRUCT.cp_size) / PAR_STRUCT.delta_f;     % OFDM符号时间
Ti = PATH_STRUCT.real_delay;
hi = PATH_STRUCT.total_fad_list;

[H,m,n] = impulse_cal(M,N,L,Ts,Ti,T,hi,K_ratio,PAR_STRUCT.delta_f,Vi,rician_index);

MULTIPATH_STRUCT.raw_impulse = H;
MULTIPATH_STRUCT.chan_impulse = reshape(H',[n * m,1]);
end