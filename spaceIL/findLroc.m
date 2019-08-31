function imagesLabels=findLroc(Lat,Lon,latRadius,lonRadius,dir,outMode,opt)
%% function imagesLabels=findLroc(Lat,Lon,latRadius,lonRadius,dir,outMode,opt)
% Find the relevant images of a landing site and return an object that 
% contains all information about those images. It can show on each 
% requested map the locations of those images (frames), 
% and can donwload them from the LROC server. 

if (~exist('opt','var'))
    opt=[];
end
%addpath('D:\Data\LROC_NAC')
%addpath('C:\Data\LROC_NAC')
if ~exist('CUMINDEX','var'),
    load('Data\LROC_NAC\CUMINDEX.mat') %load all LROC labels data file
end
if Lon<0, Lon=Lon+360; end
%    & CUMINDEX.INCIDENCE_ANGLE>60 & CUMINDEX.INCIDENCE_ANGLE<90);
%% find each image which partially overlay with the area of the site:
%U_L    U_R
%   site
%L_L    L_R
f=find(CUMINDEX.NAC_CHANNEL_A_OFFSET<999  ...
    &( ...
    (CUMINDEX.UPPER_LEFT_LATITUDE<(Lat+latRadius) & CUMINDEX.UPPER_LEFT_LATITUDE>(Lat-latRadius) ...
    & CUMINDEX.UPPER_LEFT_LONGITUDE>(Lon-lonRadius) & CUMINDEX.UPPER_LEFT_LONGITUDE<(Lon+lonRadius))...
    | ...
    (CUMINDEX.LOWER_LEFT_LATITUDE<(Lat+latRadius) & CUMINDEX.LOWER_LEFT_LATITUDE>(Lat-latRadius) ...
    & CUMINDEX.LOWER_LEFT_LONGITUDE>(Lon-lonRadius) & CUMINDEX.LOWER_LEFT_LONGITUDE<(Lon+lonRadius))...
    | ...
    (CUMINDEX.LOWER_RIGHT_LATITUDE<(Lat+latRadius) & CUMINDEX.LOWER_RIGHT_LATITUDE>(Lat-latRadius) ...
    & CUMINDEX.LOWER_RIGHT_LONGITUDE>(Lon-lonRadius) & CUMINDEX.LOWER_RIGHT_LONGITUDE<(Lon+lonRadius))...
    | ...
    (CUMINDEX.UPPER_RIGHT_LATITUDE<(Lat+latRadius) & CUMINDEX.UPPER_RIGHT_LATITUDE>(Lat-latRadius) ...
    & CUMINDEX.UPPER_RIGHT_LONGITUDE>(Lon-lonRadius) & CUMINDEX.UPPER_RIGHT_LONGITUDE<(Lon+lonRadius))...
    | ...
    (CUMINDEX.CENTER_LATITUDE<(Lat+latRadius) & CUMINDEX.CENTER_LATITUDE>(Lat-latRadius) ...
    & CUMINDEX.CENTER_LONGITUDE>(Lon-lonRadius) & CUMINDEX.CENTER_LONGITUDE<(Lon+lonRadius))...
    )...
    );
% if want only stereo pairs add this condition: 
%     & CUMINDEX.INCIDENCE_ANGLE>40 & CUMINDEX.INCIDENCE_ANGLE<65 & CUMINDEX.EMMISSION_ANGLE>2);

disp(['found ',num2str(length(f)),' images']);

% create the output object: 
Fnames=fieldnames(CUMINDEX);
for i=1:length(Fnames)
    imagesLabels.(char(Fnames(i))) = CUMINDEX.(char(Fnames(i)))(f,:);
end

%% plot frames:
for i=1:length(Fnames)
    plotLrocFrame(imagesLabels,i,opt);
end

%% produce a correct download link, and download if requested:

%imagesLabels = struct([Fnames' 'Link'])
%    & abs(CUMINDEX.CENTER_LONGITUDE-CUMINDEX.SUB_SOLAR_LONGITUDE)<10);
%stop
%for i=4:3,
if ~strcmp(outMode,'frameOnly')
for i=1:length(f),
    wfn=CUMINDEX.FILE_SPECIFICATION_NAME(f(i),:);
%     wfn=regexprep(wfn,'DATA/MAP','EXTRAS/BROWSE');
%     wfn=regexprep(wfn,'DATA/SCI','EXTRAS/BROWSE');
%     wfn=regexprep(wfn,'DATA/COM','EXTRAS/BROWSE');
%     wfn=regexprep(wfn,'DATA/ESM2','EXTRAS/BROWSE');
%     wfn=regexprep(wfn,'DATA/ESM','EXTRAS/BROWSE');
    if (strfind(wfn,'NAC') & strfind(wfn,'CDR'))%only narrow angle camera & Calibrated Data Record images
        wfn=regexprep(wfn,'"','');
        wfn=regexprep(wfn,'    ','');
        wfn=regexprep(wfn,'   ','');
        wfn=regexprep(wfn,' ','');
        wfn=regexprep(wfn,'','');
        wfn=strtrim(wfn);
        wfn=regexprep(wfn,'NAC/','');
        wfn=regexprep(wfn,'.IMG','_pyr.tif');
        wfn=['http://lroc.sese.asu.edu/data/',wfn];
        %fn=[CUMINDEX.PRODUCT_ID(f(i),:),'_pyr.tif'];
        %fn=regexprep(fn,'"',''); fn=regexprep(fn,' ','');
        sl=strfind(wfn,'/');
        picName=[dir '\' wfn(sl(end)+1:end)];
        imagesLabels.Link(i,1:length(wfn)) = wfn; 
        %Links{i} = wfn;
        %disp(wfn);
        if strcmp(outMode,'download')
    %             if ~exist(picName,'file');    
                    %unix(['/opt/local/bin/wget  -nv ',wfn]);
    %                 websave(picName,wfn,weboptions('Timeout',10)); 
    %                 pause(30);
%             websave(picName,wfn,'-browser');
            web(wfn(sl(end)+1:end),wfn,'-browser'); %save image to default download folder of the browser
%             pause(30);
            
    %             end
        end
    end
end
    imagesLabels.Link = Links;

end
end
