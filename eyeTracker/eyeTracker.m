% give focal length and lens thickness
% optionally, constrain heigth to be SM05 SM1 or SM2,
% lens will possibly be flat at the ends
% both concave and convex lenses can be made

clear all
clc

IOR_air=1.00029;
IOR_water=1.3333;
IOR_glass=1.517;


% create optical objects
Objects=cell(0,0);
Object_counter=1;

init_angle=-20;
angle_diff=-5;

inch=25.4;
init_dist=0*inch;
dist_diff=3*inch;

target_dist=7*inch;

% mirror 01
mirror_options=default_mirror;
mirror_options.thickness=1;
mirror_options.height=2*inch;
mirror_options.angle=init_angle/180*pi;
mirror_options.spatial_location=[-inch/3 init_dist];
Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;

% mirror 02
mirror_options=default_mirror;
mirror_options.thickness=1;
mirror_options.height=2*inch;
mirror_options.angle=(init_angle+angle_diff)/180*pi;
mirror_options.spatial_location=[inch/3 init_dist+dist_diff];
Objects{Object_counter}=create_mirror(mirror_options);Object_counter=Object_counter+1;

% tissue
absorber_options=default_absorber;
absorber_options.thickness=5;
absorber_options.spatial_location=[target_dist 5*inch];
absorber_options.height=10*inch;
absorber_options.nPoints=200;
absorber_options.angle=0;
Objects{Object_counter}=create_absorber(absorber_options);Object_counter=Object_counter+1;

nObjects=length(Objects);

%% Set tracing parameters
step_size=1; % choose step_size smaller than thinnest object, and do refinement step when in object5
beam_diameter=2*inch;
nRays=25;

initial_direction=pi/2;

center_location=[0 -50];
horizontal_spread=[-.5 .5]*beam_diameter*sin(initial_direction);
vertical_spread=[-.5 .5]*beam_diameter*cos(initial_direction);

next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
cur_angle=ones(nRays,1)*initial_direction;


Rays.nRays=nRays;
Rays.step_size=step_size;
Rays.next_position=next_position;
Rays.cur_angle=cur_angle;
Rays.tracing=ones(nRays,1);
Rays.p=zeros(nRays,1);


%% Plot all optical elements
x_range=[-50 300];
y_range=x_range;

figure(1)
clf
hold on
plot(x_range,[0 0],'k--')
%plot([0 0],[-50 50],'k--')
%plot([-50 -50],[-50 50],'k--')

Total_path_length=350;

D1=Total_path_length-50-init_dist;
D2=Total_path_length-50-init_dist+dist_diff;

for iObject=1:nObjects
    plot(Objects{iObject}.XV,Objects{iObject}.YV,Objects{iObject}.line_style)
end

for iRay=1:nRays
    Rays.p(iRay)=plot(x_range(1),y_range(1),'r-','markerSize',1);
end
Rays.chief=plot(x_range(1),y_range(1),'r-','lineWidth',1);
axis([x_range y_range])
%axis equal
%set(gca,'xticklabel','','yticklabel','')
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
            if ~inpolygon(x,y,x_range,y_range)
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
            nSteps_per_ray(iRay)=step_nr;
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
figure(2)
bar(nSteps_per_ray)
%%
for iRay=1:nRays
    M_ray=M_all(M_all(:,2)==iRay,:);
    if iRay==ceil(nRays/2)
        set(Rays.chief,'Xdata',M_ray(:,3),'Ydata',M_ray(:,4))
    else
        set(Rays.p(iRay),'Xdata',M_ray(:,3),'Ydata',M_ray(:,4))
    end
end


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

