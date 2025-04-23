P = [
    16 17 22 24  9  3 14 -1  4  2  7 -1 26 -1  2 -1 21 -1  1  0 -1 -1 -1 -1
    25 12 12  3  3 26  6 21 -1 15 22 -1 15 -1  4 -1 -1 16 -1  0  0 -1 -1 -1
    25 18 26 16 22 23  9 -1  0 -1  4 -1  4 -1  8 23 11 -1 -1 -1  0  0 -1 -1
     9  7  0  1 17 -1 -1  7  3 -1  3 23 -1 16 -1 -1 21 -1  0 -1 -1  0  0 -1
    24  5 26  7  1 -1 -1 15 24 15 -1  8 -1 13 -1 13 -1 11 -1 -1 -1 -1  0  0
     2  2 19 14 24  1 15 19 -1 21 -1  2 -1 24 -1  3 -1  2  1 -1 -1 -1 -1  0
    ];
blockSize = 27;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize,P);
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
cfgLDPCDec = ldpcDecoderConfig(pcmatrix);
M = 4;
iter_num = 1:1:20;
snr = 3;
numframes = 1000;

bar = waitbar(0,"waiting...");
ber = comm.ErrorRate;
ber2 = comm.ErrorRate;
c_err = zeros(1,length(iter_num));
nc_err = zeros(1,length(iter_num));
for ii = 1:length(iter_num)
    for counter = 1:numframes
        data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
        % Transmit and receive with LDPC coding
        encodedData = ldpcEncode(data,cfgLDPCEnc);
        modSignal = qammod(encodedData,M,InputType='bit');
        [rxsig, noisevar] = awgn(modSignal,snr);
        demodSignal = qamdemod(rxsig,M, ...
            OutputType='approxllr', ...
            NoiseVariance=noisevar);
        rxbits = ldpcDecode(demodSignal,cfgLDPCDec,iter_num(ii));
        errStats = ber(data,rxbits);
        % Transmit and receive with no LDPC coding
        noCoding = pskmod(data,M,InputType='bit');
        rxNoCoding = awgn(noCoding,snr);
        rxBitsNoCoding = pskdemod(rxNoCoding,M,OutputType='bit');
        errStatsNoCoding = ber2(data,int8(rxBitsNoCoding));
    end
    fprintf(['SNR = %2d\n iter = %d\n   Coded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        snr,iter_num(ii),errStats(1),errStats(2))
    fprintf(['Noncoded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        errStatsNoCoding(1),errStatsNoCoding(2))
    reset(ber);
    reset(ber2);
    c_err(ii) = errStats(1);
    nc_err(ii) = errStatsNoCoding(1);
    waitbar(ii / length(iter_num),bar);
end
close(bar);
% figure;
% hold on
%% 绘图

semilogy(iter_num,c_err + 1 / cfgLDPCEnc.NumInformationBits / numframes,'-ro');
hold on
semilogy(iter_num,nc_err + 1 / cfgLDPCEnc.NumInformationBits  / numframes,'-bo');
legend("LDPC编码","未编码"),xlabel("迭代次数"),ylabel("误码率"),title("LDPC编码误码率与迭代次数的关系");