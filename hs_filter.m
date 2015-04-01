function [filter] = hs_filter (cube)

% Prepare
signature_depth = size(cube,3);
layer_count = numel(cube) / signature_depth;

% Make filter
entropy = reshape(sum(sum(cube))/layer_count,[],signature_depth);
mean_highpass = find(entropy>mean(entropy));
dinamics = abs(circshift(entropy,[0 1]) - entropy);
dinamics_highpass = find(dinamics>mean(dinamics));
union_highpass = union(dinamics_highpass, mean_highpass);

highpassed = zeros(1,signature_depth);
higpassed(union_highpass) = 1;
filter = find(highpassed < 1);
