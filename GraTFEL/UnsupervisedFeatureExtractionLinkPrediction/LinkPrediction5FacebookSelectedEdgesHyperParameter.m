clear all
mkdir('Result','LinkPrediction3FacebookWS')
load LinkPrediction3FacebookLabellFeatureHop2

%reduce the feature vector by deleting the features which are 0 for all
%data
t=Data{1}(:,:);
for i=2:stamps+1
    t=cat(1,t,Data{i}(:,:));
end
t2=sum(t);
t3=find(t2);

for i=1:stamps+1
    Data{i}=Data{i}(:,t3);
end

MasterData=Data;
MasterStamps=stamps;


for stamps=1:MasterStamps
    clearvars Data 
    Data=cell(stamps+1,1);
    for s=1:stamps+1
        Data{s}=MasterData{s+MasterStamps-stamps};
    end
    
    %Train GTP
    GTP=cat(2,Data{1}(:,4:end));
    for i=2:stamps
        GTP=cat(2,GTP,Data{i}(:,4:end));
    end
    if stamps~=1
        %Train History
        history=cat(2,Data{1}(:,3));
        for i=2:stamps-1
            history=cat(2,history,Data{i}(:,3));
        end
        t2 = [1:stamps-1]/(stamps-1);
        t2 = ones(length(history),1)*t2;
        size(t2)
        size(history)
        history=cumsum((history.*t2)')';
    
    
        Train=cat(2,GTP,history,Data{stamps}(:,3));
    else
        Train=cat(2,GTP,Data{stamps}(:,3));
    end
    
    %Test GTP
    GTP=cat(2,Data{2}(:,4:end));
    for i=3:stamps+1
        GTP=cat(2,GTP,Data{i}(:,4:end));
    end
    if stamps~=1
        %Train History
        history=cat(2,Data{2}(:,3));
        for i=3:stamps
            history=cat(2,history,Data{i}(:,3));
        end
        t2 = [1:stamps-1]/(stamps-1);
        t2 = ones(length(history),1)*t2;
        history=cumsum((history.*t2)')';

    
        Test=cat(2,GTP,history,Data{stamps+1}(:,3));
    else
        Test=cat(2,GTP,Data{stamps+1}(:,3)); 
    end
    
    %Hiddenlayers=[5 10 20 50 100 200 400 800];
    Hiddenlayers=200;
    for HLI=1:length(Hiddenlayers)
        HL=Hiddenlayers(HLI);

    
        runs=5;
        result=zeros(runs,12);
        resultAdaBoostM1=zeros(runs,12);
        resultRobustBoost=zeros(runs,12);
    
        for i=1:runs
            cd MatlabImplSA
            [TrainPC, TrainLabel, TestPC, TestLabel]= ExtractHiddenLayer(Train,Test,HL,0.5,.1,50,1);
            cd ..

            p=50;    
            n=663;
            et=72;%from python
            [result(i,2),result(i,1),result(i,3:end)]=Classifier(TrainPC, TrainLabel, TestPC, TestLabel,n,et);
            [resultAdaBoostM1(i,2),resultAdaBoostM1(i,1),resultAdaBoostM1(i,3:end)]=ClassifierAdaBoostM1(TrainPC, TrainLabel, TestPC, TestLabel,n,et);
            [resultRobustBoost(i,2),resultRobustBoost(i,1),resultRobustBoost(i,3:end)]=ClassifierRobustBoost(TrainPC, TrainLabel, TestPC, TestLabel,n,et);
%             
%             [~,~,~,result(i,2),result(i,1),~,result(i,3)]=Classifier(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);
%             [~,~,~,resultAdaBoostM1(i,2),resultAdaBoostM1(i,1),~,resultAdaBoostM1(i,3)]=ClassifierAdaBoostM1(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);
%             [~,~,~,resultRobustBoost(i,2),resultRobustBoost(i,1),~,resultRobustBoost(i,3)]=ClassifierRobustBoost(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);        
        end

        fn=strcat('Result/LinkPrediction3FacebookWS/ResultSA_WS_Study',num2str(stamps),'.mat');
        save(fn)
    end
end



    

%r=zeros(903,1);
%for i=3:903
%    r(i)=sum(Data{2}(:,i));
%end
%r2=find(r);
quit
