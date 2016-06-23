function [ AUC,AUCpr, NDCGp ] = resultComputation( label,score)
%RESULTCOMPUTATION Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,AUCpr] = perfcurve(label,score, 1, 'xCrit', 'reca', 'yCrit', 'prec');

[~,~,~,AUC] = perfcurve(label,score, 1, 'xCrit', 'fpr', 'yCrit', 'tpr');

NDCGp=zeros(1,10);
NDCGp(1)=ComputeNDCGp( label,score,10);
NDCGp(2)=ComputeNDCGp( label,score,20);
NDCGp(3)=ComputeNDCGp( label,score,30);
NDCGp(4)=ComputeNDCGp( label,score,40);
NDCGp(5)=ComputeNDCGp( label,score,50);
NDCGp(6)=ComputeNDCGp( label,score,60);
NDCGp(7)=ComputeNDCGp( label,score,70);
NDCGp(8)=ComputeNDCGp( label,score,80);
NDCGp(9)=ComputeNDCGp( label,score,90);
NDCGp(10)=ComputeNDCGp( label,score,100);

% %NDCGp
% p
% label(label==-1)=0;
% T = [score, label];
% IDCGp = 0;
% DCGp = 0;
% T=flipud(sortrows(T,1));
% 
% for i =1:p
%     DCGp=DCGp+T(i,2)/log2(i+1);
%     IDCGp=IDCGp+1/log2(i+1);
% end    
% NDCGp=DCGp/IDCGp;
end

