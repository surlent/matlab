cd i:\FQuantToolBox
pause(5);
%% 更新全部股票日线数据（前复权）、流通股信息,股票信息(不稳定在不启用)
str=['程序开始,记录日志i:\FQuantToolBox\log\',date,'.txt'];
str1=['i:\FQuantToolBox\log\',date,'.txt'];
diary (str1);
diary on;
disp (str)
disp ('更新股票列表')
StockList=GetStockList_Web;
save StockList StockList;
AdjFlag=0;
XRDFlag=0;
tic
disp ('更新全部股票日线数据,前复权并检查');
[~,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
save ProbList0 ProbList;%保存原始数据(含前复权系数)问题清单
save NewList0 NewList;%保存原始数据(含前复权系数)新条目清单
%% 进行前复权
load StockList.mat;
AdjFlag=1;
XRDFlag=0;
tic
disp ('进行前复权');
[~,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
save AdjProbList ProbList;%保存前复权问题清单
save AdjNewList NewList;%保存前复权新条目清单
toc
pause(5);
%% 获取流通股信息
pause(5);
disp ('获取流通股信息');
SaveStockTOR;
% pause(5);
% %% 重新过滤新条目一遍,以免网络问题导致误差
% load NewList0.mat;
% StockList = NewList;
% AdjFlag=0;
% XRDFlag=0;
% [SaveLog,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
% save NewList0 NewList;%保存原始数据(含前复权系数)新条目清单
% clear all;
% pause(5);
% %% 重新过滤问题条目一遍,以免网络问题导致误差
% load ProbList0.mat;
% StockList = ProbList;
% AdjFlag=0;
% XRDFlag=0;
% [SaveLog,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag);
% save ProbList0 ProbList;%保存原始数据(含前复权系数)新条目清单
% clear all;
toc
pause(5);
%% 更新全部指数日线数据
IndexList=GetIndexList_Web;
save IndexList IndexList;
tic
disp ('更新全部指数日线数据');
[~,ProbList,NewList] = SaveIndexTSDay(IndexList);
save IndexProbList ProbList;
save IndexNewList NewList;
toc
pause(5);
%% 更新全部股票财务信息(周期使用,不需要每天运行)
load StockList.mat;
Opt=0;
disp ('更新主要指标');
[~,~,~] = SaveStockFD(StockList,Opt);
pause(5);
% load StockList.mat;
% Opt=1;
% disp ('更新三大表');
% [~,~,~] = SaveStockFD(StockList,Opt);
%% 获取股票信息，不稳定，不做日常使用
% pause(5);
% load StockList.mat;
% disp ('获取股票信息');
% [SaveLog,ProbList,NewList] = SaveStockInfo(StockList);
% save InfProbList ProbList;
% save InfNewList NewList;
% pause(5);
%% 计算指标
disp ('计算生成全部存档指标');
tic
SaveIndicator(2);%指数指标  先指数后股票,因为股票指标中包含指数信息
SaveIndicator(1);%股票指标
toc
pause(5);
%% AI回测
% Flag=3;
% AI(Flag,1);
Flag=4;
AI(Flag,1);
pause(5);
%% 发送邮件
subject=[date '回测结果'];
folderstr='.\BackTest\AIForcast\';
DataPath=struct2cell(dir(folderstr))';
DataPath=[folderstr,DataPath{end,1}];
% [~,~,raw] =xlsread(DataPath,'回测结果');
% shunwangID=find(strcmp(raw,'sz300113'));
% if raw{shunwangID,4}>2
% text='未来10日预计不会下跌,现在可能是底部了,可以行权';
% else
text='预测内容见附件(仅供参考),本邮件自动发送请不要回复.';
% end
try
    mailme(subject,text,'24030275@qq.com','hnbqgdruqtpgbgef',DataPath,'smtp.qq.com')
    disp('预测结果发送成功!')
catch
    disp('发送失败')
end
diary off;

clear
clc