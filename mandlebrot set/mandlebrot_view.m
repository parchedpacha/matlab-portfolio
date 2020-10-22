% Kyle Magness
%MISC project: Mandlebrot Set.
clc;clear;

sizeview=[3840,2160];
scale=0.001;
center=[-0.74,0];
numsize=[-(sizeview(1)/2)*scale + center(1),(sizeview(1)/2)*scale + center(1),...
         -(sizeview(2)/2)*scale + center(2),(sizeview(2)/2)*scale + center(2)];
%numsize=[-2,1.1,-1,1];
% xmin,xmax,ymin,ymax
numsx=linspace(numsize(1),numsize(2),sizeview(1));  %locations of pixels in X direction
numsy=linspace(numsize(3),numsize(4),sizeview(2))*1i;
pixels=zeros(length(numsy),length(numsx),3); %total array for picture
threshold=100;

colmap=copper(threshold+1);
colmap(1,:)=[0,0,0];

for k = 1:length(numsx) %k for X
    for i = 1:length(numsy) %i for Y
        pixels(i,k,:)=colmap(checkstability(numsx(k)+numsy(i), threshold)+1,:);

    end
end

pixels=uint8(pixels*255);

axis equal


image(pixels)