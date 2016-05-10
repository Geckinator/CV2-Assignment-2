function point_view(image_dir, threshold, n_epoch)
% point_view calculates the dense blocks of the point view matrix four by
% four frames at a time, computing the final point cloud on the way, by
% doing structure from motion via SVM factorization on the four by four
% dense blocks and then using procrustes to fit them together. The first
% two views in the dense block will already have been used as the last two
% blocks in the previous dense block.

files = dir(strcat(image_dir, '*.png'));
files = {files.name};
main_view = [];

for p = 1:2:length(files)-3

    image1 = single(imread(strcat(image_dir, files{p})));
    image2 = single(imread(strcat(image_dir, files{p + 1})));

    if size(image1, 3) > 1
        image1= rgb2gray(image1);
    end
    if size(image2, 3) > 1
        image2= rgb2gray(image2);
    end
    
    % Extract matching coordinates, save them in what will be the first two
    % entries in of the dense blocks in the point view matrix, x and y.
    [~, coordinates] = compute_fundamental_matrix(image1, image2, threshold, n_epoch);
    x = coordinates([true false true false], :);
    y = coordinates([false true false true], :);


    for i = 2:3
        
        % Continue to next couple of views
        image1= image2;
        image2 = single(imread(strcat(image_dir, files{p + i})));

        if size(image2, 3) > 1
            image2 = rgb2gray(image2);
        end
        
        % Compute fundamental matrix and return the coordinates that pass
        % as inliers
        [~, coordinates] = compute_fundamental_matrix(image1, image2, threshold, n_epoch);

        tmp_x = zeros(1, size(x, 2));
        tmp_y = zeros(1, size(y, 2));
        
        % Loop through the dense blocks, store the ones that re-occur in
        % the newly matched coordinates, store the indices of the ones that
        % don't in the vector removable_cols.
        removable_cols = [];
        for k = 1:size(x, 2)
            for j = 1:size(coordinates, 2)
                if x(size(x, 1), k) == coordinates(1, j) && y(size(y, 1), k) == coordinates(2, j)
                    tmp_x(k) = coordinates(3, j);
                    tmp_y(k) = coordinates(4, j);
                end
            end
            if tmp_x(k) == 0
                removable_cols = vertcat(removable_cols, k);
            end
        end
        
        % Concatenate the re-occurring feature points to the dense block
        % matrix
        x = vertcat(x, tmp_x);
        y = vertcat(y, tmp_y);
        % Remove the columns of the non-re-occurring points
        x(:, removable_cols) = [];
        y(:, removable_cols) = [];
        
    end
    
    % SFM does SVD to compute the coordinates
    pvm_dense = vertcat(x, y);
    pvm_dense = bsxfun(@minus, pvm_dense,  mean(pvm_dense, 2));

    [~,W,V] = svd(pvm_dense);

    structure = W(1:3, 1:3).^0.1*V(:, 1:3)';
    
    % Now we crop the point clouds so that they have an equal number of
    % columns, before fitting them together with procrustes and storing the
    % result in a big point cloud main_view
    if isempty(main_view)
        main_view = structure;
    else
        if size(main_view, 2) < size(structure, 2)
            [d, ~] = procrustes(main_view, structure(:, datasample(1:size(structure, 2), size(main_view, 2))));
            structure = d*structure;
        elseif size(main_view, 2) > size(structure, 2)
            [~, structure] = procrustes(main_view(:, datasample(1:size(main_view, 2), size(structure, 2))), structure);
        else
            [~, structure] = procrustes(main_view, structure);
        end
        main_view = horzcat(main_view, structure);
    end
    
end

% Plot results
 figure(1);
 scatter3(main_view(1,:),main_view(2,:),main_view(3,:), 2);

end