function [ds_rate, dmax, is_gray] = determineParams(testData)
    
    [h, w, d] = size(testData.im0);
    if d == 1
        is_gray = true;
    else
        channel_sad = mean(abs(testData.im0(:, :, 1) -  testData.im0(:, :, 2)),'all');
        if channel_sad > 5
            is_gray = false;
        else
            is_gray = true;
        end
    end
    if is_gray
        width_ds = 400;
    else
        width_ds = 800;
    end
    for i = 0:8
        if (h/(2*i)) < width_ds
            break;
        end
    end
    ds_rate = 2*i;
    dmax = testData.params.ndisp;
    if dmax > w/2
        dmax = floor(w/20);
    end
    dmax = floor(dmax/ds_rate);
end