function testData = readDataFromDir(test_data_path)
    test_data_path_ch = char(test_data_path);
    if test_data_path_ch(end) ~= '/'
        test_data_path_ch(end+1) = '/';
    end
    test_data_path = string(test_data_path_ch);
    
    fcalib = dir(test_data_path+ "/*.txt");
    fim = dir(test_data_path+'/*.png');
    
    if   (length(fim) ~= 2)
        error("Number of images under the given directory incorrect!");
    end
    if (length(fcalib) ~= 1)
        error("No *.txt file!");
    end
    % read 2 images
    testData.im0 = imread(test_data_path + fim(1).name);
    testData.im1 = imread(test_data_path + fim(2).name);
    
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
    testData.params = params;
end