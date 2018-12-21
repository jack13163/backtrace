function [ flag ] = schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD)
%判断当前系统状态是否可调度
%flag：可调度为1，否则为0
UDFR = sortrows([UD;DSFR(UD)]',2);   %蒸馏塔的炼油速率(升序排列)
available = zeros(size(DSFR, 2), 2);       %库存中各个蒸馏塔目前可用的油量
for i = 1:size(UDFR, 1)
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
tag = zeros(1,K);
for i=1:K
    arfai = RT * UDFR(i,2);
    DSN = UDFR(i,1);
    
    if (i==K && total(DSN) >= 4 * K * arfai) || total(DSN) >= 2 * K * arfai                 %统计下一个周期不需要的油罐数量
        tag(i) = 1;
    elseif (i==K && total(DSN) + 1 < 2 * K * arfai ) || total(DSN) + 1 < K * arfai      %判断是否满足最低油量约束
        flag=0;
        %disp('最低油量约束不满足！');
        return;
    end
end

%在调度周期内进行运油操作
time = [];
cur = PET;
for i=1:K
	beta = available(i,1);
	arfai = RT * UDFR(i,2);
    %转运该蒸馏塔所需要炼的原油
    if tag(i) == 0
        %正常油品转运
        time = [time, cur];
        %油品切换需要供油罐
        if beta > 0 && beta < K * arfai && available(i,2) >= K * arfai - beta
            time = [time, cur + beta / PIPEFR];
        end
        cur = cur + K * arfai / PIPEFR;
    end
end

%供油罐可用时间ideltime
TKSN = sortrows(TKS,6);
ideltime = TKSN(:,6)';
    
count = 0;%不可用供油罐的个数
for i=1:size(time,2)
	if ideltime(i) > time(i)
        count = count + 1;
	end
end

%判断供油罐是否在需要时可用
if count == 0
    flag = 1;
else
 	%disp('供油罐不足！');
    flag = 0;
end
end