function [structure] = SFM(povMat)


% if not(testing)
%     povMatrix = construct_point_view_matrix(foldername, threshold, testing);
%     for i = 1 : 1 : size(povMatrix, 1)
%         
%         row  = povMatrix(i, :);
%         row_mean = sum(row) / length(row);
%         centered_row = row - row_mean;
%         for z = 1 :1 : length(row)
%             povMatrix(i,z)= centered_row(z);
%         end
%         
%     end
% end
% povMatrix_testing =  importdata('PointViewMatrix.txt');

bsxfun(@minus, povMat,  mean(povMat, 2));

[U,W,V] = svd(povMat) ;

u = U(:, 1:3);
w= W(1:3, 1:3);
v= V(:, 1:3) ;

motion= U*W;
structure= W.^40*V';


end