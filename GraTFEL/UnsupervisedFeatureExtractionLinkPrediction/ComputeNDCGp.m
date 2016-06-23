function [ NDCGp ] = ComputeNDCGp( label,score,p)
    %%NDCGp
    %p
    label(label==-1)=0;
    T = [score, label];
    IDCGp = 0;
    DCGp = 0;
    T=flipud(sortrows(T,1));

    for i =1:p
        DCGp=DCGp+T(i,2)/log2(i+1);
        IDCGp=IDCGp+1/log2(i+1);
    end    
    NDCGp=DCGp/IDCGp;
end