% Script for getting Prostate Masks
clc
clear
close all
foldername = "C:\Users\Gundogdu\Desktop\University of Chicago\PATIENT_DATA\IRB17\pat083";
load(fullfile(foldername, "master.mat"))
noise_mask = zeros(128, 128, size(hybrid_data,3));
bb = [0, 150, 1000, 1500];
figure
for slice=9:size(hybrid_data,3)-5
    img2 = squeeze(hybrid_data(:, :, slice, 1, 1));
    img2 = imresize(img2,16,'bilinear');
    imagesc(img2);
    axis('off')
    title(["Slice ", num2str(slice)])
    colormap('gray')
    hold on
    movegui("center")
    roi = drawfreehand(gca,"Color",'b');
    mask = roi.createMask(img2);
    mask = imresize(mask, 1/16,'bilinear');
    noise_mask(:,:, slice) = mask;
    %pass = input("press key to pass");
    %hold off
end
filename = "C:\Users\Gundogdu\Desktop\University of Chicago\PATIENT_DATA\IRB17\pat083\pat083_noise_mask.mat";

save(filename, 'noise_mask')
disp(strcat(filename, ' saved!'))