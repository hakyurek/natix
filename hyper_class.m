function matrix = hyper_class(DB)
    [ X matrix fil col depth ] = hyper_load(DB);
    matrix = reshape(matrix,fil,col);       % Reshape
end