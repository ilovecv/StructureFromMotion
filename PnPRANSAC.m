function [Cnew, Rnew, inds] = PnPRANSAC(X, x, K, I)
%PnPRANSAC
%we assume that X and x are 3D and 2D correspondences one from the
%structure the other from a new image. 

% is the X specific matches to the points in x?
if size(x,2) == 2
    x = [x, ones(size(x,1),1)];
end
if size(X,2) == 3
    X = [X, ones(size(X,1),1)];
end

numpts = length(x);
maxiters = 3000;
eps = 10;
max_inliers= 0;
% figure();
mediane = zeros(maxiters, 1);
for i=1:maxiters
    rinds = ceil(rand(6,1)*numpts);
    [C,R] = LinearPNP(X(rinds, :), x(rinds, :), K);
    P = K*R*[eye(3),-C];
    %calculate reprojection error
    proj = bsxfun(@rdivide, P(1:2, :)*X', P(3,:)*X'); %[2xN] / [1x4]x[4xN]
    error = sqrt(sum((x(:, 1:2) - proj').^2, 2));
    mediane(i) = median(error);
    mask = error < eps;
    
    %fprintf('num inliers %d \n', sum(mask));
    if sum(mask) > max_inliers
        Cnew = C;
        Rnew = R;
        best_mask = mask;
        inds = find(mask);
        max_inliers = sum(mask);
        fprintf('found %d inliers  average error = %f\n', max_inliers, mean(error));
        inliers = x(mask, :); %the points that match with the 3D points
    end
end

[Cnew,Rnew] = LinearPNP(X(best_mask, :), x(best_mask, :), K);
% figure
% plot_projections(I, Rnew, Cnew, K, X(best_mask, :), x(best_mask, :))
end

