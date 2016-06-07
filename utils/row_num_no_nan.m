function [ length_no_nan ] = row_num_no_nan( matrix )
%ROW_NUM_NO_NAN Summary of this function goes here
%   Detailed explanation goes here


length_no_nan = NaN(1,size(matrix,2));
for col = 1:size(matrix,2)
    length_no_nan(col) = length(find(~isnan(matrix(:,col))));
end

end

