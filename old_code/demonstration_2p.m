% give focal length and lens thickness
% optionally, constrain heigth to be SM05 SM1 or SM2,
% lens will possibly be flat at the ends
% both concave and convex lenses can be made

clear all
clc

IOR_air=1.00029;
IOR_water=1.3333;
IOR_glass=1.517;

T1=50;
T2=150;

F1=50;
F2=100;

Objective_focal_length=25;
correction_factor=(IOR_glass-IOR_air)/IOR_air*2;

deflection=.05;
scenario=6;
beam_type=1;
switch scenario
    case 1
        mirror_deflection=0;
        save_name='step01_small_beam_center';
    case 2
        mirror_deflection=deflection;
        save_name='step02_small_beam_up';
    case 3
        mirror_deflection=-deflection;
        save_name='step03_small_beam_down';
    case 4
        mirror_deflection=0;
        beam_type=2;
        save_name='step04_collimate';
    case 5
        mirror_deflection=0;
        beam_type=2;
        save_name='step04_collimate_faded';
    case 6
        mirror_deflection=0;
        save_name='step06_emission';
        beam_type=3;
end

% create optical objects
Objects=cell(0,0);
Object_counter=1;

if ismember(scenario,[1 2 3])
    % mirror
    mirror_options=default_mirror;
    mirror_options.thickness=1;
    mirror_options.height=15;
    mirror_options.angle=pi/4*3+mirror_deflection;
    mirror_options.spatial_location=[-195 0];
    Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;
elseif ismember(scenario,[4 5])
    % mirror  
    mirror_options=default_mirror;
    mirror_options.thickness=1;
    mirror_options.height=15;
    mirror_options.angle=pi/4*3+mirror_deflection;
    mirror_options.spatial_location=[-197 0];    
    Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;
elseif ismember(scenario,6)    
    %no mirror faded version!!!!
end

% scan lens
lens_options=default_lens;
lens_options.radii=[50 -50];
lens_options.angle=0;
lens_options.thickness=4;
lens_options.height=25;
lens_options.spatial_location=[-148 0];
lens_options.nPoints=1000;
Objects{Object_counter}=create_lens_v4(lens_options);Object_counter=Object_counter+1;

% tube lens
lens_options=default_lens;
lens_options.radii=[100 -100];
lens_options.angle=0;
lens_options.thickness=7;
lens_options.height=50;
lens_options.spatial_location=[0 0];
lens_options.nPoints=1000;
Objects{Object_counter}=create_lens_v4(lens_options);Object_counter=Object_counter+1;

if beam_type==3
    % dichroic
    mirror_options=default_mirror;
    mirror_options.thickness=1;
    mirror_options.height=30;
    mirror_options.angle=pi/4*3+mirror_deflection;
    mirror_options.spatial_location=[50 0];
    Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;
    
    % objective
    lens_options=default_lens;
    lens_options.radii=[Objective_focal_length -Objective_focal_length]*correction_factor;
    lens_options.angle=pi;
    lens_options.kappa=0;
    lens_options.thickness=4;
    lens_options.height=18;
    lens_options.spatial_location=[100 0];
    lens_options.nPoints=1000;
    Objects{Object_counter}=create_lens_v4(lens_options);Object_counter=Object_counter+1;
else
    % objective
    lens_options=default_lens;
    lens_options.radii=[Objective_focal_length -Objective_focal_length]*correction_factor;
    lens_options.kappa=0;
    lens_options.thickness=4;
    lens_options.height=18;
    lens_options.spatial_location=[100 0];
    lens_options.nPoints=1000;
    Objects{Object_counter}=create_lens_v4(lens_options);Object_counter=Object_counter+1;
    
    % tissue
    absorber_options=default_absorber;
    absorber_options.thickness=5;
    absorber_options.spatial_location=[126 0];
    absorber_options.height=60;
    absorber_options.nPoints=20;
    absorber_options.angle=0;
    Objects{Object_counter}=create_absorber(absorber_options);Object_counter=Object_counter+1;
end




nObjects=length(Objects);

%% Set tracing parameters
step_size=1; % choose step_size smaller than thinnest object, and do refinement step when in object
initial_direction=0;
beam_diameter=20;
nRays=9;
switch beam_type
    case 1 % focus
        initial_direction=pi/2;
        
        center_location=[-195 -50];
        horizontal_spread=[-1 1]*beam_diameter*.1;
        vertical_spread=[0 0];
        
        next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
        cur_angle=ones(nRays,1)*initial_direction;
        
    case 2 % collimate
        nRays=3;
        initial_direction=0;
        direction_spread=.1;%10/180*pi;
        
        center_location=[-197 0];
        horizontal_spread=[0 0];
        vertical_spread=[0 0];
        
        next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
        cur_angle=linspace(initial_direction-direction_spread,initial_direction+direction_spread,nRays);
    case 3 % collimate
        nRays=5;
        initial_direction=pi;
        direction_spread=.1;%10/180*pi;
        
        center_location=[126 0];
        horizontal_spread=[0 0];
        vertical_spread=[0 0];
        
        next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
        cur_angle=linspace(initial_direction-direction_spread,initial_direction+direction_spread,nRays);
end

Rays.nRays=nRays;
Rays.step_size=step_size;
Rays.next_position=next_position;
Rays.cur_angle=cur_angle;
Rays.tracing=ones(nRays,1);
Rays.p=zeros(nRays,1);


%% Plot all optical elements
x_range=[-210 150];
y_range=[-35 35];

clf
hold on
plot(x_range,[0 0],'k--')
%plot([0 0],[-50 50],'k--')
%plot([-50 -50],[-50 50],'k--')

for iObject=1:nObjects
    plot(Objects{iObject}.XV,Objects{iObject}.YV,Objects{iObject}.line_style)
end

for iRay=1:nRays
    if beam_type==1
        Rays.p(iRay)=plot(x_range(1),y_range(1),'r-','markerSize',1);
    else
        if scenario==4
            Rays.p(iRay)=plot(x_range(1),y_range(1),'b-','markerSize',2);
        elseif scenario==5
            Rays.p(iRay)=plot(x_range(1),y_range(1),'b--','lineWidth',1);
        elseif scenario==6
            Rays.p(iRay)=plot(x_range(1),y_range(1),'-','lineWidth',1,'color',[0 1 0]*.7);
        end
    end
end

if scenario==4
    Rays.chief=plot(x_range(1),y_range(1),'b-','lineWidth',2);
elseif scenario==5
    Rays.chief=plot(x_range(1),y_range(1),'b--','lineWidth',1);
elseif scenario==6
    Rays.chief=plot(x_range(1),y_range(1),'-','lineWidth',2,'color',[0 1 0]*.7);
end

axis([x_range y_range])
%axis equal
set(gca,'xticklabel','','yticklabel','')
drawnow



%%

try
    M_all=[];
    tic
    
    for iRay=1:Rays.nRays
        M=[];
        current_object.medium=0;
        current_object.index=0;
        current_object.object.index_of_refraction=IOR_air;
        last_object=current_object;
        step_nr=0;
        while Rays.tracing(iRay)==1
            % Advance ray one step in direction of ray
            next_position_temp=advance_rays(Rays,iRay);
            x=next_position_temp(1);
            y=next_position_temp(2);
            
            %%% Destroy if outside of plot area
            if ~inpolygon(x,y,x_range,x_range)
                Rays.tracing(iRay)=0;
            end
            
            % Assume we hit nothing
            current_object.medium=0;
            current_object.index=0;
            current_object.object.index_of_refraction=IOR_air;
            for iObject=1:nObjects
                curr_Object=Objects{iObject};
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
                step_orig=Rays.step_size;
                Rays.step_size=Rays.step_size/100;
                
                next_position_temp=advance_rays(Rays,iRay);
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
                            next_position_temp=advance_rays(Rays,iRay);
                            x_mini=next_position_temp(1);
                            y_mini=next_position_temp(2);
                            next_position_temp=[x_mini y_mini];
                            next_position(iRay,:)=next_position_temp;
                            Rays.next_position=next_position;
                        end
                    else
                        curr_Object=current_object.object;
                        if inpolygon(x_mini,y_mini,curr_Object.XV,curr_Object.YV)
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
                
                
                %% process event type based on object properties
                curr_Object=current_object.object;
                prev_Object=last_object.object;
                
                %%% If in absorber, destroy
                if current_object.medium==1
                    Rays.tracing(iRay)=0;
                end
                
                %%% If in mirror, reflect
                if current_object.medium==2
                    N=curr_Object.normal;
                    Rays.cur_angle(iRay)=N-(Rays.cur_angle(iRay)-N);
                end
                
                %%% If in lens, refract depends on both last and current object
                if current_object.medium==3
                    % Enter lens
                    [min_dist, loc]=min(calc_dist_matrix([x_mini,y_mini],[curr_Object.XV,curr_Object.YV]));
                    angle_normal=curr_Object.Normals(loc);
                    Rays.cur_angle(iRay)=snells_law(prev_Object.index_of_refraction,curr_Object.index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                    
                    %plot(x_mini,y_mini,'m*')
                    %l=5;
                    %plot([x_mini-l*cos(angle_normal) x_mini+l*cos(angle_normal)],[y_mini-l*sin(angle_normal) y_mini+l*sin(angle_normal)],'k-')
                    
                elseif last_object.medium==3
                    % Exit lens
                    [min_dist, loc]=min(calc_dist_matrix([x_mini,y_mini],[prev_Object.XV,prev_Object.YV]));
                    angle_normal=prev_Object.Normals(loc);
                    Rays.cur_angle(iRay)=snells_law(prev_Object.index_of_refraction,curr_Object.index_of_refraction,Rays.cur_angle(iRay),angle_normal);
                    
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
            next_position(iRay,:)=next_position_temp;
            Rays.next_position=next_position;
            
            %%% Avoid long tracings
            step_nr=step_nr+1;
            if step_nr>2E3
                Rays.tracing(iRay)=0;
            end
            
            %%% Collect position in matrix
            M(step_nr,:)=[step_nr iRay next_position(iRay,:)];
        end
        %%
        M_all=cat(1,M_all,M,NaN(1,size(M,2)));
    end
    toc
catch
    M_all=cat(1,M_all,M);
    A=lasterror;
    disp(A.message)
end
%%
for iRay=1:nRays
    M_ray=M_all(M_all(:,2)==iRay,:);
    if iRay==ceil(nRays/2)
        set(Rays.chief,'Xdata',M_ray(:,3),'Ydata',M_ray(:,4))
    else
        set(Rays.p(iRay),'Xdata',M_ray(:,3),'Ydata',M_ray(:,4))
    end
end
std(Rays.cur_angle)


if 0 % show movie
    %%
    nSteps=max(M_all(:,1));
    %set(p,'marker','.')
    speed=3;
    for iStep=1:speed:nSteps
        for iRay=1:nRays
            M_now=M_all(M_all(:,1)<iStep&M_all(:,2)==iRay,:);
            if iRay==ceil(nRays/2)
                set(Rays.chief,'Xdata',M_now(:,3),'Ydata',M_now(:,4))
            else
                set(Rays.p(iRay),'Xdata',M_now(:,3),'Ydata',M_now(:,4))
            end
        end
        drawnow
    end
end
%sum(min(abs([Rays.cur_angle Rays.cur_angle-2*pi]),[],2))


if 0
    %%
    print(gcf,save_name,'-depsc')
end


