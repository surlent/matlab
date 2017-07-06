function CheckIndicator(~)
%% ���DataBase/Index/DayIndicator_mat�ļ���������ָ����쳣���
% Ŀǰֻ�����ڹ�Ʊָ��
    
d=dir ('./DataBase/Index/DayIndicator_mat');
d(1:2,:)=[];
d=struct2cell(d);
d=d';
len=size(d,1);
CheckResultsNaN=cell(len,63);
CheckResultsInf=cell(len,63);
StockCode=d(:,1);
for i=1:len
StockCode{i}(end-17:end)=[];
end
CheckResultsNaN(:,1)=StockCode;
CheckResultsInf(:,1)=StockCode;

debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��

if debug == 1
    len=5;
elseif debug == 2
    len=500;
end


parfor i=1:len
     RunIndex = i;
     Scode = StockCode{i};
     strdisp=['���...','���:',num2str(RunIndex),'   ','����:',Scode];
     disp(strdisp)
     FileString = ['./DataBase/Index/DayIndicator_mat/',StockCode{i},'_Fwd_Indicator.mat'];
    S=load(FileString)
    StockIndicators=S.StockIndicators;
    for j=2:33
    CheckResultsNaN{i,j}=ismember(1,isnan(StockIndicators(:,j)));   %MA-macd�����
    CheckResultsInf{i,j}=ismember(1,isinf(StockIndicators(:,j)));   %MA-macd�����
    end
end

xlswrite('./TechnicalAnalysis/CheckResultsNaN',CheckResultsNaN);
xlswrite('./TechnicalAnalysis/CheckResultsInf',CheckResultsInf);
clear
clc

        
        
        
        