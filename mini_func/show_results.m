function [x_offset_new,y_offset_new,Ang_x,Ang_y] = show_results(Ht,mask,line_length)

    [~,edgeDir0] = imgradient(Ht);
    edgeDir=deg2rad(edgeDir0);
    gx= sin(edgeDir);
    gy= -cos(edgeDir);
    
GB_selected =     logical(mask); 
% GB_selected = bwmorph(GB_selected,'thin',10);
% GB_selected = bwmorph(GB_selected,'skel',inf);
% GB_selected = bwmorph(logical(GB_selected),'spur');

G_selected = ~GB_selected;


%% Resturn with pixel as units
gx=rot90(gx);
gy=rot90(gy);

BW = GB_selected;
CC = bwconncomp(BW);
numPixels = cellfun(@numel,CC.PixelIdxList);

        [~,idx] = find(numPixels<60);
        for j=1:length(idx)
            BW(CC.PixelIdxList{idx(j)}) = 0;
        end
        
[~,m_index]=max(numPixels);
    
tt=CC.PixelIdxList{m_index};
t3=tt(round(end/2));
    x_offset_new=floor(t3/size(BW,1));
    y_offset_new=mod(t3,size(BW,1));
BW0=BW;
BW=BW*1;


    BW=insertMarker(BW,[x_offset_new,y_offset_new],'o','color','red','size',5);

    t=2;
    if (y_offset_new==t) 
        y_offset_new=t+1;
    end
    if (x_offset_new==t) 
        x_offset_new=t+1;    
    end

        Ang_x= gx(y_offset_new-t,x_offset_new-t);
        Ang_y= gy(y_offset_new-t,x_offset_new-t);
        
    % find the normal line
    old_sum_Ht = -9999;
    for i=1:2:360    
     
        sum_Ht = 0;
        
        pointwise_x=round(x_offset_new+max(line_length)*cos(deg2rad(i))*2);
        pointwise_y=round(y_offset_new+max(line_length)*sin(deg2rad(i))*2); 
        if(pointwise_x>=256 || pointwise_x<=0 || pointwise_y>=256 || pointwise_y<=0)
            continue;
        end
        sum_Ht = sum_Ht + Ht(pointwise_y,pointwise_x);

        if(sum_Ht>old_sum_Ht)
            old_sum_Ht = sum_Ht;
            Ang_x=cos(deg2rad(i));
            Ang_y=sin(deg2rad(i));
        end

    end

    for i=1:2:length(line_length)     

        pointwise_x=x_offset_new+line_length(i)*Ang_x*2;
        pointwise_y=y_offset_new+line_length(i)*Ang_y*2;    
        BW=insertMarker(BW,[pointwise_x,pointwise_y],'x','size',3);
    end
    
%%

% redblue_flip=flipud(redblue);
 
subplot(131);imagesc(rot90(Ht,2));axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
title('Height');colormap(gca,gray);

%% Grain Boundary

F = BW;
subplot(132);h=imagesc(rot90(BW,2));axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
title('Grain Boundaries');colormap(gca,gray);



%% Grain
F = rot90(~BW0 .* Ht,2);
F(F==0) = NaN; %-1
subplot(133);h=imagesc(F);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
title('Grain');colormap(gca,gray);

 
  
end
