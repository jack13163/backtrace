function [ crowd_value ] = calcul_crowd( new_AC,M)
%计算储备集中元素的拥挤距离值
%new_AC：外部储备集
%s2：外部储备集中粒子的数量

s2 = size(new_AC,1);
%粒子的数量大于等于2才能计算拥挤距离值，否则拥挤距离值取1
if s2 >= 2
    for i = 1:M         %目标函数个数M=2
        lim_f(i,1) = min(new_AC(:,i));         %目标函数i的极小值
        lim_f(i,2) = max(new_AC(:,i));        %目标函数i的极大值
    end
    DD = [];
    crowd_value = [];
    %遍历目标函数
    for i = 1:M
        [~,ind] = sort(new_AC(:,i));        %将目标函数i的值排序，ind：索引；val：值
        %遍历储备集中的粒子
        for j = 1:s2
            if j == 1
                DD(ind(j),i) = inf;     %设置目标函数i的极小值的拥挤距离值为无穷大
            elseif j == s2
                DD(ind(j),i) = inf;     %设置目标函数i的极大值的拥挤距离值为无穷大
            else
                DD(ind(j),i) = new_AC(ind(j+1),i) - new_AC(ind(j-1),i)/2*(lim_f(i,2) - lim_f(i,1));     %计算目标函数i非边界点的拥挤距离值
            end
        end
    end
    for jj = 1:s2
        crowd_value(jj) = sum(DD(jj,:));        %计算各个粒子的拥挤距离值
    end
else
    crowd_value(1) = 1;
end
end