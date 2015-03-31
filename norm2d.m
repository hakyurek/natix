function [ matrix ] = norm2d(matrix)
    max_ = max(matrix);
    min_ = min(matrix);
    matrix = (matrix - repmat(min_,length(matrix),1)) ./ repmat((max_ - min_),length(matrix),1);
end