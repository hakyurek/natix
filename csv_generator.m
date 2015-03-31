% Wild pigs
clear; 
clf;

% Konfiguracja

images_no = 1;

for par_image_id = images_no;       % numer obrazu
    
posters_no = [16];
par_wideness = 1;       % szeroko¶æ filtra

par_posterization_similarity = .99;
par_show_posterization = false;
par_concrete_percent = 0.03;

norm = 1;
smart_norm = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Wczytywanie obrazu
%%%

fprintf('# Wczytywanie obrazu\n  '); 
tic;
ncube = hyper_ncube(par_image_id);
ncube_god_classification = hyper_class(par_image_id);
signature_depth = size(ncube,3);
layer_count = numel(ncube) / signature_depth;
toc;
%{
%
% Image
%

subplot 111;
image(mean_RGB_from_hyperspectral(ncube));
title(sprintf('image %i\n%i layers\n%i pixels per layer', ... 
                par_image_id, signature_depth, layer_count));

% Clean-up
%clear par_image_id;
%click;
pause(.25);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Detekcja granic
%%%

fprintf('# Detekcja granic\n');tic;
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

%
% Image
%

image(cat(3,mean_edges,mean_edges,mean_edges));
title('Edges detection');

%%%%STAGES
image(cat(3,mean_edges,mean_edges,mean_edges));
imwrite(mean_edges,'00_edge_mask.png');
%click;
%%%%STAGES

% Clean-up
clear   wideness index huge_stack huge_stack_length treshold x y w ...
        par_wideness;
%click;
pause(.25);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Tworzenie filtra
%%%

fprintf('# Tworzenie filtra\n');tic;

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

%
% Image
%
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

%clf
%subplot 111; hold on;
%plot([information noise], 'r'); 
%a = plot(information, 'k');
%title('Information & noise separation');
%legend('Noise', 'Information', [0 0 450 230]);
%hold off
%saveas(a,'02.png');
%click;

% Clean-up
clear   antifilter dinamics dinamics_highpass entropy highpassed_mean i ...
        highpassed highpassed_dinamics information union_highpass w ...
        highpassed_union noise mean_highpass;
pause(.25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Filtering
%%%
fprintf('# Filtrowanie\n');tic;

filtered_edges_cube = edges_cube(:,:,filter);
filtered_mean_edges = mean(filtered_edges_cube,3);
filtered_ncube = ncube(:,:,filter);

filtered_signature_depth = size(filtered_ncube,3);

edges_treshold = mean(mean(filtered_mean_edges));
edges_mask = filtered_mean_edges > edges_treshold;

toc;

%
% Image
%
subplot 121;
image(cat(3,[mean_edges; filtered_mean_edges],[mean_edges; filtered_mean_edges],[mean_edges; filtered_mean_edges]));
title('Edges | Filtered edges');

subplot 122;
%imshow([mean_RGB_from_hyperspectral(ncube); ...
%        mean_RGB_from_hyperspectral(filtered_ncube)]);
title('RGB image | Filtered RGB image');

% Clean-up
%clear ncube;
clear edges_cube mean_edges w signature_depth;
%click;
pause(.25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Metrics
%%%
fprintf('# Wyliczanie metryk\n  '); tic;
% RGB wyliczone z trzech kwantów przekonwertowane na HSV\n');
rgb_image = mean_RGB_from_hyperspectral(filtered_ncube);
[metric_hue, metric_saturation ,metric_volume] = hsv_metrics_from_RGB_image(rgb_image, filtered_mean_edges); 

% Minimum
[metric_minimal, metric_minimal_idx]= min(filtered_ncube,[],3);
metric_minimal_idx = metric_minimal_idx / max(max(metric_minimal_idx));

% Maksimum
[metric_maximal, metric_maximal_idx] = max(filtered_ncube,[],3);
metric_maximal_idx = metric_maximal_idx / max(max(metric_maximal_idx));

% ¦rednia
metric_mean = mean(filtered_ncube,3);

% Mediana
metric_median = median(filtered_ncube,3);

% Maximum - minimum
metric_maxmin = metric_maximal - metric_minimal;
metric_maxmin_idx = abs(metric_maximal_idx - metric_minimal_idx);
toc;

metrics(:,:,1) = metric_hue;
metrics(:,:,2) = metric_saturation;
metrics(:,:,3) = metric_volume;
metrics(:,:,4) = metric_minimal;
metrics(:,:,5) = metric_minimal_idx;
metrics(:,:,6) = metric_maximal;
metrics(:,:,7) = metric_maximal_idx;
metrics(:,:,8) = metric_mean;
metrics(:,:,9) = metric_median;
metrics(:,:,10) = metric_maxmin;
metrics(:,:,11) = metric_maxmin_idx;


%%%%STAGES
subplot 111;
image(cat(3,metric_mean,metric_mean,metric_mean));
imwrite(metric_mean,'03_example_metric_8.png');

pause(.25);
%%%%STAGES

%
% Image
%
background = ones(  size(filtered_ncube,1)*4, ...
                    size(filtered_ncube,2)*3, ...
                    3 );
index = 1;
for x=0:3
    for y=0:2
        hsv_image = HSV_image_with_metric_and_borders(metrics(:,:,index),...
                                                      filtered_mean_edges);
                                                  

        rgb_image = hsv2rgb(hsv_image);
        

        width = size(filtered_ncube,1);
        height = size(filtered_ncube,2);
        
        background((1+x*width):((x+1)*width),(1+y*height):((y+1)*height),:) = rgb_image;
        
        index = index + 1;
        if index > 11
            break
        end
        
    end
end

subplot 111;
imwrite(background, 'met.png');
image(background);
title('Metrics');

% Clean-up
clear   metric_hue metric_maximaal metric_maximaal_idx metric_maxmin ...
        metric_maxmin_idx metric_median metric_meean metric_minimaal ...
        metric_minimaal_idx metric_saturation metric_volume background ...
        height width x y w rgb_image hsv_image index;
%click;
pause(.25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Normalization
%%%


if norm
fprintf('# Normalizacja metryk\n'); tic;

for i=1:11
    metric = metrics(:,:,i); 
        
    subplot 221;
    image(cat(3,metric,metric,metric));
    
    %temp = metric;
    
    med = median(median(metric));
    
    if smart_norm
        temp = metric - edges_mask;
        temp(temp<0) = med;
    else
        temp = metric;    
    end
    
    subplot 222;
    image(cat(3,temp,temp,temp));
    
    minnn = min(min(temp));
    maxxx = max(max(temp));
    
    fprintf('#Met %02i | min %f | max %f | med %f\n', i, minnn, maxxx, med);
    
    Anorm = (metric - minnn)/(maxxx - minnn);
    
    subplot 223;
    %image(cat(3,Anorm,Anorm,Anorm));
    %click;
    
    
    metrics(:,:,i) = Anorm;
end
end

toc;


%%%%STAGES
subplot 111;
%image(metrics(:,:,7:9));
imwrite(metrics(:,:,8),'04_nomalized_metric_8.png');
%click;
pause(.25);
%%%%STAGES

%
% Image
%
background = ones(  size(filtered_ncube,1)*4, ...
                    size(filtered_ncube,2)*3, ...
                    3 );
index = 1;
for x=0:3
    for y=0:2
        hsv_image = HSV_image_with_metric_and_borders(metrics(:,:,index),...
                                                      filtered_mean_edges);
                                                  

        rgb_image = hsv2rgb(hsv_image);
        

        width = size(filtered_ncube,1);
        height = size(filtered_ncube,2);
        
        background((1+x*width):((x+1)*width),(1+y*height):((y+1)*height),:) = rgb_image;
        
        index = index + 1;
        if index > 11
            break
        end
        
    end
end

subplot 111;
imwrite(background, 'met_norm.png');
image(background);
title('Normalized metrics');

%click;
pause(.25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Smart posterization
%%%
for par_posterization = posters_no;

fprintf('# Posteryzacja %i\n', par_posterization); tic;
poster_metrics = zeros(size(filtered_ncube,1),size(filtered_ncube,2),11);
for i=1:11
   poster_metrics(:,:,i) = floor(metrics(:,:,i) * par_posterization);
end

flattern_ncube = reshape(filtered_ncube,layer_count,[]);

tic;
for metric = 1:11
    fprintf('\tMetric %i\n', metric);
    poster_metric = poster_metrics(:,:,metric); % metryka
    signatures_buffer = zeros(  filtered_signature_depth,...
                                par_posterization);
                            
    %
    element_masks = false(size(poster_metric,1),size(poster_metric,2),par_posterization);
    
     for poster=0:par_posterization;
        element_mask = poster_metric == poster;
        element_mask = element_mask - edges_mask;
        element_mask = element_mask > 0;

        element_masks(:,:,poster+1) = element_mask;
     end

     foo = 1:par_posterization;

     for poster=0:par_posterization;
        element_mask = element_masks(:,:,poster+1);
        flattern_mask = reshape(element_mask,layer_count,1);
        
        masked = flattern_ncube(flattern_mask,:);
        element_signature = mean(masked);

        signatures_buffer(:,poster+1) = element_signature;
                  
        if poster > 0
            for i=poster-1:-1:1
                similarity = 1 - mae(element_signature'-signatures_buffer(:,i));

                if similarity > par_posterization_similarity
                    % To nale¿y poprawiæ
                    target = i-1; 
                    real_target = foo(i);
                    
                    poster_metric(element_mask) = real_target;
                    
                    foo(poster) = real_target;
                    
                    %fprintf('\t# %i => %i(%i)\n', poster, target, real_target);

                end
            end
        end        
        
        %foo
        %click;
        
        if par_show_posterization
            %
            % Image
            %
            subplot 223;
            hsv_image = HSV_image_with_metric_and_borders(poster_metric/par_posterization,...
                                                          filtered_mean_edges);
            rgb_image = hsv2rgb(hsv_image);

            imshow(rgb_image);
            title(sprintf('metric %i',metric));

            subplot 221;
            imshow(element_mask);
            title(sprintf('poster %i', poster));

            subplot 222;
            plot(element_signature, 'k');
         
            
            axis([-10 filtered_signature_depth+10 -0.1 1.1]);
            grid on;
            axis off;
            title('Signature');

            subplot 224;
            plot(signatures_buffer);

            axis([-10 filtered_signature_depth+10 -0.1 1.1]);

           pause(.125);
        end
        
        

    end
    poster_metrics(:,:,metric) = poster_metric; % metryka
    if par_show_posterization
        pause(.25);
        %click;
    end
end
toc;


%%%%STAGES
subplot 111;
%image(poster_metrics(:,:,7:9)/par_posterization);
imwrite(poster_metrics(:,:,8)/par_posterization,'05_posterized_metric_8.png');
%click;
pause(.25)
%%%%STAGES

%
% Image
%
background = ones(  size(filtered_ncube,1)*4, ...
                    size(filtered_ncube,2)*3, ...
                    3 );
index = 1;
for x=0:3
    for y=0:2
        hsv_image = HSV_image_with_metric_and_borders(poster_metrics(:,:,index)/par_posterization,...
                                                      filtered_mean_edges);
        
        rgb_image = hsv2rgb(hsv_image);

        width = size(filtered_ncube,1);
        height = size(filtered_ncube,2);
        
        background((1+x*width):((x+1)*width),(1+y*height):((y+1)*height),:) = rgb_image;
        
        index = index + 1;
        if index > 11
            break
        end
        
    end
end

subplot 111;
imwrite(background, 'met_pos.png');
image(background);
title('Posters');

flattered_posters = poster_metrics / par_posterization;

%imshow(flattered_posters(:,:,3:5));

output_matrix = cat(3,ncube_god_classification,flattered_posters);
output = reshape(output_matrix, [], 12);

filename = sprintf('image_%i_posters_%i.csv', par_image_id, par_posterization);

csvwrite(filename, output);

end

clear
%}
end
