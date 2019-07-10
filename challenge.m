%% Computer Vision Challenge 2019
addpath('./funcs');addpath('./lib');
% Group number:
group_number = 5;

% Group members:
% members = {'Max Mustermann', 'Johannes Daten'};
members = {'Fuqi Guan', 'Hang Yu', 'Fan Wu', 'Hanwen Zheng', 'Yidong Zhao'};


% Email-Address (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};
mail = {'a','a','a','a','yidong.zhao@tum.de'};

%% Start timer here
tic;

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
scene_path = './data/terrace';
% 
% Calculate disparity map and Euclidean motion
[D, R, T] = disparity_map(scene_path);

%% Validation
% Specify path to ground truth disparity map
gt_path = './data/terrace';
%
% Load the ground truth
G = readGTFromDir(gt_path);
% 
% Estimate the quality of the calculated disparity map
p = validate_dmap(D, G);

%% Stop timer here
elapsed_time = toc;


%% Print Results
% R, T, p, elapsed_time
fprintf("Rotation: %8.4f\nTranslation:%8.4f\nPNSR:%8.4f [dB]", R, T, p);


%% Display Disparity
figure; imshow(D); colormap jet;
