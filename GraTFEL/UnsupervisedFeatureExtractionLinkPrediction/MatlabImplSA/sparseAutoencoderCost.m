function [cost,grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data)
                                         

% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% lambda: weight decay parameter
% sparsityParam: The desired average activation for the hidden units (denoted in the lecture
%                           notes by the greek alphabet rho, which looks like a lower-case "p").
% beta: weight of sparsity penalty term
% data: Our 64x10000 matrix containing the training data.  So, data(:,i) is the i-th training example. 
  
% The input theta is a vector (because minFunc expects the parameters to be a vector). 
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 
W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

% Cost and gradient variables (your code needs to compute these values). 
% Here, we initialize them to zeros. 
cost = 0;
W1grad = zeros(size(W1)); 
W2grad = zeros(size(W2));
b1grad = zeros(size(b1)); 
b2grad = zeros(size(b2));

[~,c]=size(data(1,:));

activation_2 = sigmoid((W1 * data) + b1*ones(1,c));
activation_3 = sigmoid((W2 * activation_2) + b2*ones(1,c));
row_2 = mean(activation_2')';
cost = 0.5 * sum(sum((data-activation_3).^2));
cost = cost / c;
cost = cost + 0.5 * lambda * (sum(sum(W1.^2))+sum(sum(W2.^2)));
cost = cost + beta * sum(sum(kl(row_2,sparsityParam)));


%1 feed forward pass
delta_3 = -(data-activation_3).*activation_3.*(1-activation_3);
delta_2 = W2'*delta_3;
delta_2 = delta_2 + beta.*sparsity(row_2,sparsityParam)*ones(1,c);
delta_2 = delta_2 .* activation_2.*(1-activation_2);

pdW1 = delta_2 * data' ;
pdW2 = delta_3 * activation_2';
pdb1 = delta_2;
pdb2 = delta_3;

W1grad = pdW1;
W2grad = pdW2;
b1grad = sum(pdb1')';
b2grad = sum(pdb2')';

% for m = 1:c
%     delta_3 = -(data(:,m)-activation_3(:,m)).*activation_3(:,m).*(1-activation_3(:,m));
%     delta_2 = W2'*delta_3;
%     delta_2 = delta_2 + beta.*sparsity(row_2,sparsityParam);
%     delta_2 = delta_2 .* activation_2(:,m).*(1-activation_2(:,m));
% 
% 
%     %4 partial derivatives
%     pdW1 = delta_2 * data(:,m)' ;
%     pdW2 = delta_3 * activation_2(:,m)';
%     pdb1 = delta_2;
%     pdb2 = delta_3;
% 
%     W1grad = W1grad + pdW1;
%     W2grad = W2grad + pdW2;
%     b1grad = b1grad + pdb1;
%     b2grad = b2grad + pdb2;
% end

%5
W1grad = W1grad/c + lambda*W1;
W2grad = W2grad/c + lambda*W2;
b1grad = b1grad/c;
b2grad = b2grad/c;


%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost/optimization objective J_sparse(W,b) for the Sparse Autoencoder,
%                and the corresponding gradients W1grad, W2grad, b1grad, b2grad.
%
% W1grad, W2grad, b1grad and b2grad should be computed using backpropagation.
% Note that W1grad has the same dimensions as W1, b1grad has the same dimensions
% as b1, etc.  Your code should set W1grad to be the partial derivative of J_sparse(W,b) with
% respect to W1.  I.e., W1grad(i,j) should be the partial derivative of J_sparse(W,b) 
% with respect to the input parameter W1(i,j).  Thus, W1grad should be equal to the term 
% [(1/m) \Delta W^{(1)} + \lambda W^{(1)}] in the last block of pseudo-code in Section 2.2 
% of the lecture notes (and similarly for W2grad, b1grad, b2grad).
% 
% Stated differently, if we were using batch gradient descent to optimize the parameters,
% the gradient descent update to W1 would be W1 := W1 - alpha * W1grad, and similarly for W2, b1, b2. 
% 
%%-------------------------------------------------------------------



% After computing the cost and gradient, we will convert the gradients back
% to a vector format (suitable for minFunc).  Specifically, we will unroll
% your gradient matrices into a vector.


grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];



end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end

function third = sparsity(x,sparsityParam)
    third=-(sparsityParam ./ x)+((1-sparsityParam) ./ (1-x));
end

function third = kl(x,sparsityParam)
    third=sparsityParam*log(sparsityParam ./ x)+(1-sparsityParam)*log((1-sparsityParam) ./ (1-x));
end

