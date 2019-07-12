function plot_3D(testData, D)
    % This function calculates depth map according to disparity map and
    % plots the scene in 3D with original color.
    
    % Get f from testData
    f = testData.params.cam0(1,1);
    
    % Calculate Z using disparity map, baseline, f and doffs
    Z = (testData.params.baseline * f) ./ (double(D) + testData.params.doffs);
    
    % Calculate image coordinate
    x_pixel = 1:1:testData.params.width;
    y_pixel = 1:1:testData.params.height;
    [X,Y]   = meshgrid(x_pixel,y_pixel);
    X_Pixel = [reshape(X,1,[]);reshape(Y,1,[]);ones(1,testData.params.width*testData.params.height)];
    X_Bild  = testData.params.cam0 \ X_Pixel;
    
    % Reshape Z to get Z-Koordinaten
    Z_reshape = reshape(Z,1,[]);
    
    % Calculate world coordinate
    X_Wert  = X_Bild .* [Z_reshape;Z_reshape;Z_reshape];
    
    % Get color of original image
    Color = double(reshape(testData.im0,[],3))./255;
    
    % 3D plot
    scatter3(X_Wert(1,:),X_Wert(2,:),Z_reshape, 2, Color);
    zoom on;
    campos([0, 0, 0]);
    camup([0,-1, 0]);
end

