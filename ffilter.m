function [ filter ] = ffilter(edges_cube)

depth = size(edges_cube, 3);
pixel_count = numel(edges_cube) / depth;

entropy = reshape(sum(sum( edges_cube )) / pixel_count, [], depth);
mean_highpass = find(entropy > mean(entropy));
dinamics = abs(circshift(entropy, [0, 1]) - entropy);
dinamics_highpass = find(dinamics > mean(dinamics));
union_highpass = union(dinamics_highpass, mean_highpass);

highpassed = zeros(1, depth);
highpassed(union_highpass) = 1;
filter = find(highpassed < 1);
