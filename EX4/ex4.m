%% Flow Phantom Data
data = load('pht_center1.mat');

%% Ccarotid Artery Data
data = load('pm_car1.mat');

%% Aorta Data
data = load('aorta_long1.mat');

%% parameter
comp_data = data.complex_data;
Ns = size(comp_data,2)
exc_fs = 3.2 * 1000000; % [Hz]
segment_size = 128; % 
pct_overlap = 0.50; % [pct] how much to overlap each segment.
dynamic_range = 30; % [dB]
duration = 10.34; % [s]
sample_freq = Ns / duration; % [Hz]
dt = 1/sample_freq; % [s]
c = 1500;


%% Hanning and compression
data = hann_comp( ...
    comp_data, ...
    segment_size, ...
    pct_overlap, ...
    dynamic_range);
data = flip(data);
figure(1)
f = -sample_freq/2:sample_freq/segment_size:sample_freq/2;
v = f/exc_fs * c / 2.0;
t = (1:length(data))*duration/length(data);
image(t, v, data)
xlabel('Time [s]')
ylabel('Velocity [m/s]')
title([num2str(segment_size), ' segment size, ', ...
    num2str(100*pct_overlap), '% overlap, ', ...
    num2str(dynamic_range), ' dB dynamic range.'])
colormap(gray(128))




