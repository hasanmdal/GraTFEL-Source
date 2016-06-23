if 0
clear all

stamps=7;
Data=cell(stamps+1,1);
for s=0:stamps
    s
    %s=0;
    file=strcat('../../Graphs/FacebookAdjDelta',num2str(s),'.txt');
    Delta=load(file,'-ascii');
    %clearvars -except Delta

    %graphlets of different types
    load graphlets.txt
    n=length(graphlets);

    %map to index [1:30]
    t=changem(Delta(:,4:5),1:length(graphlets),graphlets);
    Delta=cat(2,Delta(:,1:3),t,Delta(:,6));
    %clearvars -except Delta graphlets n

    %list the edges on time stamp s
    edges= unique(Delta(:,2:3),'rows');
    edgeFeatures=zeros(length(edges),2+30*30);
    for i =1:length(edges)
        freq = Delta(Delta(:,2)==edges(i,1) & Delta(:,3)==edges(i,2),:);
    
        %construct matrix
        S = sparse(freq(:,4),freq(:,5),freq(:,6),n,n);
        F=full(S);
        F=F/max(max(F));
        edgeFeatures(i,:)=[edges(i,1),edges(i,2),reshape(F,[1 30*30])];
    end

    %clearvars -except Delta graphlets n edgeFeatures

    load FacebookTruth2.txt
    Truth=FacebookTruth2;
    %clearvars -except Delta graphlets n edgeFeatures Truth
    [~,c]=size(Truth);
    for i=3:c
        t2=find(Truth(:,i)==0); 
        Truth(t2,i)=-1;
    end
    

    label=Truth(:,3+s);
    t1=table(Truth(:,1),Truth(:,2),label);
    score=edgeFeatures(:,3:end);
    t2=table(edgeFeatures(:,1),edgeFeatures(:,2),score);
    %t3=outerjoin(t1,t2,'Type','left');
    %t3=innerjoin(t1,t2);
    %if s==stamps
    %    t3=outerjoin(t1,t2,'Type','left');
    %end
    %Data{s+1}=table2array(t3);
    %Data{s+1}=Data{s+1}(:,[1:3,6:end]);
    %Data{s+1}(isnan(Data{s+1})) = 0 ;
    
    
    %if s==stamps
    %    t3=outerjoin(t1,t2,'Type','left');
    %    Data{s+1}=table2array(t3);
    %    Data{s+1}=Data{s+1}(:,[1:3,6:end]);
    %    Data{s+1}(isnan(Data{s+1})) = 0 ;
    %else
    %    t3=innerjoin(t1,t2);
    %    Data{s+1}=table2array(t3);
    %    Data{s+1}=Data{s+1}(:,[1:3,4:end]);
    %    Data{s+1}(isnan(Data{s+1})) = 0 ;
    %end
    t3=outerjoin(t1,t2,'Type','left');
    Data{s+1}=table2array(t3);
    Data{s+1}=Data{s+1}(:,[1:3,6:end]);
    Data{s+1}(isnan(Data{s+1})) = 0 ;
end

save('LinkPrediction3FacebookLabellFeatureHop2','Data','stamps','-v7.3')
end
clear all
%stamps=7;
mkdir('Result','LinkPrediction3Facebook')
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


%Train=cat(2, Data{1}(:,4:end),Data{1}(:,3));
%for i=2:8 %should contain all time but last
%    Train=cat(1,Train,cat(2, Data{i}(:,4:end),Data{i}(:,3)));
%end


%Train GTP
GTP=cat(2,Data{1}(:,4:end));
for i=2:stamps
    GTP=cat(2,GTP,Data{i}(:,4:end));
end
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

%Test GTP
GTP=cat(2,Data{2}(:,4:end));
for i=3:stamps+1
    GTP=cat(2,GTP,Data{i}(:,4:end));
end
%Train History
history=cat(2,Data{2}(:,3));
for i=3:stamps
    history=cat(2,history,Data{i}(:,3));
end
t2 = [1:stamps-1]/(stamps-1);
t2 = ones(length(history),1)*t2;
history=cumsum((history.*t2)')';

Test=cat(2,GTP,history,Data{stamps+1}(:,3));

%Train=cat(2, Data{1}(:,4:end),Data{1}(:,3));
%for i=2:9 %should contain all time but last
%    Train=cat(1,Train,cat(2, Data{i}(:,4:end),Data{i}(:,3)));
%end

%Test=cat(2, Data{10}(:,4:end),Data{10}(:,3));

p=50;    
n=663;
et=72;%from python
resultWOUL=zeros(3,12);
[resultWOUL(1,2),resultWOUL(1,1),resultWOUL(1,3:end)]=Classifier(Train(:,1:end-1)', Train(:,end)', Test(:,1:end-1)', Test(:,end)',n,et);        
[resultWOUL(2,2),resultWOUL(2,1),resultWOUL(2,3:end)]=ClassifierAdaBoostM1(Train(:,1:end-1)', Train(:,end)', Test(:,1:end-1)', Test(:,end)',n,et);
[resultWOUL(3,2),resultWOUL(3,1),resultWOUL(3,3:end)]=ClassifierRobustBoost(Train(:,1:end-1)', Train(:,end)', Test(:,1:end-1)', Test(:,end)',n,et);
fn=strcat('Result/LinkPrediction3Facebook/ResultSA_HL_Study','_noUL','.mat');
save(fn)


Hiddenlayers=[5 10 20 50 100 200 400 800];
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
        
%         [~,~,~,result(i,2),result(i,1),~,result(i,3)]=Classifier(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);
%         [~,~,~,resultAdaBoostM1(i,2),resultAdaBoostM1(i,1),~,resultAdaBoostM1(i,3)]=ClassifierAdaBoostM1(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);
%         [~,~,~,resultRobustBoost(i,2),resultRobustBoost(i,1),~,resultRobustBoost(i,3)]=ClassifierRobustBoost(TrainPC, TrainLabel, TestPC, TestLabel,n,et,'Result/Facebook/15SA_SVM',p);        
    end

    fn=strcat('Result/LinkPrediction3Facebook/ResultSA_HL_Study',num2str(HL),'.mat');
    save(fn)
end
%r=zeros(903,1);
%for i=3:903
%    r(i)=sum(Data{2}(:,i));
%end
%r2=find(r);
quit
