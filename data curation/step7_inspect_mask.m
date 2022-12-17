clc
clear
close all

foldername = "C:\Users\Gundogdu\Desktop\University of Chicago\PATIENT_DATA\IRB17\pat083";
load(fullfile(foldername, "master.mat"))

bb = [0, 150, 1000, 1500];
for slice=1:size(hybrid_data,3)
    if sum(sum(cancer_mask(:,:, slice)))
        img2 = squeeze(hybrid_data(:, :, slice, :, 1));
        adc = zeros(128);
        for row=1:128
            for col=1:128
                val = polyfit(bb(1:end)/1000, log(img2(row, col, :)), 1);
                adc(row,col) = -val(1);
            end
        end
        subplot(121)
        imagesc(adc, [0.3, 3]);
        axis('off')
        sgtitle(["Slice ", num2str(slice)])
        colormap('gray')
        subplot(122)
        imagesc(adc, [0.3, 3]);
        axis('off')
        colormap('gray')
        bw = edge(cancer_mask(:,:, slice));
        I = mat2gray(bw, [0 1]);
        I_s_rs = I.*0.70;
        rgbI = cat(3, I_s_rs+0.3,I_s_rs,I_s_rs+0.3);
        hold on
        image(rgbI,'AlphaData',I)
        roi = drawfreehand(gca,"Color",'g');
        mask = roi.createMask(adc);
        if sum(sum(mask))
            cancer_mask(:,:, slice) = mask;
        end

    end

end
verified = True;
save(fullfile(foldername, "master.mat"), "-v7.3")
