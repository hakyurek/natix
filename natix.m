function [ tmp tmp2 tmp3 ] = natix(image_id, wideness, similarity_treshold, amount, blur_size)

%%% Wczytywanie obrazu

fprintf('# Loading an image\n');

cube = hyper_ncube(image_id);
ground_truth = hyper_class(image_id);
depth = size(cube, 3);
pixel_count = numel(cube) / depth;

imshow(false_color(cube));
title('False-color image');
pause(.5);

%%% Detekcja granic

fprintf('# Border detection\n');

edges_cube = fedges_cube(cube, wideness);

subplot 132;
imshow(mean(edges_cube,3));
title('Flattered borders cube');
pause(.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Filtering
%%%
fprintf('# Filtering\n');

filter = ffilter(edges_cube);

tmp = filter;

subplot 131;
imshow(mean(edges_cube,3));
title('Before');

edges_cube = edges_cube(:,:,filter);
mean_edges = max(edges_cube,[],3);
cube = cube(:,:,filter);
depth = size(cube,3);

subplot 132;
imshow(mean(edges_cube,3));
title('After');

edges_treshold = mean(mean(mean_edges));
edges_mask = mean_edges > edges_treshold;

subplot 133;
imshow(edges_mask);
title('Mask');

pause(.5);

%%% Filling

fprintf('# Filling\n');
% http://www.mathworks.com/help/images/ref/imfill.html
% http://blogs.mathworks.com/steve/2008/08/05/filling-small-holes/
negative = imcomplement(edges_mask);
filled = imfill(negative, 'holes');
holes = filled & ~negative;
bigholes = bwareaopen(holes, 200);
smallholes = holes & ~bigholes;
new = negative | smallholes;

subplot 131;
imshow(negative);
title('1');
subplot 132;
imshow(filled);
title('2');
subplot 133;
imshow(new);
title('3');
pause(.5);

%%% Labelling
fprintf('# Labelling\n');

labels = bwlabel(new);
labels_no = max(max(labels));

fprintf('%i labels\n', labels_no);

subplot 131;
imshow(label2rgb(labels));
title('Region labels');
pause(.5);

%%% Remove all small regions
one_percent = (size(labels,1)*size(labels,2)) / amount;
for label = 1:labels_no
    amount = sum(sum(labels==label));
    if amount < one_percent
        labels(labels==label) = 0;
    end
end

subplot 132;
imshow(label2rgb(labels));
title('Cut off the small regions');
pause(.5);

%%% Remap

fprintf('# Remap\n');
labels = remap(labels);

labels_no = max(max(labels));
fprintf('%i labels\n', labels_no);

subplot 133;
imshow(label2rgb(labels));
title('Remap');
pause(.5);


%%% Signature merging

fprintf('# Signature merging\n');
tmp = cube;
flattern_cube = reshape(cube,pixel_count,depth);

for i=1:labels_no
    mask = labels == i;
    flattern_mask = reshape(mask,pixel_count,1);
    masked = flattern_cube(flattern_mask,:);
    signature = mean(masked);
      
    for j=1:(i-1)
       another_mask = labels == j;
       another_flattern_mask = reshape(another_mask,pixel_count,1);
       another_signature = mean(flattern_cube(another_flattern_mask,:));
       
       distance = mean(abs(signature-another_signature));
       
       if(distance < similarity_treshold)
           labels(labels==i) = j;
           break;
       end
    end   
end

subplot 132;
imshow(label2rgb(labels));
title('Merged signatures');
pause(.5);

labels = remap(labels);
subplot 133;
imshow(label2rgb(labels));

title('Remap');
pause(.5);

labels_no = max(max(labels));

fprintf('%i labels\n', labels_no);

foo = zeros(size(cube,1),size(cube,2),labels_no);
for label = 1:labels_no
    mask = labels == label;
    subplot 142;
    imshow(mask);
    title(label);

    flattern_mask = reshape(mask, pixel_count, 1);
    masked = flattern_cube(flattern_mask,:);
    signature = mean(masked);

    subplot 141;
    plot(signature);
    ylim([0 1]);
    title('Signature');

    distance = abs(bsxfun(@minus,flattern_cube,signature));
    layer = reshape(distance,size(cube,1),size(cube,2),[]);
    
%    layer = (layer - min2(layer)) / (max2(layer) - min2(layer));
    layer = 1-max(layer,[],3);

%    layer = (layer - min2(layer))/(max2(layer) - min2(layer));
   

    layer(layer < .9) = layer(layer < .9) / 3;
    % Blur it!
    h = fspecial('disk',blur_size);
    layer2 = imfilter(layer,h,'replicate');
    foo(:,:,label) = layer;

    subplot 143;
    imshow(layer);

    subplot 144;
    imshow(layer2);
    pause(.5);

    foo(:,:,label) = layer2;
end

[ saturation hue ] = max(foo,[],3); 
tmp = foo;
tmp2 = saturation;
tmp3 = hue;

hsv_image = ones(size(cube,1), size(cube,2), 3);
hsv_image(:,:,1) = hue / labels_no;
hsv_image(:,:,3) = max(cube,[],3);
hsv_image(:,:,3) = hsv_image(:,:,3)*.7;%saturation;

rgb_image = hsv2rgb(hsv_image);

subplot 131;
imshow(rgb_image);

tmp = rgb_image;
tmp2 = ground_truth;

imwrite(tmp, 'r.png');
imwrite(label2rgb(tmp2), 'g.png');

pause(1);
learning_labels = hue;
labels_no = max(max(hue));
for label = 1:labels_no
    fprintf('label %i\n', label);
    a = mode(mode(ground_truth(hue == label)));
    fprintf('value %i\n', a);
    learning_labels(learning_labels==label) = a;
end

subplot 132;
imshow(label2rgb(ground_truth));
subplot 133;
imshow(label2rgb(learning_labels));

imwrite(label2rgb(learning_labels), 'gg.png');
