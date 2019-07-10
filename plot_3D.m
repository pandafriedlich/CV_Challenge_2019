function plot_3D(scene_path, D)
% This function calculates depth map according to disparity map and
% plots the scene in 3D with original color.

    % Load and parse the testData from given path
    testData = readDataFromDir(scene_path);
    gt_n = uint8((testData.im_gt/max(max(testData.im_gt))*255));
    
    % Get f from testData
    f = testData.params.cam0(1,1);
    
    % Calculate Z using disparity map, baseline, f and doffs
    Z = (testData.params.baseline * f) ./ (double(D) + testData.params.doffs);
    
    % Calculate Bild Koordinaten from Pixel Koordinaten
    x_pixel = 1:1:testData.params.width;
    y_pixel = 1:1:testData.params.height;
    [X,Y]   = meshgrid(x_pixel,y_pixel);
    X_Pixel = [reshape(X,1,[]);reshape(Y,1,[]);ones(1,testData.params.width*testData.params.height)];
    X_Bild  = testData.params.cam0 \ X_Pixel;
    
    % Reshape Z to get Z-Koordinaten
    Z_reshape = reshape(Z,1,[]);
    
    % Calculate Wert Koordinaten
    X_Wert  = X_Bild .* [Z_reshape;Z_reshape;Z_reshape];
    
    % Get color of original image
    Color = double(reshape(testData.im0,[],3))./255;
    
    % 3D plot
    scatter3(X_Wert(1,:),X_Wert(2,:),Z_reshape, 2, Color);
end

