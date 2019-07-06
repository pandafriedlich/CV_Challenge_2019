function [T, R, depth] = T_R_Finder(E, Corresponds, K)
%% Find Matrices T and R from Essential matrix E
%   Input             E,             Essential matrix
%   Input             Corresponds,   Matching corner pts found
%   Input             K,             Calib matrix if given
%   Output            T,             Camera movement T
%   Output            R,             Camera rotation R
%   Output            depth,         The depth value of the Corresponds
%% 1. Get T,R candidates from E
    R_pos = [0 -1 0;1 0 0;0 0 1];
    R_neg = [0 1 0; -1 0 0;0 0 1];
    [U,S,V]=svd(E);
    U=U*[1 0 0; 0 1 0; 0 0 det(U)]; 
    V=V*[1 0 0; 0 1 0; 0 0 det(V)];
    R1 = U*R_pos'*V';
    R2 = U*R_neg'*V';
    T1_s = U*R_pos*S*U';
    T2_s = U*R_neg*S*U';
    T1 = [T1_s(3,2);T1_s(1,3);-T1_s(1,2)];
    T2 = [T2_s(3,2);T2_s(1,3);-T2_s(1,2)];
%% 2. Preparation for depth calculation
    N=size(Corresponds,2);
    x1_hom = Corresponds(1:2,:);
    x1_hom(3,:) = 1;
    x2_hom = Corresponds(3:4,:);
    x2_hom(3,:) = 1;
    x1_hom_k = inv(K{1})*x1_hom;
    x2_hom_k = inv(K{2})*x2_hom;
    x1 = x1_hom_k;
    x2 = x2_hom_k;
    T_cell={T1,T2,T1,T2};
    R_cell = {R1,R1,R2,R2};
    d_cell = {zeros([N,2]),zeros([N,2]),zeros([N,2]),zeros([N,2])};
%% 3. Calc depth vaules and finds the combo with most pos. values
    pos_max = 0;
    for i = 1:4
        M1 = cross(x2, R_cell{i}*x1);
        m1 = mat2cell(M1,3,ones([1,size(M1,2)]));
        M1 = blkdiag(m1{:});
        tt= repmat(T_cell{i},1,size(M1,2));
        ttt=cross(x2,tt);
        M1(:,end+1) = ttt(:);
        M2 = cross(x1,R_cell{i}'*x2);
        m2 = mat2cell(M2,3,ones([1,size(M2,2)]));
        M2 = blkdiag(m2{:});
        tt = cross(-x1,repmat(R_cell{i}'*T_cell{i},1,size(M2,2)));
        M2(:,end+1) = tt(:);
        [u1,s1,v1] = svd(M1);
        d1 = v1(:,end);
        [u2,s2,v2] = svd(M2);
        d2 = v2(:,end);
        d1 = d1/d1(end);
        d2 = d2/d2(end);
        d_cell{i} = [d1(1:end-1),d2(1:end-1)];
        pos_nr = nnz(d1(d1>0))+nnz(d2(d2>0));
        if pos_max<pos_nr
            pos_max = pos_nr;
            T = T_cell{i};
            R = R_cell{i};
            lambda = d_cell{i};
        end
    end
    depth = lambda;
end