function [ AP,AUC,NDCGp ] = ClassifierRobustBoost( TrainPC, TrainLabel, TestPC, TestLabel,n,et)
    Mdl = fitensemble(TrainPC', TrainLabel,'RobustBoost',300,'Tree','RobustErrorGoal',0.15,'RobustMaxMargin',1);
    [label,score] = predict(Mdl,TestPC');

    %considering only 2 hop data 
    decision_values=score(:,2);
    %[AUC,AP,Data1,NDCGp] = resultComputation(TestLabel',decision_values,strcat(fName,'1'),p);
%     AUC=0;
%     AP=0;
%     Data1=0;
%     
    
    if n>0
        %considering all data 
        e=nchoosek(n,2)-length(TestLabel);
        decision_values=vertcat(decision_values,ones(e,1)*min(decision_values));
        TestLabel=horzcat(TestLabel,zeros(1,e-et),ones(1,et));
    end
    [AUC,AP,NDCGp] = resultComputation(TestLabel',decision_values);
end

