clear;close all;
clc;
addpath("./lib");
%%
testData = readDataFromDir('./data/sword');
[ds_rate, dmax] = determineParams(testData);
[dmap] = disparityColorImage(testData.im0, testData.im1, ds_rate, dmax);
%%
figure;
imshow(dmap);colormap jet;
gt_n = uint8((testData.im_gt/max(max(testData.im_gt))*255));
p = verify_dmap(dmap, gt_n);
fprintf("PSNR : %.4f [dB] \n", p);

