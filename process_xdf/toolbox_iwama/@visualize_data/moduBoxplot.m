function a = moduBoxplot(a,pointsz,colorMat)
if ~exist('pointsz','var')
    pointsz = 12;
end
colorPalette;
num_col = size(col4,2);
flag_col = 1;
if exist('colorMat','var')
    num_col = size(colorMat,2);
    flag_col = 2;
end
Fnames = fieldnames(a);
for i = 1 : numel(a)
    a(i).sdPtch.FaceColor = [0.5 0.5 0.5];
    a(i).sdPtch.EdgeColor = [0.5 0.5 0.5];
    a(i).semPtch.FaceColor = [0.65 0.65 0.65];
    a(i).semPtch.EdgeColor = [0.65 0.65 0.65];
    a(i).mu.Color  = [0 0 0];
    switch flag_col
        case 1
            a(i).data.MarkerFaceColor  = col4(:,mod(i,num_col)+1);
            a(i).data.MarkerEdgeColor  = col4(:,mod(i,num_col)+1);
        case 2
            a(i).data.MarkerFaceColor  = colorMat(:,min(i,size(colorMat,2)));
            a(i).data.MarkerEdgeColor  = colorMat(:,min(i,size(colorMat,2)));
    end
    a(i).data.MarkerSize  = pointsz;
    
    for j = 1 : 3
        hAnnotation = eval(["get(a(i)."+string(Fnames{j,1})+",'Annotation');"]);
        hLegendEntry = get(hAnnotation,'LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
    end
end
hold on;
end