function H=lrocOnSite(ellipseProp,LrocLabels,imageNum,saveOpt,dir,ax,cropOpt)
%% function H=lrocOnSite(ellipseProp,LrocLabels,imageNum,saveOpt,dir,ax,cropOpt)
% Display the relevant part of an LROC NAC image within a landing site. 
% Input Arguments: 
% -ellipseProp: ellipse properties vector: 
%               [centroid coordinates (x0,y0), semi major axis, 
%                          semi minor axis, orientation angle]
% -LrocLabels: a structure contains all information of multiple LROC
% images. This is the output of findLroc.m
% -imageNum: the number of image to show, within LrocLabels
% -saveOpt: which format to save the image. options are: 
%           'fig' for editable matlab format
%           'print' for tif image format
%           'all' for both the above formats
%           'manual' for letting the user play with the figure before
%           saving it. 
% -dir: path to save the image in
% -ax: figure axes to plot the image in
% -cropOpt: show all the image (default), or just the overlay with the
% choosen site ('overlay')
% Output Argument: 
% -H: an image object (useful if one wants to delete or rearrange the show 
% order of several images shown in one axes)

if nargin==0 % plot the function's help if no arguments in
    help lrocOnSite
    return
end

refvec=[16 70 -90]; %referance vector: map resolution, first latitue, first longitude
%Longitude=site.CentCoord(1);Latitude=site.CentCoord(2);
Longitude=ellipseProp(1);Latitude=ellipseProp(2);
lonRadius=ellipseProp(3);latRadius=ellipseProp(4);

wfn=LrocLabels.Link(imageNum,:); 
sl=strfind(wfn,'/');
picName=[dir '\' wfn(sl(end)+1:end)];
if ~exist(picName,'file') % download image from LROC site if doesn't exist in path
    websave(picName,wfn,weboptions('Timeout',10)); 
end            

%for i=1:length(LrocLabels.PRODUCT_ID)
pid=LrocLabels.PRODUCT_ID(imageNum,:);
pid=regexprep(pid,'"',''); pid=regexprep(pid,' ','');
pic=imread([dir '\' pid '_pyr.tif']);
pic=pic(:,[find(pic(1,:),1,'first'):find(pic(1,:),1,'last')]);
% choose the boundaries of the image to show: 
llonlim=min([LrocLabels.UPPER_LEFT_LONGITUDE(imageNum),LrocLabels.LOWER_LEFT_LONGITUDE(imageNum),LrocLabels.UPPER_RIGHT_LONGITUDE(imageNum),LrocLabels.LOWER_RIGHT_LONGITUDE(imageNum)]);
rlonlim=max([LrocLabels.UPPER_LEFT_LONGITUDE(imageNum),LrocLabels.LOWER_LEFT_LONGITUDE(imageNum),LrocLabels.UPPER_RIGHT_LONGITUDE(imageNum),LrocLabels.LOWER_RIGHT_LONGITUDE(imageNum)]);
uplatlim=min([LrocLabels.UPPER_LEFT_LATITUDE(imageNum),LrocLabels.LOWER_LEFT_LATITUDE(imageNum),LrocLabels.UPPER_RIGHT_LATITUDE(imageNum),LrocLabels.LOWER_RIGHT_LATITUDE(imageNum)]);
lolatlim=max([LrocLabels.UPPER_LEFT_LATITUDE(imageNum),LrocLabels.LOWER_LEFT_LATITUDE(imageNum),LrocLabels.UPPER_RIGHT_LATITUDE(imageNum),LrocLabels.LOWER_RIGHT_LATITUDE(imageNum)]);

if (~exist('ax','var') || isempty(ax))
    figure(imageNum);
    ax=gca;

% old version - rotation of the image: 
% thetar=atand((LrocLabels.UPPER_RIGHT_LONGITUDE(i)-LrocLabels.LOWER_RIGHT_LONGITUDE(i))*cosd(Latitude)/(LrocLabels.UPPER_RIGHT_LATITUDE(i)-LrocLabels.LOWER_RIGHT_LATITUDE(i)));
% thetal=atand((LrocLabels.UPPER_LEFT_LONGITUDE(i)-LrocLabels.LOWER_LEFT_LONGITUDE(i))*cosd(Latitude)/(LrocLabels.UPPER_LEFT_LATITUDE(i)-LrocLabels.LOWER_LEFT_LATITUDE(i)));
% theta=mean([thetar,thetal]);
% if theta>0
%     pic=flip(pic);
% end
% R=imrotate(double(pic)./510,-theta);
% if LrocLabels.NORTH_AZIMUTH(i)<180
%     H=imagesc(ax,[llonlim rlonlim],[lolatlim uplatlim],R,'alphadata',logical(R>0));
% else 
%     H=imagesc(ax,[rlonlim llonlim],[lolatlim uplatlim],R,'alphadata',logical(R>0));
% end

% new version - full projection of the image, using imtransform: 
in_im = pic;
udata = [0 1]; 
vdata = [0 1];
fill_color = 0;
org_rect = [0 0;0 1;1 0;1 1];
new_rect=[LrocLabels.UPPER_LEFT_LONGITUDE(imageNum) LrocLabels.UPPER_LEFT_LATITUDE(imageNum);LrocLabels.LOWER_LEFT_LONGITUDE(imageNum) LrocLabels.LOWER_LEFT_LATITUDE(imageNum);LrocLabels.UPPER_RIGHT_LONGITUDE(imageNum) LrocLabels.UPPER_RIGHT_LATITUDE(imageNum);LrocLabels.LOWER_RIGHT_LONGITUDE(imageNum) LrocLabels.LOWER_RIGHT_LATITUDE(imageNum)];
tform = maketform('projective', org_rect, new_rect);
[out_im,xdata,ydata] = imtransform( in_im, tform, 'bicubic', 'udata', udata, 'vdata', vdata, 'size', size(in_im), 'fill', fill_color);
%R = double(out_im)./255;
H=imagesc(ax,out_im,'XData',xdata,'YData',ydata,'alphadata',logical(out_im>0));
axis image xy;colormap gray; hold on

plotEllipse(ax,ellipseProp);
plotLrocFrame(LrocLabels,imageNum)
xltemp=[max(llonlim,Longitude-lonRadius) min(rlonlim,Longitude+lonRadius)];
yltemp=[max(uplatlim,Latitude-latRadius) min(lolatlim,Latitude+latRadius)];

%limits:
if strcmp(cropOpt,'overlay')
    xlim(xltemp);
    ylim(yltemp);
end

title(['Lroc NAC image ' num2str(imageNum) ' - ' pid])
fsn=LrocLabels.FILE_SPECIFICATION_NAME(imageNum,:);
text(mean(xltemp),mean(yltemp),fsn(end-10:end-6),'color','w')
% show scale bar on the image: 
scalebarHandle = plotScalebar();

% when zooming and moving across the image - show scale bar and stretch the
% colorbar automatically: 
h = zoom;
h.ActionPreCallback = 'set(scalebarHandle,''Visible'',''off'');axis normal';
h.ActionPostCallback = 'scalebarHandle=plotScalebar();stretchroi;';
h.Enable = 'on';
h2 = pan;
h2.ActionPreCallback = 'set(scalebarHandle,''Visible'',''off'');axis normal';
h2.ActionPostCallback = 'scalebarHandle=plotScalebar();stretchroi;';
h2.Enable = 'on';

% save: 
mkdir([dir '\LROC\'])
switch saveOpt
    case 'fig'
        savefig([dir '\LROC\' pid])
    case 'print'
        print([dir '\LROC\' pid],'-dtiff','-r600')
    case 'all'
        savefig([dir '\LROC\' pid])
        print([dir '\LROC\' pid],'-dtiff','-r600')
    case 'manual'
        disp('Adjust limits and type ''dbcont'' to continue and save')
        keyboard
        savefig([dir '\LROC\' pid])
        print([dir '\LROC\' pid],'-dtiff','-r600')        
end
end