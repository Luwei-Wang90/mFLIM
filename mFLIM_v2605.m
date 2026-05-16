%% mFLIM for TCSPC B&H data format *.sdt
%   Package name:     mFLIM
%   Package version:  2026-05-16
%   File version:     2026-05-16

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
% % % % %    addpath(genpath('./bfmatlab'))
% % % % %    savepath
%% Perform photon stacking on the .sdt data to obtain the Ig and Id intensity images
% load the data from *.sdt format file
[filename, path] = uigetfile( ...
{'*.sdt','Backer file format (*.sdt)';
   '*.mat', 'MATLAB formatted data (*.mat)'; ...
   '*.dat',  'Data (*.dat)'; ...
   '*.fig','Figures (*.fig)'; ...
   '*.txt','Text (*.txt)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Select a FLIM data file');
data = bfopen([path, filename]);
seriesCount = size(data, 1);
series1 = data{1,1};
metadataList = data{1,2};

% dimensions of the image
[x_dim_roi, y_dim_roi] = size(series1{1});
% lifetime channel count
tp_cot = size(series1, 1); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transfor the data cells from into matrix form
photons_matrix = zeros(x_dim_roi,y_dim_roi,tp_cot);
pho_mat_bin = zeros(x_dim_roi,y_dim_roi,tp_cot);
bin = 0; % INPUT: mean decay at each pixel by average bin*bin pixels
for i = 1:tp_cot
    % transform the data from cell to matrix
    photons_matrix(:,:,i) = series1{i,1};
    % calculate the mean decay matrix
    if bin>1
        pho_mat_bin(:,:,i) = colfilt(series1{i,1},[bin,bin],'sliding','mean');
    else
        pho_mat_bin(:,:,i) = series1{i,1};
    end
end

%% Obtain 8bit image
% Set the time channel alpha, such as 118
alpha = 120;  % Time-gated threshold
Ig = sum(photons_matrix(:,:,1:alpha),3);  %  Confocal image (32bit)
Id = sum(photons_matrix(:,:,alpha+1:end),3);  % Donut image (32bit)

% Increase contrast and convert to uin8 format
Ig = im2uint8(mat2gray(Ig));
Id = im2uint8(mat2gray(Id));

% Save Confcal and STED images
imwrite(Ig,'Ig.tif');
imwrite(Id,'Id.tif');

figure(1);
imshow(Id,[0 255]);

%% Perform low-pass filtering on the Id image
% Calculate the frequency domain of the Id image
s = fftshift(fft2(double(Id))); 
% figure(2), imshow(log(abs(s)+1),[]);
title('Fourier spectrum'); 
[a,b] = size(s);
h = zeros(a,b); % Filter function
LP_Donut = zeros(a,b); % Low-pass filtered image 
a0 = round(a/2);
b0 = round(b/2);
d = 35;  % The cutoff radius of the ideal low-pass filter

% Identification filtering range
figure(3), imshow(log(abs(s)+1),[]); hold on
title('The Fourier spectrum that indicates the filtering range'); 
circle_x = b0 - d; 
circle_y = a0 - d; 
circle_width = 2*d; 
circle_height = 2*d; 
rectangle('Position', [circle_x, circle_y, circle_width, circle_height], ...
          'Curvature', [1, 1], ... 
          'EdgeColor', 'r', ...    
          'LineWidth', 2);         
hold off; 

% Obtain the low-pass filtered image
for i = 1:a
    for j = 1:b
        distance = sqrt((i-a0)^2 + (j-b0)^2);
        if distance > d
            h(i,j) = 0;
        else
            h(i,j) = 1;
        end
    end
end
LP_Donut = s .* h;
LP_Donut = real(ifft2(ifftshift(LP_Donut)));

figure(4),imshow(LP_Donut,[0 255]);
title('Low-pass filtered donut');
Id_smooth = uint8(LP_Donut);

% Save Confocal and Donut images
imwrite(Id_smooth,'Id_smooth.tif');

%% %%%%%%%%%%%%%%%%% Obtain the secondary computational depletion (SCD) image %%%%%%%%%%%%%%%%%% 
% Set the differential coefficient, such as 1.5
beta = 1;
% obtain the SCD intensity image
Im = Ig - beta.*Id_smooth;

%% Obtain the mFLIM image
data = double(Im);
intensity_normal = (data-min(min(data)))/(max(max(data))-min(min(data)));   
imwrite(intensity_normal,'Im.tif');

% load confocal-equivalent lifetime(*.asc) obatained from TCSPC B&H data
file =sprintf('./3 beads/3 beads_color coded value.asc');
lifetime = double(load(file));

%  Fluorescence lifetime normalization
lifetime_min = 0000;
lifetime_max = 6000;  % Fluorescence lifetime display threshold
lifetime(lifetime > lifetime_max) = lifetime_max;
lifetime(lifetime < lifetime_min) = lifetime_min; 
tao = (lifetime-lifetime_min)/(lifetime_max-lifetime_min); 

% Allocate the HSV color channels
hsv_mFLIM = zeros(x_dim_roi,y_dim_roi,3);
hsv_mFLIM(:, :, 1) = tao*2/3;    % Hue
hsv_mFLIM(:, :, 2) = 1;        % Saturation
hsv_mFLIM(:, :, 3) = intensity_normal(:,:);  % Value

% Convert the HSV color space to the RGB color space
mFLIM_image = hsv2rgb(hsv_mFLIM);

% Display the mFLIM image(RGB image)
figure(5)
imshow(mFLIM_image,[],'border','tight');
figure(6)
imshow(intensity_normal,[],'border','tight');
%  save the mFLIM image
imwrite(mFLIM_image,'mFLIM_image.tif');  

