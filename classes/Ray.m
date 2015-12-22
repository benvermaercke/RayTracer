classdef Ray < handle
    properties
        next_position=[];
        cur_angle=[];
        step_size=[];
        tracing=1;
        p=0;
        color=[1 0 0];
        thickness=1;
        history=[];
    end
    
    methods
        function self=Ray(varargin)
            %%% Constructor
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end

        end
    end
end