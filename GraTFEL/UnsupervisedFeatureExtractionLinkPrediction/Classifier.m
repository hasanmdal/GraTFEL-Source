    function [ AP,AUC,NDCGp ] = Classifier( TrainPC, TrainLabel, TestPC, TestLabel,n,et)
    addpath /home/mmrahman/liblinear-multicore-2.1-3/matlab/
    %addpath /Users/mmrahman/Documents/MATLAB/liblinear-1.96/matlab/
    %addpath /home/mmrahman/liblinear-1.96/matlab/
    %addpath /Users/mmrahman/Documents/MATLAB/liblinear-multicore-2.1-3/matlab/
    
    %considering only 2 hop data 
    model=train(TrainLabel(1,:)', sparse(TrainPC(:,:)'),'-s 1 -c 15');
    [predicted_label, accuracy, decision_values] = predict(TestLabel'*0, sparse(TestPC(:,:)'), model, '-b 0');
    
    %[AUC,AP,Data1,NDCGp] = resultComputation(TestLabel',decision_values,strcat(fName,'1'),p);
%     AUC=0;
%     AP=0;
%     Data1=0;
%     
    
    
    %considering all data 
    if n>0
        e=nchoosek(n,2)-length(TestLabel);
        decision_values=vertcat(decision_values,ones(e,1)*min(decision_values));
        TestLabel=horzcat(TestLabel,zeros(1,e-et),ones(1,et));
    end
    
        
    [AUC,AP,NDCGp] = resultComputation(TestLabel',decision_values);
end

