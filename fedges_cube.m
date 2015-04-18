function [ edges_cube ] = fedges_cube(cube, wideness)

output = zeros(size(cube));
index = 1;
huge_stack_length = ( 1 + wideness * 2 ) ^ 2;
huge_stack = zeros(size(cube,1),...
                   size(cube,2),...
                   size(cube,3),...
                   huge_stack_length);

for x = -wideness : wideness
    for y = -wideness : wideness
        huge_stack(:,:,:,index) = circshift(cube, [x, y]);
        index = index + 1;
    end
end

edges_cube = max(huge_stack,[],4) - min(huge_stack,[],4);
treshold = mean(mean(mean(edges_cube)));
edges_cube(edges_cube < treshold) = 0;
edges_cube(edges_cube >= treshold) = 1;
