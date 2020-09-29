function data = hann_comp(comp_data, segment_size, pct_overlap, dynamic_range)
    Ns = size(comp_data,1);
    
    %% Apply highpass filter, and hanning-window
    %comp_data = highpass(comp_data, 8000/25, 8000);
    hann_window = hann(segment_size);
    
    N_seq = round( ...
    (Ns - segment_size)/(segment_size - (segment_size * pct_overlap) / 2))-1;
    
    spectrum_sig = zeros(segment_size, N_seq);
    for i=1:N_seq
        % Get sequence
        start = segment_size*i - (segment_size*(pct_overlap*0.5))*i;
        en = start + segment_size;
        segment = comp_data(start+1:en);
        
        % Hanning window
        segment = hann_window .* segment;
        
        % Fourier transform
        segment = fftshift(fft(segment));
        
        spectrum_sig(:,i) = segment;
    end
    
    %% Compression
    %comp_data = abs(hilbert(comp_data));
    comp_data = spectrum_sig / max(max(spectrum_sig)); % Normalize
    comp_data = 20 * log10(comp_data); %log compress.
    comp_data = 127/dynamic_range*(comp_data + dynamic_range); % Scale to grayscale.
    data = real(comp_data);
end