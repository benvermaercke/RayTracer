classdef Mirror < handle
    properties
        object_type=[];
        height=40;
        thickness=5;
        spatial_location=[0 0];
        angle=0;
        nPoints=15;
        
        line_style='c.-';
        
        center=[];
        XV=[];
        YV=[];
        Normals=[];
        nVertices=[];
    end
    
    methods
        function self=Mirror(varargin)
            %%% Constructor
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end
            
            % start construction
            Y_points=linspace(self.spatial_location(2)-self.height/2,self.spatial_location(2)+self.height/2,self.nPoints);
            [X, Y]=meshgrid([self.spatial_location(1)-self.thickness/2 self.spatial_location(1)+self.thickness/2],Y_points);
            
            M=[X(:) Y(:)];
            M(end/2+1:end,:)=flipud(M(end/2+1:end,:));
            M(end+1,:)=M(1,:);
            
            M=rotate_points(M,self.spatial_location,self.angle);
            
            %%% add small offset to move center of gravity to mirror surface
            offset=[cos(self.angle) sin(self.angle)]*self.thickness/2;
            M=M+repmat(offset,size(M,1),1);
            
            % Construct object
            self.object_type=2;
            self.center=self.spatial_location;
            self.XV=M(:,1);
            self.YV=M(:,2);
            self.Normals=normalizeAngle(self.angle+pi/2);           
        end
    end
end