function PSNR = calc_psnr_cv(D, gt)
%% Calculate the PSNR of disparity map to the groundtruth
    % normalize to 255
    D = D.*(255/max(D,[],'all'));
    gt = gt.*(255/max(gt,[],'all'));
    [x,y,z] = size(D);
    sum = 0;
    %% MSE
    %original = original*256;
    %reconstructed = reconstructed*256;
    for i = 1:(x*y*z)
        sum = (gt(i)-D(i))^2 + sum;
    end
    MSE = sum/(x*y*z);
    %% PSNR
    PSNR = 10*log10((2^8 - 1)^2/MSE);
end