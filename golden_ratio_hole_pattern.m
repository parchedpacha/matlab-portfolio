clc;clear;clf
%Kyle Magness, spiral hole pattern generating script
%% variables
n=500; %number of holes
orad=2.5;%wanted outer radius, in inches
s=3; %for skipping some holes for plotting, 2 = no skip, 3 = #2 is skipped, 4 = 2&3 skipped
hole_rad=(1/16)/2; %hole radius
index=[1:n]; %this is to skip the plotting of some initial holes due to spacing
holes_to_plot=length(index); %must be equal to or less than the length of index


%% generating spiral in polar coords
phi = (sqrt(5)-1)/2; %fancy constant
rho = sqrt((0:n)/n);  %radius
theta = (0:n)*2*pi*phi; %angle

%rho = (0:n-1).^phi
%% converting to cartesian and scaling down
% rho2= (rho/max(rho))*orad; %scales math radii to physical radii
% sfunclin=@(r) (((-1.1+0.85)./orad).*r+1.1);
% sfuncexp=@(r) 2*exp(-r-0.2).^3+0.80;
% sfuncinsq=@(r) 1/(r^2);
% %linear scaling function
% %rho3=sfuncexp(rho2).*rho2;
% %[rho3]=gaussianscale(rho2).*rho2;
% [rho3]=gaussianscale(rho2).*rho2;
% rho4=(rho3/max(rho3))*(orad-hole_rad);
 %scales all radius values to wanted radius
[x,y] = pol2cart(theta,rho.*orad);



%change s to change at which hole you start plotting again
% subplot(2,4,[1,2,5,6])
%plot(x(index),y(index),'.b');
axis equal;hold on;
plot(0,0,'+k','MarkerSize',10)
title([num2str(holes_to_plot) ' Holes and Radii']);
set(gcf, 'color', 'w');
xlabel('Inches');ylabel('Inches');

%plotting hole diameters to check for intersections
t=linspace(0,2*pi,50);
xc=cos(t)*hole_rad;
yc=sin(t)*hole_rad;
for k=index(1:holes_to_plot) %this makes sure we downt draw on skipped circles
    xct=xc+x(k); %move circle to hole spot
    yct=yc+y(k);
    plot(xct,yct,'-b')
    
end

%subplot(2,4,[3,4,7,8]);hold on;
% fplot(sfuncexp,[0,orad]);
% fplot(sfunclin,[0,orad]);
%plot([0,orad],[1,1],'-k')
% title('Scaling functions visualized');
% axis([0,2.5,0.75,2])
% legend('gaussian','exponential','linear','no scaling');
% xlabel('radius');ylabel('scaling factor');
% disp([x',y'])

M=[x',y',zeros(length(x),1)];
csvwrite('pointsforimport.txt',M);
