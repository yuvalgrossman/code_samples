function [blon,blat]=findMinMap(lon,lat,r,ax,lonRadius,latRadius,mapN)
% Find the site with the minimum delta topography/ra/slope/roughness for specific radius 
% map: data product number: 1-topography, 2-rock abundance, 3-slopes, 4-roughness

kpd = 30.3234; %km per degree on the moon
rd = r/kpd; %radius in degrees
res = [512,128,16,16]; %resolution for maps of: topography, ra, slope, roughness
h=plotEllipse(ax,[lon,lat,rd/cosd(lat),rd,0]);
t=text(ax,lon-rd/2,lat,['\Delta: ']);
pxlim=xlim(ax); pylim=ylim(ax);
pclim=get(ax,'CLim');

d=round(diff(pylim)-2*rd)*res(3)  %number of grid points
% d=4

a=[linspace(-lonRadius+rd/cosd(lat),lonRadius-rd/cosd(lat),d)+lon]; %vector of longitudes
b=[linspace(-latRadius+rd,latRadius-rd,d)+lat];                     %vector of latitudes
rp=rd*res(mapN); %radius in pixels

optimizedPar=10000; 

for lon=a
    for lat=b
        xtlim=[lon-rd/cosd(lat),lon+rd/cosd(lat)];
        ytlim=[lat-rd,lat+rd];
        set(ax,'xlim',xtlim,'ylim',ytlim)
        [maxv,minv,~]=stretchroi(ax,res(mapN),[lon,lat,rd/cosd(lat),rd,0],mapN);
        set(ax,'xlim',pxlim,'ylim',pylim)
        switch mapN
            case 1
                if (maxv-minv<optimizedPar)
                    optimizedPar = maxv-minv    %minimal delta topography
                    blon=lon; blat=lat;         %best longitude and latitude
%                     madianPar = medianv;        %median value of the optimized site
                    h.Visible='off'; t.Visible='off';
                    h=plotEllipse(ax,[blon,blat,rd/cosd(blat),rd,0]);
                    t=text(ax,lon-rd/2,lat,['\Delta: ' num2str(optimizedPar,3)]);
                    drawnow
                end
            case {2 3 4}
                if (maxv<optimizedPar)     %minimizing the maximum value of the parameter within the map
                    optimizedPar = maxv     %maximum value
                    blon=lon; blat=lat;     %best longitude and latitude
%                     madianPar = medianv;    %median value of the optimized site
                    h.Visible='off'; t.Visible='off';
                    h=plotEllipse(ax,[blon,blat,rd/cosd(blat),rd,0]);
                    t=text(ax,lon-rd/2,lat,['Max: ' num2str(optimizedPar,3)],'color','k');
                    drawnow
                end
            end
        
    end
end

set(ax,'CLim',pclim);
