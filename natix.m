function [ tmp ] = natix(image_id, wideness, similarity_treshold, amount)

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
imshow(mean(edges_cube,3));
title('Flattered borders cube');
pause(.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Filtering
%%%
fprintf('# Filtrowanie\t');tic;

fprintf('# Tworzenie filtra\n');tic;

% Ustalanie entropii
entropy = reshape(sum(sum( edges_cube )) / pixel_count, [] ,depth);
% Filtr górnoprzepustowy entropii
mean_highpass = find(entropy>mean(entropy));
% Wyznaczanie dynamiki
dinamics = abs(circshift(entropy,[0,1]) - entropy);
% Filtr górnoprzepustowy dynamiki
dinamics_highpass = find(dinamics>mean(dinamics));
% Unia filtrów
union_highpass = union(dinamics_highpass,mean_highpass);
% Filtr
highpassed = zeros(1,depth);
highpassed(union_highpass) = 1;
filter = find(highpassed < 1);
antifilter = find(highpassed > 0);

tmp = filter;
%{
toc;

filtered_edges_cube = edges_cube(:,:,filter);
filtered_mean_edges = mean(filtered_edges_cube,3);
filtered_ncube = ncube(:,:,filter);

filtered_signature_depth = size(filtered_ncube,3);

edges_treshold = mean(mean(filtered_mean_edges));
edges_mask = filtered_mean_edges > edges_treshold;

imwrite(mean(edges_cube,3), '01_edge_mask.png');
imwrite(edges_mask, '01_edge_mask_f.png');

subplot 131;
imshow(mean(edges_cube,3));
subplot 132;
imshow(mean(filtered_edges_cube,3));
subplot 133;
imshow(edges_mask);
toc;
click;
%%% Filling
% http://www.mathworks.com/help/images/ref/imfill.html
% http://blogs.mathworks.com/steve/2008/08/05/filling-small-holes/
negative = imcomplement(edges_mask);
filled = imfill(negative, 'holes');
holes = filled & ~negative;
bigholes = bwareaopen(holes, 200);
smallholes = holes & ~bigholes;
new = negative | smallholes;

% Image
imwrite(negative, '02_negative.png');
imwrite(filled, '03_filled_negative.png');
imwrite(new, '04_new.png');

subplot 131;
imshow(negative);
subplot 132;
imshow(filled);
subplot 133;
imshow(new);
click;

%%% Labelling
% http://www.mathworks.com/help/images/ref/bwlabel.html
labels = bwlabel(new);
flat_labels = reshape(labels,1,[]);
labels_no = max(flat_labels);

fprintf('%i labels\n', labels_no);

% Image
% http://www.mathworks.com/help/images/ref/labelmatrix.html
imwrite(label2rgb(labels), '05_labels.png');

subplot 111;
imshow(label2rgb(labels));
click;


%%% Remove all small regions
one_percent = (size(labels,1)*size(labels,2))/par_amount;
for label = 1:labels_no
    amount = sum(flat_labels==label);
    if amount < one_percent
        flat_labels(flat_labels==label) = 0;
    else
        fprintf('lab %i [%i]\n', label, amount);
    end
end

for destination_label = 1:labels_no
    amount = sum(flat_labels == destination_label);
    if amount == 0
        for source_label = labels_no:-1:destination_label
            amount = sum(flat_labels == source_label);
            if amount > 0
                fprintf('remap %i -> %i\n', source_label, destination_label);
                flat_labels(flat_labels == source_label) = destination_label;
                break;
            end
        end
    end
end

fprintf('Establishing labels\n');
labels_no = max(flat_labels);
labels = reshape(flat_labels,[],size(labels,2));
imwrite(label2rgb(labels), '06_clean_labels.png');
imshow(label2rgb(labels));
fprintf('We have %i basic labels\n', labels_no);
click;
% Porównywanie sygnatur etykiet
flattern_ncube = reshape(filtered_ncube,layer_count,filtered_signature_depth);

for i=1:labels_no
    mask = labels == i;
    flattern_mask = reshape(mask,layer_count,1);
    masked = flattern_ncube(flattern_mask,:);
    signature = mean(masked);
    
    %subplot 121;
    %imshow(mask);
    
    for j=1:(i-1)
       another_mask = labels == j;
       another_flattern_mask = reshape(another_mask,layer_count,1);
       another_signature = mean(flattern_ncube(another_flattern_mask,:));
       %subplot 122;
       
       distance = mean(abs(signature-another_signature));
       
       %plot(signature,'r');
       %hold on
       %plot(another_signature,'b');
       %hold off;
       %title(distance);
       
       %ylim([0 1]);
       
       if(distance < par_similarity_treshold)
           %fprintf('We are family! %i and %i\n', i, j);
           labels(labels==i) = j;
           break;
       end
       %pause(.5);
    end
    
    fprintf('Etykieta %i\n', i);
    %pause(1);
end

imwrite(label2rgb(labels), '07_joined_labels.png');
imshow(label2rgb(labels));
%}

%{
flat_labels = reshape(labels,1,[]);
labels_no = max(flat_labels);

fprintf('%i labels\n', labels_no);

for destination_label = 1:labels_no
    amount = sum(flat_labels == destination_label);
    if amount == 0
        for source_label = labels_no:-1:destination_label
            amount = sum(flat_labels == source_label);
            if amount > 0
                fprintf('remap %i -> %i\n', source_label, destination_label);
                flat_labels(flat_labels == source_label) = destination_label;
                break;
            end
        end
    end
end

fprintf('Establishing labels\n');
labels_no = max(flat_labels);
labels = reshape(flat_labels,[],size(labels,2));
imwrite(label2rgb(labels), '08_clean_labels.png');
imshow(label2rgb(labels));
fprintf('We have new %i basic labels\n', labels_no);
click;

%}
