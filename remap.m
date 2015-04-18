function [ labels ] = remap(labels)

labels_no = max(max(labels));

for destination_label = 1:labels_no
    amount = sum(sum(labels == destination_label));
    if amount == 0
        for source_label = labels_no:-1:destination_label
            amount = sum(sum(labels == source_label));
            if amount > 0
                fprintf('\tremap %i -> %i\n', source_label, destination_label);
                labels(labels == source_label) = destination_label;
                break;
            end
        end
    end
end

