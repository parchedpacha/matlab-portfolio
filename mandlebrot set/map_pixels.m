function [y] = map_pixels(x,a,b)
%MAP_PIXEL converts one range of numbers to another
%   No detailed explanation
y = (x-min(x)).*(b-a)./(max(x)-min(x)) + a;
end

