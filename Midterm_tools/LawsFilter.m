clear
close all

%%


OneDim = cell(1,5);
OneDim{1} = [1;4;6;4;1];
OneDim{2} = [-1;-2;0;2;1];
OneDim{3} = [-1;0;2;0;-1];
OneDim{4} = [-1;2;0;-2;1];
OneDim{5} = [1;-4;6;-4;1];

LawFilters = cell(5,5);

for i = 1:5
    for j = 1:5
        LawFilters{i,j} = OneDim{i}*transpose(OneDim{j});
    end
end