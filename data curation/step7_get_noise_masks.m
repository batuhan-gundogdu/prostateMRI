clc
clear
close all
foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat083";
load(fullfile(foldername, "pat083_hybridSortedInput.mat"))
noise_mask = zeros(128, 128, size(hybrid_data,3));
bb = [0, 150, 1000, 1500];
figure
for slice=18:18
    img2 = squeeze(hybrid_data(:, :, slice, 1, 1));
    img2 = imresize(img2,16,'bilinear');
    imagesc(img2,[0, 70000]);
    axis('off')
    title(["Slice ", num2str(slice)])
    colormap('gray')

end

filename = fullfile(foldername, 'noise_mask.mat');
save(filename, 'noise_mask')
disp(strcat(filename, ' saved!'))