function [ metricHue metricSaturation metricVolume ] = hsv_metrics_from_RGB_image( input_image, borders )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    hsv_image = rgb2hsv(input_image);

    metricHue = hsv_image(:,:,1);
    metricSaturation = hsv_image(:,:,2);
    metricVolume = hsv_image(:,:,3);
end

