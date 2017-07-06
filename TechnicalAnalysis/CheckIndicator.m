function CheckIndicator(~)
%% 检查DataBase/Index/DayIndicator_mat文件夹下所有指标的异常情况
% 目前只适用于股票指标
    
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

debug=0;     %调试模式0关闭,1通过性,2效率

if debug == 1
    len=5;
elseif debug == 2
    len=500;
end


parfor i=1:len
     RunIndex = i;
     Scode = StockCode{i};
     strdisp=['检查...','序号:',num2str(RunIndex),'   ','代码:',Scode];
     disp(strdisp)
     FileString = ['./DataBase/Index/DayIndicator_mat/',StockCode{i},'_Fwd_Indicator.mat'];
    S=load(FileString)
    StockIndicators=S.StockIndicators;
    for j=2:33
    CheckResultsNaN{i,j}=ismember(1,isnan(StockIndicators(:,j)));   %MA-macd相关列
    CheckResultsInf{i,j}=ismember(1,isinf(StockIndicators(:,j)));   %MA-macd相关列
    end
end

xlswrite('./TechnicalAnalysis/CheckResultsNaN',CheckResultsNaN);
xlswrite('./TechnicalAnalysis/CheckResultsInf',CheckResultsInf);
clear
clc

        
        
        
        