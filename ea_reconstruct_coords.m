function [coords,goodz]=ea_reconstruct_coords(trajectory,trajvector,options)

[cimat,reldist]=ea_sample_cuboid(trajectory,options);


%imat=ea_gencontrastimage(imat,options.zheights);

%cnii=make_nii(imat);
%save_nii(cnii,'trajectory_run.nii');

switch options.modality
    case 1
        headtemp=load_nii(fullfile(options.earoot,'templates','electrode_contacts','mr','template.nii'));
    case 2
        headtemp=load_nii(fullfile(options.earoot,'templates','electrode_contacts','ct','template.nii'));
end

htemp=headtemp.img;
temp=ea_nanmean(htemp(:,:,:,:),4);




%% calculate cross-correlation series for all x and y values within the
%% cuboid volume.

disp('Calculating cross-correlation series for all x and y values within the cuboid volume.');

    
    
 %   cnii=make_nii(temp);
 %   save_nii(cnii,['template_run',num2str(1),'.nii']);
    
cnt=1;
corrs=zeros(size(cimat,1)*size(cimat,2),length(min(trajectory(:,3)):size(cimat,3)-size(temp,3)));
for xx=1:size(cimat,1)
    for yy=1:size(cimat,2)
        for lag=min(trajectory(:,3)):size(cimat,3)-size(temp,3)
            corrs(cnt,lag+1-min(trajectory(:,3)))=corr(squeeze(cimat(xx,yy,lag:lag+size(temp,3)-1)),squeeze(temp(xx,yy,:)),'rows','pairwise');

        end
                    cnt=cnt+1;
    end
end

corrs=ea_nanmean(corrs);
[maxv,maxi]=max(corrs);


try
goodz=maxi+min(trajectory(:,3))+reldist; % -1 because lag-series starts with 0 and not one. +reldist because templates start ~reldist voxels before electrode point.
ea_showdis(['Maximal value was: ',num2str(maxv),'.'],options.verbose);
catch
   ea_showdis(['Probably algorithm stopped to early. No guess of electrode heights possible.'],options.verbose);
   goodz=min(trajectory(:,3));
   maxi=1;
end
if isempty(goodz) 
      ea_showdis(['Probably algorithm stopped to early. No guess of electrode heights possible.'],options.verbose);
   goodz=min(trajectory(:,3));
   maxi=1;
end


% error on maxi empty:
if isempty(maxi)
    ea_error('Reconstruction failed. Please adjust mask-size and entry-point parameters and re-run reconstruction.');
end

startpt=trajectory(end,:);
ntrajvector=trajvector/norm(trajvector);

for coo=1:4
    coords(coo,:)=startpt+ntrajvector*maxi       +ntrajvector*(coo*reldist);

end







function y = ea_nanmean(varargin)
if nargin==2
    x=varargin{1};
    dim=varargin{2};
elseif nargin==1
x=varargin{1};
    dim=1;
end
    
N = sum(~isnan(x), dim);
y = nansum(x, dim) ./ N;


