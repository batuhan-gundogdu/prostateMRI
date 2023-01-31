clc
clear
close all

foldername = "C:\Users\mrirc\Desktop\Master Data\IRB17\pat065";
load(fullfile(foldername, "master.mat"))
num_cancers = 2;
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
        bw = edge(cancer_mask(:,:, slice));
        I = mat2gray(bw, [0 1]);
        I_s_rs = I.*0.70;
        rgbI = cat(3, I_s_rs+0.3,I_s_rs,I_s_rs+0.3);

        hold on
        image(rgbI,'AlphaData',I)
        subplot(122)
        imagesc(adc, [0.3, 3]);
        axis('off')
        colormap('gray')

        movegui("center")
        changed_the_previous = 1;
        for j=1:num_cancers
            roi = drawfreehand(gca,"Color",'g');
            mask = roi.createMask(adc);
            if sum(sum(mask))
                if changed_the_previous
                    changed_the_previous = 0;
                    cancer_mask = zeros(128, 128, size(hybrid_data,3));
                end
                cancer_mask(:,:, slice) = cancer_mask(:,:, slice) + mask;
            end
        end

    end

end
close all
verified = 1;
save(fullfile(foldername, "master.mat"), "-v7.3")
