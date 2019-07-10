function corners = Corner_Finder(Image, varargin)
%%  Corner_Finder  
%   Input             image 
%   Input (optional)  window_length, Window_size to apply Harris detection
%   Input (optional)  k,             Parameter for efficient Harris implementation
%   Input (optional)  tau,           Threshold value for corner-decision
%   Input (optional)  block_size,    block size to identify max.N corners
%   Input (optional)  N,             max.N corners in one block
%   Input (optional)  min_dist,      min. distance between found corners
%   Input (optional)  do_plot,       plot the found corners
%   Input (optional)  edge_width,    The width to cut for board-effect
%   Output            corners        nx2 Matrix, corners' coordinates found

%% Convert Image to Grayscale if given RGB
Image = rgb_to_gray(Image);
%% Input Parameters
p = inputParser;

p.addRequired('Image', @(x) size(x,3) == 1 && isnumeric(x));
p.addOptional('window_length', 5, @(x) isscalar(x) && isnumeric(x));
p.addOptional('k', 0.05, @(x) isnumeric(x));
p.addOptional('tau', 200000, @(x) isnumeric(x));
p.addOptional('block_size', floor(size(Image)/10), @(x) isnumeric(x));
p.addOptional('N', 10, @(x) isnumeric(x) && x>0 );
p.addOptional('min_dist', 10, @(x) isnumeric(x));
p.addOptional('edge_width', 3, @(x) isnumeric(x));
p.addOptional('do_plot', false, @islogical);
p.parse(Image, varargin{:});

Image           = p.Results.Image;
window_length   = p.Results.window_length;
k               = p.Results.k;
tau             = p.Results.tau;
block_size      = p.Results.block_size;
N               = p.Results.N;
min_dist        = p.Results.min_dist;
edge_width      = p.Results.edge_width;
do_plot         = p.Results.do_plot;
%% Pasing Parameter block_size
if(length(block_size)==2)
        BlockWidth = block_size(2);
        BlockHeight = block_size(1);
    else
        BlockWidth = block_size;
        BlockHeight = block_size;
end 
%% Implement Harris detector
Image = double(Image);

% Image gradient using sobel filter
[I_x,I_y] = sobel_xy(Image);

%% Components of H Matrix
i11 = I_x.*I_x;
i12 = I_x.*I_y;
i22 = I_y.*I_y;

% Apply weights 
sigma = sqrt(1./(2*log(2)));
W = gaussianWindow(window_length,sigma);
g11 = conv2(i11,W,'same');
g12 = conv2(i12,W,'same');
g22 = conv2(i22,W,'same');
H = g11.*g22 - g12.^2 - k * (g11+g22).^2;

% Erase Image edges
H(:,1:edge_width) = 0;
H(:,end-edge_width+1:end) = 0;
H(1:edge_width,:) = 0;
H(end-edge_width+1:end,:) = 0;

% Blockwise processing of Image
H = blockProcessor(H,tau,BlockWidth,BlockHeight,N,min_dist);

%% Output
[row,col] = find(H);
corners = [col,row];

%% do_plot
if do_plot
    figure;
    imshow(uint8(Image))
    hold on
    plot(corners(:,1), corners(:,2), 'r*');
end
end

%% Block Processing
function H_out = blockProcessor(H,tau,BlockWidth,BlockHeight,N,min_dist)


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