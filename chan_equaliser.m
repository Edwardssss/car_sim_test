function [equalise_signal,h_est] = chan_equaliser(rx_signal,faded_signal,...
    tx_signal,ofdm_subframe_num,pilot_spacing)
%CHAN_EQUALISER 信道均衡

frame_sample_num = numel(rx_signal)/ofdm_subframe_num;       % 每符号采样点数
subcarrier_num = pow2(floor(log2(frame_sample_num)));   % 实际用于传输数据的子载波数

% 重组为矩阵(行=采样点，列=符号)
faded_signal_matrix = reshape(faded_signal, [frame_sample_num,ofdm_subframe_num]);
tx_signal_matrix = reshape(tx_signal, [frame_sample_num,ofdm_subframe_num]);

% 去除循环前缀(保留有效数据部分)
faded_signal_matrix(1:(frame_sample_num - subcarrier_num),:) = [];
tx_signal_matrix(1:(frame_sample_num - subcarrier_num),:) = [];

% 信道估计
h = zeros(size(tx_signal_matrix)); % 估计的信道响应
for i = 1:size(tx_signal_matrix,1)
    for j = 1:size(tx_signal_matrix,2)
        % 第一个与最后一个子载波强制作为导频
        if i == 1
            if abs(tx_signal_matrix(i,j)) == 0
                sample(i,j) = 1; % 防止因为除0导致NaN出现
            else
                sample(i,j) = faded_signal_matrix(i,j) ./ tx_signal_matrix(i,j);
            end
        elseif mod(i,pilot_spacing) == 0
            if abs(tx_signal_matrix(i,j)) == 0
                sample(i / pilot_spacing + 1,j) = 1;
            else
                sample(i / pilot_spacing + 1,j) = faded_signal_matrix(i,j) ./ tx_signal_matrix(i,j);
            end
        end
    end
end

% 对导频之间的子载波进行频域线性插值
interp_points = ((1 + (1 / pilot_spacing)):(1 / pilot_spacing):size(sample,1));
for j = 1:size(tx_signal_matrix,2)
    h(:,j) = interp1(sample(:,j),interp_points,"makima",1);
end

% 取符号的导频响应
h1 = [h(:,1)';h(:,8)';h(:,16)';h(:,24)';h(:,32)';h(:,40)';h(:,48)';h(:,56)';h(:,64)']';

% 进行符号间线性插值
interpPoints1 = (1:(1 / (pilot_spacing - 1)):2); % 1-8插值
interpPoints2 = ((2 + (1 / pilot_spacing)):(1 / pilot_spacing):3); % 8-16插值
interpPoints3 = ((3 + (1 / pilot_spacing)):(1 / pilot_spacing):4); % 16-24插值
interpPoints4 = ((4 + (1 / pilot_spacing)):(1 / pilot_spacing):5); % 24-32插值
interpPoints5 = ((5 + (1 / pilot_spacing)):(1 / pilot_spacing):6); % 32-40插值
interpPoints6 = ((6 + (1 / pilot_spacing)):(1 / pilot_spacing):7); % 40-48插值
interpPoints7 = ((7 + (1 / pilot_spacing)):(1 / pilot_spacing):8); % 48-56插值
interpPoints8 = ((8 + (1 / pilot_spacing)):(1 / pilot_spacing):9); % 56-64插值

h18 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h816 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h1624 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h2432 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h3240 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h4048 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h4856 = zeros(size(tx_signal_matrix,1),pilot_spacing);
h5664 = zeros(size(tx_signal_matrix,1),pilot_spacing);

for i = 1:size(tx_signal_matrix,1)
    h18(i,:) = interp1(h1(i,:),interpPoints1,"makima",1);
    h816(i,:) = interp1(h1(i,:),interpPoints2,"makima",1);
    h1624(i,:) = interp1(h1(i,:),interpPoints3,"makima",1);
    h2432(i,:) = interp1(h1(i,:),interpPoints4,"makima",1);
    h3240(i,:) = interp1(h1(i,:),interpPoints5,"makima",1);
    h4048(i,:) = interp1(h1(i,:),interpPoints6,"makima",1);
    h4856(i,:) = interp1(h1(i,:),interpPoints7,"makima",1);
    h5664(i,:) = interp1(h1(i,:),interpPoints8,"makima",1);
end

% 合并插值结果
h = [h18';h816';h1624';h2432';h3240';h4048';h4856';h5664']';

% 将循环前缀部分的信道响应设为与第一个子载波相同
for q = 1:(frame_sample_num - subcarrier_num)
    h = [h(1,:);h];
end
h_est = h;
% 序列化输出
H = reshape(h,[numel(h),1]);
H(isnan(H)) = 1; % 将NaN设置为1(避免分母出现0)

% 信号均衡
equalise_signal = rx_signal ./ H;
equalise_signal(isnan(equalise_signal)) = 0;            % 将所有NaN设置为0

end

