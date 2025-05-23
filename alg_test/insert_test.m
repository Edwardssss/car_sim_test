% -*- coding: utf-8 -*-
%
% @File    :   insert_test.m
% @Time    :   2025/04/22 15:40:06
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

%% 多径信道冲激响应生成函数
function [time_axis, h] = generate_multipath_channel(num_paths, max_delay, snr_db)
% 参数设置
fs = 100e6;              % 采样率 100 MHz
t_max = max_delay * 1.2; % 时间轴范围
num_samples = round(t_max * fs); % 采样点数

% 随机生成多径参数
delays = sort(rand(1, num_paths) * max_delay); % 均匀分布的时延
amplitudes = raylrnd(1, 1, num_paths);        % 瑞利分布幅度
phases = rand(1, num_paths) * 2 * pi;         % 均匀相位

% 初始化冲激响应
time_axis = linspace(0, t_max, num_samples);
h = complex(zeros(1, num_samples)); % 复数冲激响应

% 添加多径成分
for i = 1:num_paths
    delay = delays(i);
    idx = round(delay * fs) + 1; % MATLAB索引从1开始
    if idx <= num_samples
        h(idx) = h(idx) + amplitudes(i) * exp(1j*phases(i));
    end
end

% 添加高斯白噪声
signal_power = mean(abs(h).^2);
noise_power = signal_power * 10^(-snr_db/10);
noise = sqrt(noise_power/2) * (randn(1, num_samples) + 1j*randn(1, num_samples));
h = h + noise;
end

function error_mse = error_mse(est_x,real_x)
    error_mse = mean(abs(est_x - real_x));
end

%% 主测试程序
% 清空工作区
clear; close all; clc;

% 生成信道冲激响应
num_paths = 5;      % 多径数量
max_delay = 1e-6;   % 最大时延（秒）
snr_db = 30;        % 信噪比（dB）

[t, h] = generate_multipath_channel(num_paths, max_delay, snr_db);

% 可视化时域响应
figure('Position', [100 100 800 400])
subplot(1,2,1)
stem(t, abs(h), 'filled', 'MarkerSize', 4)
xlabel('Time (s)')
ylabel('Amplitude')
title('Channel Impulse Response')
xlim([0 max_delay*1.1])
grid on

% 计算并可视化功率时延分布
[~, idx] = max(abs(h)); % 找到主径位置
h_cir = h(idx:end);     % 截取信道冲激响应

subplot(1,2,2)
plot(t(idx:end), 10*log10(abs(h_cir).^2), 'LineWidth', 1.5)
xlabel('Time (s)')
ylabel('Power (dB)')
title('Power Delay Profile')
xlim([t(idx) max_delay*1.1])
grid on

%% 频域分析（附加功能）
NFFT = 1e4;
fs = 12.8e6 * 2;
H = fftshift(fft(h, NFFT));
f = (-NFFT/2:NFFT/2-1)*(fs/NFFT)/1e6; % 频率轴（MHz）

figure
plot(f, 20*log10(abs(H)/max(abs(H))))
xlabel('Frequency (MHz)')
ylabel('Normalized Magnitude (dB)')
title('Channel Frequency Response')
grid on
axis on

%% 采集样本
sample_index = 1:9:length(H);
sample_data = H(sample_index);

%% 插值
max_space = 10; % 最大导频间隔
min_space = 3; %最小导频间隔
% 计算时间
linear_mse = zeros(1,max_space - min_space + 1);
nearest_mse = zeros(1,max_space - min_space + 1);
next_mse = zeros(1,max_space - min_space + 1);
previous_mse = zeros(1,max_space - min_space + 1);
pchip_mse = zeros(1,max_space - min_space + 1);
cubic_mse = zeros(1,max_space - min_space + 1);
makima_mse = zeros(1,max_space - min_space + 1);
spline_mse = zeros(1,max_space - min_space + 1);

for i = 1:max_space - min_space + 1
    sample_index = 1:i:length(H);
    % 插值操作
    est_linear = interp1(sample_index,H(sample_index),1:length(H),"linear","extrap");
    est_nearest = interp1(sample_index,H(sample_index),1:length(H),"nearest","extrap");
    est_next = interp1(sample_index,H(sample_index),1:length(H),"next",1);
    est_previous = interp1(sample_index,H(sample_index),1:length(H),"previous");
    est_pchip = interp1(sample_index,H(sample_index),1:length(H),"pchip");
    est_cubic = interp1(sample_index,H(sample_index),1:length(H),"cubic");
    est_makima = interp1(sample_index,H(sample_index),1:length(H),"makima");
    est_spline = interp1(sample_index,H(sample_index),1:length(H),"spline");
    % 计算误差
    linear_mse(i) = error_mse(est_linear,H);
    nearest_mse(i) = error_mse(est_nearest,H);
    next_mse(i) = error_mse(est_next,H);
    previous_mse(i) = error_mse(est_previous,H);
    cubic_mse(i) = error_mse(est_cubic,H);
    makima_mse(i) = error_mse(est_makima,H);
    spline_mse(i) = error_mse(est_spline,H);
end

%% 比对结果
figure;
plot(min_space:1:max_space,linear_mse);
hold on
plot(min_space:1:max_space,nearest_mse);
% plot(min_space:1:max_space,next_mse);
% plot(min_space:1:max_space,previous_mse);
% plot(min_space:1:max_space,pchip_mse);
% plot(min_space:1:max_space,cubic_mse);
plot(min_space:1:max_space,makima_mse);
% plot(min_space:1:max_space,spline_mse);
% legend("linear","nearest","next","previous","pchip","cubic","makima","spline");
legend("linear","nearest","makima"),xlabel("采样点间隔"),ylabel("均方误差");
