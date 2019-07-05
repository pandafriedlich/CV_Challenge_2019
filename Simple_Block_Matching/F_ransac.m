function Correspondings_robust = F_ransac(Correspondings, varargin)
%%  Pick out the robust corresponding points using ransac algorithm  
%   Input             Correspondings, the matching corner points found earlier  
%   Input (optional)  epsilon,       outlier probability
%   Input (optional)  p,             Inlier probability?
%   Input (optional)  tolerance,     threshold
%   Input (optional)  do_plot,       Plot the found robust matching points
%   Output             Correspondings_robust        robust corres pts found 
        p = inputParser;
        addRequired(p,'Correspondings');
        valideps = @(x) isnumeric(x)&&x<1&&x>0;;
        addParameter(p,'epsilon',0.5,valideps);
        addParameter(p,'p',0.5,valideps);
        validtol = @(x) isnumeric(x);
        addParameter(p,'tolerance',0.01,validtol);
        addParameter(p,'do_plot',0);
        parse(p,Correspondings,varargin{:});
        % Convert to homogene coordinates
        x1_pixel = Correspondings(1:2,:);
        x1_pixel(3,:) = 1;
        x2_pixel = Correspondings(3:4,:);
        x2_pixel(3,:) = 1; 
        % Prepare variables for the ransac algorithm
        k = 8;
        s = log(1-p)/(log(1-(1-epsilon)^k));
        largest_set_size = 0;
        largest_set_dist = Inf;
        largest_set_F = zeros([3,3]);    
        b = size(Correspondings,2);
        for i = 1:s
            rd_index = randi([1,b],8,1);
            current_set = Correspondings(:,rd_index);
            % get Matrix F
            F = achtpunktalgorithmus(current_set);
            % get Correspondings without in set selected pairs
            k_paar1 = x1_pixel;
            k_paar1(:,rd_index) = [];
            k_paar2 = x2_pixel;
            k_paar2(:,rd_index) = [];        
            % Calc the sampson distance
            sd = sampson_dist(F, k_paar1, k_paar2);
            % update zustand-variable
            Consensus_set_dist = sd.*(sd<tolerance);
            current_set_dist = sum(Consensus_set_dist);
            current_set_size = nnz(Consensus_set_dist);
            if current_set_size > largest_set_size
                largest_set_size = current_set_size;
                largest_set_F = F;
                Correspondings_robust = current_set;
            elseif current_set_size == largest_set_size
                if current_set_dist < largest_set_dist
                    largest_set_dist = current_set_dist;
                    largest_set_F = F;
                    Correspondings_robust = current_set;
                end
            end
        end 
        %% Do_plot
        % No image as input, plot will be implementet in father function
end

function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e3=[0 -1 0;1 0 0;0 0 0];
    diag(x2_pixel'*F*x1_pixel).^2
    sum(((e3*F*x1_pixel).^2),1)
    sum(((x2_pixel'*F*e3).^2),2)
    sd = diag(x2_pixel'*F*x1_pixel).^2./(sum(((e3*F*x1_pixel).^2),1)'+sum(((x2_pixel'*F*e3).^2),2));  
    sd = sd';
end