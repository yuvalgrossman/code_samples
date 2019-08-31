function h=plotEllipse(frame,ellipseProp,color,facecolor,faceAlpha,txt)
% Plot ellipse in a specific frame
% h = plotEllipse(frame,ellipseProp,color,txt)
% 
%   Input Arguments: 
% frame: axis handle (default is current axis)
% ellipseProp: vector of ellipse properties: 
% [centroid coordinates x0, y0, semi major axis, semi minor axis, orientation]
% color: of plotted ellipse
% txt: text to print at the center of the ellipse
% 
% Author: Yuval Grossman
% Department of Earth and Planetary Sciences
% Weizmann Institute of Science
% Updated: 20/12/18

if nargin==0 
    help plotEllipse
    return
end
if ~exist('color','var')
    frame=gca;
end
if ~exist('color','var')
    color='r';
end

phi = linspace(0,2*pi,100); cosphi = cos(phi); sinphi = sin(phi); 

for i=1:size(ellipseProp,1)
xbar=ellipseProp(i,1);
ybar=ellipseProp(i,2);
a = ellipseProp(i,3);
b = ellipseProp(i,4);
theta = ellipseProp(i,5);

R = [ cosd(theta)   -sind(theta)
      sind(theta)    cosd(theta)];
xy = [a*cosphi; b*sinphi];
xy = R*xy;
x = xy(1,:) + xbar;
y = xy(2,:) + ybar;
hold on
% h=plot(frame,x,y,'LineWidth',1,'color',color);
h=patch(frame,x,y,facecolor,'facealpha',faceAlpha,'edgealpha',1,'edgecolor',color);

if exist('txt','var') & size(txt)
    text(xbar,ybar,txt(i,:),'HorizontalAlignment','center');
end

if (~a & ~b)
    h=plot(frame,xbar,ybar,'.','LineWidth',1,'color',color);
end
end
end