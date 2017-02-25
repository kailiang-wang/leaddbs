function xyzv=ea_buildxyzv(M,varnum)

% varnum can be an integer referring to the regressor # or a string
% {'contacts','pairs'} to give back contact or contact pair coordinates.

if ~exist('varnum','var')
    varnum='contacts';
end
if ischar(varnum) % simply return coordinate list
    switch varnum
        case 'contacts'
            ixx=1:4;
            meannec=0;
        case 'pairs'
            ixx=1:3;
            meannec=1;
    end
    cnt=1;
    for pt=1:length(M.patient.list)
        for side=1:2
            for clen=ixx
                if meannec
                    xyzv(cnt,:)=mean(M.elstruct(pt).coords_mm{side}(clen:clen+1,:),1);
                else
                    xyzv(cnt,:)=M.elstruct(pt).coords_mm{side}(clen,:);
                end
                cnt=cnt+1;
            end
        end
    end
else
    cnt=1;
    switch size(M.clinical.vars{varnum},2)
        
        case {6,8} % contacts / contact pairs
            
            if size(M.clinical.vars{varnum},2)==6
                ixx=1:3;
                meannec=1;
            else
                ixx=1:4;
                meannec=0;
            end
            
            for pt=1:length(M.patient.list)
                for side=1:2
                    for clen=ixx
                        sidec=[ixx]+(side-1)*ixx(end);
                        if meannec
                            xyzv(cnt,:)=[mean(M.elstruct(pt).coords_mm{side}(clen:clen+1,:),1),M.clinical.vars{varnum}(pt,sidec(clen))];
                        else
                            xyzv(cnt,:)=[M.elstruct(pt).coords_mm{side}(clen,:),M.clinical.vars{varnum}(pt,sidec(clen))];
                        end
                        cnt=cnt+1;
                    end
                end
            end
    end
end