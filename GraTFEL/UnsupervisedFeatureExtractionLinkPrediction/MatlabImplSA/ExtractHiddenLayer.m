%trainFile: Train data features and labels
%testFile: Test data features and labels
%HS: Hidden layer size
%SP: sparsity parameter
%LM: weight decay parameter 
%I: maximum iteration
%b: weight of sparsity penalty term 
%n: number of nodes in graph
%et: number of edges missed due to preselection

function [TrainPC, TrainLabel, TestPC, TestLabel] = ExtractHiddenLayer(trainFile,testFile,HS,SP,LM,I,b)
%%Load Data
%clear all
%Train = dlmread(trainFile)';
Train = cat(1,trainFile,testFile)';


TrainFeatures = Train(1:end-1,:);
TrainLabel = Train(end,:);
clearvars Train

[visibleSize,D] = size(TrainFeatures);   % number of input units 
hiddenSize = HS;     % number of hidden units 
sparsityParam = SP;   % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		     %  in the lecture notes). 
lambda = LM;     % weight decay parameter       
%lambda = 0;

beta = b;            % weight of sparsity penalty term       


%  Obtain random parameters theta
theta = initializeParameters(hiddenSize, visibleSize);

[cost, grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, lambda, ...
                                     sparsityParam, beta, TrainFeatures);

addpath minFunc/
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % sparseAutoencoderCost.m satisfies this.
options.maxIter = I;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'on';


[opttheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, TrainFeatures), ...
                              theta, options);

                          
%%======================================================================
%% STEP 5: MAP TO NEW DATA  

W1 = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
b1 = opttheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);


Train = trainFile';
TrainFeatures = Train(1:end-1,:);
TrainLabel = Train(end,:);
[~,D] = size(TrainFeatures);
TrainPC = sigmoid((W1 * TrainFeatures) +  (b1 * ones(1,D))); 
%size(TrainFeatures)

clearvars -except TrainPC TrainLabel D W1 b1 hiddenSize testFile

%input test file
%Test = dlmread(testFile)';
Test = testFile';

TestFeatures = Test(1:end-1,:);
TestLabel = Test(end,:);
%size(W1)
%size(TestFeatures)
%size(b1)
%size(ones(1,D))
[~,D] = size(TestFeatures);
%size(ones(1,D))

TestPC = sigmoid((W1 * TestFeatures) +  (b1 * ones(1,D))); 


clearvars -except TrainPC TrainLabel TestPC TestLabel hiddenSize
end




