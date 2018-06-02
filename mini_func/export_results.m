function [isFerro,lines_Static,numPixels,x_offset_new,y_offset_new,Ang_x,Ang_y] = export_results(float_amp,float_pha,mask_Pha,mask_Amp,png_folder,ibw_name,t,gx,gy)

line_length=[-16 -8 -4 -2  0  2 4 8 16];  

pixel_size=length(float_amp);

float_amp=rot90(float_amp,1);
float_pha=rot90(float_pha,1);
mask_Pha=rot90(mask_Pha,1);
mask_Amp=rot90(mask_Amp,1);

Amp=float_amp(t+1:pixel_size-t,t+1:pixel_size-t); 
Pha=float_pha(t+1:pixel_size-t,t+1:pixel_size-t); 
c1 = [0 1];

Pha_edge = edge(float_pha,'canny');
Amp_edge = edge(float_amp,'canny');


%%

% figure;
% scrsz = get(0,'ScreenSize');
% set(gcf,'Position',scrsz);
redblue_flip=flipud(redblue);
% subplot(241);imagesc(float_amp);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
% title('Amp-Original');colorbar;colormap(gca,redblue);
% caxis(c1);
% subplot(242);imagesc(float_pha);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
% title('Pha-Original');colorbar;colormap(gca,redblue);

%% Amp - Domain Boundary

F=mask_Amp;
subplot(131);h=imagesc(F);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
title('AI:   Amp');
% colorbar;caxis(c1);

%% Pha - Domain Boundary

F=mask_Pha;
subplot(132);h=imagesc(F);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
title('AI:   Pha');
% colorbar;caxis(c1);

%%  Amp+Pha
BW0=mask_Pha&mask_Amp;

% mask_Pha_1 = bwmorph(mask_Pha,'thick',3);
% mask_Amp_1 = bwmorph(mask_Amp,'thick',3);
% BW=mask_Pha_1&mask_Amp_1;

BW=BW0;
% BW = bwmorph(BW,'skel');

CC = bwconncomp(BW);
numPixels = cellfun(@numel,CC.PixelIdxList);

lines_Static = zeros(1,30);
for i = 2:2:60
    lines_Static(i/2) = sum(numPixels>i);
end

[~,idx] = find(numPixels<10);
for i=1:length(idx)
    BW(CC.PixelIdxList{idx(i)}) = 0;
end

%% Resturn with pixel as units
gx=rot90(gx);
gy=rot90(gy);
[~,m_index]=max(numPixels);

if( isempty(numPixels) || ( max(numPixels)<20 && length(find(numPixels>25))<5 ) )
    isFerro=0;
else
    isFerro=1;
end

if(~isempty(m_index))
    
    tt=CC.PixelIdxList{m_index};
    t3=tt(round(end/2));
else
    t3=1;
end
x_offset_new=floor(t3/size(BW,1));
y_offset_new=mod(t3,size(BW,1));
BW=BW*1;

Ang_x= 1;
Ang_y= 0;

if( isFerro==1)
    
    BW=insertMarker(BW,[x_offset_new,y_offset_new],'o','color','red','size',5);

    if (y_offset_new==t) 
        y_offset_new=t+1;
    end
    if (x_offset_new==t) 
        x_offset_new=t+1;    
    end

        Ang_x= gx(y_offset_new-t,x_offset_new-t);
        Ang_y= gy(y_offset_new-t,x_offset_new-t);

    for i=1:2:length(line_length)     

        sspfm_x=x_offset_new+line_length(i)*Ang_x*2;
        sspfm_y=y_offset_new-line_length(i)*Ang_y*2;    
        BW=insertMarker(BW,[sspfm_x,sspfm_y],'x','size',3);
    end
end

% subplot(247);h=imagesc(BW0);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
% title('AI: Amp && Pha');colorbar;caxis(c1);

subplot(133);
if( isFerro==1)
    imagesc(BW);title('AI:  FE domain wall');
else
    imagesc(zeros(length(BW)));title('AI:  Not FE');
end
axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
caxis([0 1]);

F0 = (Pha_edge&Amp_edge);
% subplot(243);h=imagesc(F0);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
% title('Tradition: Amp && Pha');colorbar;caxis(c1);

F = F0;
CC2 = bwconncomp(F);
numPixels2 = cellfun(@numel,CC2.PixelIdxList);
[~,idx2] = find(numPixels2<10);
for i=1:length(idx2)
    F(CC2.PixelIdxList{idx2(i)}) = 0;
end
% subplot(244);h=imagesc(F);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
% title('Tradition: filter applied');colorbar;caxis(c1);




%% print png
    
if (isFerro==1)
    name=[png_folder,'\Ferroelectric\',ibw_name];
else
    name=[png_folder,'\Non\',ibw_name];
end

% print(gcf, [name,'.png'], '-dpng', '-r72');

end
