function E = achtpunktalgorithmus(Correspondings, K)
%%  Find the Essential Matrix 
%   Input             Correspondings, the matching corner points found earlier 
%   Input (optional)  K,              Calibration matrix
%   Output            E/F,            Essential/Fundamental Matrix
    % Convert to homogene coordinate
    x1 = Correspondings(1:2,:);
    x2 = Correspondings(3:4,:);
    x1(3,:) = 1;
    x2(3,:) = 1;
    % Check if K given
    if exist('K','var')
        x1 = K{1}\x1;
        x2 = K{2}\x2;
    end
    % Kronecker operator 
    for i = 1:size(x1,2)
        a = kron(x1(:,i), x2(:,i));
        A(i,:) = a';
    end
    % SVD Zerlegung
    [U,S,V] = svd(A);
    G = V(:,9);
    G = reshape(G,[3 3]);
    [Ug,Sg,Vg] = svd(G);
    E = Ug*diag([1,1,0])*Vg';
    if exist('K','var')
        EF = E;
    else
        EF=Ug*[Sg(1,1),0,0;
            0,Sg(2,2),0;
            0,0,0]*Vg';
    end

end