function gt = readGTFromDir(gt_path)
    gt_path = char(gt_path);
    if gt_path(end) ~= '/'
        gt_path(end+1) = '/';
    end
    gt_path = string(gt_path);
    fgroundtruth = dir(gt_path+'/*.pfm');
    
    if (length(fgroundtruth) ~= 1)
        error("The path doesn't contain any pfm file!");
    end
    
    % disparity map groud truth 
    [gt, ~] = ...
        parsePfm(gt_path + fgroundtruth(1).name);
    gt(gt == Inf) = 0;
    gt = uint8((gt/max(max(gt))*255));
end