function angle=calc_heading(varargin)

if nargin==1
    input=varargin{1};
    if size(input,2)~=4
        input=input';
    end
    x1=input(:,1);
    y1=input(:,2);
    x2=input(:,3);
    y2=input(:,4);
elseif nargin==2
    p1=varargin{1};
    p2=varargin{2};
    
    if isstruct(p1)
        x1=p1.xCoord;
        y1=p1.yCoord;
        x2=p2.xCoord;
        y2=p2.yCoord;
    else
        d=NaN(size(p1,1),size(p2,1));
        for i=1:size(p1,1)
            for j=1:size(p2,1)
                x1=p1(i,1);
                y1=p1(i,2);
                x2=p2(j,1);
                y2=p2(j,2);
            end
        end
    end
elseif nargin==4
    x1=varargin{1};
    y1=varargin{2};
    x2=varargin{3};
    y2=varargin{4};
end

if x1~=x2&&y1~=y2
    %if ~eq(x1,x2)&~eq(y1,y2)
    rico=(y2-y1)/(x2-x1);
    angle=atan(rico);
elseif x1==x2
    angle=pi/2;
elseif y1==y2
    angle=0;
end
