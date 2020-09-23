clear;
%% Load and plot (1)
pulse = load('pulse.mat');
data = pulse.pulse;
time_step = (1 /pulse.fs) / size(data,1);
time_axis = zeros(size(data,1),1);
time_axis(:,1) = reshape(0:time_step:(time_step*(size(data,1)-1)), size(data));
figure(1)
plot(time_axis, data(:,1));
xlabel('Time [0,10] nanoseconds.') 
ylabel('Velocity.') 


%% Make signal.
%Make scatterer map
c = 1500;
dim = 1000;
[x,z] = meshgrid(1:dim, 1:dim);
scatter_map = randn(dim);
center = round(dim/2);
radius = (0.005 / (c/pulse.fs));
circle = (x - center).^2 + (z - center).^2 / 2 <= radius.^2;
scatter_map = scatter_map .* circle;
time_axis = zeros(dim,1);
time_axis(:,1) = reshape(0:time_step:(time_step*(dim-1)), dim,1);
figure(2)
imagesc(time_axis, time_axis, scatter_map);

received_signal = conv2(scatter_map, data);
figure(3)
imagesc(time_axis, time_axis, received_signal)


%% Generate 100 signals
fprf = 5000;
tprf= 1 / fprf;
vz = 0.15;
time_shift = ((2 * vz) / c) * tprf;
