% draw the cancer masks looking at the key images
% 1/22/2023
% Author: Batuhan Gundogdu
% Use this function to draw cancer masks on the relevant slices
% Make sure to change the address and the relevant slice range in the for
% loop
% the cancer masks are saved them as MATLAB files
%% change the address for the current patient
clc
clear
close all
foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat065";
load(fullfile(foldername, "pat065_hybridSortedInput.mat"))
%% change the range of the slices below
cancer_mask = zeros(128, 128, size(hybrid_data,3));
num_cancers = 2;
bb = [0, 150, 1000, 1500];
figure
for slice=15:15
    img2 = squeeze(hybrid_data(:, :, slice, :, 1));
    adc = zeros(128);
    for row=1:128
        for col=1:128
            val = polyfit(bb(1:end)/1000, log(img2(row, col, :)), 1);
            adc(row,col) = -val(1);
        end
    end
    adc = imresize(adc,16,'bilinear');
    imagesc(adc, [0.3, 3]);
    axis('off')
    title(["Slice ", num2str(slice)])
    colormap('gray')
    hold on
    movegui("center")
    for j=1:num_cancers
        roi = drawfreehand(gca,"Color",'r');
        mask = roi.createMask(adc);
        mask = imresize(mask, 1/16,'bilinear');
        cancer_mask(:,:, slice) = cancer_mask(:,:, slice) + mask;
    end
    %pass = input("press key to pass");
    %hold off
end

filename = fullfile(foldername, 'cancer_mask.mat');
save(filename, 'cancer_mask')
disp(strcat(filename, ' saved!'))