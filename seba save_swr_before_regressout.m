%este script guarda los archivos swau... antes de correr el regress out y
%los guarda en /smooth

sessions_dir = '/home/usuario/disco1/proyectos/2023-resting-state-estados-fMRI_conn/data/sub01';
sessions = dir(sessions_dir);
sessions(1:2) = [];

conditions = {'cond1', 'cond2', 'cond3', 'cond4'};
condition_names = {'reposo', 'transicion', 'alteracion', 'recuperacion'};

for s=1:length(sessions)
    disp(sessions(s).name)
    for c=1:4
        path_to_condition = strcat(sessions_dir,'/',sessions(s).name,'/functional/',conditions(c));
        cd(char(path_to_condition))
        mkdir smooth
        copyfile(char(strcat(path_to_condition, '/nii/swau', condition_names(c), '.nii')), char(strcat(path_to_condition, '/smooth/')))
    end
end
