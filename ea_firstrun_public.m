function ea_firstrun(handles)

% check if a newer version is available..
local=ea_getvsn('local',1);
web=ea_getvsn('web',1);
if strcmp(local,'Unknown')
    vcheck=1;
else
    vcheck=(local<web);
end

if vcheck
    set(handles.updatebutn,'Visible','on');
    set(handles.updatebutn,'BackgroundColor',[0.2,0.8,0.2]);
else
    set(handles.updatebutn,'Visible','off');
end

options=struct;
options.prefs=ea_prefs(options);
if ~isfield(options.prefs,'firstrun') % first run.
    fprintf(['Welcome to LEAD-DBS.\n \n',...
        'This seems to be your first run of the toolbox.\n',...
        'Please be aware that the toolbox comes without atlases which you have to\n',...
        'generate yourself based on nifti data. The process is quite easy:\n',...
        'Simply put nifti images into a folder named "atlases" inside your LEAD \n',...
        'installation directory.\n\n',...
        'The structure of the atlases directory should be as the following:\n',...
        '+ lead installation folder \n',...
        '   + atlases \n',...
        '        + atlas-set-1 (you can name this folder as you wish, e.g. "basal ganglia") \n',...
        '            + lh (put left-hemisphere atlases inside this folder) \n',...
        '                 atlas-file-1.nii (could be named "STN.nii") \n',...
        '                 atlas-file-2.nii (could be named "GPi.nii") \n',...
        '                 ... \n',...
        '            + rh (put right-hemisphere atlases inside this folder) \n',...
        '                 atlas-file-1.nii (could be named "STN.nii") \n',...
        '                 atlas-file-2.nii (could be named "GPi.nii") \n',...
        '                 ... \n',...
        '            + mixed (put atlases with separated structures on each hemisphere inside this folder) \n',...
        '                 atlas-file-1.nii (could be named "STN.nii") \n',...
        '                 atlas-file-2.nii (could be named "GPi.nii") \n',...
        '                 ... \n',...
        '            + midline (put atlases with non-separated inside this folder) \n',...
        '                 atlas-file-1.nii (could be named "SubCallosalCortex.nii") \n',...
        '                 atlas-file-2.nii (could be named "Cg25.nii") \n',...
        '                 ... \n',...
        '        + atlas-set-2\n',...
        '            ... \n',...
        '        ... \n \n',...
        'After putting atlas files inside the directory, you can choose which atlas-set you \n',...
        'wish to visualize alongside the trajectory reconstructions using the dropdown-menu \n',...
        'of the toolbox. \n',...
        'A script that can convert the FSL Harvard-Oxford atlas is supplied inside the \n',...
        'lead/support_scripts directory. However, since the HO-Atlas does not differentiate between \n',...
        'GPi and GPe, we recommend to gather different atlas sets from responsible authors \n',...
        'Suggestions are to obtain an MNI-version of the Morel atlas (Jakab 2012) or the \n',...
        'BGHAT atlas (Prodoehl 2008). \n \n \n',...
        'To start with your first reconstruction, create a folder for a patient and put either MR files \n',...
        'or CT files inside of it. \n',...
        'Naming of the files should be as the following: \n \n',...
        'MR images: \n',...
        '+ patient_directory \n',...
        '    + tra.nii (for an unnormalized version of a transversal postoperative image, i.e. in native space). \n',...
        '    + cor.nii (for an unnormalized version of a coronal postoperative image). \n',...
        '    + sag.nii (for an unnormalized version of a coronal postoperative image). \n',...
        '    + pre_tra.nii (for an unnormalized version of a preoperative image). \n \n',...
        'If you only have one postoperative image, you should name that one tra.nii and omit the rest. \n',...
        'If you only have postoperative images, this should work as well, however normalization has to be \n',...
        'performed on the postoperative version, which is probably not too accurate. \n \n',...
        'If you want to start off with normalized images, just put an l prefix in front of the images. \n',...
        'Please note that LEAD-DBS might modify the normalized images, so please always use copies of your \n',...
        'original data. \n \n',...
        'CT images: \n',...
        '+ patient_directory \n',...
        '    + lfusion.nii (for a normalized version of the postoperative CT or fused image). \n',...
        '    + lpre_tra.nii (for a normalized version of the preoperative MRI image). \n \n',...
        'It is not recommended to use LEAD DBS for normalizing CT-images as of now. There is limited \n',...
        'functionality implemented in case you want to try that out. \n \n',...
        'Most naming-conventions can be modified by editing the file ea_prefs.m \n',...
        'However sticking to the given naming-conventions might make it easier e.g. to work on collaborations. \n \n',...
        'We hope that you enjoy using the LEAD toolbox. \n \n',...
        'Any suggestions are more than welcome (andreas.horn@charite.de). \n'
        ]);

    fid = fopen([fileparts(which('lead')),filesep,'ea_prefs.m'],'a');
    fwrite(fid,sprintf(['prefs.firstrun=','''','off','''','; \n']));
    fclose(fid);

end
