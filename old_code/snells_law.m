function angle_out=snells_law(n1,n2,angle_in,normal)

switch 7
    case 1
        % function angle_out=snells_law(IOR_leaving,IOR_entering,angle_in)
        %
        % angle_out=asin((IOR_leaving*sin(angle_in)) / IOR_entering);
        %
        % % check solution
        % check=[IOR_entering/IOR_leaving sin(angle_in)/sin(angle_out)]
        % %[angle_in angle_out]
    case 2
        % detect cases where incident beam is coming from direction normal is
        % pointing to
        if abs(theta_01-normal)<pi
            theta_02=normal+asin(n1*sin(theta_01-normal)/n2)-pi;
            %disp('Against normal')
        else
            theta_02=normal+asin(n1*sin(theta_01-normal)/n2);
            disp('Along normal')
            [theta_01 normal theta_01-normal theta_02]/pi*180
        end
    case 3
        % incident angle relative to face normal, within pi range
        angle_in=mod(theta_01-normal,pi);
        refraction_angle=angle_in-asin(n1*sin(angle_in)/n2);        
        theta_02=theta_01-refraction_angle;
        
        [theta_01 normal angle_in refraction_angle theta_02]/pi*180
        
    case 4
        theta_01=min(abs([angle_in-normal angle_in-normal+pi]))
        theta_02=asin(n1*sin(theta_01)/n2)
    case 5
        theta_01=min(abs([angle_in-normal angle_in-normal+pi]));
        %n1/n2
        theta_02=asin(n1*sin(theta_01)/n2);
        deflection=theta_02-theta_01;
        angle_out=angle_in+deflection;
        
        %[incident_angle normal theta_01 theta_02 deflection out_angle]/pi*180
    case 6
        normal_difference=abs(angle_in-normal);
        normal_difference_pi=abs(angle_in-normal+pi);
        
        if normal_difference>normal_difference_pi
            %disp('against normal')
            theta_in=angle_in-normal+pi;
            theta_out=asin((n1/n2)*(sin(theta_in)));
            angle_out=normal+pi-theta_out;
            
            [angle_in normal normal_difference normal_difference_pi theta_in theta_out angle_out]/pi*180
        else
            %disp('along normal')            
            theta_in=angle_in-normal-pi;
            theta_out=asin((n1/n2)*(sin(theta_in)));
            angle_out=normal-theta_out;
            
            [angle_in normal normal_difference normal_difference_pi theta_in theta_out angle_out]/pi*180
        end
        %angle_in/angle_out
    case 7
        theta_in=angle_in-normal;
        theta_in_lim=constrain_angle(theta_in);
        
        theta_out=asin(n1/n2 * theta_in_lim);
        angle_out=mod(normal+pi+theta_out,2*pi);
        
%         if theta_in>pi
%             disp('against normal')
%             
%         elseif theta_in<-pi
%             disp('against normal')
%             theta_out=asin((n1/n2)*constrain_angle(sin(theta_in)));
%         else
%             disp('along normal')
%         end
        %[angle_in normal theta_in_lim theta_out angle_out]/pi*180
end


% check=[n2/n1 sin(theta_01)/sin(theta_02)];
% if diff(check)>1e-6
%     [check diff(check)]
%     error('Calculation error in Snell''s law')
% end


