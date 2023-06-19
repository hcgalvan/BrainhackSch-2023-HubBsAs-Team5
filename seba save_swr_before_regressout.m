%este script guarda los archivos swau... antes de correr el regress out y
%los guarda en /smooth

sessions_dir = '/home/usuario/disco1/CarpetasPersonales/seba/data/';
sessions = dir(sessions_dir);
sessions(1:2) = [];

conditions = {'cond1'};
condition_names = {'reposo'};

for s=1:length(sessions)
    disp(sessions(s).name)
    for c=1:4
        path_to_condition = strcat(sessions_dir,'/',sessions(s).name,'/functional/',conditions(c));
        cd(char(path_to_condition))
        mkdir smooth
        copyfile(char(strcat(path_to_condition, '/nii/swau', condition_names(c), '.nii')), char(strcat(path_to_condition, '/smooth/')))
    end
end
