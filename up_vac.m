function [ new_AC ] = up_vac( AC,old_AC,M,Na )
%�����㷨���ⲿ���������Լ����ӵ�ȫ��������
%AC����ѡ��
%old_AC���ⲿ������
%new_AC�����º���ⲿ������
%popsize����Ⱥ��С

%size(AC,1)����ѡ�ߵ�����
for i = 1:size(AC,1)
    %��ÿ����ѡ�����ⲿ�������е�Ԫ�ؽ��бȽϣ����´�����
    old_AC = up_vac0(AC(i,:),old_AC,M,Na);
end
%�ⲿ�������Ѿ����£������浽new_AC��
new_AC = old_AC;
%������º���ⲿ��������ӵ������ֵ
crowd_value = calcul_crowd(new_AC,M);

Gbest_set = new_AC;
Gbest_crowd_val = crowd_value;
%�ⲿ�������е����Ӹ���
g_size = size(Gbest_set,1);
while g_size > Na                                        %�ⲿ�������е�����NA
    [~, ind] = sort(Gbest_crowd_val);         %�����º���ⲿ�������е����ӵ�ӵ������ֵ����
    Gbest_set(ind(1),:) = [];                           %ɾ��ӵ������ֵ��С��Ԫ��
    Gbest_crowd_val(ind(1)) = [];                 %ɾ��ӵ������ֵ��С��Ԫ�ص�ӵ������ֵ
    g_size = size(Gbest_set,1);                   %���¼����ⲿ�������е���������
end
end

