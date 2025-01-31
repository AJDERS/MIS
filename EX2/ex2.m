%%
p = load('psf1.mat');
%%
% Contour plot
x_axis = [1:length(p.psf1(1,:))].*p.dx;
z_axis = [1:length(p.psf1(:,1))].*p.dz;
levels = [-11:0].*6.0;
env = abs(hilbert(p.psf1));
envelope = 20 * log10(env / max(env(:)));
figure(1)
contour(x_axis, z_axis, envelope, levels);

%%
p = load('psf2.mat');
%%
% Contour plot
x_axis = [1:length(p.psf2(1,:))].*p.dx;
z_axis = [1:length(p.psf2(:,1))].*p.dz;
levels = [-11:0].*6.0;
env = abs(hilbert(p.psf2));
envelope = 20 * log10(env / max(env(:)));
figure(2)
contour(x_axis, z_axis, envelope, levels);

%%
%Make scatterer map
Nz = round(40/1000/p.dz);
scatter_point_10 = round(10/1000/p.dx);
scatter_point_30 = round(30/1000/p.dx);
Nx = round(40/1000/p.dx);
Nr = round(5/1000/p.dx);
scatter_map = randn(Nz, Nx);
x = ones(Nz,1)*(-Nx/2:Nx/2-1);
z = (-Nz/2:Nz/2-1)'*ones(1,Nx);
outside = sqrt(z.^2 + x.^2) > Nr*ones(Nz, Nx);
scatter_map = scatter_map.*outside;
scatter_map(scatter_point_10, scatter_point_10) = 300.0;
scatter_map(scatter_point_10, scatter_point_30) = 300.0;
scatter_map(scatter_point_30, scatter_point_10) = 300.0;
scatter_map(scatter_point_30, scatter_point_30) = 300.0;
%%
% Add point reflectors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plt = imshow(scatter_map);
saveas(plt, 'scatter_map.png');

%%
% Do convolution.
p = load('psf1.mat');
conv = conv2(scatter_map, p.psf1);

% Find envelope and scale to dynamic range of 60 dB.
envelope = abs(hilbert(double(conv)));
envelope = envelope /(max(max(envelope)));
envelope = 20 * log10(envelope + eps);
envelope = 127/60 * (envelope + 60);
envelope(envelope<-60)=-60;
imagesc(envelope(1:180, 50:200));
colormap gray;
axis;


%%
p_2 = load('psf2.mat');
conv = conv2(p_2.psf2, scatter_map);

% Find envelope and scale to dynamic range of 60 dB.
envelope = abs(hilbert(double(conv)));
envelope = envelope /(max(max(envelope)));
envelope = 20 * log10(envelope + eps);
envelope = 127/60 * (envelope + 60);
envelope(envelope<-60)=-60;
imagesc(envelope(1:180, 50:200));
colormap gray;
axis;
