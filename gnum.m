function [ x ] = gnum( a )
%供油罐个数
    TKSet = [];
    for i=1:size(a,1)
        if a(i,2) ~= 0 && ~ismember(a(i,2), TKSet)
            TKSet = [TKSet, a(i,2)];
        end
    end
    x = size(TKSet,2);      %供油罐的个数
end