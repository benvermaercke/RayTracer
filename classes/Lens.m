classdef Lens < handle
    properties
        object_type=[];
        
        radii=[50 -50]; % mm
        thickness=5; % mm
        height=25.4; % mm =SM01
        kappa=0; % default to spherical lens
        coeffs=[];
        
        spatial_location=[0 0]; % mm
        angle=0; % rotation in radians
        nPoints=51;
        index_of_refraction=1.517; % glass
        medium_index_of_refraction=1.00029; % air
        focal_length=[];
        line_style='g.-';
        
        center=[];
        XV=[];
        YV=[];
        Normals=[];
        nVertices=[];
        optical_power=[];
    end
    
    methods
        function self=Lens(varargin)
            %%% Constructor
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end
            
            % start construction
            R=self.radii;
            
            X=linspace(-self.height/2,self.height/2,self.nPoints); % this implements the height feature
            for iSurface=1:2
                Y=X.^2 ./ (R(iSurface) * (1 + sqrt(1-(1+self.kappa)*X.^2/R(iSurface)^2) ) ) ;
                if self.kappa~=0&&R(iSurface)<1000&&~isempty(self.coeffs)
                    %if self.kappa~=0&&R(iSurface)<1000&&isfield(self,'coeffs')
                    nCoeff=length(self.coeffs);
                    coeff_matrix=zeros(nCoeff,self.nPoints);
                    for iCoeff=1:nCoeff
                        coeff_matrix(iCoeff,:)=self.coeffs(iCoeff)*X.^iCoeff;
                    end
                    Y=Y+sum(coeff_matrix);
                end
                Y=Y(:);
                
                %%% Define ratio to maintain focal point at specified spatial location
                ratio=abs(R(1)/sum(abs(R)));
                if iSurface==1
                    Y=Y-self.thickness*(1-ratio);
                else
                    Y=Y+self.thickness*ratio;
                    X=-X;
                end
                Y=Y(:)';
                
                % get normals
                normals=zeros(self.nPoints,1);
                for iPoint=2:self.nPoints-1
                    neighbors=[-X([iPoint-1 iPoint+1]) ;  Y([iPoint-1 iPoint+1])];
                    % use neighbor to estimate normal
                    alpha=calc_heading(neighbors(:));
                    normals(iPoint)=alpha-pi;
                end
                normals(1)=normals(2);
                normals(end)=normals(end-1);
                
                self.XV=cat(1,self.XV,Y(:));
                self.YV=cat(1,self.YV,X(:));
                self.Normals=cat(1,self.Normals,normals);
            end
            self.XV(end+1)=self.XV(1);
            self.YV(end+1)=self.YV(1);
            self.Normals(end+1)=self.Normals(1);
            
            M=[self.XV self.YV self.Normals];
            
            %M(1:end/2,:)=sortrows(M(1:end/2,:),-2);
            %M(end/2+1:end,:)=sortrows(M(end/2+1:end,:),2);
            %M(end+1,:)=M(1,:);
            
            %%% Allow lens rotation
            M(:,1:2)=rotate_points(M(:,1:2),self.spatial_location*0,self.angle);
            M(:,3)=M(:,3)+self.angle;
            
            %%% get focal length
            R=self.radii;
            n=self.index_of_refraction;
            n_0=1;%self.medium_index_of_refraction;
            P=((n-n_0)/n_0)*( 1/R(1) - 1/R(2) );
            
            %%% translation and rotations of final lens
            self.XV=M(:,1)+self.spatial_location(1);
            self.YV=M(:,2)+self.spatial_location(2);
            
            % Build self
            self.object_type=3;
            self.center=self.spatial_location;
            self.radii=R;
            self.angle=self.angle;
            self.Normals=M(:,3);
            
            self.nVertices=length(self.XV);
            self.thickness=self.thickness;
            self.optical_power=P*100;
            self.focal_length=1/P;
        end
    end
end