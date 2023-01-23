% draw the prostate masks for the whole prostate and TZ
% 1/22/2023
% Author: Batuhan Gundogdu
% Use this function to draw prostate masks on the relevant slices
% Make sure to change the address and the relevant slice range in the for
% loop
% the prostate masks are saved them as MATLAB files
%% change the address for the current patient
close all
clear
clc
foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat083";
load(fullfile(foldername, "pat083_hybridSortedInput.mat"))
prostate_mask = zeros(128, 128, size(hybrid_data,3));

figure
for slice=5:20
    img = squeeze(hybrid_data(:, :, slice, 1, 1));
    norm_img = (img-mean(img(:)))/std(img(:));
    img2 = norm_img;
    img2(norm_img>5) = 0;
    img2(img2==0) = max(img2(:));
    img2 = imresize(img2,16,'bilinear');
    imagesc(img2);
    axis('off')
    title(["Slice :", num2str(slice), "Draw Prostate with BLUE, press ESC to skip"])
    colormap('gray')
    hold on
    
    movegui("center")
    roi = drawfreehand(gca,"Color",'b');
    prostate = roi.createMask(img2);
    prostate = imresize(prostate, 1/16,'bilinear');
    prostate_mask(:,:, slice) = prostate;
    title(["Slice :", num2str(slice), "Draw TZ with RED, press ESC to skip"])
    movegui("center")
    roi = drawfreehand(gca,"Color",'r');
    TZ = roi.createMask(img2);
    TZ = imresize(TZ, 1/16,'bilinear');
    prostate_mask(:,:, slice) = prostate_mask(:,:, slice) + TZ;
end

filename = fullfile(foldername, 'prostate_mask.mat');
save(filename, 'prostate_mask')
disp(strcat(filename, ' saved!'))