








data_dir = '/home/usuario/disco1/CarpetasPersonales/seba/data/sub*';  % Ruta al directorio que contiene los archivos funcionales
file_extension = '*.nii.gz';  % Extensión de los archivos funcionales, por ejemplo, '*.nii' para archivos NIfTI

% Obtener la lista de archivos funcionales en el directorio
files = dir(fullfile(data_dir, file_extension));

if isempty(files)
    disp('No se encontraron archivos funcionales en el directorio especificado.');
else
    % Extraer los nombres de los archivos funcionales
    functional_files = {files.name};  % Crea una celda con los nombres de los archivos funcionales

    % Imprimir los nombres de los archivos funcionales
    for i = 1:numel(functional_files)
        disp(functional_files{i});
    end
end

% Define a directory name
dir_name = 'sub-01_task-rest_bold';

% Use regular expressions to extract the subject ID or name
match = regexp(dir_name, '^sub-[a-zA-Z0-9]+', 'match');

% Display the subject ID or name
disp(match);
