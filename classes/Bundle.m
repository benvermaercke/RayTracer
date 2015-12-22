classdef Bundle < handle
    properties
        bundle_type=[];
        
        % Init values
        step_size=1;
        initial_direction=0;
        center_location=[0 0]; % distance between point = size of object
        color=[1 0 0];
        
        % For diverging bundle (point source)
        angle_spread=.1;%10/180*pi;
        
        % For parallel bundel (front)
        beam_spread=4;
        
        % Ray parameters
        nRays=0;
        %Ray=struct('next_position',[],'cur_angle',[],'step_size',[],'tracing',1,'p',0,'color',[1 0 0],'history',[]);
        Rays=[];
    end
    
    methods
        function self=Bundle(varargin)
            %%% Constructor
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end
            
            % start construction
            switch self.bundle_type
                case 1 % point sources
                    if self.nRays==1
                        angle_range=linspace(self.initial_direction-self.angle_spread/2,self.initial_direction+self.angle_spread/2,3);
                        angle_range=angle_range(2);
                    else
                        angle_range=linspace(self.initial_direction-self.angle_spread/2,self.initial_direction+self.angle_spread/2,self.nRays);
                    end
                    
                    for iRay=1:self.nRays
                        self.Rays{iRay}=Ray('next_position',self.center_location,'cur_angle',angle_range(iRay),'step_size',self.step_size,'color',self.color);
                        if mod(self.nRays,2)==1&&iRay==round(self.nRays/2)
                            %%% layout chief ray
                            self.Rays{iRay}.thickness=2;
                        end
                    end
                case 2 % collimated
                    if self.nRays==1
                        position_range=[linspace(self.center_location(1)-self.beam_spread/2,self.center_location(1)+self.beam_spread/2,3)' ones(self.nRays,1)*self.center_location(2)];
                        M=rotate_points(position_range,self.center_location,self.initial_direction+pi/2);
                        M=M(2,:);
                    else
                        position_range=[linspace(self.center_location(1)-self.beam_spread/2,self.center_location(1)+self.beam_spread/2,self.nRays)' ones(self.nRays,1)*self.center_location(2)];
                        M=rotate_points(position_range,self.center_location,self.initial_direction+pi/2);
                    end
                    
                    for iRay=1:self.nRays
                        self.Rays{iRay}=Ray('next_position',M(iRay,:),'cur_angle',self.initial_direction,'step_size',self.step_size,'color',self.color);
                        if mod(self.nRays,2)==1&&iRay==round(self.nRays/2)
                            %%% layout chief ray
                            self.Rays{iRay}.thickness=2;
                        end
                    end
            end
        end
    end
end