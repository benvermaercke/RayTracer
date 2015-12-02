classdef Bundle < handle
    properties
        bundle_type=[];
        
        % Init values
        step_size=1;
        initial_direction=0;
        center_location=[0 0]; % distance between point = size of object
        
        % For diverging bundle (point source)
        angle_spread=.1;%10/180*pi;
        
        % For parallel bundel (front)
        beam_spread=4;
        
        % Ray parameters
        nRays=0;
        Ray=struct('next_position',[],'cur_angle',[],'step_size',[],'tracing',1,'p',0,'color',[1 0 0],'history',[]);
        Chief_ray=struct('next_position',[],'cur_angle',[],'step_size',[],'tracing',1,'p',0,'color',[0 0 1],'history',[]);
    end
    
    methods
        function self=Bundle(varargin)
            %%% Constructor
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end
            
            % start construction
            if mod(self.nRays,2)==0
                self.nRays=self.nRays+1;
            end
            
            switch self.bundle_type
                case 1 % point sources
                    angle_range=linspace(self.initial_direction-self.angle_spread/2,self.initial_direction+self.angle_spread/2,self.nRays);
                    for iRay=1:self.nRays
                        self.Ray(iRay).next_position=self.center_location;
                        self.Ray(iRay).cur_angle=angle_range(iRay);
                        self.Ray(iRay).step_size=self.step_size;
                        self.Ray(iRay).tracing=1;
                        self.Ray(iRay).p=0;
                        self.Ray(iRay).color=[1 0 0];
                        self.Ray(iRay).history=[];
                        if iRay==round(self.nRays/2)
                            self.Chief_ray=self.Ray(iRay);
                        end
                        
                    end
                case 2 % collimated
                    position_range=[linspace(self.center_location(1)-self.beam_spread/2,self.center_location(1)+self.beam_spread/2,self.nRays)' ones(self.nRays,1)*self.center_location(2)];
                    M=rotate_points(position_range,self.center_location,self.initial_direction+pi/2);
                    
                    for iRay=1:self.nRays
                        self.Ray(iRay).next_position=M(iRay,:);
                        self.Ray(iRay).cur_angle=self.initial_direction;
                        self.Ray(iRay).step_size=self.step_size;
                        self.Ray(iRay).tracing=1;
                        self.Ray(iRay).p=0;
                        self.Ray(iRay).color=[1 0 0];
                        self.Ray(iRay).history=[];
                        if iRay==round(self.nRays/2)
                            self.Chief_ray=self.Ray(iRay);
                        end
                    end
            end
        end
    end
end