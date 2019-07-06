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
    im0 = double(testData.im0);   
    im1 = double(testData.im1);
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
    Corresponds_robust = F_ransac(corresponds)
    % Apply acht-punkt-algo to get E or F
    E = achtpunktalgorithmus(Corresponds_robust, K);
    %% T and R from Essential Matrix
    [T, R, depth] = T_R_Finder(E, corresponds, K);
    D= 0;
end