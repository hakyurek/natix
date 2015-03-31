function matrix = hyper_ncube(DB)
  [ matrix Y fil col depth ] = hyper_load(DB);
  matrix = norm2d(matrix);              % Normalize
  matrix = reshape(matrix,fil,col,[]);  % Reshape
end