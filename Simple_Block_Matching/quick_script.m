% script for testing during WIP
path_motor = '/Users/guanfuqi/CODE/CV_CHALLANGE/Materials/motorcycle';
Data = readDataFromDir(path_motor);
[D, R, T] = disparity_map(path_motor);
