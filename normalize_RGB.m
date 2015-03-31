function [ output_image ] = normalize_RGB( input_image )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    output_image = input_image;
    for channel=1:3
        layer = input_image(:,:,channel);
        mn = mean(layer);
        sd = std(layer);
        sd(sd==0) = 1;

        xn = bsxfun(@minus,layer,mn);
        xn = bsxfun(@rdivide,xn,sd);
        
        output_image(:,:,channel) = xn;
    end


end

