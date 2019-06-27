function testData = readDataFromDir(test_data_path)
    test_data_path_ch = char(test_data_path);
    if test_data_path_ch(end) ~= '/'
        test_data_path_ch(end+1) = '/';
    end
    test_data_path = string(test_data_path_ch);
    
    fcalib = dir(test_data_path+ "/*.txt");
    fgroundtruth = dir(test_data_path+'/*.pfm');
    fim = dir(test_data_path+'/*.png');
    
    if (length(fcalib) ~= 1) || (length(fgroundtruth) ~= 1) || (length(fim) ~= 2)
        error("The path seems to be invalid!");
    end
    % read 2 images
    testData.im0 = imread(test_data_path + fim(1).name);
    testData.im1 = imread(test_data_path + fim(2).name);
    
    % disparity map groud truth 
    [testData.im_gt, testData.gt_scale] = ...
        parsePfm(test_data_path + fgroundtruth(1).name);
    testData.im_gt(testData.im_gt == Inf) = 0;
    % parsing parameters
    fcalib_fid = fopen(test_data_path + fcalib(1).name,'r');
    if fcalib_fid < 0
        error("Unable to open calib file!");
    end
    while true
        s = fgetl(fcalib_fid);
        if s == -1
            fclose(fcalib_fid);
            break;
        end
        eval(string(s) + ";");            
    end
    params.cam0 = cam0;
    params.cam1 = cam1;
    params.doffs = doffs;
    params.baseline = baseline;
    params.width = width;
    params.height = height;
    params.ndisp = ndisp;
%     params.isint = isint;
%     params.vmin = vmin;
%     params.vmax = vmax;
%     params.dyavg= dyavg;
%     params.dymax = dymax;
    
    testData.params = params;
end