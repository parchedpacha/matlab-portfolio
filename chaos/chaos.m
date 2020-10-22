%kyle magness
%Chaos plotting
clc;clear;


%% Variables
w=1920*3; %width of image
h=1080*3; %height
pixels=zeros(h,w); %allocate space for image
weight=1; %used in adding light to the image


rmin=1;
rmax=4;

%% Math
for r=linspace(rmin,rmax,w) %loop over a bunch of r values 
    y=zeros(1,250);
    y(1)=0.1;

    for k=1:length(y)-1  %population growth equation
        y(k+1)=r*y(k)*(1-y(k));
    end

    y=y( round(end/2):end); %only use the last set of values
    y=uniquetol(y,1e-5);  % from those values, trim out duplicates and prep for plotting
    x=ones(1,length(y))*r; %create some x values for those y values, to ease plotting
    xp=round(x*w/rmax); %scale the x and y values such that they are within a picture
    yp=round(y*h); %rmax is not used here because the max value is pegged at 1, and dividing by 1 is uneccesary
    for q=1:length(yp) %read through each set of x and y pixels, and make sure there arent any out of bounds values
        if yp(q)==0
           yp(q)=1; 
        end
        if xp(q)>w
           xp(q)=w; 
        end
    end   
    pixels(yp,xp)=pixels(yp,xp)+weight.* sqrt( (xp-x).^2+(yp-y).^2 );
end
pixels= round(pixels./max(pixels).*256);
pixels=flip(pixels);
pixels=blur(pixels,1);
imshow(pixels)
imwrite(pixels,'chaos.png','png')