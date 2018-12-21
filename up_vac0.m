function [ new_AC ] = up_vac0( par_eff,old_AC,M,Na )
%更新外部储备集
%par_eff：候选粒子
%k：决策变量维数
%old_AC：外部储备集
%new_AC：新的外部储备集

%获取外部储备集中粒子的个数
ss1 = size(old_AC,1);
%判断粒子与外部储备集中粒子的支配关系
for i = 1:ss1
    bb1 = 0;
    bb2 = 0;
    for j = 1:M     %目标函数的个数M
        aa1 = old_AC(i,j);
        aa2 = par_eff(1,j);
        if aa2 < aa1
            bb1 = bb1 + 1;
        elseif aa2 == aa1
            bb2 = bb2 + 1;
        end
    end
    %判断支配关系
    if bb1 == M         %候选者支配old_AC(i,:)，即候选者支配外部储备集中的当前粒子
        old_AC(i,:) = inf;          %删除外部储备集中被候选者支配的粒子
    elseif bb2 > 0 && bb1 == M - bb2        %候选者支配old_AC(i,:)，即候选者支配外部储备集中的当前粒子
        old_AC(i,:) = inf;
    elseif bb1 + bb2 == 0       %候选者不支配old_AC(i,:)
        par_eff(1,:) = inf;         %删除候选者粒子，候选者粒子被淘汰，不能进入外部储备集
        break;      %当前候选者支配于外部储备集中的当前粒子，退出
    elseif bb2 ~= 0 && bb1 == 0         %候选者不支配old_AC(i,:)
        par_eff(1,:) = inf;
        break;
    end
end
%将候选者加入到临时外部储备集中，临时外部储备集中被支配的粒子所在的行变为inf，即无穷大
tmp_AC = [par_eff;old_AC]; 
new_AC = [];
%遍历合并后的临时外部储备集
for i = 1:ss1+1
    %判断当前粒子是否被其他粒子所支配，若否，则将其纳入新的外部储备集张
    if tmp_AC(i,1) ~= inf
        new_AC = [new_AC;tmp_AC(i,:)];
    end
end
%获取新的外部储备集的大小
ss2 = size(new_AC,1);
%若外部储备集中元素个数超出其最大容量
if ss2 > Na
    %遍历各个目标函数
    for i = 1:M
        lim_f(i,2) = max(new_AC(:,i));       %求目标函数i的极大值
        lim_f(i,1) = min(new_AC(:,i));        %求目标函数i的极小值
    end
    DD = [];        %拥挤度
    deep = [];
    for i = 1:M
       [val, ind] = sort(new_AC(:,i));        %将目标函数i的函数值按照从小到大的顺序排列
       %外部储备集中粒子个数ss2>50，又当前只有一个粒子进入外部储备集，故当前情况下，外部储备集中粒子个数为NA+1
       for j = 1:(Na+1)
           %两端的拥挤度最大
           if j == 1 || j == (Na+1)
               DD(ind(j),i) = inf;
           else
               DD(ind(j),i) = new_AC(ind(j+1),i) - new_AC(ind(j-1),i)/(lim_f(i,2) - lim_f(i,1));
           end
       end
    end
    %从外部储备集中删除拥挤距离值最小的粒子
    for jj = 1:(Na+1)
       	deep(jj) = sum(DD(jj,:));
    end
   	[val, ind] = sort(deep);
    new_AC(ind(1),:) = [];
end
end