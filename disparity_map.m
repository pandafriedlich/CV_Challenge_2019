function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.
    %% Load input image pair - Not used any more!
    %  It's okay if u have '/' at the end of scene_path ;)
    %  im0 = double(imread(strcat(scene_path,'/im0.png')));
    %  im1 = double(imread(strcat(scene_path,'/im1.png')));
    %%  Use function readDataFromDir 
    testData = readDataFromDir(scene_path);
    im0 = rgb_to_gray(double(testData.im0));   
    im1 = rgb_to_gray(double(testData.im1));
    % Pack 2 cams' calib matrices into cell K
    K{1} = testData.params.cam0;
    K{2} = testData.params.cam1;
    %% Find Corners
    Corner_im0 = Corner_Finder(im0,'do_plot',false);
    Corner_im1 = Corner_Finder(im1);
    %% Find Matching points
    % Corner matrix must be transposed
    corresponds = Correspondings_Finder(im0, im1, Corner_im0', Corner_im1', ...
        'min_corr',0.96, 'do_plot', false); % 0.96 should be a good min_corr value
    %% Get Essential Matrix E
    %  get robust matching points using ransac
    Corresponds_robust = F_ransac(im0, im1, corresponds, 'k', 20, 'do_plot', false);
    % Apply acht-punkt-algo to get E or F
    E = achtpunktalgorithmus(Corresponds_robust, K);
    %% T and R from Essential Matrix
    [T, R, depth] = T_R_Finder(E, Corresponds_robust, K);
    %% Find disparity
    %% Laplacian Pre-filter
    lap_filter = [0 1 0; 1 -4 1; 0 1 0];
    im0_filtered = conv2(im0,lap_filter,'same');
    im1_filtered = conv2(im1,lap_filter,'same');
    %% Substrct the mean
    im0_cent = im0 - mean(im0,'all');
    im1_cent = im1 - mean(im1,'all');
    %D = disparity_finder(im0, im1, Corresponds_robust, 1, 0);
    %D = disparity_finder(im0_cent, im1_cent, Corresponds_robust, 1, 0);
    D = disparity_finder(im0_filtered, im1_filtered, Corresponds_robust, 9, 0);
    PSNR = calc_psnr_cv(D, testData.im_gt);
    fprintf('PSNR is %d dB',PSNR);
    %figure;
    %imshow(D./max(D,[],'all'),'colormap',jet);
    
end