function [ matrix ] = remove_gap( matrix, gap_sz )
%REMOVE_GAP Summary of this function goes here
%   Detailed explanation goes here

sz = size(matrix,2);

for i = 1:sz
    if matrix(i)==1 && any(matrix(i+1:min(i+gap_sz,sz)))
        j = i+1;
        while matrix(j)==0 && j<=min(i+gap_sz,sz)
            matrix(j)=1;
            j=j+1;
        end
    end
end

