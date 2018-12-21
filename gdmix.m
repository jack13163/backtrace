function [ x ] = gdmix( a, c1 )
%获取管道混合次数
%c1：管道混合成本
    m1 = zeros(6,6);
    K = 0;
    
    %获取转运记录
    for i=1:size(a,1)
        if a(i,1) >= max(a(:,1))
            K = i;
            break;
        end
    end
    PIPE = a(K:size(a,1),:);
    PIPE = PIPE(PIPE(:,5)~=0,:);   %删除其中的停运记录
    
    for i=1:size(PIPE,1)-1
        if PIPE(i,5) ~= PIPE(i+1,5)
            m1(PIPE(i,5),PIPE(i+1,5)) = m1(PIPE(i,5),PIPE(i+1,5)) +1;
        end
    end
    x = sum(sum(m1.*c1));       %管道混合次数
end

