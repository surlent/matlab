function [DetailProcess,FloatingStock,StockData,StockFinInd,StockIndicators,StockInfo,StockSheet3]=loads(stockcode)
if nargin<1
stockcode=input('请输入代码,格式为xx000000 \n','s');
end

try
load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat'],'StockIndicators');%读入指标列表
catch
    disp('无指标文件')
end
try
load(['.\DataBase\Stock\FinancialIndicators_mat\' stockcode '_FinIndicator.mat'],'StockFinInd');%读入财务指标
catch
    disp('无财务指标文件')
end
try
load(['.\DataBase\Stock\StockInfo_mat\' stockcode '_StockInfo.mat'],'StockInfo');%读入基本信息表
catch
    disp('无基本信息文件')
end
try
load(['.\DataBase\Stock\Floating stock_mat\' stockcode '.mat'],'FloatingStock');%读入流通股信息
catch
    disp('无流通股信息文件')
end
try
%load(['.\DataBase\Stock\Day_ExDividend_mat\' stockcode '_D_ExDiv.mat']);%未除权除息数据
load(['.\DataBase\Stock\Day_ForwardAdj_mat\' stockcode '_D_ForwardAdj.mat'],'StockData');%除权除息数据
catch
    disp('无基本前复权数据文件')
end
try
load(['.\DataBase\BackTestResult\AI\' stockcode '_DetailProcess.mat'],'DetailProcess');%回测数据
catch
    disp('无单独回测明细文件')
end
try
load(['.\DataBase\Stock\Sheet3_mat\' stockcode '_Sheet3.mat'],'StockSheet3');%财务三大表文件
catch
    disp('无财务三大表数据')
end
end
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
% load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
