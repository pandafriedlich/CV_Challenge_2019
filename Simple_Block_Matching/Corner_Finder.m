function corners = Corner_Finder(Image, varargin)
%%  Corner_Finder  Detects corner features in GrayScale Images.
%   corners = Corner_Finder(Image) detects corner features in Image.
%
%   corners = Corner_Finder(Image,'do_plot',true) displays detected features
%   in Image.
%
%   corners = Corner_Finder(Image,...,'wimdow_length',value) allows to 
%   specify the search-window length.
%
%   corners = Corner_Finder(Image,...,'k',value) allows to specify the 
%   edge-corner weighing factor.
%
%   corners = Corner_Finder(Image,...,'tile_size',value) allows to select 
%   the window size for blockprocessing the Image.
%   tile_size can either be a scalar for rectangular blocks or a
%   vector of length two, where the first element specifies the block width
%   and the second element specifies the block height. If not specified,
%   the tile_size is selected automatically such that there are 100 blocks
%   and a minimum amount of border spacing.
%
%   corners = Corner_Finder(Image,...,'N',value) allows to set the maximum 
%   amount of corners detected per block.
%
%   corners = Corner_Finder(Image,...,'min_dist',value)
%   same as above and allows you to specify the minimum distance between
%   two detected corners.

%% Convert Image to Grayscale if given RGB
Image = rgb_to_gray(Image);
%% Input Parameters
p = inputParser;

p.addRequired('Image', @(x) size(x,3) == 1 && isnumeric(x));
p.addOptional('do_plot', false, @islogical);
p.addOptional('window_length', 5, @(x) isscalar(x) && isnumeric(x));
p.addOptional('k', 0.05, @(x) isscalar(x) && isnumeric(x));
p.addOptional('tau', 200000, @(x) isscalar(x) && isnumeric(x));
p.addOptional('tile_size', floor(size(Image)/10), @(x) isnumeric(x) ...
    && (isscalar(x) || all(size(x) == [1,2]) || all(size(x) == [2,1])));
p.addOptional('N', 10, @(x) isscalar(x) && isnumeric(x) && x>0 );
p.addOptional('min_dist', 10, @(x) isscalar(x) && isnumeric(x));

p.parse(Image, varargin{:});

Image           = p.Results.Image;
do_plot         = p.Results.do_plot;
window_length   = p.Results.window_length;
k               = p.Results.k;
tau             = p.Results.tau;
tile_size       = p.Results.tile_size;
N               = p.Results.N;
min_dist        = p.Results.min_dist;

if(length(tile_size)==2)
        BlockWidth = tile_size(2);
        BlockHeight = tile_size(1);
    else
        BlockWidth = tile_size;
        BlockHeight = tile_size;
end

% check if N, window_length and tile_size are integers, if not=>round
if (N-floor(N))>0
    N=round(N);
    warning(['only integer-values allowed for N, ' num2str(N) ' was used instead']);
end

if (window_length-floor(window_length))>0
    window_length=round(window_length);
    warning(['only integer-values allowed for window_length,'...
        num2str(window_length) ' was used instead']);
end

if (BlockWidth-floor(BlockWidth))>0 || (BlockHeight-floor(BlockHeight))>0
    BlockHeight=round(BlockHeight);
    BlockWidth=round(BlockWidth);
    warning(['only integer-values allowed for tile_size, [' ...
        num2str(BlockHeight) ' ' num2str(BlockWidth) '] was used instead']);
end
 
%% Image Processing
% As proposed in Slide27 of
% 'http://www.cse.psu.edu/~rcollins/CSE486/lecture06.pdf'
Image = double(Image);

% 1. Compute x and y derivatives of Image.
[I_x,I_y] = sobel_xy(Image);

% 2. Compute products of derivatives at every pixel
i11 = I_x.*I_x;
i12 = I_x.*I_y;
i22 =I_y.*I_y;

% 3. Compute the sums of the product derivatives at each pixel
sigma = sqrt(1./(2*log(2)));
W = gaussianWindow(window_length,sigma);
g11 = conv2(i11,W,'same');
g12 = conv2(i12,W,'same');
g22 = conv2(i22,W,'same');

% 4. Compute the response of the detector at each pixel
% Note that tr[a,b;c,d] = a+d if b=c

H = g11.*g22 - g12.^2 - k * (g11+g22).^2;

% Erase Image edges
H(:,1:3) = 0;
H(:,end-2:end) = 0;
H(1:3,:) = 0;
H(end-2:end,:) = 0;

% Small global threshold
%H(H <= 500000)=0;

% Blockwise processing of Image
H = blockProcessor(H,tau,BlockWidth,BlockHeight,N,min_dist);

%% Data Output
[row,col] = find(H);
corners = [col,row];

%% Data Display
if do_plot
    figure;
    imshow(uint8(Image))
    hold on
    plot(corners(:,1), corners(:,2), 'r*');
end
end

%% Block Processing
function H_out = blockProcessor(H,tau,BlockWidth,BlockHeight,N,min_dist)
% Assert if defined maximum number of corners per block
if(N > BlockWidth*BlockHeight)
    error('Cant detect more corners than pixels per block')
end

% Calculate required number of block iterations
nr_windows_horz=floor(size(H,2)/BlockWidth);
nr_windows_vert=floor(size(H,1)/BlockHeight);

% Calculate start pixels for iteration such that the processed part of the
% Image is in the center of the Image. (Only nescessarry if block width 
% and block height are not integer multiples of Image width and height)
start_y = round((size(H,1)-nr_windows_vert*BlockHeight)/2)+1;
start_x = round((size(H,2)-nr_windows_horz*BlockWidth)/2)+1;

% Pixels not affected by block processing (if block width/height not
% integer multiple of Image width/height)
H(:,1:start_x-1) = 0;
H(:,end-start_x-2:end) = 0;
H(1:start_y-1,:) = 0;
H(end-start_y--2:end,:) = 0;

% Warn if block width/height not integer multiple of Image width/height
if(start_x~=1)
    warning('tile_size.Width should be an integer multiple of the Image width')
end
if(start_y~=1)
    warning('tile_size.Height should be an integer multiple of the Image height')
end
% Row Iterator
for y = start_y:BlockHeight:nr_windows_vert*BlockHeight
    % Column iteratior
    for x = start_x:BlockWidth:nr_windows_horz*BlockWidth
        % Define current pixel block
        H_Block = H(y:y+BlockHeight-1,x:x+BlockWidth-1);
        % Threshold current pixel block
        H_Block(H_Block<=tau) = 0;
        % Sort maxima descending
        [~,sortIndex] = sort(H_Block(:),'descend');
        % Take into account N maxima
        maxIndex = sortIndex(1:N);
        % Pixel position of N maxima
        [I,J] = ind2sub(size(H_Block),maxIndex);
        points=[I,J];
        % Iterate through N maxima and check pixel distance
        for i = 1:size(maxIndex,1)
            % Do not process pixel if already detected as invalid
            if (maxIndex(i) == -1)
                continue
            end
            % Calculate Euklidean distance between current pixel and all
            % other pixels
            pointMatrix = repmat(points(i,:),size(points(i+1:end,:),1),1);
            pointsDifSquare = (sum(((pointMatrix-points(i+1:end,:)).^2), 2)).^0.5;
            % Check if one of the other pixels is too close to current
            % pixel
            delta = min_dist-pointsDifSquare;
            % Neglect all pixels that violate the distance constraint
            delta(delta<0) = 0;
            ind = find(delta)+i;
            % Remove all pixels that are too close to higher valued pixels
            maxIndex(ind) = -1;
        end
        % Calculate resulting pixel block
        maxIndex(maxIndex==-1)=[];       
        H_Block_Copy = zeros(size(H_Block));
        H_Block_Copy(maxIndex) = H_Block(maxIndex);       
        % Update H matrix with processed pixel block
        H(y:y+BlockHeight-1,x:x+BlockWidth-1) = H_Block_Copy;
    end
end
H_out = H;

end

%% Gaussian Window
function W = gaussianWindow(window_length,sigma)
[x,y]=meshgrid(round(-window_length/2):round(window_length/2), ...
    round(-window_length/2):round(window_length/2));
W=exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
W=W./sum(W(:));
end