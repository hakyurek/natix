warning off
clear
clf

for image_id = [1];
wideness = 1;
similarity_treshold = 0.025;
amount = 1000;
blur_size = 10;

[tmp tmp2 tmp3] = natix(image_id, wideness, similarity_treshold, amount, blur_size);

end
