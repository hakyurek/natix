function [ image ] = mean_RGB_from_hyperspectral( ncube )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    signature_depth = size(ncube,3);
    component_length = floor(signature_depth/3);
    red = ncube(:,:,1:component_length);
    green = ncube(:,:,component_length:(2*component_length));
    blue = ncube(:,:,(2*component_length):(3*component_length));

    red = mean(red,3);
    green = mean(green,3);
    blue = mean(blue,3);

    image = cat(3,red,green,blue);
end

