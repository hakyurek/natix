for i=1:11
    something_one = poster_metrics(:,:,i) + 1;
    something_two = poster_metrics(:,:,i) + 1 - (par_posterization*edges_mask);
    
    filename = sprintf('im_%02i_m_%02i_p_%02i', par_image_id, ...
        i, par_posterization)
    
    path = sprintf('~/results/%s.png', filename);
    path_two = sprintf('~/results/%s_b.png', filename);
    
    
    subplot 211;
    imshow(something_one/par_posterization)
    imwrite(something_one/par_posterization, path);
    title(filename);
    
    subplot 212;
    imshow(something_two/par_posterization)
    imwrite(something_two/par_posterization, path_two);
    title(filename);
    %click;
    
    pause(1);
    
    ncube_new_classification = something_one;
    ncube_new_classification_br = something_two;
    
    % Pixels
    ncube_new_reshape=reshape(ncube_new_classification,...
        [size(ncube_new_classification,1)*size(ncube_new_classification,2) ...
        size(ncube_new_classification,3)]);
    
    ncube_new_reshape_br=reshape(ncube_new_classification_br,...
        [size(ncube_new_classification_br,1)*size(ncube_new_classification_br,2) ...
        size(ncube_new_classification_br,3)]);

    ncube_god_reshape=reshape(ncube_god_classification,...
        [size(ncube_god_classification,1)*size(ncube_god_classification,2)...
        size(ncube_god_classification,3)]);

    ncube_origin_reshape=reshape(ncube,[size(ncube,1)*size(ncube,2) size(ncube,3)]);

    ncube_joined_reshape = [ncube_origin_reshape ncube_new_reshape ncube_god_reshape];
    ncube_joined_reshape_br = [ncube_origin_reshape ncube_new_reshape_br ncube_god_reshape];

    
    original_background_idx = (ncube_joined_reshape(:, end) ~= 0);
    new_background_idx = (ncube_joined_reshape(:, end-1) ~= 0);
    new_background_idx_br = (ncube_joined_reshape_br(:, end-1) ~= 0);
    
    joined_background_idx = original_background_idx & new_background_idx;  
    joined_background_idx_br = original_background_idx & new_background_idx_br;  

    pixels_without_background = ncube_joined_reshape(joined_background_idx,:);
    pixels_without_background_br = ncube_joined_reshape_br(joined_background_idx_br,:);

    csvwrite(['~/results/' strcat(filename,'_pxl.csv')],pixels_without_background);
    csvwrite(['~/results/' strcat(filename,'_bpxl.csv')],pixels_without_background_br);
    
    pause(1);
end