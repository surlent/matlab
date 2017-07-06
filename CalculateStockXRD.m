function [StockDataXRD, adjFactor] = CalculateStockXRD(StockData, XRD_Data, AdjFlag, AlgoFlag)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
% �ǵ���ǰ��Ȩ�㷨
% ����ǰ��Ȩ�㷨
% �ȱȸ�Ȩ�㷨
% StockData:���� �� �� �� ��
% AdjFlag 1:ǰ��Ȩ�۸����� 2:��Ȩ�۸�����
% % % ����� ������ 2014.12.09
% ��Ȩ��=(��Ȩǰһ�����̼�+��ɼ�X��ɱ���-ÿ����Ϣ)/(1+��ɱ���+�͹ɱ���)
% ��Ȩ����=��Ȩǰһ�����̼�/��Ȩ��
% AlgoFlag ��� 1 == AlgoFlag ��ʱҪ�������StockData�����һ��Ϊ��Ȩ����
% 1 �ǵ���ǰ��Ȩ�㷨
% 2 ����ǰ��Ȩ�㷨
%% �������Ԥ����
if nargin < 4 || isempty(AlgoFlag)
    AlgoFlag = 1;
end
if nargin < 3 || isempty(AdjFlag)
    AdjFlag = 1;
end

Date = StockData(:,1);

StockDataXRD = [];
adjFactor = [];

StockDataXRD = StockData;
StockDataXRD(:,1) = StockData(:,1);
%% ǰ��Ȩ�۸�����
if 1 == AdjFlag
    % �ǵ���ǰ��Ȩ�㷨
    % % ���������StockData��������ô������տ�ʼ
    if 1 == AlgoFlag
        if size(StockData,2) > 5
            BackwardAdjFactor = StockData(:,end);
            ForwardAdjFactor = BackwardAdjFactor/BackwardAdjFactor(end,1);
            
            for i = 2:5
                StockDataXRD(:,i) = StockData(:,i).*ForwardAdjFactor;
            end
        else
            str = ['�����StockData������������������Ӧ��Ϊ���ڡ������ߡ��͡��ա���Ȩ����'];
            disp(str);
        end
    end
    
    
    % ����ǰ��Ȩ�㷨   
    if 2 == AlgoFlag
        for i = 2:5
            Web_XRD_Data = XRD_Data;
            Stock_Data_Date = Date;
            Stock_Data_Close = StockData(:,i);
            [ XRD_Close ] = F_Stock_XRD_Processing(Web_XRD_Data,Stock_Data_Date,Stock_Data_Close);
            StockDataXRD(:,i) = XRD_Close;
        end
    end
end
%% ��Ȩ�۸�����
if 2 == AdjFlag
    % �ǵ���ǰ��Ȩ�㷨
    if 1 == AlgoFlag
        if size(StockData,2) > 5
            BackwardAdjFactor = StockData(:,end);
            ForwardAdjFactor = BackwardAdjFactor/BackwardAdjFactor(end,1);
            
            for i = 2:5
                StockDataXRD(:,i) = StockData(:,i).*BackwardAdjFactor;
            end
        else
            str = ['�����StockData������������������Ӧ��Ϊ���ڡ������ߡ��͡��ա���Ȩ����'];
            disp(str);
        end
    end
    
    
    % ����ǰ��Ȩ�㷨   
    if 2 == AlgoFlag
        
        
    end   
end

end

%% sub function
function [ XRD_Close ] = F_Stock_XRD_Processing(Web_XRD_Data,Stock_Data_Date,Stock_Data_Close)
%% ���ø�ʽ:
%      [ XRD_Close ] = F_Stock_XRD_Processing(Web_XRD_Data,Stock_Data_Date,Stock_Data_Close)
% ����: Web_XRD_Data �� ��Ȩ��Ϣ����
%       Stock_Data_Date �� ��������
%       Stock_Data_Close �� �۸����̼ۣ�����
% ���: XRD_Close �� ǰ��Ȩ����
% by Chandeman
% У���� 2014/8/4
% �����κ���������ϵEmail: 414117285@qq.com
%% �ҳ���Ȩ��Ϧ���ڵ�λ��

if ~isempty(Web_XRD_Data)
    
    XRD_Time = nan(length(Web_XRD_Data(:,1)),1);
    Intermediate_variable_j = length(Web_XRD_Data(:,1));
    
    for Intermediate_variable_i = length(Web_XRD_Data(:,1)) : -1 : 1
        
        if find(Web_XRD_Data(Intermediate_variable_i,1) == Stock_Data_Date(:,1))
            XRD_Time(Intermediate_variable_j,1) = ...
                find(Web_XRD_Data(Intermediate_variable_i,1) == Stock_Data_Date(:,1));
            Intermediate_variable_j = Intermediate_variable_j - 1;
        end
        
    end
    
    XRD_Time = XRD_Time(~isnan(XRD_Time));
    
    %% ǰ��Ȩ����
    
    XRD_Close = nan(length(Stock_Data_Close),1);
    
    if ~isempty(XRD_Time)
        
        XRD_Data = Web_XRD_Data(end-length(XRD_Time)+1:end,:);
        
        for Intermediate_variable_i = length(XRD_Time) : -1 : 0
            
            if  Intermediate_variable_i == length(XRD_Time)
                XRD_Close(XRD_Time(Intermediate_variable_i):end) = ...
                    Stock_Data_Close(XRD_Time(Intermediate_variable_i):end);
            elseif Intermediate_variable_i == 0
                XRD_Close(1:XRD_Time(Intermediate_variable_i+1)-1) = ...
                    Stock_Data_Close(1:XRD_Time(Intermediate_variable_i+1)-1);
                for Intermediate_variable_j = 1 : length(XRD_Time)
                    XRD_Close(1:XRD_Time(Intermediate_variable_i+1)-1) = ...
                        (XRD_Close(1:XRD_Time(Intermediate_variable_i+1)-1) - XRD_Data(Intermediate_variable_j,4)/10 + XRD_Data(Intermediate_variable_j,5)/10*XRD_Data(Intermediate_variable_j,6))...
                        /(1+(XRD_Data(Intermediate_variable_j,2)+XRD_Data(Intermediate_variable_j,3)+XRD_Data(Intermediate_variable_j,5))/10);
                end
            else
                XRD_Close(XRD_Time(Intermediate_variable_i):XRD_Time(Intermediate_variable_i+1)-1) = ...
                    Stock_Data_Close(XRD_Time(Intermediate_variable_i):XRD_Time(Intermediate_variable_i+1)-1);
                for Intermediate_variable_j = Intermediate_variable_i + 1 : length(XRD_Time)
                    XRD_Close(XRD_Time(Intermediate_variable_i):XRD_Time(Intermediate_variable_i+1)-1) = ...
                        (XRD_Close(XRD_Time(Intermediate_variable_i):XRD_Time(Intermediate_variable_i+1)-1) - XRD_Data(Intermediate_variable_j,4)/10 + XRD_Data(Intermediate_variable_j,5)/10*XRD_Data(Intermediate_variable_j,6))...
                        /(1+(XRD_Data(Intermediate_variable_j,2)+XRD_Data(Intermediate_variable_j,3)+XRD_Data(Intermediate_variable_j,5))/10);
                end
            end
            
        end
        
    else
        XRD_Close = Stock_Data_Close;
    end
    
else
    XRD_Close = Stock_Data_Close;
end

XRD_Close = round(XRD_Close*100)/100;
end