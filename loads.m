function [DetailProcess,FloatingStock,StockData,StockFinInd,StockIndicators,StockInfo,StockSheet3]=loads(stockcode)
if nargin<1
stockcode=input('���������,��ʽΪxx000000 \n','s');
end

try
load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat'],'StockIndicators');%����ָ���б�
catch
    disp('��ָ���ļ�')
end
try
load(['.\DataBase\Stock\FinancialIndicators_mat\' stockcode '_FinIndicator.mat'],'StockFinInd');%�������ָ��
catch
    disp('�޲���ָ���ļ�')
end
try
load(['.\DataBase\Stock\StockInfo_mat\' stockcode '_StockInfo.mat'],'StockInfo');%���������Ϣ��
catch
    disp('�޻�����Ϣ�ļ�')
end
try
load(['.\DataBase\Stock\Floating stock_mat\' stockcode '.mat'],'FloatingStock');%������ͨ����Ϣ
catch
    disp('����ͨ����Ϣ�ļ�')
end
try
%load(['.\DataBase\Stock\Day_ExDividend_mat\' stockcode '_D_ExDiv.mat']);%δ��Ȩ��Ϣ����
load(['.\DataBase\Stock\Day_ForwardAdj_mat\' stockcode '_D_ForwardAdj.mat'],'StockData');%��Ȩ��Ϣ����
catch
    disp('�޻���ǰ��Ȩ�����ļ�')
end
try
load(['.\DataBase\BackTestResult\AI\' stockcode '_DetailProcess.mat'],'DetailProcess');%�ز�����
catch
    disp('�޵����ز���ϸ�ļ�')
end
try
load(['.\DataBase\Stock\Sheet3_mat\' stockcode '_Sheet3.mat'],'StockSheet3');%����������ļ�
catch
    disp('�޲������������')
end
end
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
