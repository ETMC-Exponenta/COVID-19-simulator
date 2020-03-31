function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
dev = VirusPropagationDev;
dev.test('', false);
% Post-install commands
cd('..');
ext = VirusPropagationExtender;
ext.doc;
% Add your post-install commands below