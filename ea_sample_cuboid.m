function [cimat,reldist,mat]=ea_sample_cuboid(varargin)
% This function samples image points alongside a trajectory specified.
trajectory=varargin{1};
[~,trajvector]=ea_fit_line(trajectory);
options=varargin{2};

switch options.modality
    case 1 % MR
        if exist([options.root,options.prefs.patientdir,filesep,options.prefs.cornii],'file')
            niifn=[options.root,options.prefs.patientdir,filesep,options.prefs.cornii];
        else
            niifn=[options.root,options.prefs.patientdir,filesep,options.prefs.tranii];
        end
    case 2 % CT
        niifn=[options.root,options.prefs.patientdir,filesep,options.prefs.tranii];
end

if nargin>=3 % custom sampling image specified.
    
    niifn=varargin{3};
    
    
end

if nargin>=4
    interp=varargin{4};
else
    interp=3;
end

if nargin>=5
width=varargin{5};
else
width=15;
end

V=spm_vol(niifn);


top_vx=[trajectory(1:2,:),ones(2,1)]';
top_mm=V.mat*top_vx;
top_vx=top_vx(1:3,:)';
top_mm=top_mm(1:3,:)';

% % map trajectory to voxels:
% trajectory_mm=[trajectory,ones(length(trajectory),1)];
%     trajectory_vx=V.mat\trajectory_mm';
%     trajectory_vx=trajectory_vx(1:3,:)';
%     trajectory_mm=trajectory_mm(:,1:3);

   
    
dvox=pdist(top_vx);
dmm=pdist(top_mm);
mm2vx=dmm/dvox; % -> 1 mm equals mm2vx voxels.
%[trajectory,trajectory]=ea_map_coords(trajectory',traniifn);
%trajectory=trajectory';
%trajectory=trajectory';
reldist=options.elspec.eldist/mm2vx; % real measured distance between electrodes in voxels.


% interpolate to include all z-heights:

% xversatz=mean(diff(trajectory(1:end,1))); %wmean(diff(centerline(1:end,1)),gaussweights,1);
% yversatz=mean(diff(trajectory(1:end,2)));%wmean(diff(centerline(1:end,2)),gaussweights,1);
% zversatz=mean(diff(trajectory(1:end,3)));%wmean(diff(centerline(1:end,2)),gaussweights,1);
% 
% trajvector2=[xversatz,yversatz,zversatz];

ntrajvector=trajvector/norm(trajvector);

trajvector=trajvector*((reldist/10)/(norm(trajvector))); % normed trajvector.
if trajvector(3)<0
    trajvector=trajvector*-1; % now going from dorsal to ventral.
    ntrajvector=ntrajvector*-1;
end


% now set trajvector to a size that 10 of it will be the size of eldist.





startpt=trajectory(end,:);            % 3d point of starting line (5 vox below coord 1).
%endpt=coords_vox(1,:);            % 3d point of end line (5 vox above coord 4).


orth=null(trajvector);
orthx=orth(:,1)'*((reldist/10)/norm(orth(:,1))); % vector going perpendicular to trajvector by 0.5 mm in x dir.
orthy=orth(:,2)'*((reldist/10)/norm(orth(:,2))); % vector going perpendicular to trajvector by 0.5 mm in y dir.




xdim=width; % default is 15
ydim=width; % default is 15
zdim=150; % will be sum up to 5 times reldist (three between contacts and two at borders).


imat=nan(2*ydim+1,2*xdim+1,zdim);



        V=spm_vol(niifn);
    
    
    
    cnt=1;
    coord2write=zeros(length(1:zdim)* length(-xdim:xdim)*length(-ydim:ydim),3);
    coord2extract=zeros(length(1:zdim)* length(-xdim:xdim)*length(-ydim:ydim),3);
    
    for zz=1:zdim
        for xx=-xdim:xdim
            for yy=-ydim:ydim
                
                pt=startpt+zz*trajvector;
                coord2extract(cnt,:)=[pt(1)+orthx(1)*xx+orthy(1)*yy; ...
                    pt(2)+orthx(2)*xx+orthy(2)*yy; ...
                    pt(3)+orthx(3)*xx+orthy(3)*yy]';
                coord2write(cnt,:)=[xx+xdim+1;yy+ydim+1;zz]';
                cnt=cnt+1;
                % plot3(coord2extract(1),coord2extract(2),coord2extract(3),'.');
            end
        end
    end
    
%                     imat(xx+xdim+1,yy+ydim+1,zz,(tracor))=spm_sample_vol(V,coord2extract(1),coord2extract(2),coord2extract(3),3);
    imat(sub2ind(size(imat),coord2write(:,1),coord2write(:,2),coord2write(:,3)))=spm_sample_vol(V,coord2extract(:,1),coord2extract(:,2),coord2extract(:,3),interp);
 cimat=squeeze(imat(:,:,:));


if nargout>2 % also export V.mat
% put coord2extract to mm coordinates

coord2extract=V.mat*[coord2extract';ones(1,size(coord2extract,1))];
%coord2extract=coord2extract(1:3,:)';
coord2write=[coord2write,ones(size(coord2write,1),1)];
mat=linsolve(coord2write,coord2extract');
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


