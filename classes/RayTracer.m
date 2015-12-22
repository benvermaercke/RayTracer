classdef RayTracer < handle
    properties
        % constants
        IOR_air=1.00029;
        IOR_water=1.3333;
        IOR_glass=1.517;
        correction_factor=[];
        
        %%% Optical elements
        nObjects=0;
        Objects={};
        
        %%% Rays
        nBundles=0;
        Bundles={};
        nRays_total=0;
        nSteps_total=0;
        
        x_range=[-75 275];
        y_range=[-50 50];
    end
    
    methods
        function self=RayTracer(varargin)
            %disp('<RayTracer by Ben Vermaercke, 2015>')
            
            % check inputs
            for iArg=1:2:nargin
                self.(varargin{iArg})=varargin{iArg+1};
            end
            
            self.correction_factor=(self.IOR_glass-self.IOR_air)/self.IOR_air*2;
        end
        
        %%% Optical elements
        function add_lens(varargin)
            self=varargin{1};
            
            self.nObjects=self.nObjects+1;
            self.Objects{self.nObjects}=Lens(varargin{2:end});
        end
        
        function add_mirror(varargin)
            self=varargin{1};
            
            self.nObjects=self.nObjects+1;
            self.Objects{self.nObjects}=Mirror(varargin{2:end});
        end
        
        function add_absorber(varargin)
            self=varargin{1};
            
            self.nObjects=self.nObjects+1;
            self.Objects{self.nObjects}=Absorber(varargin{2:end});
        end
        
        
        %%% Rays
        function add_bundle(varargin)
            self=varargin{1};
            self.nBundles=self.nBundles+1;
            self.Bundles{self.nBundles}=Bundle(varargin{2:end});
        end
        
        
        %%% Simulation
        function run_simulation(varargin)
            self=varargin{1};
            
            
            current_object.medium=0;
            current_object.index=0;
            current_object.object.index_of_refraction=self.IOR_air;
            last_object=current_object;
            
            for iBundle=1:self.nBundles
                Bundle=self.Bundles{iBundle};
                
                for iRay=1:Bundle.nRays
                    [iBundle iRay]
                    Ray=Bundle.Rays{iRay};
                    transition=0;
                    
                    step_nr=0;
                    while Ray.tracing==1
                        % Advance ray one step in direction of ray
                        next_position_temp=self.advance_ray(Ray);
                        x=next_position_temp(1);
                        y=next_position_temp(2);
                        
                        %%% Destroy if outside of plot area
                        if ~inpolygon(x,y,self.x_range,self.y_range)
                            Ray.tracing=0;
                        end
                        
                        % Assume we hit nothing
                        current_object.medium=0;
                        current_object.index=0;
                        current_object.object=[];
                        current_object.object.index_of_refraction=self.IOR_air;
                        for iObject=1:self.nObjects
                            curr_Object=self.Objects{iObject};
                            if inpolygon(x,y,curr_Object.XV,curr_Object.YV)
                                current_object.medium=curr_Object.object_type;
                                current_object.index=iObject;
                                current_object.object=curr_Object;
                            end
                        end
                        
                        %%% Define transition based on comparison prev and curr object
                        if current_object.index==last_object.index
                            % just continue
                            transition=0;
                        else
                            % shit happens
                            transition=1;
                        end
                        
                        %% refine crossing point with smaller stepsizes
                        % do mini steps since last point
                        if transition==1
                            step_orig=Ray.step_size;
                            Ray.step_size=Ray.step_size/100;
                            
                            next_position_temp=self.advance_ray(Ray);
                            x_mini=next_position_temp(1);
                            y_mini=next_position_temp(2);
                            
                            hit=0;
                            while hit==0
                                % and find first hit with current_object
                                if current_object.medium==0
                                    curr_Object=last_object.object;
                                    if ~inpolygon(x_mini,y_mini,curr_Object.XV,curr_Object.YV)
                                        hit=1;
                                    else
                                        next_position_temp=self.advance_ray(Ray);
                                        x_mini=next_position_temp(1);
                                        y_mini=next_position_temp(2);
                                        next_position_temp=[x_mini y_mini];
                                        Ray.next_position=next_position_temp;
                                    end
                                else
                                    curr_Object=current_object.object;
                                    if inpolygon(x_mini,y_mini,curr_Object.XV,curr_Object.YV)
                                        hit=1;
                                    else
                                        next_position_temp=self.advance_ray(Ray);
                                        x_mini=next_position_temp(1);
                                        y_mini=next_position_temp(2);
                                        next_position_temp=[x_mini y_mini];
                                        Ray.next_position=next_position_temp;
                                    end
                                end
                            end
                            Ray.step_size=step_orig;
                            
                            
                            %% process event type based on object properties
                            curr_Object=current_object.object;
                            prev_Object=last_object.object;
                            
                            %%% If in absorber, destroy
                            if current_object.medium==1
                                Ray.tracing=0;
                            end
                            
                            %%% If in mirror, reflect
                            if current_object.medium==2
                                N=curr_Object.Normals;
                                Ray.cur_angle=N-(Ray.cur_angle-N);
                            end
                            
                            %%% If in lens, refract depends on both last and current object
                            if current_object.medium==3
                                % Enter lens
                                [min_dist, loc]=min(calc_dist_matrix([x_mini,y_mini],[curr_Object.XV,curr_Object.YV]));
                                angle_normal=curr_Object.Normals(loc);
                                Ray.cur_angle=snells_law(prev_Object.index_of_refraction,curr_Object.index_of_refraction,Ray.cur_angle,angle_normal);
                                
                                %plot(x_mini,y_mini,'m*')
                                %l=5;
                                %plot([x_mini-l*cos(angle_normal) x_mini+l*cos(angle_normal)],[y_mini-l*sin(angle_normal) y_mini+l*sin(angle_normal)],'k-')
                                
                            elseif last_object.medium==3
                                % Exit lens
                                [min_dist, loc]=min(calc_dist_matrix([x_mini,y_mini],[prev_Object.XV,prev_Object.YV]));
                                angle_normal=prev_Object.Normals(loc);
                                Ray.cur_angle=snells_law(prev_Object.index_of_refraction,curr_Object.index_of_refraction,Ray.cur_angle,angle_normal);
                                
                                %plot(x_mini,y_mini,'m*')
                                %l=5;
                                %plot([x_mini-l*cos(angle_normal) x_mini+l*cos(angle_normal)],[y_mini-l*sin(angle_normal) y_mini+l*sin(angle_normal)],'k-')
                            end
                        end
                        
                        %%% Reset transition flag
                        if transition==1
                            transition=0;
                            last_object=current_object;
                        end
                        
                        %%% Update position
                        %next_position(iRay,:)=next_position_temp;
                        Ray.next_position=next_position_temp;
                        
                        Ray.history=cat(1,Ray.history,Ray.next_position);
                        %Ray.history
                        Bundle.Rays{iRay}=Ray;
                        
                        %%% Avoid long tracings
                        step_nr=step_nr+1;
                        if step_nr>2E3
                            Ray.tracing=0;
                        end
                        
                        %%% Collect position in matrix
                        %M(step_nr,:)=[step_nr iRay next_position(iRay,:)];
                    end
                end
            end
        end
        
        function trace_ray(varargin)
            self=varargin{1};
        end
        
        function out=advance_ray(varargin)
            %self=varargin{1};
            Ray=varargin{2};
            out=Ray.next_position+Ray.step_size*[cos(Ray.cur_angle) sin(Ray.cur_angle)];
        end
        
        
        
        %%% Drawing
        function draw_space(varargin)
            self=varargin{1};
            
            clf
            hold on
            plot(self.x_range,[0 0],'k--')
            
            %%% Show optical elements
            for iObject=1:self.nObjects
                plot(self.Objects{iObject}.XV,self.Objects{iObject}.YV,self.Objects{iObject}.line_style)
            end
            
            %%% Init Rays
            for iBundle=1:self.nBundles
                bundle=self.Bundles{iBundle};
                for iRay=1:bundle.nRays
                    Ray=bundle.Rays{iRay};                    
                    bundle.Rays{iRay}.p=plot(self.x_range(1),self.y_range(1),'-','color',Ray.color,'lineWidth',Ray.thickness);
                end                
            end
            
            axis([self.x_range self.y_range])
            axis equal
            drawnow
        end
        
        function update_space(varargin)
            self=varargin{1};
            
            for iBundle=1:self.nBundles
                Bundle=self.Bundles{iBundle};
                
                for iRay=1:Bundle.nRays
                    Ray=Bundle.Rays{iRay};
                    M=Ray.history;
                    if ~isempty(M)                        
                        set(Ray.p,'xData',M(:,1),'yData',M(:,2))
                    end
                end
            end
        end
        
    end
end