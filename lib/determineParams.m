function [ds_rate, dmax, is_gray] = determineParams(testData, boost)
    % Add extra parameter for boost mode in GUI
    if nargin == 2
        boost_flag = 1;
    else
        boost_flag = 0;
    end
    % End of the boost mode modification
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
        if boost_flag
            width_ds = 160;
        else
            width_ds = 400;
        end
    else 
        if boost_flag
            width_ds = 200;
        else
            width_ds = 800;
        end
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