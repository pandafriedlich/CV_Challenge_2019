function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.
    %% Load input image pair
    %  It's okay if u have '/' at the end of scene_path ;)
    im0 = double(imread(strcat(scene_path,'/im0.png')));
    im1 = double(imread(strcat(scene_path,'/im1.png')));
    %% Find Corners
    Corner_im0 = Corner_Finder(im0,'do_plot',true);
    Corner_im1 = Corner_Finder(im1);
    %% Find Matching points
    % Corner matrix must be transposed
    corresponds = Correspondings_Finder(im0, im1, Corner_im0', Corner_im1', ...
        'min_corr',0.96, 'do_plot', true); % 0.96 should be a good min_corr value
    
end