function ea_apply_normalization(options)
% This is a function that simply applies normalization parameters (y_ea_normparams.nii) to the
% unnormalized files.
%
% This function uses resize_img.m authored by Ged Rigdway
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn

% Apply estimated deformation to (coregistered) post-op data.

directory=[options.root,options.patientname,filesep];
[whichnormmethod]=ea_whichnormmethod(directory);

switch whichnormmethod

    case {'ea_normalize_ants','ea_normalize_ants_brainsfit'}

        ea_ants_applytransforms(options);

    otherwise

        switch spm('ver')

            case 'SPM8'
                matlabbatch{1}.spm.util.defs.comp{1}.def = {[options.root,options.patientname,filesep,'y_ea_normparams.nii']};
                matlabbatch{1}.spm.util.defs.ofname = '';

                postops={options.prefs.tranii_unnormalized,options.prefs.cornii_unnormalized,options.prefs.sagnii_unnormalized,options.prefs.prenii_unnormalized,options.prefs.ctnii_coregistered};
                cnt=1;
                for postop=1:length(postops)
                    if exist([options.root,options.patientname,filesep,postops{postop}],'file')
                        matlabbatch{1}.spm.util.defs.fnames{cnt}=[options.root,options.patientname,filesep,postops{postop},',1'];
                        cnt=cnt+1;
                    end
                end

                matlabbatch{1}.spm.util.defs.savedir.saveusr = {[options.root,options.patientname,filesep]};
                matlabbatch{1}.spm.util.defs.interp = 1;
                jobs{1}=matlabbatch;
                cfg_util('run',jobs);
                clear matlabbatch jobs;

                % rename files:
                try copyfile([options.root,options.patientname,filesep,'w',options.prefs.prenii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gprenii]); end
                try movefile([options.root,options.patientname,filesep,'w',options.prefs.prenii_unnormalized],[options.root,options.patientname,filesep,options.prefs.prenii]); end
                try copyfile([options.root,options.patientname,filesep,'w',options.prefs.tranii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gtranii]); end
                try movefile([options.root,options.patientname,filesep,'w',options.prefs.tranii_unnormalized],[options.root,options.patientname,filesep,options.prefs.tranii]); end
                try copyfile([options.root,options.patientname,filesep,'w',options.prefs.cornii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gcornii]); end
                try movefile([options.root,options.patientname,filesep,'w',options.prefs.cornii_unnormalized],[options.root,options.patientname,filesep,options.prefs.cornii]); end
                try copyfile([options.root,options.patientname,filesep,'w',options.prefs.sagnii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gsagnii]); end
                try movefile([options.root,options.patientname,filesep,'w',options.prefs.sagnii_unnormalized],[options.root,options.patientname,filesep,options.prefs.sagnii]); end
                try copyfile([options.root,options.patientname,filesep,'w',options.prefs.ctnii_coregistered],[options.root,options.patientname,filesep,options.prefs.gctnii]); end
                try movefile([options.root,options.patientname,filesep,'w',options.prefs.ctnii_coregistered],[options.root,options.patientname,filesep,options.prefs.ctnii]); end
            case 'SPM12'

                % export lfiles (fine resolution, small bounding box.
                postops={options.prefs.tranii_unnormalized,options.prefs.cornii_unnormalized,options.prefs.sagnii_unnormalized,options.prefs.prenii_unnormalized,options.prefs.ctnii_coregistered};

                for postop=1:length(postops)
                    if exist([options.root,options.patientname,filesep,postops{postop}],'file') && ~strcmp(postops{postop},options.prefs.rawctnii_unnormalized)
                        nii=ea_load_untouch_nii([options.root,options.patientname,filesep,postops{postop}]);
                        gaussdim=abs(nii.hdr.dime.pixdim(2:4));
                        if mean(gaussdim>1)
                            resize_img([options.root,options.patientname,filesep,postops{postop}],gaussdim./2,nan(2,3),0);
                        else
                            copyfile([options.root,options.patientname,filesep,postops{postop}],[options.root,options.patientname,filesep,'r',postops{postop}]);
                        end

                        %gaussdim=abs(gaussdim(1:3)).*2;
                        matlabbatch{1}.spm.util.defs.comp{1}.def = {[options.root,options.patientname,filesep,'y_ea_inv_normparams.nii']};
                        matlabbatch{1}.spm.util.defs.out{1}.push.fnames{1}=[options.root,options.patientname,filesep,'r',postops{postop},''];
                        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
                        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {[options.root,options.patientname,filesep]};
                        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [-55 45 9.5; 55 -65 -25];
                        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [0.22 0.22 0.22];
                        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
                        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = gaussdim;
                        jobs{1}=matlabbatch;
                        cfg_util('run',jobs);
                        clear matlabbatch jobs;

                    end
                end


                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.prenii_unnormalized],[options.root,options.patientname,filesep,options.prefs.prenii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.tranii_unnormalized],[options.root,options.patientname,filesep,options.prefs.tranii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.cornii_unnormalized],[options.root,options.patientname,filesep,options.prefs.cornii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.sagnii_unnormalized],[options.root,options.patientname,filesep,options.prefs.sagnii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.ctnii_coregistered],[options.root,options.patientname,filesep,options.prefs.ctnii]); end

                % export glfiles (a bit more coarse resolution, full brain bounding box.

                for postop=1:length(postops)
                    if exist([options.root,options.patientname,filesep,postops{postop}],'file') && ~strcmp(postops{postop},options.prefs.rawctnii_unnormalized)
                        nii=ea_load_untouch_nii([options.root,options.patientname,filesep,postops{postop}]);
                        gaussdim=abs(nii.hdr.dime.pixdim(2:4));
                        %gaussdim=abs(gaussdim(1:3)).*2;
                        matlabbatch{1}.spm.util.defs.comp{1}.def = {[options.root,options.patientname,filesep,'y_ea_inv_normparams.nii']};
                        matlabbatch{1}.spm.util.defs.out{1}.push.fnames{1}=[options.root,options.patientname,filesep,'r',postops{postop},''];
                        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
                        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {[options.root,options.patientname,filesep]};
                        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [-78 -112 -50; 78 76 85];
                        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [0.5 0.5 0.5];
                        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
                        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = gaussdim;
                        jobs{1}=matlabbatch;
                        cfg_util('run',jobs);
                        clear matlabbatch jobs;
                    end
                end

                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.prenii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gprenii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.tranii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gtranii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.cornii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gcornii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.sagnii_unnormalized],[options.root,options.patientname,filesep,options.prefs.gsagnii]); end
                try movefile([options.root,options.patientname,filesep,'swr',options.prefs.ctnii_coregistered],[options.root,options.patientname,filesep,options.prefs.gctnii]); end
                try delete([options.root,options.patientname,filesep,'r',options.prefs.prenii_unnormalized]); end
                if ~strcmp(options.prefs.tranii_unnormalized,options.prefs.rawctnii_unnormalized)
                    try delete([options.root,options.patientname,filesep,'r',options.prefs.tranii_unnormalized]); end
                end
                try delete([options.root,options.patientname,filesep,'r',options.prefs.cornii_unnormalized]); end
                try delete([options.root,options.patientname,filesep,'r',options.prefs.sagnii_unnormalized]); end
        end

end



function resize_img(imnames, Voxdim, BB, ismask)
%  resize_img -- resample images to have specified voxel dims and BBox
% resize_img(imnames, voxdim, bb, ismask)
%
% Output images will be prefixed with 'r', and will have voxel dimensions
% equal to voxdim. Use NaNs to determine voxdims from transformation matrix
% of input image(s).
% If bb == nan(2,3), bounding box will include entire original image
% Origin will move appropriately. Use world_bb to compute bounding box from
% a different image.
%
% Pass ismask=true to re-round binary mask values (avoid
% growing/shrinking masks due to linear interp)
%
% See also voxdim, world_bb

% Based on John Ashburner's reorient.m
% http://www.sph.umich.edu/~nichols/JohnsGems.html#Gem7
% http://www.sph.umich.edu/~nichols/JohnsGems5.html#Gem2
% Adapted by Ged Ridgway -- email bugs to drc.spm@gmail.com

% This version doesn't check spm_flip_analyze_images -- the handedness of
% the output image and matrix should match those of the input.

% Check spm version:
if exist('spm_select','file') % should be true for spm5
    spm5 = 1;
elseif exist('spm_get','file') % should be true for spm2
    spm5 = 0;
else
    ea_error('Can''t find spm_get or spm_select; please add SPM to path')
end

spm_defaults;

% prompt for missing arguments
if ( ~exist('imnames','var') || isempty(char(imnames)) )
    if spm5
        imnames = spm_select(inf, 'image', 'Choose images to resize');
    else
        imnames = spm_get(inf, 'img', 'Choose images to resize');
    end
end
% check if inter fig already open, don't close later if so...
Fint = spm_figure('FindWin', 'Interactive'); Fnew = [];
if ( ~exist('Voxdim', 'var') || isempty(Voxdim) )
    Fnew = spm_figure('GetWin', 'Interactive');
    Voxdim = spm_input('Vox Dims (NaN for "as input")? ',...
        '+1', 'e', '[nan nan nan]', 3);
end
if ( ~exist('BB', 'var') || isempty(BB) )
    Fnew = spm_figure('GetWin', 'Interactive');
    BB = spm_input('Bound Box (NaN => original)? ',...
        '+1', 'e', '[nan nan nan; nan nan nan]', [2 3]);
end
if ~exist('ismask', 'var')
    ismask = false;
end
if isempty(ismask)
    ismask = false;
end

% reslice images one-by-one
vols = spm_vol(imnames);
for V=vols'
    % (copy to allow defaulting of NaNs differently for each volume)
    voxdim = Voxdim;
    bb = BB;
    % default voxdim to current volume's voxdim, (from mat parameters)
    if any(isnan(voxdim))
        vprm = spm_imatrix(V.mat);
        vvoxdim = vprm(7:9);
        voxdim(isnan(voxdim)) = vvoxdim(isnan(voxdim));
    end
    voxdim = voxdim(:)';

    mn = bb(1,:);
    mx = bb(2,:);
    % default BB to current volume's
    if any(isnan(bb(:)))
        vbb = world_bb(V);
        vmn = vbb(1,:);
        vmx = vbb(2,:);
        mn(isnan(mn)) = vmn(isnan(mn));
        mx(isnan(mx)) = vmx(isnan(mx));
    end

    % voxel [1 1 1] of output should map to BB mn
    % (the combination of matrices below first maps [1 1 1] to [0 0 0])
    mat = spm_matrix([mn 0 0 0 voxdim])*spm_matrix([-1 -1 -1]);
    % voxel-coords of BB mx gives number of voxels required
    % (round up if more than a tenth of a voxel over)
    imgdim = ceil(mat \ [mx 1]' - 0.1)';

    % output image
    VO            = V;
    [pth,nam,ext] = fileparts(V.fname);
    VO.fname      = fullfile(pth,['r' nam ext]);
    VO.dim(1:3)   = imgdim(1:3);
    VO.mat        = mat;
    VO = spm_create_vol(VO);
    spm_progress_bar('Init',imgdim(3),'reslicing...','planes completed');
    for i = 1:imgdim(3)
        M = inv(spm_matrix([0 0 -i])*inv(VO.mat)*V.mat);
        img = spm_slice_vol(V, M, imgdim(1:2), 1); % (linear interp)
        if ismask
            img = round(img);
        end
        spm_write_plane(VO, img, i);
        spm_progress_bar('Set', i)
    end
    spm_progress_bar('Clear');
end
% call spm_close_vol if spm2
if ~spm5
    spm_close_vol(VO);
end
if (isempty(Fint) && ~isempty(Fnew))
    % interactive figure was opened by this script, so close it again.
    close(Fnew);
end
disp('Done.')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bb = world_bb(V)
%  world-bb -- get bounding box in world (mm) coordinates

d = V.dim(1:3);
% corners in voxel-space
c = [ 1    1    1    1
    1    1    d(3) 1
    1    d(2) 1    1
    1    d(2) d(3) 1
    d(1) 1    1    1
    d(1) 1    d(3) 1
    d(1) d(2) 1    1
    d(1) d(2) d(3) 1 ]';
% corners in world-space
tc = V.mat(1:3,1:4)*c;

% bounding box (world) min and max
mn = min(tc,[],2)';
mx = max(tc,[],2)';
bb = [mn; mx];
