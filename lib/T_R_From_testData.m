function [T,R] = T_R_From_testData(testData)
%% Calculate the Matrix T and R, given parsed testData
%   Input       testData:      Parsed test data including Images, Calib-Matrices
%   Output      T       :      Translation Matrix, 3x1
%   Output      R       :      Rotation Matrix,    3x3

%% Set input variables

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
    Corresponds_robust = F_ransac(im0, im1, corresponds, 'k', 19, 'do_plot', false);
    % Apply acht-punkt-algo to get E or F
    E = achtpunktalgorithmus(Corresponds_robust, K);
    
%% T and R from Essential Matrix

    [T, R, ~] = T_R_From_E(E, Corresponds_robust, K);
end