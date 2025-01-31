function beamforming
clear;
close all;

%% Geometry  %%%% GET FROM PARAMETER FILE
num_elm = 192;
num_trans_elm = 64;
conv_radius = 60.3 / 1000; %m
elm_height = 13 / 1000; %m
elm_width = 0.3 / 1000; %m
elm_kerf = 0.03 / 1000; %m

circle_convex = 2 * pi * conv_radius;
elm_pitch = elm_kerf + elm_width; %m
size_transducer = (num_elm - 1) * elm_pitch + elm_width; %m
angle_span_transducer = (size_transducer / circle_convex) * (360*pi/180); %radians
angle_span_elm = angle_span_transducer / 192;

%% Element positions (Polar coordinates)
offset = (elm_kerf + elm_width) / 2 ; %m
radial_coord = ones(num_elm,1) * (conv_radius);
angular_coord = ...
    reshape( ...
        cat(2, ...
            (-offset -angle_span_elm * 95):angle_span_elm:(-offset), ...
            offset:angle_span_elm:(offset + angle_span_elm * 95)), ...
        num_elm, 1); %radians


%% Simulation Parameters
sim_para = load('sim_parameters.mat');
par = load('parameters.mat');
t_start = par.sarus_rx.record(1).start_time;
sample_fs = par.sarus_sys.sampling_frequency;
c = sim_para.sim_para.c;



%% Load RF data
rf_data_cell = cell(1,129); % store each image line.
i = 1;
directory = dir('duplex/B_mode/seq_0001/');
for file_index = 3%:length(directory) 
    disp(directory(file_index).name);
    if directory(file_index).isdir == 0
        data = ...
            load(['duplex/B_mode/seq_0001/', directory(file_index).name]);
        rf_data_cell{i} = data.samples;
        i = i + 1;
    end
end

%% Time/depth axis, images.
steps = size(rf_data_cell{1}, 1);
time_axis = (0:(steps-1))/ sample_fs + t_start;
depth_axis = (time_axis / 2 * c);
figure(1)
imagesc(1:192, depth_axis, rf_data_cell{1})
xlabel('Elements')
ylabel('depth [m]')


%% ROI (Polar coordinates)
min_depth = 0.058; %m
max_depth = 0.062; %m
roi_r = (min_depth:0.001:max_depth); % [m] 'r' for radius.
roi_t = angular_coord;

%% Beamforming
beamformed_image = zeros(length(roi_r), length(roi_t));
figure(2)
%imagesc(1:192, depth_axis, rf_data_cell{1})
% xlabel('Elements')
% ylabel('Depth [m]')
% title('Time-of-flight delays for each element at (r=0.0420 [m], theta=-29 [degrees]) for the 65th emission.')
%ylim([depth_axis(800), depth_axis(1100)])
hold on

for i=1%:5%:length(rf_data_cell)
    sprintf('Calculating the %0.5g frame.', i)
    % Make meshgrid of ROI and elements.
    % (mm, radians)
    [R, Theta] = meshgrid(roi_r, roi_t(i));
        
    % Convert to cartesian coords for delay calculation.
    [g_z, g_x] = pol2cart(Theta, R); % Grid (x,z)
    [e_z, e_x] = pol2cart(Theta, conv_radius); % Element (x,z)
    e_z = e_z - conv_radius
    
    figure()
    plot(g_x, g_z, 'o')
    hold 
    % Calculate time of flight delay array.
    time_of_flight_delay = ToF(g_x, g_z, e_x, e_z, c);
    pxl_to_take = round(time_of_flight_delay * sample_fs);
     
    for t = 1:length(roi_t) % Angular Axis
        for r = round(length(roi_r)/2)%1:length(roi_r)    % Radial Axis
            %sprintf('Beamforming at %0.5g mm, %0.5g degrees', roi_r(r)*1000, roi_t(t)*57)
            coord_sum = ones(num_elm,1);
            for elm = 1:num_elm
                delay = pxl_to_take(elm, r);
                t_start = par.sarus_rx.record(i).start_time;
                depth_to_take = round(((g_z(elm,r)*2/c) - t_start) * sample_fs ) + delay;
                %depth_to_take = round(((g_z(elm,r)*2/c) - t_start) * sample_fs ) + delay;
                if depth_to_take >= 0 && depth_to_take <= steps
                    
                    coord_sum(elm) = rf_data_cell{i}(depth_to_take,elm);
                    if t==2
                        %tmp(:,elm) = cat(1, rf_data_cell{1}(depth_to_take:end,elm), zeros(depth_to_take-1,1));
                        plot(elm, depth_axis(depth_to_take), 'ro');
                    end
                else
                    coord_sum(elm) = rf_data_cell{i}(1,elm);
                end
            end
            % Sum
            beamformed_image(r,t) = sum(coord_sum);    
        end
    end
end
hold off
% figure(3)
% imagesc(1:192, depth_axis, tmp)
% ylim([depth_axis(1), depth_axis(2500)])
% xlabel('Elements')
% ylabel('Depth [m]')

% %% Interpolation parameters
start_depth = 0; %?????? - Depth for start of image in meters
image_size = 0.1; %??????  - Size of image in meters
start_of_data = roi_r(1);
delta_r = c / sample_fs;
N_samples = size(rf_data_cell{1},1);
theta_start = roi_t(1);
delta_theta = roi_t(1)-roi_t(2);
N_lines = size(rf_data_cell{2},2);
scaling = 1.0; %????? - Scaling factor from envelope to image
Nz = 128; % - Size of image in pixels
Nx = 128; % - Size of image in pixels



%% Make image
figure(4)
imagesc(roi_r, roi_t, beamformed_image);
colormap gray;
envelope = abs(hilbert(double(beamformed_image)));
norm_env = envelope /(max(max(envelope)));
comp_env = 20 * log10(norm_env + eps);
dyna_range_env = uint32(127/60 * (comp_env + 60));
make_tables(start_depth, ...
    image_size, ...
    start_of_data, ...
    delta_r, ...
    N_samples, ...
    theta_start, ...
    delta_theta, ...
    N_lines, ...
    scaling, ...
    Nz, ...
    Nx);
img = make_interpolation(dyna_range_env);
figure(5)
imagesc(img);
colormap gray;
sprintf('Done') 
end

%% Subfunctions
function time_of_flight_delay = ToF(g_x, g_z, e_x, e_z, c)
    dist_to_grid_point = sqrt(g_z.^2 + g_x.^2);
    dist_from_grid_to_elm = sqrt((g_x-e_x).^2 + (g_z-e_z).^2);
    time_of_flight_delay = (dist_from_grid_to_elm - dist_to_grid_point) / c;
end
