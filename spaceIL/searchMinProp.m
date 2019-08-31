% addpath C:\Users\Oagroup\Dropbox (Weizmann Institute)\spaceIL\updated
addpath properties_study

% for s=1:5
%     switch s
%         case 1
%             site='Wohler'
%             dir='C:\Users\oagroup.WISMAIN\Dropbox (Weizmann Institute)\spaceIL\updated\Landing_sites\site_Wohler_Lat-38_Lon29.5_size5x6.3';
%         case 2
%             site='Wohler Smaller';
%             dir='C:\Users\oagroup.WISMAIN\Dropbox (Weizmann Institute)\spaceIL\updated\Landing_sites\site_Wohler_smaller_Lat-38_Lon29.5_size1.5x1.9';
%         case 3
%             site='Buch'
%             dir='C:\Users\oagroup.WISMAIN\Dropbox (Weizmann Institute)\spaceIL\updated\Landing_sites\site_Buch_Lat-37.4_Lon15.3_size5x6.3';
%         case 4
%              site='Gemma Frisius'
%              dir='C:\Users\oagroup.WISMAIN\Dropbox (Weizmann Institute)\spaceIL\updated\Landing_sites\site_Rabbi_Levi_Lat-36.7_Lon19.7_size5x6.2';
%         case 5
%              site='Rabbi Levi'
%              dir='C:\Users\oagroup.WISMAIN\Dropbox (Weizmann Institute)\spaceIL\updated\Landing_sites\site_Gemma_Frisius_Lat-36.2_Lon14.5_size5x6.2';

showMaps;
% f=showMaps3('site_Large_Lat-38_Lon22_size4x9');

%%
cols=get(gca,'ColorOrder');

res = [512,128,16,16,5];
kpd = 30.3234; %km per degree on the moon

% filename = [site, '\optimized_sites.xlsx'];
filename = strcat(dir,'\optimized_sites_details.xlsx');
titles={'Longitude','Latitude','Radius (km)','del_Topography (m)','max RA (%)','max Slope (deg)','max Roughness (m)','max Magnetic Field (nT)','<RA>(%)'...
    '<Slope> (deg)','<Roughness> (m)','<Magnetic Field> (nT)'};
xlswrite(filename,titles);

for i=1:4
%7.5 km minimizing delta topography: 
% figure(2);
r=7.5;
rd=r/kpd;

[blon,blat] = findMinMap(Longitude,Latitude,r,f(i),lonRadius,latRadius,i);

for j=1:length(f)
    pxlim=xlim(f(j)); pylim=ylim(f(j));
    pclim=get(f(j),'CLim');
    xtlim=[blon-rd/cosd(blat),blon+rd/cosd(blat)];
    ytlim=[blat-rd,blat+rd];
    set(f(j),'xlim',xtlim,'ylim',ytlim)  
    [maxv(j),minv(j),meanv(j)]=stretchroi(f(j),res(j),[blon,blat,r/kpd/cosd(blat),r/kpd,0],j);
    set(f(j),'xlim',pxlim,'ylim',pylim)
    set(f(j),'CLim',pclim);
end

data=[blon,blat,r,maxv(1)-minv(1),maxv(2),maxv(3),maxv(4),maxv(5),meanv(2),meanv(3),meanv(4),meanv(5)];
xlRange=strcat('A',num2str(i+1));
xlswrite(filename,data,1,xlRange);

r=15;
rd=r/kpd;

[blon,blat] = findMinMap(Longitude,Latitude,r,f(i),lonRadius,latRadius,i);

for j=1:length(f)
    pxlim=xlim(f(j)); pylim=ylim(f(j));
    pclim=get(f(j),'CLim');
    xtlim=[blon-rd/cosd(blat),blon+rd/cosd(blat)];
    ytlim=[blat-rd,blat+rd];
    set(f(j),'xlim',xtlim,'ylim',ytlim)  
    [maxv(j),minv(j),meanv(j)]=stretchroi(f(j),res(j),[blon,blat,r/kpd/cosd(blat),r/kpd,0],j);
    set(f(j),'xlim',pxlim,'ylim',pylim)
    set(f(j),'CLim',pclim);
end

data=[blon,blat,r,maxv(1)-minv(1),maxv(2),maxv(3),maxv(4),maxv(5),meanv(2),meanv(3),meanv(4),meanv(5)];
xlRange=strcat('A',num2str(i+5));
xlswrite(filename,data,1,xlRange);
end

data=xlsread(filename);
f=figure('pos',[100,100,1400,400]);
t=uitable(f,'Position',[20 20 1370 300],'data',data,'columnname',titles,'fontsize',14,'ColumnWidth',{100});

filename(end-3:end)='fig ';
savefig(filename)
% type comparison4.xt
% fileID = fopen('properties_study\comparison4.txt','a');
% fprintf(fileID,'%6.4f %6.4f %3.2f %3.0f %3.2f %3.1f %3.2f\n',lon,lat,r,maxv(1)-minv(1),maxv(2),maxv(3),maxv(4));
% fclose(fileID);
% end