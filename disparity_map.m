function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.
    
    testData = readDataFromDir(scene_path);
    [ds_rate, dmax, is_gray] = determineParams(testData);
    if is_gray
        testData.im0 = rgb2gray(testData.im0);
        testData.im1 = rgb2gray(testData.im1);
        [D] = disparityGrayImage(testData.im0, testData.im1, ds_rate, dmax);
    else
        [D] = disparityColorImage(testData.im0, testData.im1, ds_rate, dmax);
        D = uint8(refineDMap(testData.im0, D));
    end
    R = eye(3);
    T = -[1, 0, 0];
    
end