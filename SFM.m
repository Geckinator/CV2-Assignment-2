function [] = SFM(foldername, threshold, epochs, testing)


if not(testing)
    povMatrix = construct_point_view_matrix(foldername, threshold, testing);
    for i = 1 : 1 : size(povMatrix, 1)
        
        row  = povMatrix(i, :);
        row_mean = sum(row) / length(row);
        centered_row = row - row_mean;
        for z = 1 :1 : length(row)
            povMatrix(i,z)= centered_row(z);
        end
        
    end
end
povMatrix_testing =  importdata('PointViewMatrix.txt');



%CENTER the povMatrix

if testing
    povMatrix = povMatrix_testing ;
end


[U,W,V] = svd(povMatrix) ;

u = U(:, 1:3);
w= W(1:3, 1:3);
v= V(1:3, :) ;

M= U*W;
S= W*V';


figure(1);
scatter3(M(:,1),M(:,2),M(:,3));
figure(2);
scatter3(S(1,:),S(2,:),S(3,:));

    



end