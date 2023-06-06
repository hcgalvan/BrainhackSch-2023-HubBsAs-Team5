clc,clear

main_dir = '/home/usuario/disco1/CarpetasPersonales/seba';
seed_dir = '/home/usuario/disco1/CarpetasPersonales/seba/scripts/seed analysis/mask';
results_dir = '/home/usuario/disco1/proyectos/2023-resting-state-estados-fMRI_conn/results/seed/mask';
session_list = dir('/home/usuario/disco1/proyectos/2023-resting-state-estados-fMRI_conn/data/sub01');
session_list(1:2) = [];

seed_name = 'sphere_5-1_55_-3';
seed_header = spm_vol([seed_dir, '/', seed_name, '.nii']);
seed_mask = spm_read_vols(seed_header);
seed_mask = logical(reshape(seed_mask, 1, 91*109*91));


%cargar una funcional
rest_header = spm_vol('/home/usuario/disco1/CarpetasPersonales/seba/resultados/rest/niftiDATA_Subject001_Condition000.nii')
read = spm_read_vols(rest_header);
read = reshape(read,91*109*91,152);
reading = read;
reading = mean(reading(seed_mask, :));
correlation = corr(reading',read');
correlation_cerebro = reshape(correlation, 91, 109, 91);

%exportar como nii
header_exportar = rest_header(1);
header_exportar.fname = 'correlation_seed_sujeto_1.nii';
spm_write_vol(header_exportar, correlation_cerebro);


%cargar otra funcional