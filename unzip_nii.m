main_dir = '/home/usuario/disco1/CarpetasPersonales/seba';
files = dir([main_dir, '/data/sub*']);

for i=1:length(files)
    disp(i)                                                                      %acá le cambias anat o func
   [status, cmdout] = system(['gzip -k -d ', main_dir, '/data/', files(i).name, '/anat/', files(i).name, '_T1w.nii.gz']);
end