function ellipsePixs=findEllipsePixs(res,mapSize,a,b,theta)
% Find the pixels in a given map that are inside an ellipse.
% ellipsePixs = findEllipsePixs(res, mapSize, a, b, theta)
%    Input arguments:
% res: resolution of the map in pixels per degree (ppd)
% mapSize: the size of the map. The result of size(map)
% a,b: semi Major and minor axes, in degrees
% theta: oriantaion angle, in degrees
%    Output:
% ellipsePixs: map in the size of mapSize, with ones where the ellipse is
% and Nans where it isn't. 
%
% Author: Yuval Grossman
% Department of Earth and Planetary Sciences
% Weizmann Institute of Science
% Revised: 16/9/18

if nargin==0 
    help findEllipsePixs
    return
end

if (~exist('theta','var') || isempty(theta)) 
    theta=0;
end

ellipsePixs = nan(mapSize);
Rm = 1737.4;            %Lunar radius in Km
kpp = 2*pi*Rm/360/res;  %km per pixel
y=1:size(ellipsePixs,1);
x=1:size(ellipsePixs,2);
[X,Y]=meshgrid(x,y);
     x0=length(x)/2;
     y0=length(y)/2;
     %a=sites(eNum).semiMajorAxisKm/kpp; %(axes in term of degrees)
     %b=sites(eNum).semiMinorAxisKm/kpp;
     %theta=sites(eNum).Orientation;
     a = a*res;
     b = b*res;
     xc = (X-x0).*cosd(theta)-(Y-y0).*sind(theta);
     yc = (X-x0).*sind(theta)+(Y-y0).*cosd(theta);
ellipsePixs(((xc./a).^2+(yc./b).^2)<1)=1;
end