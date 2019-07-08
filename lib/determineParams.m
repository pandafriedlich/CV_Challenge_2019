function [ds_rate, dmax] = determineParams(testData)
    [h, w, ~] = size(testData.im0);
    for i = 0:8
        if (h/(2*i)) < 300
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