function corresponds = Correspondings_Finder(I1, I2, Mpt1, Mpt2, varargin)
%%  Correspodings_Finder  
%   Input             I1,            Image1
%   Input             I2,            Image2
%   Input             Mpt1,          2xn,Corners found in Image1
%   Input             Mpt2,          2xn,Corners found in Image2
%   Input (optional)  Method,        1: NCC, 2: To be implemented...
%   Input (optional)  window_length, Window size for comparing the corners
%   Input (optional)  min_corr,      Min. correlation to be matching pts
%   Input (optional)  do_plot,       plot the found corners
%   Output            correspnds     4xn Matrix, Matching points as pairs
    %% Input parser
    p = inputParser;
    addRequired(p,'Mpt1');
    addRequired(p,'Mpt2');
    addRequired(p,'I1');
    addRequired(p,'I2');
    addParameter(p,'Method',1);
    validwin = @(x) isnumeric(x)&&x>1&&mod(x,2)==1;
    addParameter(p,'window_length',25,validwin);
    validmc = @(x) isnumeric(x)&&x<1&&x>0;
    addParameter(p,'min_corr',0.95,validmc);
    validd = @(x) islogical(x);
    addParameter(p,'do_plot',false,validd);
    parse(p,I1,I2,Mpt1,Mpt2,varargin{:});
    % Variables
%     I1            = double(p.Results.I1);
%     I2            = double(p.Results.I2);
%     Mpt1          = p.Results.Mpt1;
%     Mpt2          = p.Results.Mpt2;
    window_length = p.Results.window_length;
    min_corr      = p.Results.min_corr;
    do_plot       = p.Results.do_plot;
    Method        = p.Results.Method;
    %% Delete the corner points on the edge
    edge_size = ceil(window_length/2);
    [~,len_Mpt1] = size(Mpt1);
    [~,len_Mpt2] = size(Mpt2);
    [I1_height,I1_width] = size(I1);
    [I2_height,I2_width] = size(I2);
    for i = 1:len_Mpt1
        if Mpt1(1,i)<edge_size || Mpt1(1,i)>I1_width-edge_size ||...
                Mpt1(2,i)<edge_size || Mpt1(2,i)>I1_height-edge_size 
            Mpt1(:,i)=[0;0];
        end
    end
    Mpt1=Mpt1(:,any(Mpt1)); % Delete '0' elements
    for i = 1:len_Mpt2
        if Mpt2(1,i)<edge_size || Mpt2(1,i)>I2_width-edge_size ||...
                Mpt2(2,i)<edge_size || Mpt2(2,i)>I2_height-edge_size 
            Mpt2(:,i)=[0;0];
        end
    end
    Mpt2=Mpt2(:,any(Mpt2)); % Delete '0' elements
    %% Create window around the Corner pts
    edge_size = floor(window_length/2);
    [~,len_Mpt1] = size(Mpt1);
    [~,len_Mpt2] = size(Mpt2);
    Mat_feat_1 = [];
    Mat_feat_2 = [];
    for i = 1:len_Mpt1
        block = I1(Mpt1(2,i)-edge_size:Mpt1(2,i)+edge_size,Mpt1(1,i)-edge_size:Mpt1(1,i)+edge_size);
        block_bar = mean(block,'all'); %Version R2019
        block_var = sqrt(var(block,0,'all'));
        block = (block-block_bar)/block_var;
        Mat_feat_1 = [Mat_feat_1,block(:)];
    end
    for i = 1:len_Mpt2
        block = I2(Mpt2(2,i)-edge_size:Mpt2(2,i)+edge_size,Mpt2(1,i)-edge_size:Mpt2(1,i)+edge_size);
        block_bar = mean(block,'all'); %Version R2019
        block_var = sqrt(var(block,0,'all'));
        block = (block-block_bar)/block_var;
        Mat_feat_2 = [Mat_feat_2,block(:)];
    end
    %% NCC to compare if Method == 1
    if Method == 1
        N = window_length^2;
        NCC_matrix = zeros(size(Mpt2,1),size(Mpt1,1));
        for i = 1:size(Mpt1,2)
            for j = 1:size(Mpt2,2)
                ww = reshape(Mat_feat_2(:,j),[window_length,window_length]);
                v = reshape(Mat_feat_1(:,i),[window_length,window_length]);
                col = trace(ww'*v)/(N-1);
                NCC_matrix(j,i) = col;
            end
        end
        NCC_matrix(NCC_matrix<min_corr) = 0;
        [b, I] = sort(NCC_matrix(:), 'descend');
        n = nnz(NCC_matrix(:));
        sorted_index = I(1:n);
    else
        error('Other comparing methods not implemented yet');
    end
    %% Get matching points
    corresponds = [];
    for i = 1:length(sorted_index)
        [nx, ny]=ind2sub(size(NCC_matrix), sorted_index(i));
        if NCC_matrix(nx,ny)>0
            k = [Mpt1(:,ny);Mpt2(:,nx)];
            corresponds=[corresponds,k];
            NCC_matrix(:,ny)=0;
        end
    end
    %% Double-check, delete the Matching pts with dY>3;
    for i = 1:size(corresponds,2)
        dy = abs(corresponds(2,i)-corresponds(4,i));
        if dy > 3
            corresponds(:,i) = [0;0;0;0];
        end
    end
    corresponds=corresponds(:,any(corresponds));
    %% Do_plot
    if do_plot
        marker_size=10;
        figure;
        imshow(uint8(I1));
        hold on;
        imshow(uint8(I2));
        alpha(0.5);
        hold on;
        for i=1:size(corresponds,2)
            plot(corresponds(1,i),corresponds(2,i),'Color','blue','Marker','o',...
                'MarkerSize',marker_size);
            hold on;
            plot(corresponds(3,i),corresponds(4,i),'Color','red','Marker','o',...
                'MarkerSize',marker_size);
            hold on;
            line(corresponds([1,3],i),corresponds([2,4],i),'Color','green');
            hold on;
        end
    end
end