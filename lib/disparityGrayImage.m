function [dmap_re] = disparityGrayImage(im0, im1, ds_rate, dmax)
    [h1, w1] = size(im0);
    im0 = im0(1:ds_rate:end, 1:ds_rate:end);
    im1 = im1(1:ds_rate:end, 1:ds_rate:end);
    
    
    % pre-processing
    I1 = double(im0);
    I2 = double(im1);
    [h, w] = size(I1);
    % image padding
    pad_sz = 100;       
    I1 = array_padd(I1, pad_sz);
    I2 = array_padd(I2, pad_sz);

    % parameters
    block_radius = {5, 7, 60, 70};
    gamma_s = {};
    gamma_c = {};
    delta_s = {};
    for i = 1:length(block_radius)
        block_size{i} = block_radius{i}*2+1;
        gamma_s{i} = block_radius{i}*1;
        gamma_c{i} = block_radius{i}*2;
        ds = zeros(block_size{i}, block_size{i});
        for m=1:block_size{i}
            for n = 1:block_size{i}
                ds(m, n) = sqrt((m-block_radius{i}-1)^2+(n-block_radius{i}-1)^2);
            end
        end
        delta_s{i} = ds;
    end
    % iterate over all pixels
    dmap = zeros(h, w);
    valid_px = (pad_sz+1):1:(pad_sz+w);
    valid_py = (pad_sz+1):1:(pad_sz+h);
    prev_d = 0;
    
    f = waitbar(0,'Progressing(0.00%)');
    for py = valid_py
        for px = valid_px
            
            waitbar((py-pad_sz)/h,f,sprintf("Progressing(%4.2f%%)",(py-pad_sz)/h*100) );
            sz_idx = 1;
            blk_r = block_radius{sz_idx};
            S1 = I1(py-blk_r :py+blk_r, px-blk_r: px+blk_r);
            var_s1 = var(S1(:));
            if var_s1 > 1500
                sz_idx = 1;
            elseif var_s1 > 400
                sz_idx = 2;
            elseif var_s1 > 20
                sz_idx = 3;
            else
                sz_idx = 4;
            end
            
            blk_r = block_radius{sz_idx};
            gs = gamma_s{sz_idx};
            gc = gamma_c{sz_idx};
            ds = delta_s{sz_idx};
            S1 = I1(py-blk_r :py+blk_r, px-blk_r: px+blk_r);
            delta_c1 = abs(S1 - S1(blk_r+1, blk_r+1));
            Ws = exp(-(ds/gs));
            W1 = Ws.*exp(-(delta_c1/gc)) ; 
            min_cost = Inf;
            min_d = 0;
            for d = 0:dmax
               if (px-pad_sz - d < 1) 
                   break;
               end
               S2 = I2(py-blk_r :py+blk_r, px-d-blk_r: px-d+blk_r);
               delta_c2 = abs(S2 - S2(blk_r+1, blk_r+1));
               W2 = Ws .*exp(-(delta_c2/gc)) ;
               C = abs(S1 - S2);
               cost = sum(W1.* W2 .* C, 'all')/sum(W1 .* W2, 'all');
               if cost < min_cost
                   min_cost = cost;
                   min_d = d;
               end
            end
            if min_d > 0.8*dmax
                dmap(py-pad_sz, px-pad_sz) = 0.2*min_d+0.8*prev_d;
            else
                dmap(py-pad_sz, px-pad_sz) = 0.8*min_d+0.2*prev_d;
                prev_d = min_d;
            end
        end
    end
    dmap_n = dmap/max(max(dmap));
    dmap_n(dmap_n < 0) = 0;
    dmap_re = repelem(dmap_n, ds_rate, ds_rate);
    dmap_re = dmap_re(1:h1, 1:w1);
    W = [1:2*ds_rate, 2*ds_rate-1:-1:1];
    W = W*W';
    W = W/sum(W);
    dmap_re = conv2(dmap_re, W, 'same');
    dmap_re = uint8(dmap_re*255);
    delete(f);
end