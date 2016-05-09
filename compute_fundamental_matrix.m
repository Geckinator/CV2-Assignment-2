function [fundamental_matrix, matches, coordinates] = compute_fundamental_matrix(image1, image2, threshold, n_epoch)
% COMPUTE_FUNDAMENTAL_MATRIX returns the fundamental matrix of the two
% images image1 and image2 using the normalized eight-point algorithm with
% RANSAC.

% Detect interest points in each image and characterize the local
% appearance around interst points
[features1, descriptors1] = vl_sift(image1);
[features2, descriptors2] = vl_sift(image2);

% Get a set of supposed matches between region descriptors in each image
[matches, scores] = vl_ubcmatch(descriptors1, descriptors2);

% Estimate the fundamental matrix for the given two images using
% Eight-point Algo:

% Pick out only matched points
coordinates1 = vertcat(features1(1:2, matches(1, :)), ones(1, length(scores)));
coordinates2 = vertcat(features2(1:2, matches(2, :)), ones(1, length(scores)));
coordinates = vertcat(coordinates1(1:2, tmp_matches), coordinates2(1:2, tmp_matches));

% Find normalization matrix T and apply to the coordinates
d = sum(scores);
m1_x = 1/length(scores)*sum(coordinates1(1, :));
m1_y = 1/length(scores)*sum(coordinates1(2, :));
m2_x = 1/length(scores)*sum(coordinates2(1, :));
m2_y = 1/length(scores)*sum(coordinates2(2, :));
T1 = [sqrt(2)/d 0 -m1_x*sqrt(2)/d; 0 sqrt(2)/d -m1_y*sqrt(2)/d; 0 0 1];
T2 = [sqrt(2)/d 0 -m2_x*sqrt(2)/d; 0 sqrt(2)/d -m2_y*sqrt(2)/d; 0 0 1];
coordinates1 = T1*coordinates1;
coordinates2 = T2*coordinates2;

it = 0;
inliers = 0;
A = ones(8, 9);
while it < n_epoch
    % Pick random selection of 8 points
    random_indices = randi(length(scores), 8, 1);
    points1 = coordinates1(:, random_indices);
    points2 = coordinates2(:, random_indices);
    A(:, 1) = points1(1, :).*points2(1, :);
    A(:, 2) = points1(1, :).*points2(2, :);
    A(:, 3) = points1(1, :);
    A(:, 4) = points1(2, :).*points2(1, :);
    A(:, 5) = points1(2, :).*points2(2, :);
    A(:, 6) = points1(2, :);
    A(:, 7) = points2(1, :);
    A(:, 8) = points2(2, :);
    [~,~,V] = svd(A);
    F = [V(1:3, 9), V(4:6, 9), V(7:9, 9)];
    % Force F to have rank 2 and denormalize
    [U, S, V] = svd(F);
    S(3, 3) = 0;
    F = T2'*U*S*V'*T1;

    Fp1 = F*coordinates1;
    Fp2 = F'*coordinates2;
    d_sampson = sum(reshape(bsxfun(@times, coordinates2(:), Fp1(:)), size(coordinates1, 2), 3), 2)'.^2./(Fp1(1, :).^2 + Fp1(2, :).^2 + Fp2(1, :).^2 + Fp2(2, :).^2);
    tmp_inliers = sum(d_sampson < threshold);
    if tmp_inliers > inliers
        tmp_matches = find(d_sampson < threshold);
        inliers = tmp_inliers;
        fundamental_matrix = F;
    end

    it = it + 1;
end
fprintf('Number of inliers: %i\n', inliers);

if inliers < 200
    [fundamental_matrix, matches, coordinates] = compute_fundamental_matrix(image1, image2, threshold*10, n_epoch);
elseif inliers > 300
    [fundamental_matrix, matches, coordinates] = compute_fundamental_matrix(image1, image2, threshold/10, n_epoch);
end

end