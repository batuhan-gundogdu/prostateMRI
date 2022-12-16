% define the filenames
clc
close all;
clear

%% change the following folder addresses
patient_folder = 'C:\Users\mrirc\Desktop\Deep_Learning_Dataset\IRB17-1694 Pt 083\Guo_Rawdata\2021_08_24\RO_26421';
master_directory = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat083';
%%
scans = containers.Map();

listOfFiles = dir(patient_folder);
for f=1:length(listOfFiles)
    filename = listOfFiles(f).name;
    if endsWith(filename, 'senserefscanV4.raw')
        refscan = filename;
    elseif endsWith(filename, 'coilsurveyscanV4.raw')
        coilsurveyscan = filename;
    elseif endsWith(filename, 'te057_4bV4.raw')
        scans('HM57.mat') = filename;
    elseif endsWith(filename, 'te070_4bV4.raw')
        scans('HM70.mat') = filename;
    elseif endsWith(filename, 'te150_4bV4.raw')
        scans('HM150.mat') = filename;
    elseif endsWith(filename, 'te200_4bV4.raw')
        scans('HM200.mat') = filename;
    elseif endsWith(filename, 'dwi_max_4bV4.raw')
        scans('DWI.mat') = filename;
        

    end
end
refscan = fullfile(patient_folder, refscan);
coilsurveyscan = fullfile(patient_folder, coilsurveyscan);
%%

for k = keys(scans)
    key = k{1};
    scan = scans(key)
    scan = fullfile(patient_folder, scan);
    disp('Reading Raw Files')
    S = MRsense(refscan, scan, coilsurveyscan);
    S.Perform;
    r = MRecon(scan);
    r.Parameter.Recon.Sensitivities = S;
    r.Parameter.Parameter2Read.typ = 1;
    r.ReadData;
    r.RandomPhaseCorrection;
    r.PDACorrection;
    r.DcOffsetCorrection;
    r.MeasPhaseCorrection;
    r.Parameter.Recon.ImmediateAveraging = 'no';
    r.SortData;
    disp('k-space finalized')
    r.GridData;
    r.RingingFilter;
    r.ZeroFill;
    r.K2IM;
    r.EPIPhaseCorrection;
    r.K2IP;
    disp('x-space created')
    r.GridderNormalization;
    r.SENSEUnfold;
    r.PartialFourier;
    r.ConcomitantFieldCorrection;
    r.DivideFlowSegments;
    %r.CombineCoils;
    %r.Average;
    r.GeometryCorrection;
    r.RemoveOversampling;
    r.FlowPhaseCorrection;
    r.ReconTKE;
    r.ZeroFill;
    r.RotateImage;
    disp('x-space finalized')
    raw = squeeze(abs(r.Data));
    mat_address = fullfile(master_directory, key);
    save(mat_address, 'raw')
end
disp('Done!')