function [ new_AC ] = up_vac( AC,old_AC,M,Na )
%更新算法的外部储备集，以及粒子的全局引导者
%AC：候选者
%old_AC：外部储备集
%new_AC：更新后的外部储备集
%popsize：种群大小

%size(AC,1)：候选者的数量
for i = 1:size(AC,1)
    %将每个候选者与外部储备集中的元素进行比较，更新储备集
    old_AC = up_vac0(AC(i,:),old_AC,M,Na);
end
%外部储备集已经更新，并保存到new_AC中
new_AC = old_AC;
%计算更新后的外部储备集的拥挤距离值
crowd_value = calcul_crowd(new_AC,M);

Gbest_set = new_AC;
Gbest_crowd_val = crowd_value;
%外部储备集中的粒子个数
g_size = size(Gbest_set,1);
while g_size > Na                                        %外部储备集中的容量NA
    [~, ind] = sort(Gbest_crowd_val);         %将更新后的外部储备集中的粒子的拥挤距离值排序
    Gbest_set(ind(1),:) = [];                           %删除拥挤距离值最小的元素
    Gbest_crowd_val(ind(1)) = [];                 %删除拥挤距离值最小的元素的拥挤距离值
    g_size = size(Gbest_set,1);                   %重新计算外部储备集中的粒子数量
end
end

