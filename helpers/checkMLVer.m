function checkMLVer()
%% Check MATLAB version
if VirusPropagationDev.mlver() < 9.85
    warning('Project was developed in MATLAB R2020a and will not work properly in older releases');
end