function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
    %sigm = log(1+exp(x));
end

