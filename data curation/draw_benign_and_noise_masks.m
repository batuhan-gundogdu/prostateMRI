% draw the benign and noise masks looking at the key images
% 1/22/2023
% Author: Batuhan Gundogdu
% Use this function to draw cancer masks on the relevant slices
% Make sure to change the address and the relevant slice range in the for
% loop
% the benign masks are saved them as MATLAB files
% you can get only one ROI of benign tissue and a noise ROI from one slice
%% change the address for the current patient
clc
clear
close all
foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat104";
load(fullfile(foldername, "pat104_hybridSortedInput.mat"))
benign_mask = zeros(128, 128, size(hybrid_data,3));
noise_mask = zeros(128, 128, size(hybrid_data,3));
bb = [0, 150, 1000, 1500];
figure
for slice=15:15 % make sure to select one slice only
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
    title(["Slice :", num2str(slice), "Draw a benign ROI with GREEN"])
    colormap('gray')
    hold on
    movegui("center")
    roi = drawfreehand(gca,"Color",'g');
    mask = roi.createMask(adc);
    mask = imresize(mask, 1/16,'bilinear');
    benign_mask(:,:, slice) = mask;
    img2 = squeeze(hybrid_data(:, :, slice, 1, 1));
    close all
    imagesc(img2);
    axis('off')
    title(["Slice :", num2str(slice), "Draw a noise ROI with BLUE"])
    colormap('gray')
    movegui("center")
    roi = drawfreehand(gca,"Color",'b');
    noise = roi.createMask(img2);
    noise_mask(:,:, slice) = noise;
end

filename = fullfile(foldername, 'benign_mask.mat');
save(filename, 'benign_mask')
filename = fullfile(foldername, 'noise_mask.mat');
save(filename, 'noise_mask')
disp('Done')