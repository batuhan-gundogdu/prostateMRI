% Script for getting Prostate Masks
clc
clear
close all
foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat083";
load(fullfile(foldername, "pat083_hybridSortedInput.mat"))
benign_mask = zeros(128, 128, size(hybrid_data,3));
bb = [0, 150, 1000, 1500];
figure
for slice=16:19
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
    roi = drawfreehand(gca,"Color",'g');
    mask = roi.createMask(adc);
    mask = imresize(mask, 1/16,'bilinear');
    benign_mask(:,:, slice) = mask;
    %pass = input("press key to pass");
    %hold off
end

filename = fullfile(foldername, 'benign_mask.mat');
save(filename, 'benign_mask')
disp(strcat(filename, ' saved!'))