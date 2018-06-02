function [isferro, x_spot , y_spot,Ang_x,Ang_y] = IsFerro(SVMModels_Amp,SVMModels_Pha,ibw_path,ibw_name,line_length)

    png_folder = 'C:\Users\Asylum User\Desktop\Identify_result';
    
    ed=max(line_length);
    dx=line_length;
    Part_Amp=1:length(dx);
    Part_Pha= length(dx)+[1:3,5,7:9];
    
    D = IBWread(ibw_path);
        
    s = size(D.y);

    Not_PFM = (isempty(strfind(D.WaveNotes,'PFM mode')) && isempty(strfind(D.WaveNotes,'PFM Mode')) ...
        && isempty(strfind(D.WaveNotes,'ImagingMode: 3')));

    if (  Not_PFM || ~(s(1)==256 && s(2)==256) )

        disp(['Invalid ibw or not PFM mode:' ibw_path]);
        return;  
    end

    M = D.y;
    Amp = reshape(M(:,:,2),256,256); % Just use raw data of DART PFM
    Pha = reshape(M(:,:,4),256,256);

        min_a = prctile(Amp(:),1); 
        max_a = prctile(Amp(:),99);
        Amp=(Amp-min_a)./(max_a-min_a);

        Amp(Amp>0.9)=1;
        Amp(Amp<=0.1)=0;

    pixel_size = length(Amp);

    float_amp=Amp;
    float_pha=deg2rad(Pha);
    float_pha=wrapTo2Pi(float_pha)/2/pi;

    float_pha = medfilt2(float_pha);
    float_amp = medfilt2(float_amp);

%         Pha_edge_thick = Edge_thick(float_pha);
%         Amp_edge_thick = Edge_thick(float_amp);
%         edge_thick = Pha_edge_thick&Amp_edge_thick;%
%         edge_thick = bwmorph(edge_thick,'fill');

        edge_thick = edge(float_pha,'canny');%sobel
%             se = strel('line',5,6);
%         edge_thick = imdilate(edge_thick,se);


    %% Prepare format   
    t=ed;
    
    Amp_set = zeros(length(dx),1);
    Pha_set = zeros(length(dx),1);

    edge_thick_sub = edge_thick(t+1:pixel_size-t,t+1:pixel_size-t);
    float_pha_sub = float_pha(t+1:pixel_size-t,t+1:pixel_size-t);
    [row,col] = find(edge_thick_sub==1);

    Test_set = zeros(length(row),length(dx)*2);
    
    [~,edgeDir0] = imgradient(float_pha_sub);
    edgeDir=deg2rad(edgeDir0);
    gx= sin(edgeDir);
    gy= -cos(edgeDir);

    for k=1:length(row)
        
        dx=round(gx(row(k),col(k))*line_length);
        dy=round(gy(row(k),col(k))*line_length);

        for i=1:length(dx)

             x=row(k)+t+dx(i);
             y=col(k)+t+dy(i);

             Amp_set(i) = float_amp(x,y);%
             Pha_set(i) = float_pha(x,y);

        end

        Test_set(k,:)= [Amp_set' Pha_set'];% 
    end

    index_set = [row,col];

    %% Amp Prediction
    X_val_Amp =  Test_set(:,Part_Amp);
    Scores_Amp = zeros(length(X_val_Amp),2);
    for j = 1:2
        [~,score_Amp] = predict(SVMModels_Amp{j},X_val_Amp);
        Scores_Amp(:,j) = score_Amp(:,2); % Second column contains positive-class scores
    end
    [~,maxScore_Amp] = max(Scores_Amp,[],2);

    mask_Amp=zeros(pixel_size);
    for i=1:length(index_set)
        if(maxScore_Amp(i)==2)
            mask_Amp(index_set(i,1)+t,index_set(i,2)+t)=1;
        end
    end

    %% Pha Prediction
    X_val_Pha =  Test_set(:,Part_Pha);
    Scores_Pha = zeros(length(X_val_Pha),2);
    for j = 1:2
        [~,score_Pha] = predict(SVMModels_Pha{j},X_val_Pha);
        Scores_Pha(:,j) = score_Pha(:,2); % Second column contains positive-class scores
    end
    [~,maxScore_Pha] = max(Scores_Pha,[],2);

    mask_Pha=zeros(pixel_size);
    for i=1:length(index_set)
        if(maxScore_Pha(i)==2)
            mask_Pha(index_set(i,1)+t,index_set(i,2)+t)=1;
        end
    end

    %% Save png and info.

    ibw_name = strrep(ibw_name,'.ibw','');
    [~,~,numPixels,x_spot,y_spot,Ang_x,Ang_y] = export_results(float_amp,float_pha,mask_Pha,mask_Amp,png_folder,ibw_name,ed,gx,gy); 
    
    if( isempty(numPixels) || ( max(numPixels)<20 && length(find(numPixels>25))<5 ) )
        isferro=0;
    else
        isferro=1;
    end
    


end


%%
function M_edge = Edge_thick(M)

    M_edge = edge(M,'canny');
    
%     se = strel('line',11,90);
%     M_edge = imdilate(M_edge,se);
    
    M_edge = bwmorph(M_edge,'thick',2);
    M_edge = bwmorph(M_edge,'diag');
    M_edge = bwmorph(M_edge,'bridge');
    M_edge = bwmorph(M_edge,'thick',2); 
end