function p = verify_dmap(D, G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [0,255].
    D = double(D);
    G = double(G);
    mse = sum((D - G).^2, 'all')/numel(G);
    p = 10*1*log10(255^2/mse);

end

