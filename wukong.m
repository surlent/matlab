cd i:\FQuantToolBox
pause(5);
%% ����ȫ����Ʊ�������ݣ�ǰ��Ȩ������ͨ����Ϣ,��Ʊ��Ϣ(���ȶ��ڲ�����)
str=['����ʼ,��¼��־i:\FQuantToolBox\log\',date,'.txt'];
str1=['i:\FQuantToolBox\log\',date,'.txt'];
diary (str1);
diary on;
disp (str)
disp ('���¹�Ʊ�б�')
StockList=GetStockList_Web;
save StockList StockList;
AdjFlag=0;
XRDFlag=0;
tic
disp ('����ȫ����Ʊ��������,ǰ��Ȩ�����');
[~,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
save ProbList0 ProbList;%����ԭʼ����(��ǰ��Ȩϵ��)�����嵥
save NewList0 NewList;%����ԭʼ����(��ǰ��Ȩϵ��)����Ŀ�嵥
%% ����ǰ��Ȩ
load StockList.mat;
AdjFlag=1;
XRDFlag=0;
tic
disp ('����ǰ��Ȩ');
[~,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
save AdjProbList ProbList;%����ǰ��Ȩ�����嵥
save AdjNewList NewList;%����ǰ��Ȩ����Ŀ�嵥
toc
pause(5);
%% ��ȡ��ͨ����Ϣ
pause(5);
disp ('��ȡ��ͨ����Ϣ');
SaveStockTOR;
% pause(5);
% %% ���¹�������Ŀһ��,�����������⵼�����
% load NewList0.mat;
% StockList = NewList;
% AdjFlag=0;
% XRDFlag=0;
% [SaveLog,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
% save NewList0 NewList;%����ԭʼ����(��ǰ��Ȩϵ��)����Ŀ�嵥
% clear all;
% pause(5);
% %% ���¹���������Ŀһ��,�����������⵼�����
% load ProbList0.mat;
% StockList = ProbList;
% AdjFlag=0;
% XRDFlag=0;
% [SaveLog,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
% save ProbList0 ProbList;%����ԭʼ����(��ǰ��Ȩϵ��)����Ŀ�嵥
% clear all;
toc
pause(5);
%% ����ȫ��ָ����������
IndexList=GetIndexList_Web;
save IndexList IndexList;
tic
disp ('����ȫ��ָ����������');
[~,ProbList,NewList] = SaveIndexTSDay(IndexList);
save IndexProbList ProbList;
save IndexNewList NewList;
toc
pause(5);
%% ����ȫ����Ʊ������Ϣ(����ʹ��,����Ҫÿ������)
load StockList.mat;
Opt=0;
disp ('������Ҫָ��');
[~,~,~] = SaveStockFD(StockList,Opt);
pause(5);
% load StockList.mat;
% Opt=1;
% disp ('���������');
% [~,~,~] = SaveStockFD(StockList,Opt);
%% ��ȡ��Ʊ��Ϣ�����ȶ��������ճ�ʹ��
% pause(5);
% load StockList.mat;
% disp ('��ȡ��Ʊ��Ϣ');
% [SaveLog,ProbList,NewList] = SaveStockInfo(StockList);
% save InfProbList ProbList;
% save InfNewList NewList;
% pause(5);
%% ����ָ��
disp ('��������ȫ���浵ָ��');
tic
SaveIndicator(2);%ָ��ָ��  ��ָ�����Ʊ,��Ϊ��Ʊָ���а���ָ����Ϣ
SaveIndicator(1);%��Ʊָ��
toc
pause(5);
%% AI�ز�
% Flag=3;
% AI(Flag,1);
Flag=4;
AI(Flag,1);
pause(5);
%% �����ʼ�
subject=[date '�ز���'];
folderstr='.\BackTest\AIForcast\';
DataPath=struct2cell(dir(folderstr))';
DataPath=[folderstr,DataPath{end,1}];
% [~,~,raw] =xlsread(DataPath,'�ز���');
% shunwangID=find(strcmp(raw,'sz300113'));
% if raw{shunwangID,4}>2
% text='δ��10��Ԥ�Ʋ����µ�,���ڿ����ǵײ���,������Ȩ';
% else
text='Ԥ�����ݼ�����(�����ο�),���ʼ��Զ������벻Ҫ�ظ�.';
% end
try
    mailme(subject,text,'24030275@qq.com','hnbqgdruqtpgbgef',DataPath,'smtp.qq.com')
    disp('Ԥ�������ͳɹ�!')
catch
    disp('����ʧ��')
end
diary off;

clear
clc