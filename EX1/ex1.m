rf_data = load('rf_data_phantom.mat');
rf_data.RFdata = cast(rf_data.RFdata, 'double');
center_index = round(length(rf_data.RFdata(1,:))/2);
center_line = rf_data.RFdata(:,center_index);
lambda = 1540 / rf_data.fs;
M = 2;


depth_step = lambda * M;
n_measurement = length(rf_data.RFdata(:,1));
X = zeros(1,n_measurement);
for i = 1:n_measurement
    X(i) = rf_data.start_of_data + i * depth_step;
end

% Plot of RF-center line
plt = plot(X,center_line)
%saveas(plt, 'figures/center_rf_plt.png');

% Plot of envelope and RF-center line
env = zeros(size(rf_data.RFdata));
for i = 1:length(rf_data.RFdata(1,:))
    env(:,i) = abs(hilbert(rf_data.RFdata(:,i)));
end
env_single = abs(hilbert(center_line));

plt = plot(X, center_line);
title('RF center line')
hold on
plot(X, env_single)
legend('RF_line','Envelope')
hold off
%saveas(plt, 'figures/center_rf_env_plt.png');


% Compression and scale

comp_env = 20 * log10(env + eps);
comp_env = comp_env /(max(max(comp_env)));
scale_comp_env = 127/60 * (comp_env + 60);
env = uint8(scale_comp_env);
plt = imshow(env);
%saveas(plt, 'figures/scale_comp_env_center.png');


% Use make_tables, and make_interpolation
start_depth = rf_data.roc; %?????? - Depth for start of image in meters
image_size = 0.3; %??????  - Size of image in meters
start_of_data = rf_data.start_of_data;
delta_r = rf_data.c_sound / rf_data.fs;
N_samples = size(env,1);
theta_start = rf_data.start_angle;
delta_theta = rf_data.angle;
N_lines = size(env,2);
scaling = 60.0; %????? - Scaling factor from envelope to image
Nz = 512; % - Size of image in pixels
Nx = 512; % - Size of image in pixels
make_tables(start_depth, image_size, start_of_data, delta_r, N_samples, theta_start, delta_theta, N_lines, scaling, Nz, Nx);
img_data = make_interpolation(uint32(env));

img = image(double(img_data));
colormap gray;
%saveas(img, '/figures/out_interpolation.png');


% Calculate envelops and maxs and mins
h = figure;
axis tight manual
filename = 'invivo.gif';
for i = 1:66
    im_data = load(['/frame_data/8820e_B_mode_invivo_frame_no_', num2str(i), '.mat']);
    data = cast(im_data.RFdata, 'double');
    env = zeros(size(data));
    for j = 1:length(data(1,:))
        env(:,j) = abs(hilbert(data(:,j)));
    end
    comp_env = env / max(max(env)); % Normalize
    comp_env = 20 * log10(comp_env); %log compress.
    scale_comp_env = 127/60*(comp_env+60); % Scale to grayscale.
    env_final = uint32(scale_comp_env); %to fit make_tables
    make_tables(start_depth, image_size, start_of_data, delta_r, N_samples, theta_start, delta_theta, N_lines, scaling, Nz, Nx);
    img = make_interpolation(env_final);
    imagesc(double(img));
    colormap gray;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1
        imwrite(imind, cm, filename, 'gif', 'LoopCount', inf);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append');
    end
end  
sprintf('Done')