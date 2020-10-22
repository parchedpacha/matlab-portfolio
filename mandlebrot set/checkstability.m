function [num2fail] = checkstability(num,threshold)
%CHECKSTABILITY Iterates over the mandlebrot set to check if answer goes to
%inf.
%   No detailed explanation

%% Variable Initialization
dist=0;
numruns=0; 
maxruns=threshold;
Zn=0;
%% Iteration
while (numruns < maxruns) && (dist < 2)
    Zn=Zn^2 + num; %iterate
    numruns=numruns+1; %count iterations
    dist=abs(Zn); %use this to check for failure condition
end


%% Variable checking and output assignment

if numruns==maxruns
    num2fail=0;
else
    num2fail=maxruns-numruns;
end

end

