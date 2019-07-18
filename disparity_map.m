function [D, R, T] = disparity_map(scene_path, boost)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.

    %% Add extra parameter for boost mode in GUI
    if nargin == 2
        boost_flag = 1;
    else
        boost_flag = 0;
    end
    % End of the boost mode modification
    
    %% Load and parse the testData from given path  
    
    testData = readDataFromDir(scene_path);
    % Parse the max_disparity and determine the down_sample rate
    if boost_flag
        [ds_rate, dmax, is_gray] = determineParams(testData,boost_flag);
    else
        [ds_rate, dmax, is_gray] = determineParams(testData);
    end
    
    %% Disparity Calculation
    
    % Handle RGB and Grayscale image differently
    if is_gray
        im0 = rgb2gray(testData.im0);
        im1 = rgb2gray(testData.im1);
        [D] = disparityGrayImage(im0, im1, ds_rate, dmax);
    else
        [D] = disparityColorImage(testData.im0, testData.im1, ds_rate, dmax);
        D = uint8(refineDMap(testData.im0, D));
    end
    
    %% T,R Calculation
    
    [T,R] = T_R_From_testData(testData);
    % T to meter convert 
    T = T * testData.params.baseline * 0.001;
    
    %% 3D-plot for debug mode:
    plot_3D(testData, D);
        
end
    
    
