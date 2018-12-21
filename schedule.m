function [ Flag,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable ] = schedule( step,ET,UD,PET,DSFET,FP,TKS,SchduleTable,DSFR,PIPEFR,FPORDER,RT )
%% ���ݵ���(��Ҫ�ҵ����еĿ��н�)
    Flag = false;
    %�����ֵ
    Old_step = step;
    Old_ET = ET;
    Old_UD = UD;
    Old_PET = PET;
    Old_DSFET = DSFET;
    Old_FP = FP;
    Old_TKS = TKS;
    Old_SchduleTable = SchduleTable;
    %һ��ת�˵���С����
    VMin = 300;         
    %������
    persistent AC;
    
    %% ���ⲻ��Ҫ�Ĳ���
    [f1,f2,f3,f4] = getresult(SchduleTable);
    tmp = [f1,f2,f3,f4];
    if ~isempty(AC)&&~domination(tmp,AC)
        return;
    end
    
    %% ��¼�������㼣
    footprint = zeros(1,length(ET)*length(UD)+1);
    
   	%% ������ȱ���
   	while ~all(footprint)
      	tplan = find(footprint==0,1);
        try
            %% �ҵ�һ�����еķ������������±�����������
            if isempty(UD) || sum(FP) == 0
             	[f1,f2,f3,f4] = getresult(SchduleTable);
                a = [f1,f2,f3,f4];
                [AC] = up_vac(a,AC,length(a),100);
               	fprintf('%d:     %d     %d       %d        %d\n',step,f1,f2,f3,f4);              %���������̨
                break;
            else
            	%% ѡ���͹޺�������
               	TK_NO = ceil((tplan-1)/length(UD));                %���͹����
               	DS_NO = mod(tplan-1,length(UD));
              	if DS_NO==0
                 	DS_NO = length(UD);
                end
              	DS = UD(DS_NO);         %������
               	%% ͣ�˻���ת��
               	f1 = false;
               	if TK_NO==0 || isempty(ET)
                 	PipeStoptime  = roundn(getPipeStoptime(FPORDER, DSFR, RT, TKS, PET, FP, UD),-6);%�������룬ȡ6λС��
                   	if PipeStoptime > 0 
                      	f1 = true;
                       	[SchduleTable,TKS,ET,PET] = stop(ET,PET,TKS,SchduleTable,PipeStoptime,DSFR);
                    end
              	else
                  	[f2,PET,TKS,FP,ET,UD,DSFET,SchduleTable] = tryschedule(ET(TK_NO),DS,DSFET,PET,PIPEFR,RT,ET,UD,DSFR,TKS,FP,FPORDER,SchduleTable,VMin);
                   	%�ж��Ե����Ƿ�ɹ�����һ״̬�Ƿ���Ե���
                  	if f2 && schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD)
                     	f1 = true;
                    end
                end
               	%% �ж��Ե����Ƿ�ɹ�����һ״̬�Ƿ���Ե���
              	if f1
                 	step = step + 1;
                  	[ ~,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable ] = schedule( step,ET,UD,PET,DSFET,FP,TKS,SchduleTable,DSFR,PIPEFR,FPORDER,RT );
                end
            end
             %% �ָ���ʼ�������������
            [step,ET,UD,PET,DSFET,FP,TKS,SchduleTable] = rollback(Old_step,Old_ET,Old_UD,Old_PET,Old_DSFET,Old_FP,Old_TKS,Old_SchduleTable);      
            footprint(tplan) = 1;
        catch err
          	disp(err);
        end
    end
end

%% �ж�֧���ϵ
function flag = domination(par_eff,old_AC)
    flag = true;
    %��������Ԫ�صĸ���
    ss1 = size(old_AC,1);
    M = length(par_eff);
    for i = 1:ss1
        bb1 = 0;
        bb2 = 0;
        for j = 1:M     %Ŀ�꺯���ĸ���M
            aa1 = old_AC(i,j);
            aa2 = par_eff(1,j);
            if aa2 < aa1
                bb1 = bb1 + 1;
            elseif aa2 == aa1
                bb2 = bb2 + 1;
            end
        end
        %�ж�֧���ϵ
        if (bb1 + bb2 == 0) ||  (bb2 ~= 0 && bb1 == 0)     %��ѡ�߲�֧�䴢����
            flag = false;
            break;
        end
    end
end

%% ������
function [f1,f2,f3,f4] = getresult(SchduleTable)
    SchduleTable=sortrows(SchduleTable,1);
   	c1 = [0 11 12 13 7 15;
                        10 0 9 12 13 7;
                        13 8 0 7 12 13;
                        13 12 7 0 11 12;
                        7 13 12 11 0 11;
                        15 7 13 12 11 0];           %�ܵ���ϳɱ�
  	c2 = [0 11 12 13 10 15;
                        11 0 11 12 13 10;
                        12 11 0 10 12 13;
                        13 12 10 0 11 12;
                        10 13 12 11 0 11;
                        15 10 13 12 11 0];          %�޵׻�ϳɱ�
  	%% ������Ӧ�Ⱥ���
 	f1 = gnum(SchduleTable);              %���͹޸���
   	f2 = gchange(SchduleTable);        %�������Ĺ��͹��л�����
   	f3 = gdmix(SchduleTable, c1);      %�ܵ���ϳɱ�
 	f4 = gdimix(SchduleTable, c2);     %�޵׻�ϳɱ�
end

%% ���ݻع�
function [step,ET,UD,PET,DSFET,FP,TKS,SchduleTable] = rollback(Old_step,Old_ET,Old_UD,Old_PET,Old_DSFET,Old_FP,Old_TKS,Old_SchduleTable)
        step = Old_step;
        ET = Old_ET;
        UD = Old_UD;
        PET = Old_PET;
        DSFET = Old_DSFET;
        FP = Old_FP;
        TKS = Old_TKS;
        SchduleTable = Old_SchduleTable;
end

%% �������ԭ������
function [total] = gettotal(UD,DSFR,FP,TKS,PET,FPORDER)
	UDFR = sortrows([UD;DSFR(UD)]',2);   %����������������(��������)
	K = size(UDFR, 1);
	available = zeros(size(DSFR, 2), 2);       %����и���������Ŀǰ���õ�����
	for i = 1:K
        DSN = UDFR(i,1);    %������
        COTN1 = FPORDER(DSN, 1);      %ԭ������1
        COTN2 = FPORDER(DSN, 2);      %ԭ������1
        for j = 1:size(TKS, 1)          %j�����͹�
            if TKS(j, 2) == COTN1
                if TKS(j, 5) <= PET && TKS(j, 6) > PET
                    available(DSN, 1) = available(DSN, 1) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);
                else
                    available(DSN, 1) = available(DSN, 1) + TKS(j, 3);
                end
            elseif TKS(j, 2) == COTN2
                if TKS(j, 5) <= PET && TKS(j, 6) > PET
                    available(DSN, 2) = available(DSN, 2) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);   %����״̬
                else
                    available(DSN, 2) = available(DSN, 2) + TKS(j, 3);  %�ǹ���״̬
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
end

%% ͣ��
function [SchduleTable,TKS,ET,PET] = stop(ET,PET,TKS,SchduleTable,PipeStoptime,DSFR)
	PETOLD = PET;
    tk = 0;
    [feedendtimes,ind] = sort(TKS(:,6));
	%ͣ���ڼ䣬�����������Ƿ����ͽ���
	for i = 1:size(TKS,1)
        if feedendtimes(i) > PET && feedendtimes(i) <= PET + PipeStoptime
            tk = i;
            break;
        end
	end
	%���͹��ͷ�
	if tk ~= 0
        %����ת�˽���ʱ��Ϊ���͹޿��õ�ʱ��
        PET = feedendtimes(tk);
        %��ͣ���ڼ��ͷŵĹ��͹���ӵ�ET��
        ET = [ET, ind(tk)];      %����ǰ�͹���ӵ�ET��
        %���͹���Ϣ
        TKS(ind(tk), 2) = inf;
        TKS(ind(tk), 3) = 0;
        TKS(ind(tk), 4) = 0;
        TKS(ind(tk), 5) = 0;
        TKS(ind(tk), 6) = 0;
    else
        %����ͣ��
        PET = PET + PipeStoptime;
	end
	%����ת�˼�¼������Ҫ��ѡ���͹޹���
	SchduleTable = [SchduleTable; length(DSFR) + 1, 0, PETOLD, PET, 0];
end

%% ��ȫ����
function [V] = getVolume(DS,DSFET,PET,RT,UD,total,DSFR,PIPEFR)
	V = (DSFET(DS) - PET - RT) * PIPEFR;    %����פ��ʱ��Լ��
	VSec = inf;     %��������ԭ��ת�˵İ�ȫ���
	for i=1:size(UD,2)
        if UD(i) ~= DS
            if DSFR(UD(i)) == max(DSFR)
                mincapacity = 2 * size(UD, 2) * RT * DSFR(UD(i));
            else
                mincapacity = size(UD, 2) * RT * DSFR(UD(i));
            end
            if VSec > PIPEFR / DSFR(UD(i)) * (total(UD(i)) - mincapacity)
                VSec = PIPEFR / DSFR(UD(i)) * (total(UD(i)) - mincapacity);
            end
        end
	end
	if VSec < V
        V = VSec;
	end
end

%% �Ե���
function [Flag,PET,TKS,FP,ET,UD,DSFET,SchduleTable] = tryschedule(TK,DS,DSFET,PET,PIPEFR,RT,ET,UD,DSFR,TKS,FP,FPORDER,SchduleTable,VMin)
	%ԭ������
	if FP(FPORDER(DS, 1)) == 0
        COT = FPORDER(DS, 2);      %ԭ������2
	else
        COT = FPORDER(DS, 1);      %ԭ������1
	end
	%���������
	total = gettotal(UD,DSFR,FP,TKS,PET,FPORDER);    
    %��ȫ��ԭ�����
    V = roundn(getVolume(DS,DSFET,PET,RT,UD,total,DSFR,PIPEFR),-6);
	%��������Ե����ض�����ֵ
	if V >= VMin
        if TKS(TK, 1) < V
            V = TKS(TK, 1);
        end
        if FP(COT) < V
            V = FP(COT);
        end

        %���ϰ�
        FP(COT) = FP(COT) - V;

        %���͹޼���
        ET(ET==TK) = [];       %ɾ��TK

        %ת���ڼ��ͷŵĹ��͹���ӵ����͹޼���
        for i = 1:size(TKS,1)
            if (TKS(i,6) > PET && TKS(i,6) <= PET + V / PIPEFR)
                %����ǰ�͹���ӵ�ET��
                ET = [ET, i];
                %���͹���Ϣ���
                TKS(i, 2) = inf;
                TKS(i, 3) = 0;
                TKS(i, 4) = 0;
                TKS(i, 5) = 0;
                TKS(i, 6) = 0;
            end
        end

        %�ܵ�ת�˽���ʱ��
        PETOLD = PET;
        PET = PET + V / PIPEFR;

        %��������ʱ��
        DSFETOLD = DSFET(DS);
        DSFET(DS) = DSFETOLD + V / DSFR(DS);

        %���͹޵�״̬��Ϣ
        TKS(TK, 2) = COT;
        TKS(TK, 3) = V;
        TKS(TK, 4) = DS;
        TKS(TK, 5) = DSFETOLD;
        TKS(TK, 6) = DSFET(DS);
        Flag = true;
        
    	%����ת�˼�¼�����ͼ�¼
        SchduleTable = [SchduleTable;  length(DSFR)+1, TK, PETOLD, PET, COT];
    	SchduleTable = [SchduleTable;  DS, TK, DSFETOLD, DSFET(DS), COT];
        %�ж�DS�Ƿ����ͳɹ�
     	if roundn(DSFET(DS),0) == 240
            UD(UD==DS) = [];        %ɾ��DS
     	end
    else
        Flag = false;
	end
end