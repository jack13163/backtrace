function [ scheduleplan ] = fat( )
%% 计算所有解
    %参数设置
    RT = 6;                                                     %驻留时间
    DSFR = [333.3, 291.7, 625];                 %蒸馏塔炼油速率(可计算蒸馏塔个数)
    PIPEFR = 1250;                                     %管道输油速率
    FPORDER = [5,1;6,2;4,3];                     %蒸馏塔的炼油顺序
    TKS = [
        16000,5,8000,0,0,0;
        34000,5,30000,0,0,0;
        34000,4,30000,0,0,0;
        34000,inf,0,0,0,0;
        34000,3,30000,0,0,0;
        16000,1,16000,0,0,0;
        20000,6,16000,0,0,0;
        16000,6,5000,0,0,0;
        16000,inf,0,0,0,0;
        30000,inf,0,0,0,0
        ];                                        %油罐初始库存，后面会自动添加蒸馏塔和供油开始时间和结束时间

    FP = [25992,49008,90000,0,0,0];        %进料包(可计算原油种类)
    ET = [];              %空闲供油罐集合
    DSFET = [0,0,0];   %蒸馏塔最后一次的炼油结束时间
    PET = 0;                %管道最后一次转运的结束时间(停运也记录在内)
    %调度信息记录表
    scheduleplan = [];
    %统计初始时空油罐的集合
    for i=1:size(TKS,1)
        if TKS(i,3) == 0
            ET = [ET,i];
        end
    end
    %未实现炼油计划的蒸馏塔集合
    UD = [1,2,3];
    %首先判断当前状态是否可以调度
	if schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD) 
        %根据炼油顺序随机选择一个非空的供油罐为各个蒸馏塔供油
        for i = 1:3     %i代表蒸馏塔
            for j = 1:2     %j代表进料包
                for k = 1:size(TKS,1)       %k代表油罐
                    if FPORDER(i,j) == TKS(k,2)
                        Temp = DSFET(i);
                        %计算供油罐的供油结束时间，并添加到供油罐对应的供油记录表中
                        DSFET(i) = DSFET(i) + TKS(k,3) / DSFR(i);%DSFET(i)代表蒸馏塔i的最后一次供油结束时间，TKS(k,3)代表供油罐k的当前油量，DSFR(i)代表蒸馏塔i的炼油速率
                        scheduleplan = [scheduleplan; i, k, Temp, DSFET(i), TKS(k,2)];
                        TKS(k, 4) = i;   %记录蒸馏塔
                        TKS(k, 5) = Temp;   %记录供油开始时间
                        TKS(k, 6) = DSFET(i);   %记录供油结束时间
                    end
                end
            end
        end
        %回溯调度，并修正不可行解
        schedule( 1,ET,UD,PET,DSFET,FP,TKS,scheduleplan,DSFR,PIPEFR,FPORDER,RT );
	else
        disp('初始库存不满足指定条件，系统不可调度！\n');
	end
end