clear; 
clf;

% Konfiguracja

images_no = [1:6];

for par_image_id = images_no;       % numer obrazu
    
par_wideness = 2;       % szeroko¶æ filtra

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Wczytywanie obrazu
%%%

fprintf('\n# Wczytywanie obrazu\t'); 
tic;
ncube = hyper_ncube(par_image_id);
ncube_god_classification = hyper_class(par_image_id);
signature_depth = size(ncube,3);
layer_count = numel(ncube) / signature_depth;
toc;

% Image
imwrite(mean_RGB_from_hyperspectral(ncube), '00_image.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Detekcja granic
%%%

fprintf('# Detekcja granic\t');tic;
edges_cube = zeros(size(ncube));

% Budowa czterowymiarowej kostki
index = 1;
huge_stack_length = (1+par_wideness*2)^2;
huge_stack = zeros( size(ncube,1),...
                    size(ncube,2),...
                    size(ncube,3),...
                    huge_stack_length);
for x=-par_wideness:par_wideness
    for y=-par_wideness:par_wideness
            huge_stack(:,:,:,index) = circshift(ncube,[x,y]);
            index = index+1;
    end
end

% Analiza kostki
edges_cube = max(huge_stack,[],4)-min(huge_stack,[],4);
treshold = mean(mean(mean(edges_cube)));

edges_cube(edges_cube < treshold) = 0;
edges_cube(edges_cube > treshold) = 1;

mean_edges = mean(edges_cube,3);

toc;

% Image
imwrite(mean_edges,'01_edge_mask.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Tworzenie filtra
%%%

fprintf('# Tworzenie filtra\t');tic;

% Ustalanie entropii
entropy = reshape(sum(sum(edges_cube))/layer_count,[],signature_depth);

% Filtr górnoprzepustowy entropii
mean_highpass = find(entropy>mean(entropy));

% Wyznaczanie dynamiki
dinamics = abs(circshift(entropy,[0,1]) - entropy);

% Filtr górnoprzepustowy dynamiki
dinamics_highpass = find(dinamics>mean(dinamics));

% Unia filtrów
union_highpass = union(dinamics_highpass,mean_highpass);

% Filtr
highpassed = zeros(1,signature_depth);
highpassed(union_highpass) = 1;
filter = find(highpassed < 1);
antifilter = find(highpassed > 0);

toc;

% Image
highpassed_mean = zeros(1,signature_depth);
highpassed_dinamics = zeros(1,signature_depth);
highpassed_union = zeros(1,signature_depth);

highpassed_mean(mean_highpass) = 1;
highpassed_dinamics(dinamics_highpass) = 1;
highpassed_union(union_highpass) = 1;

information = entropy(filter);
noise = entropy(antifilter);

subplot 611; plot(entropy,'k'); 
%title('Entropy');

subplot 612; plot(highpassed_mean ,'k'); 
%title('Mean entropy highpass');

subplot 613; plot(dinamics, 'k'); 
%title('Dinamics');

subplot 614; plot(highpassed_dinamics , 'k'); 
%title('Mean dinamics highpass');

subplot 615; plot(highpassed_union, 'k'); 
%title('Union');

subplot 616; hold on;
plot([information noise], 'r'); plot(information, 'k');
%title('Information & noise separation');
%legend('Noise', 'Information', [0 0 450 230]);

for i=1:6
    subplot(6,1,i);
    axis off;
    axis([-10 signature_depth+10 -0.1 1.1]);
    hold off;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Filtering
%%%
fprintf('# Filtrowanie\t');tic;

filtered_edges_cube = edges_cube(:,:,filter);
filtered_mean_edges = mean(filtered_edges_cube,3);
filtered_ncube = ncube(:,:,filter);

filtered_signature_depth = size(filtered_ncube,3);

edges_treshold = mean(mean(filtered_mean_edges));
edges_mask = filtered_mean_edges > edges_treshold;

toc;

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

%%% Labelling
% http://www.mathworks.com/help/images/ref/bwlabel.html
labels = bwlabel(new);
labels_no = max(max(labels));
centroids = regionprops(labels,'centroid');

fprintf('%i labels\n', labels_no);

% Image
% http://www.mathworks.com/help/images/ref/labelmatrix.html
imwrite(label2rgb(labels), '05_labels.png');

end
