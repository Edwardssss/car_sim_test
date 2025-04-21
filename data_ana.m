clc,clear,clf;
load("81_num_SNR_result.mat");
total_bits = 1e6;
% 绘图
figure(1);
semilogy(EbN0_dB,ofdm_err(:,1),'-g');
hold on;
semilogy(EbN0_dB,otfs_err(:,1),'-r');
semilogy(EbN0_dB,c_ofdm_err(:,1) + 1 / total_bits,'--g');
semilogy(EbN0_dB,c_otfs_err(:,1) + 1 / total_bits,'--r');
axis on
legend("OFDM","OTFS","C-OFDM","C-OTFS");
xlabel("Eb/N0"),ylabel("误码率");

legend(["OFDM", "OTFS", "C-OFDM", "C-OTFS"],...
    "Position", [0.1585 0.1428 0.1768, 0.1464])
xlim("auto")
ylim("auto")
% 信道响应绘图
figure(2);
mesh(1:281,0:63,abs(SFFT(raw_impulse)));
ylabel("多普勒频移"),xlabel("时延"),title("原始信道响应网格曲面图");
figure(3);
imagesc(1:281,0:63,abs(SFFT(raw_impulse))),colorbar;
ylabel("多普勒频移"),xlabel("时延"),title("原始信道响应");
figure(4);
mesh(1:281,0:63,abs(SFFT(chan_est)'));
ylabel("多普勒频移"),xlabel("时延"),title("信道估计结果网格曲面图");
figure(5);
imagesc(1:281,0:63,abs(SFFT(chan_est)')),colorbar;
ylabel("多普勒频移"),xlabel("时延"),title("信道估计响应");