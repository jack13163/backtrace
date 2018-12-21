function [ x ] = gdimix( a, c2 )
%罐底混合次数
%c2：罐底混合成本
    m2 = zeros(6,6);
    K = 0;
    
    %获取转运记录
    for i=1:size(a,1)
        if a(i,1) >= max(a(:,1))
            K = i;
            break;
        end
    end
    K = K - 1;
    record = a(1:K,:);
    record = sortrows(record,2);
    
    %统计各个油罐的使用次数
    A = record(:,2)';
    B = unique(A);
    tks = [];
    for i=1:size(B,2)
        tks(i) = sum(A(:)==B(i));
    end
    
	%根据炼油记录表分析罐底混合次数
    for i=1:size(tks,2)     %i代表油罐
        tmp = 0;
        for j=1:(size(record,1) - 1)      %j代表炼油记录
            if record(j,2) == i
                tmp =  tmp + 1;
                if tmp >= tks(i)     %tks(i)：油罐i中的使用次数
                    break;
                end
                if record(j,5) ~= record(j+1,5)
                    m2(record(j,5), record(j+1,5)) = m2(record(j,5), record(j+1,5)) + 1;
                end
            end
        end
    end
    x = sum(sum(m2.*c2));          %罐底混合次数
end

