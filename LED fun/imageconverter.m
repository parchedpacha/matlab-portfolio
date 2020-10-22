%Kyle Magness
clc;clear;clf;

% this function loads small images, then converts them into arduino code
% for loading onto a persistance of vision display.

%% variables
numpixels=28;

%% loading and shrinking
[file,path]=uigetfile({'*.jpg;*.png;*.bmp;*.gif;*.jpeg','Image files (*.jpg,*.png,*.bmp,*.gif,*.jpeg)'});
%get filename easily
image= imread( [path,file]);  %read in file

w=size(image,2);
h=size(image,1);
ar=w/h;


if h > numpixels
    nw=round(ar*numpixels);
    newimage=imresize(image,[numpixels,nw]);
else
    newimage=image;
    nw=w;
    numpixels=h;
end



%% viewing
subplot(2,2,1);
imshow(image);
title('Original');
subplot(2,2,2);
imshow(newimage);
title('compressed');
%% tranasform
newimage=flip(newimage,1);
subplot(2,2,3);

imshow(newimage);
title('transformed image');

%% making arduino variables
p(1,:)=['const PROGMEM byte red[][',num2str(numpixels),']={'];
p(2,:)=['const PROGMEM byte grn[][',num2str(numpixels),']={'];
p(3,:)=['const PROGMEM byte blu[][',num2str(numpixels),']={'];
fa='';
for i=1:3 %this is for each color
    for j=1:nw %this loop goes left to right, for a row

        var=char(zeros(1,4*numpixels)   +65);
        for k=1:numpixels
            if newimage(k,j,i) <10
               c = ['  ',num2str(newimage(k,j,i))];
            elseif newimage(k,j,i) <100
               c = [' ',num2str(newimage(k,j,i))];
            else
                c = num2str(newimage(k,j,i));
            end
            var( (k-1)*4+1:(k-1)*4+4)= [c,','];
        end
       var = ['{' ,var(1:end-1) , '}' ];
        
        
        if j==1%this starts off thewhole shbang
            var2= [p(i,:), newline, var , ', ',newline   ];
        elseif j==nw % this pads the end with nulls to separate images
            var2= [var2, var ,',',newline, '{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}, ',newline,'{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}, ',newline,'{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}, ',newline,'{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}, ',newline,'{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}',newline,'}'  ];
        else
            var2= [var2, var , ', ',newline  ];
        end
    end
    
    
    
    fa=[fa,var2,';',newline];
end

%% showing just red
redimg=newimage;
redimg(:,:,2:3)=0;

subplot(2,2,4);
imshow(redimg);
title('just the red channel');

%% writing to file

fid= fopen([file(1:end-4),'arduino.txt'],'w');
fprintf(fid,'%s',fa);
fclose(fid);