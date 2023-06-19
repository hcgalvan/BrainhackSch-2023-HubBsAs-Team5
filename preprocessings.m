function preprocessing()


try spm quit; end
display 'start'

% =========================================================================
%                        LOCATE THE DATA TO BE USED
% =========================================================================
spm_path = '/home/usuario/disco1/toolboxes/spm12/';
addpath('/home/usuario/disco1/CarpetasPersonales/seba/data');

addpath(spm_path)
MAIN_DIRECTORY = '/home/usuario/disco1/CarpetasPersonales/seba';

cd (fullfile(MAIN_DIRECTORY,'data'));

regexp_func    = '^*\.nii';
regexp_anat    = '.nii';

% =========================================================================
%                         PREPROCESSING PARAMETERS
% =========================================================================

smoothing_kernel        = [5 5 5];
TR                      = 2.0;
nslices                 = 36; 
TA                      = TR * (1-1/nslices);
nSubj                   = 5;
refslice                = 24;
slice_order             = [2:2:36,1:2:35];
voxel_size              = [3 3 3];   %  [1 0.488 0.488];
% =========================================================================
%                           INITIALIZE SPM
% =========================================================================

spm('defaults', 'FMRI');
spm_jobman('initcfg');


% =========================================================================
%                            GET DATA FILES
% =========================================================================
sub_files = dir([MAIN_DIRECTORY, '/data/sub*']);

subjectsXsession = 0; % counter for subjects x session

subNames = {sub_files};
nSubj = length(subNames); %use subjects as sessions 
sessionNames = {'anat', 'func'};
maxSess = length(sessionNames);



for iSub = 1%:length(sub_files)
    fprintf('\n');
    fprintf('Read data for Subject %d\n',iSub);
                                            
    subjdir = fullfile(MAIN_DIRECTORY, 'data', ['sub-*']);
    funcfiles = cell(1,1);
    for iSess = 1:maxSess
        disp(' ')
        fprintf('Data loading (%d/%d)\n',iSess,maxSess)
        
        subjectsXsession = subjectsXsession + 1;  % one session is considered one independent subject
        
        anatdir     =  fullfile(subjdir, 'anat');
        exp_anat = [sub_files(iSub).name, '_T1w.nii'];
        
        %delete([MAIN_DIRECTORY, '/data/', sub_files(iSub).name, '/anat/', sub_files(iSub).name, '_T1w.nii.gz']) 
        anatfile    = spm_select('FPList', anatdir, exp_anat);
        
        if isequal(anatfile,  '') || not(exist(anatfile))
            error('No T1 file')
        end
        
        fdir    =  fullfile(subjdir, 'func', sessionNames{iSess});
        ffiles  = spm_select('List', fdir, regexp_func);
        nFiles    = size(ffiles,1);
        
        if nFiles == 0
            error('No functional file')
        end
        cffiles = cellstr(ffiles);
        
        for iFiles = 1:nFiles
            funcfiles{iFiles,1} = spm_select('ExtFPList', fdir, ['^', cffiles{iFiles}], Inf);
        end
        
        
        clear matlabbatch
        
        % =========================================================================
        %                            PREPROCESS_JOB
        % =========================================================================
        
        display 'Creating preprocessing job'
        
        %Slice timing
        % ======================
        
        display 'Slice timing'
        matlabbatch{1}.spm.temporal.st.scans                    = {funcfiles};
        matlabbatch{1}.spm.temporal.st.nslices                  = nslices;
        matlabbatch{1}.spm.temporal.st.tr                       = TR;
        matlabbatch{1}.spm.temporal.st.ta                       = TA;
        matlabbatch{1}.spm.temporal.st.so                       = slice_order;
        matlabbatch{1}.spm.temporal.st.refslice                 = refslice;
        matlabbatch{1}.spm.temporal.st.prefix                   = 'a';
        
        % Realign
        % ======================
        
        matlabbatch{2}.spm.spatial.realign.estimate.data{1}(1)          = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.quality    = 0.9;
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.sep        = 4;
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.fwhm       = 5;
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.rtm        = 1;
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.interp     = 2;
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.wrap       = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estimate.eoptions.weight     = '';
        
        matlabbatch{3}.spm.spatial.realign.write.data(1)                = cfg_dep('Realign: Estimate: Realigned Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
        matlabbatch{3}.spm.spatial.realign.write.roptions.which         = [2 1];
        matlabbatch{3}.spm.spatial.realign.write.roptions.interp        = 4;
        matlabbatch{3}.spm.spatial.realign.write.roptions.wrap          = [0 0 0];
        matlabbatch{3}.spm.spatial.realign.write.roptions.mask          = 1;
        matlabbatch{3}.spm.spatial.realign.write.roptions.prefix        = 'r';
        
        
        %Coregister
        % ======================
        display 'Coregister'
        matlabbatch{4}.spm.spatial.coreg.estimate.ref(1)                = cfg_dep('Realign: Reslice: Mean Image', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
        matlabbatch{4}.spm.spatial.coreg.estimate.source                = {[anatfile,',1']};
        matlabbatch{4}.spm.spatial.coreg.estimate.other                 = {''};
        matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.cost_fun     = 'nmi';
        matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.sep          = [4 2];
        matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.tol          = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.fwhm         = [7 7];
        
        matlabbatch{5}.spm.spatial.preproc.channel.vols                 = {[anatfile,',1']};
        matlabbatch{5}.spm.spatial.preproc.channel.biasreg              = 0.001;
        matlabbatch{5}.spm.spatial.preproc.channel.biasfwhm             = 60;
        matlabbatch{5}.spm.spatial.preproc.channel.write                = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(1).tpm                = {sprintf('%s/tpm/TPM.nii,1', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(1).ngaus              = 1;
        matlabbatch{5}.spm.spatial.preproc.tissue(1).native             = [1 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(1).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(2).tpm                = {sprintf('%s/tpm/TPM.nii,2', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(2).ngaus              = 1;
        matlabbatch{5}.spm.spatial.preproc.tissue(2).native             = [1 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(2).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(3).tpm                = {sprintf('%s/tpm/TPM.nii,3', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(3).ngaus              = 2;
        matlabbatch{5}.spm.spatial.preproc.tissue(3).native             = [1 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(3).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(4).tpm                = {sprintf('%s/tpm/TPM.nii,4', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(4).ngaus              = 3;
        matlabbatch{5}.spm.spatial.preproc.tissue(4).native             = [1 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(4).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(5).tpm                = {sprintf('%s/tpm/TPM.nii,5', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(5).ngaus              = 4;
        matlabbatch{5}.spm.spatial.preproc.tissue(5).native             = [1 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(5).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(6).tpm                = {sprintf('%s/tpm/TPM.nii,6', spm_path)};
        matlabbatch{5}.spm.spatial.preproc.tissue(6).ngaus              = 2;
        matlabbatch{5}.spm.spatial.preproc.tissue(6).native             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.tissue(6).warped             = [0 0];
        matlabbatch{5}.spm.spatial.preproc.warp.mrf                     = 1;
        matlabbatch{5}.spm.spatial.preproc.warp.cleanup                 = 1;
        matlabbatch{5}.spm.spatial.preproc.warp.reg                     = [0 0.001 0.5 0.05 0.2];
        matlabbatch{5}.spm.spatial.preproc.warp.affreg                  = 'mni';
        matlabbatch{5}.spm.spatial.preproc.warp.fwhm                    = 0;
        matlabbatch{5}.spm.spatial.preproc.warp.samp                    = 3;
        matlabbatch{5}.spm.spatial.preproc.warp.write                   = [0 0];
        
        % Normalise
        % ======================
        display 'Spatial normalise'
        matlabbatch{6}.spm.spatial.normalise.estwrite.subj.vol(1)       = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
        matlabbatch{6}.spm.spatial.normalise.estwrite.subj.resample(1)  = cfg_dep('Realign: Reslice: Resliced Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.biasreg  = 0.0001;
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.tpm      = {sprintf('%s/tpm/TPM.nii', spm_path)};
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.affreg   = 'mni';
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.fwhm     = 0;
        matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.samp     = 3;
        matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.bb       = [-78 -112 -70
            78 76 85];
        matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.vox      = voxel_size;
        matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.interp   = 4;
        matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.prefix   = 'w';
        
        % Smooth
        % ======================
        display 'Spatial smooth'
        matlabbatch{7}.spm.spatial.smooth.data(1)                       = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{7}.spm.spatial.smooth.fwhm                          = smoothing_kernel;
        matlabbatch{7}.spm.spatial.smooth.dtype                         = 0;
        matlabbatch{7}.spm.spatial.smooth.im                            = 0;
        matlabbatch{7}.spm.spatial.smooth.prefix                        = 's';
        
        
               
        % ======================        
        matfile                 = sprintf('%s/%s/preprocess_%s_%s.mat',MAIN_DIRECTORY,'scripts/preprocesamiento/preprocessing_batchs', subNames{iSub}, sessionNames{iSess});
        save(matfile,'matlabbatch');
        jobs{subjectsXsession}  = matfile;
    end   
end
spm_jobman('run', jobs);


