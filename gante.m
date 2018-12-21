%蒸馏塔/管道 油罐 开始时间 结束时间 原油类型
a=[4   10.0000         0   24.0000    2.0000;
    4    4.0000   24.0000   39.2064    2.0000;
    4    1.0000   39.2064   52.0064    1.0000;
    4    9.0000   52.0064   60.0000    1.0000;
    4    3.0000   60.0000   87.2000    3.0000;
    4    8.0000   87.2000  100.0000    3.0000;
    4    5.0000  100.0000  127.2000    3.0000;
    4    7.0000  127.2000  132.0000    3.0000;
    1    1.0000         0   24.0024    5.0000;
    1    2.0000   24.0024  114.0114    5.0000;
    1    6.0000  114.0114  162.0162    1.0000;
    1    1.0000  162.0162  210.0210    1.0000;
    1    9.0000  210.0210  240.0000    1.0000;
    2    7.0000         0   54.8509    6.0000;
    2    8.0000   54.8509   71.9918    6.0000;
    2   10.0000   71.9918  174.8372    2.0000;
    2    4.0000  174.8372  240.0000    2.0000;
    3    3.0000         0   48.0000    4.0000;
    3    5.0000   48.0000   96.0000    3.0000;
    3    3.0000   96.0000  150.4000    3.0000;
    3    8.0000  150.4000  176.0000    3.0000;
    3    5.0000  176.0000  230.4000    3.0000;
    3    7.0000  230.4000  240.0000    3.0000]; 
w=0.5;       %横条宽度
color=['r','g','b','c','m','y','w'];    %颜色

dset = [];   %蒸馏塔/管道的集合
%统计蒸馏塔/管道的个数
for i=1:size(a,1)
    if ~ismember(a(i,1), dset)
        dset = [dset, a(i,1)]
    end
end

xlabel('时间'); 
ylabel('设备'); 
axis([0 270 0 10]); 
set(gca,'Box','on'); 
set(gca,'XTick',0:30:240);      %设置刻度
set(gca,'YTick',0:10/(size(dset,2)+1):10);      %设置刻度
set(gca,'YTickLabel',{'';num2str((1:size(dset,2)-1)','DS%d');'PIPE';''});       %设置标记

for ii=1:size(a,1) 
    %计算矩形区域的边界点
    x=a(ii,[3 3 4 4]);
    y=a(ii,1)*10/(size(dset,2)+1)+[-w/2 w/2 w/2 -w/2]
    %使用不同的颜色填充封闭的矩形区域
    if a(ii,5)==1
        p=patch('xdata',x,'ydata',y,'facecolor',color(1),'edgecolor','k'); 
    elseif a(ii,5)==2
        p=patch('xdata',x,'ydata',y,'facecolor',color(2),'edgecolor','k'); 
    elseif a(ii,5)==3
        p=patch('xdata',x,'ydata',y,'facecolor',color(3),'edgecolor','k'); 
    elseif a(ii,5)==4
        p=patch('xdata',x,'ydata',y,'facecolor',color(4),'edgecolor','k'); 
    elseif a(ii,5)==5
        p=patch('xdata',x,'ydata',y,'facecolor',color(5),'edgecolor','k'); 
    elseif a(ii,5)==6
        p=patch('xdata',x,'ydata',y,'facecolor',color(6),'edgecolor','k'); 
    elseif a(ii,5)==0
        p=patch('xdata',x,'ydata',y,'facecolor',color(7),'edgecolor','k'); 
    end
    %设置矩形区域的文字
    text(a(ii,3)+0.5,a(ii,1)*10/(size(dset,2)+1),['TK', num2str(a(ii,2))]); 
end 
legend('#1','#2','#3','#4','#5','#6');