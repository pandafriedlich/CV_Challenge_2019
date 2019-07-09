function D = disparity_finder(im0, im1, corresponds, window_radius, do_plot)
%% Find the disparity of each pixel
%   Input             im0            Image 0 
%   Input             im1            Image 1 
%   Input             corresponds    Matching corner pts
%   Input             window_radius  Window size for the match pts search
%   Output            D              Disparity map
%%  Using corrsponds to find the max. and min. of disparity
    diff_x = corresponds(1,:) - corresponds(3,:);
    disp_max = max(diff_x);

% disp_min default as 0
    
%     disp_min = min(diff_x);
%     if disp_min <= 0
%         disp_min = 1+ window_radius;
%     end
%% Seachch for matching pixel pair
% boarder treat as same disparity as ...
% crop the boarder out during the pixel-matching
    wb = waitbar(0,'Calculating disparity map...');
    for i = (1+window_radius):(size(im0,1)-window_radius)
%        for j = (1+window_radius):(size(im0,2)-window_radius) 
%             % window size should be window_radius*2+1
%             window_size = window_radius * 2 + 1;
%             % Block in im0
%             blk = im0(i-window_radius:i+window_radius, j-window_radius:j+window_radius);
%             % The long block to be searched in im1
%             if j > disp_max + window_radius    
%                 search_blk = im1(i-window_radius:i+window_radius, j-disp_max-window_radius: ...
%                     j+window_radius);
%             else
%                 search_blk = im1(i-window_radius:i+window_radius, 1:j+window_radius);
%             end
%             %% Using sum of absolute distance
%             % Initialise the sad value vector
%             
%             sad = [];
%             for candidates = 1:size(search_blk,2)-2*window_radius
%                blk1 = search_blk(:, candidates:candidates+2*window_radius);
%                sad(candidates) = calcSad(blk1, blk);
%             end
% %             for match_search_i = 1+window_radius:size(search_blk,2)-window_radius
% %                blk1 = search_blk(:,match_search_i-window_radius:match_search_i+window_radius);
% %                sad(match_search_i - window_radius) = calcsad(blk1, blk); 
% %             end
%             % Find the min sad
%             [value, index] = min(sad);
%             disp(i,j) = size(search_blk,2) - 2*window_radius-index;
%             %% Plot each matching points found
%             if do_plot
%                 [logical,loc] = ismember([i;j]',corresponds(1:2,:)','rows');
%                 if logical
%                     figure;
%                     subplot(1,2,1);
%                     imshow(uint8(im0));
%                     hold on;
%                     %plot(10,450,'o');
%                     hold on;
%                     plot(j,i,'x');
%                     subplot(1,2,2);
%                     imshow(uint8(im1));
%                     hold on;
%                     plot(j-disp(i,j),i,'x');
%                     hold on;
%                     plot(corresponds(4,loc), corresponds(3,loc),'o');
%                     hold on;
%                     %close;
%                     sad_see = sad;
%                 end
%             end
%         end
        %clc;
        %fprintf('Line %d', i );
        waitbar(i/size(im0,1));
    end
    delete(wb);
%     D = disp((1+window_radius):(size(im0,1)-window_radius), ...
%         (1+window_radius):(size(im0,2)-window_radius));
%     D = padarray(D,[window_radius, window_radius],'replicate','both');
    %% Post filter
%     box_filter = ones([8 8])/64;
%     D = round(conv2(D,box_filter,'same'));
D=0;
end

function sad_scaler = calcSad(blk1, blk0)
%% calculate the sad of 2 blocks
    diff = blk0 - blk1;
    sad_scaler = sum(sum(abs(diff)));
end