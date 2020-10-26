% Kyle Magness
%MISC project: Mandlebrot Set.
clc;clear;
sizeview=[1920,1080];%1080p
threshold=200;

scale=0.002;
center=[0,0];
numsize=[-(sizeview(1)/2)*scale + center(1),(sizeview(1)/2)*scale + center(1),...
    -(sizeview(2)/2)*scale + center(2),(sizeview(2)/2)*scale + center(2)];
% xmin,xmax,ymin,ymax
go = 1;
while go
    fprintf("Render start...");
    %% determine if second run or first run
    if exist("h","var")
        center=[ interp1([1,sizeview(1)],numsize(1:2),h.Position(1)),interp1([1,sizeview(2)],numsize(3:4),h.Position(2))];
        scale=scale/2;
        numsize=[-(sizeview(1)/2)*scale + center(1),(sizeview(1)/2)*scale + center(1),...
            -(sizeview(2)/2)*scale + center(2),(sizeview(2)/2)*scale + center(2)];
        %numsize=[-2,1.1,-1,1];
        % xmin,xmax,ymin,ymax

        if  ( (h.Position(1)<10)&&(h.Position(2)))
            go=0;
            fprintf("Render Cancelled\n")
            break
        end
        h=[];
    end
    %% check stability of all points

    numsx=linspace(numsize(1),numsize(2),sizeview(1));  %locations of pixels in X direction
    numsy=linspace(numsize(3),numsize(4),sizeview(2))*1i; %same in Y / complex direction.
    [NX,NY] =meshgrid(numsx,numsy); %creates a complex plane representaed by an array of complex numbers
    pixels=NX+NY; %combines into 1 array
    pzed=zeros(length(numsy),length(numsx)); %creates an array of zeros for holding iterations
    pcount=pzed;  %array for holding the number of times that the result of the mandlebrot thing is less than 2
    for k=1:threshold %check stability this many times
        pzed= pzed.^2 +pixels; %the actual iteration equation.
        plog=abs(pzed)<2; %checks if iteration value is less than 2
        pcount=pcount+plog; %stores all those in the array
        
    end    
    %% Set the Stable points to 0 for coloring
    %this next line compares values in the entire array to he threshold
    %value, if any values have survived all the iterations, then reset them
    %to zero.
    pend=(threshold.*ones(length(numsy),length(numsx)));
    pcount = (~(pcount == pend )).* pcount;
    
    pixels=zeros(length(numsy),length(numsx),3); %total array for picture
    colmap=copper(threshold+1);
    colmap(1,:)=[0,0,0];
    
        for k = 1:length(numsx) %k for X
            for i = 1:length(numsy) %i for Y
                pixels(i,k,:)=colmap(pcount(i,k)+1,:);
            end
        end
    pixels=uint8(pixels*255);
    axis equal
    %save('madlebrotinfo.mat',["center","scale","sizeview","numsize"]);
    
    
    imshow(pixels)
    fprintf("Render Complete\n")
    h=drawpoint;
    while ~exist('h','var') && isempty(h)
        pause(0.01);
        
       
    end
end