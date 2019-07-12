function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.

    %% Load and parse the testData from given path  
    
    testData = readDataFromDir(scene_path);
    % Parse the max_disparity and determine the down_sample rate
    [ds_rate, dmax, is_gray] = determineParams(testData);
    
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
    T = T * testData.param.baseline * 0.001;
        
    %% Bonus -- 3D-Plot
    plot_3D(testData, D);
end
    
    
