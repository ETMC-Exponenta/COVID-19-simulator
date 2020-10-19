function gen_doc
DU = DocUtils;
p = currentProject;
DU.convertMlx(fullfile(p.RootFolder, 'doc'));