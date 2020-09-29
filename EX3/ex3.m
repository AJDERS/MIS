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
depth_axis = (1:dim) * (0.005 / radius * dim);
figure(2)
imagesc(depth_axis, depth_axis, scatter_map);

center_line = round(size(scatter_map,1)/2);
received_signal = conv(scatter_map(center_line,:), data);
figure(3)
plot(((1:1350)*(0.005 / radius * dim)), received_signal)


%% Generate 100 signals
Ns = 100;
fprf = 5000;
tprf= 1 / fprf;
vz = 0.15;
x_shift = 1/fprf
time_shift = ((2 * vz) / c) * tprf;

time_shift_mat = zeros(size(received_signal,2),Ns);
for i=1:Ns
    disp(size(received_signal(i:end)))
    time_shift_mat(:,i) = cat(2,zeros(1,(i-1)*3),received_signal(1:end-((i-1)*3)));
end
z_axis = ((1:1350)*(0.005 / radius * dim));
figure(4)
imagesc((1:100)*x_shift, z_axis, time_shift_mat)

figure(5)
plot((1:100)*time_shift, time_shift_mat(length(z_axis)/2,:))


