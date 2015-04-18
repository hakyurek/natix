warning off
clear
clf

for image_id = 1:2;
wideness = 2;
similarity_treshold = 0.02;
amount = 1000;

[tmp tmp2 tmp3] = natix(image_id, wideness, similarity_treshold, amount);

end
