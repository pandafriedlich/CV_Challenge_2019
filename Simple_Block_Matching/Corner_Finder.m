function corners = Corner_Finder(image, varargin)
% Input:  Image (double)
% Input:  Future parameters
% Output: Corners found using Harris detector
    %% Input Parser
    p = inputParser;
    %  Default values
    %  Loading optional arguments
    %  See Homework 1.3 for details
    parse(p,varargin{:});
    %% First convert RGB to grayscle if given RGB image
    if size(image,3) == 3
        img = rgb2gray(image_rgb);
    else
        img = image;
    end
    %% Get the Harrix Matrix
end