function [ image ] = combine_metrics_to_image ( metrics, red, green, blue )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    image = cat(3,metrics(:,:,red),metrics(:,:,green),metrics(:,:,blue));

end

