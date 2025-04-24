function faded_signal = multi_fad(u,tx_frame_buffer,ofdm_tx,chan_impulse)
    % extraction of signal by frame
    tx_signal = tx_frame_buffer(((u - 1) * numel(ofdm_tx) + 1):u * numel(ofdm_tx));
    % signal through a communication channel
    faded_signal = zeros(size(tx_signal)); % fading signal
    for i = 1:size(tx_signal,1)
        for j = 1:size(tx_signal,2)
            faded_signal(i,j) = tx_signal(i,j) .* chan_impulse(i,j);
        end
    end
end