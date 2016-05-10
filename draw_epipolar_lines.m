function draw_epipolar_lines(image1, image2, threshold, n_epoch)

[F, coordinates] = compute_fundamental_matrix(single(imread(image1)), single(imread(image2)), threshold, n_epoch);

I2 = imread(image2);
imshow(I2);
title('Epipolar lines'); hold on;
indices = datasample(1:size(coordinates, 2), 30);
for k = 1:length(indices)
    line = F'*[coordinates(1:2, indices(k)); 1];
    plot(coordinates(3, indices(k)), coordinates(4, indices(k)), 'o');
    plot(linspace(1, 1000, 1000), -1/line(2)*(line(1)*linspace(1,1000, 1000) + repmat(line(3), 1, 1000)));
end

end