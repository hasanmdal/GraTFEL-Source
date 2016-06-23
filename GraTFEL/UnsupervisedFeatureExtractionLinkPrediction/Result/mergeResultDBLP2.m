RESULT=zeros(27,13);

I=1;
Hiddenlayers=[5 10 20 50 100 200 400 800];
for HLI=1:length(Hiddenlayers)
    HL=Hiddenlayers(HLI);
    fn=strcat('LinkPrediction3DBLP2/ResultSA_HL_Study',num2str(HL),'.mat');
    load(fn)
    RESULT(I,:)=[HL mean(result)];
    I=I+1;
    RESULT(I,:)=[HL mean(resultAdaBoostM1)];
    I=I+1;
    RESULT(I,:)=[HL mean(resultRobustBoost)];
    I=I+1;
end

RESULT(I:I+2,2:end)=resultWOUL;

Data='DBLP2';
clearvars -except RESULT Data

save('MergedDBLP21.mat')
quit