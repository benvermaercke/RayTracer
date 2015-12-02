% give focal length and lens thickness
% optionally, constrain heigth to be SM05 SM1 or SM2,
% lens will possibly be flat at the ends
% both concave and convex lenses can be made

clear all
clc

IOR_air=1.00029;
IOR_water=1.3333;
IOR_glass=1.517;

correction_factor=(IOR_glass-IOR_air)/IOR_air*2;

Objects=cell(0,0);
Object_counter=1;

%% create scan lens
lens_options=default_lens;
lens_options.radii=[50 -50]*correction_factor;
lens_options.thickness=12;
lens_options.height=25.4*2;
lens_options.spatial_location=[-50 0];
lens_options.nPoints=1000;
%Lenses(1)=create_lens_v2(lens_options);
Objects{Object_counter}=create_lens_v2(lens_options);Object_counter=Object_counter+1;
%Lenses(1).focal_length

%% create tube lens
lens_options=default_lens;
lens_options.radii=[200 -200]*correction_factor;
lens_options.thickness=4;
lens_options.height=25.4*2;
lens_options.spatial_location=[200 0];
lens_options.nPoints=1000;
%Lenses(2)=create_lens_v2(lens_options);
Objects{Object_counter}=create_lens_v2(lens_options);Object_counter=Object_counter+1;

%% create objective lens
lens_options=default_lens;
lens_options.radii=[25 -25]*correction_factor;
lens_options.thickness=10;
lens_options.height=40;
lens_options.spatial_location=[400 0];
lens_options.nPoints=1000;
%Lenses(3)=create_lens_v2(lens_options);
Objects{Object_counter}=create_lens_v2(lens_options);Object_counter=Object_counter+1;

%nLenses=length(Lenses);


%% create moveable mirrors
mirror_options=default_mirror;
mirror_options.height=40;
mirror_options.angle=pi/4*3;%+.015;%+rand*.03-.015;
mirror_options.spatial_location=[-100 -50];
%Mirrors(1)=create_mirror(mirror_options);
Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;

mirror_options=default_mirror;
mirror_options.height=40;
mirror_options.angle=-pi/4+.1;%+rand*.03-.015;
mirror_options.spatial_location=[-100 0];
%Mirrors(2)=create_mirror(mirror_options);
Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;
%nMirrors=length(Mirrors);

%% Create tissue absorber
absorber_options=default_absorber;
absorber_options.thickness=2;
absorber_options.spatial_location=[Objects{3}.center(1)+Objects{3}.focal_length+absorber_options.thickness/2 0];
absorber_options.height=40;
absorber_options.nPoints=20;
absorber_options.angle=0;
%Absorbers(1)=create_absorber(create_absorber);
Objects{Object_counter}=create_absorber(absorber_options);Object_counter=Object_counter+1;

%nAbsorbers=length(Absorbers);

nObjects=length(Objects);

%% Plot all optical elements
x_range=[-150 500];
y_range=[-25 25];

clf
hold on

%plot(x_range,[0 0],'k--')
p=plot(0,0,'r.-','markerSize',1);
for iObject=1:nObjects
    plot(Objects{iObject}.XV,Objects{iObject}.YV,Objects{iObject}.line_style)
end

axis([x_range y_range])
axis equal
drawnow

%% do ray tracing on this
step_size=3; % choose step_size smaller than thinnest object, and do refinement step when in object
initial_direction=0;

switch 2
    case 1
        nRays=1;
        next_position=[-150 -50];
        cur_angle=initial_direction;
    case 2
        nRays=3;
        initial_direction=0;
        
        center_location=[-150 -50];
        horizontal_spread=[0 0];
        vertical_spread=[-1 1]*1.5;
        
        next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
        cur_angle=ones(nRays,1)*initial_direction;
end

%%
Rays.nRays=nRays;
Rays.step_size=step_size;
Rays.next_position=next_position;
Rays.cur_angle=cur_angle;
Rays.tracing=ones(nRays,1);
Rays.in_object=zeros(nRays,1);
Rays.leaving_object=zeros(nRays,1);

try
    M_all=[];
    tic
    for iRay=1:Rays.nRays
        M=[];
        last_object=[];
        step_nr=0;
        while Rays.tracing(iRay)==1
            % Advance ray one step in direction of ray
            next_position_temp=advance_rays(Rays,iRay);
            x=next_position_temp(1);
            y=next_position_temp(2);
            
            % assume no hit
            current_object.medium=0;
            current_object.index=0;
            current_object.object=[];
            current_object.transition=0;
            
            for iObject=1:nObjects
                Object=Objects{iObject};
                if inpolygon(x,y,Object.XV,Object.YV)
                    current_object.medium=Object.object_type;
                    current_object.index=iObject;
                    current_object.object=Object;
                    last_object=current_object;
                end
            end
            
            %% Given our current medium, check for new hit with new medium all objects, return object
            if Rays.in_object(iRay)==0
                % we are in air check for hits
                if current_object.medium>0
                    Rays.in_object(iRay)=current_object.index;
                    current_object.transition=1;
                end
            else
                % We are in object, check whether we move out of one
                if current_object.medium==0
                    Rays.leaving_object(iRay)=1;
                    current_object.transition=1;
                end
            end
            
            %% refine crossing point with smaller stepsizes
            % do mini steps since last point
            if current_object.transition==1
                step_orig=Rays.step_size;
                Rays.step_size=Rays.step_size/10;
                
                next_position_temp=advance_rays(Rays,iRay);
                x_mini=next_position_temp(1);
                y_mini=next_position_temp(2);
                
                hit=0;
                while hit==0
                    % and find first hit with current_object
                    if current_object.medium==0
                        Object=last_object.object;
                        if ~inpolygon(x_mini,y_mini,Object.XV,Object.YV)
                            hit=1;
                        else
                            next_position_temp=advance_rays(Rays,iRay);
                            x_mini=next_position_temp(1);
                            y_mini=next_position_temp(2);
                            next_position_temp=[x_mini y_mini];
                            next_position(iRay,:)=next_position_temp;
                            Rays.next_position=next_position;
                        end
                    else
                        Object=current_object.object;
                        if inpolygon(x_mini,y_mini,Object.XV,Object.YV)
                            hit=1;
                        else
                            next_position_temp=advance_rays(Rays,iRay);
                            x_mini=next_position_temp(1);
                            y_mini=next_position_temp(2);
                            next_position_temp=[x_mini y_mini];
                            next_position(iRay,:)=next_position_temp;
                            Rays.next_position=next_position;
                        end
                    end
                end
                
                Rays.step_size=step_orig;
            end
            %% process event type based on object properties
            
            Object=current_object.object;
            
            %%% Destroy if outside of plot area
            if ~inpolygon(x,y,x_range,x_range)
                Rays.tracing(iRay)=0;
            end
            
            %%% If in absorber, destroy
            if current_object.medium==1
                Rays.tracing(iRay)=0;
            end
            
            %%% If in mirror, reflect
            if current_object.medium==2
                N=Object.normal;
                Rays.cur_angle(iRay)=N-(Rays.cur_angle(iRay)-N);
            end
            
            
            %%% If in lens, refract
            if current_object.medium==3&&current_object.transition==1
                if Rays.leaving_object(iRay)==0
                    Rays.in_object(iRay)=current_object.index;
                    [min_dist, loc]=min(calc_dist_matrix([Rays.next_position((iRay),1),Rays.next_position((iRay),2)],[Object.XV,Object.YV]));
                    angle_normal=Object.Normals(loc);
                    
                    % refract angle
                    Rays.cur_angle(iRay)=snells_law(Object.medium_index_of_refraction,Object.index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                end
            end
            
            if Rays.leaving_object(iRay)==1&&last_object.medium==3
                if Rays.in_object(iRay)==last_object.index % transition object to air                    
                    [min_dist, loc]=min(calc_dist_matrix([Rays.next_position(iRay,1),Rays.next_position(iRay,2)],[last_object.object.XV,last_object.object.YV]));
                    angle_normal=last_object.object.Normals(loc);
                    
                    % refract angle
                    Rays.cur_angle(iRay)=snells_law(last_object.object.index_of_refraction,last_object.object.medium_index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                end
            end
            
            
            if 0
                
                %%% Check for absorber crossing => destroy
                for iAbsorber=1:nAbsorbers
                    if inpolygon(next_position_temp(1),next_position_temp(2),Absorbers(iAbsorber).XV,Absorbers(iAbsorber).YV)
                        Rays.tracing(iRay)=0;
                        break
                    end
                end
                
                %%% Check for mirror crossing => reflect
                for iMirror=1:nMirrors
                    if inpolygon(next_position_temp(1),next_position_temp(2),Mirrors(iMirror).XV,Mirrors(iMirror).YV)
                        N=Mirrors(iMirror).normal;
                        Rays.cur_angle(iRay)=N-(Rays.cur_angle(iRay)-N);
                    end
                end
                
                %%% Check for lens crossing => refract
                for iLens=1:nLenses
                    if inpolygon(next_position_temp(1),next_position_temp(2),cat(1,Lenses(iLens).XV),cat(1,Lenses(iLens).YV))
                        if Rays.in_object(iRay)==0 % transition air to object
                            Rays.in_object(iRay)=iLens;
                            [min_dist, loc]=min(calc_dist_matrix([Rays.next_position((iRay),1),Rays.next_position((iRay),2)],[Lenses(iLens).XV,Lenses(iLens).YV]));
                            angle_normal=Lenses(iLens).Normals(loc);
                            
                            % refract angle
                            Rays.cur_angle(iRay)=snells_law(Lenses(iLens).medium_index_of_refraction,Lenses(iLens).index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                        end
                    else % not in any object
                        if Rays.in_object(iRay)==iLens % transition object to air
                            Rays.in_object(iRay)=0;
                            [min_dist, loc]=min(calc_dist_matrix([Rays.next_position(iRay,1),Rays.next_position(iRay,2)],[Object.XV,Object.YV]));
                            angle_normal=Object.Normals(loc);
                            
                            % refract angle
                            prev=Rays.cur_angle(iRay);
                            Rays.cur_angle(iRay)=snells_law(Object.index_of_refraction,Object.medium_index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                        end
                    end
                end
                
            end
            
            if current_object.transition==1
                current_object.transition=0;
            end
            
            %%% Reset object leaving flag
            if Rays.leaving_object(iRay)==1
                Rays.in_object(iRay)=0;
                Rays.leaving_object(iRay)=0;
            end
            
            %%% update position
            next_position(iRay,:)=next_position_temp;
            Rays.next_position=next_position;
            
            step_nr=step_nr+1;
            if step_nr>2E3
                Rays.tracing(iRay)=0;
            end
            
            M(step_nr,:)=next_position(iRay,:);
        end
        %%
        M_all=cat(1,M_all,M,NaN(1,2));
    end
    toc
catch
    M_all=cat(1,M_all,M);
    A=lasterror;
    disp(A.message)
end
%%
set(p,'Xdata',M_all(:,1),'Ydata',M_all(:,2))

%sum(min(abs([Rays.cur_angle Rays.cur_angle-2*pi]),[],2))
