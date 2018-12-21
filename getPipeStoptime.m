function [ t ] = getPipeStoptime(FPORDER, DSFR, RT, TKS, PET, FP, UD)
%获取管道停运安全时间
t=inf;
%1.0000  333.3000
%3.0000  625.0000
UDFR = sortrows([UD;DSFR(UD)]',2);   %蒸馏塔的炼油速率(升序排列)
available = zeros(size(FPORDER));       %库存中各个蒸馏塔目前可用的油量
for i = 1:size(UD, 2)
    DSN = UDFR(i,1);    %蒸馏塔
    COTN1 = FPORDER(DSN, 1);      %原油类型1
    COTN2 = FPORDER(DSN, 2);      %原油类型1
    for j = 1:size(TKS, 1)          %j代表供油罐
        if TKS(j, 2) == COTN1
            if TKS(j, 5) <= PET && TKS(j, 6) > PET
                available(DSN, 1) = available(DSN, 1) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);
            else
                available(DSN, 1) = available(DSN, 1) + TKS(j, 3);
            end
        elseif TKS(j, 2) == COTN2
            if TKS(j, 5) <= PET && TKS(j, 6) > PET
                available(DSN, 2) = available(DSN, 2) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);   %供油状态
            else
                available(DSN, 2) = available(DSN, 2) + TKS(j, 3);  %非供油状态
            end
        end
    end
end

total = zeros(1, size(FPORDER, 1));
for i=1:size(available, 1)
    if FP(FPORDER(i, 1)) ~= 0
        total(i) = available(i,1);
    else
        total(i) = available(i,1) + available(i,2);
    end
end

%油量约束
K = size(UDFR, 1);
for i=1:K
    arfai = RT * UDFR(i,2);
    DSN = UDFR(i,1);
    
    %预留一个调度周期的原油
    if i==K
        total(DSN) = total(DSN) - 2 * K * arfai;
    else
        total(DSN) = total(DSN) - K * arfai;
    end
    
    tmp = total(DSN) / UDFR(i, 2);
    if tmp < t
        t = tmp;
    end
end
end