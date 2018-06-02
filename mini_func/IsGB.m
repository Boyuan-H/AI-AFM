function [x_spot,y_spot,Ang_x,Ang_y] = IsGB(ibw_path,line_length)

    D = IBWread(ibw_path);    

    M = D.y;
    Ht = rot90(reshape(M(:,:,1),256,256),3);
    
        Ht = medfilt2(Ht);
 

    Ht_1 = Ht(1:255,:) - Ht(2:256,:);
    Ht_2 = Ht_1(1:254,:) - Ht_1(2:255,:);
    Ht_3 = Ht(:,1:255) - Ht(:,2:256);
    Ht_4 = Ht_3(:,1:254) - Ht_3(:,2:255);
    
%     line_length=line_length/2;
    
    Ht_2 = prcM(Ht_2);
    Ht_4 = prcM(Ht_4);
    GB_mask = zeros(256);
    GB_mask(2:255,2:255) = (Ht_4(1:254,1:254)+Ht_2(1:254,1:254));
    
    
%     figure;imshow(GB_mask);
    
    for i=1:256
        BW = GB_mask(i,:);
        CC = bwconncomp(BW);
        numPixels = cellfun(@numel,CC.PixelIdxList);

        [~,idx] = find(numPixels>15);
        for j=1:length(idx)
            BW(CC.PixelIdxList{idx(j)}) = 0;
        end
        GB_mask(i,:)=BW;
    end
%     figure;imshow(GB_mask);
    % figure; 
%         subplot(221);imshow(Ht_2);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
%         subplot(222);imshow(Ht_4);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
%         subplot(223);imagesc(Ht);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);
%         subplot(224);imshow(GB_mask);axis square; set(gca,'xtick',[]);set(gca,'ytick',[]);

%     figure('Position',[125,52,910,300]); 
    [x_spot,y_spot,Ang_x,Ang_y] = show_results(Ht,GB_mask,line_length);
    x_spot = 256-x_spot;
    y_spot = 256-y_spot;
end
