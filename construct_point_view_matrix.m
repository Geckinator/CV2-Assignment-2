function [point_view_matrix] = construct_point_view_matrix(image_dir, threshold, n_epoch)

files = dir(image_dir);
files = {files.name};

[~, point_view_matrix, coordinates] = compute_fundamental_matrix(single(imread(files(1))), single(imread(files(2))), threshold, n_epoch);

for i = 3:length(files)

    [~, matches, tmp_coordinates] = compute_fundamental_matrix(single(imread(files(i-1))), single(imread(files(i))), threshold, n_epoch);
    coordinates = {coordinates, tmp_coordinates};
    new_matches = matches(2, ~ismember(matches(1, :), point_view_matrix(size(point_view_matrix, 1), :)));
    old_matches = matches(2, ismember(matches(1, :), point_view_matrix(size(point_view_matrix, 1), :)));
    
    point_view_matrix = horzcat(point_view_matrix, zeros(1, length(new_matches)));
    point_view_matrix = vertcat(point_view_matrix, matches);
    
end