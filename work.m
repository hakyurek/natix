warning off
clear
clf

for image_id = [ 1 ];
wideness = 2;                   %1-2 2-1
similarity_treshold = 0.04;     %1-0.04 2-0.08
amount = 1000;                  %1-1000 2-1000
blur_size = 2;                  %1-2 2-2

[tmp tmp2 tmp3] = natix(image_id, wideness, similarity_treshold, amount, blur_size);

end
