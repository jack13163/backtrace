function [ x ] = gchange( a )
%供油罐切换次数
    K = 0;
    
    %获取转运记录
    for i=1:size(a,1)
        if a(i,1) >= max(a(:,1))
            K = i;
            break;
        end
    end
    x = K - 1;
end