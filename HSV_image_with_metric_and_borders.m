function [ image ] = HSV_image_with_metric_and_borders( metric, borders)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    mean_border = mean(mean(borders));
    borders(borders>mean_border) = 1;
    borders(borders<mean_border) = 0;
    
    image = cat(3, metric, 1-borders, 1-borders);

end

