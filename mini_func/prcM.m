function prc_M = prcM (m)
    
     i=90;
     m(m<prctile(m(:),i))=0;
     m(m>=prctile(m(:),i))=1;
     
     
     prc_M = m;
     
    CC = bwconncomp(prc_M);
    numPixels = cellfun(@numel,CC.PixelIdxList);


    [~,idx] = find(numPixels<25);
    for i=1:length(idx)
        prc_M(CC.PixelIdxList{idx(i)}) = 0;
    end
 
end