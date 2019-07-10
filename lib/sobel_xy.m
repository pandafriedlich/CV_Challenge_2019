function [Fx,Fy]=sobel_xy(Image)
% SOBEL_XY performs image derrivatives in x and y direction
%   Merkmale = SOBEL_XY(Image)

% vertical sobel filter
Sx = [1,2,1;0,0,0;-1,-2,-1];
% horizontal sobel filter
Sy = [1,0,-1;2,0,-2;1,0,-1];
 
Image = double(Image);

Fx = conv2(Image,Sx,'same');
Fy = conv2(Image,Sy,'same');

end