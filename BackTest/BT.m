function [Result]=BT(ResourceStr,FileString,Scode)
%% 本函数用来读取指标信息等,传输至具体回测函数,在本函数中保存具体的回测数据,返回个股的回测结论
try
    load(ResourceStr);  
catch
    disp('没有对应的文件')
    return
end
%%初始参数设置,对所有策略适用
Slip=0.001;      %滑点1%由于我采用当日成交平均价格作为参数,滑点设置初期可以保守些,后期看实际情况调整,应当相对其他价格标准要小些,因为可能成交交个相对要更优一些.
StartMoney=100000;  %初始金钱
Fee=0.00025;    %手续费
%% 读入基础数据
Date=StockIndicators(:,1);
Price=StockIndicators(:,2);
Open=StockIndicators(:,3);
High=StockIndicators(:,4);
Low=StockIndicators(:,5);
Close=StockIndicators(:,6);
Volume=StockIndicators(:,7);
Amount=StockIndicators(:,8);
TOR=StockIndicators(:,11);
%% 读入衍生指标数据
MeanCost5=StockIndicators(:,14);
MeanCost10=StockIndicators(:,15);
MeanCost20=StockIndicators(:,16);
MeanCost40=StockIndicators(:,17);
MeanCost80=StockIndicators(:,18);
MeanCost160=StockIndicators(:,19);
MeanCost320=StockIndicators(:,20);
RSIValue=StockIndicators(:,21);
UpperLine=StockIndicators(:,22);
MiddleLine=StockIndicators(:,23);
LowerLine=StockIndicators(:,24);
%% 传输至具体的回测算法
%% 算法1
%[Result,DetailProcess]=BT_macd2(Slip,StartMoney,Fee,Price,DIF,DEA,Scode,Date);%result={1Scode,2年化收益率,3夏普比率,4最大回撤,5alpha,6beta}列1代码,2年化收益率,3夏普比率,4最大回撤,5alpha,6beta
%% 算法2
% Period=350;             %周期,大于100,小于350,使用短周期可以过滤掉MeanCost160,MeanCost320数据,避免使用空值进行判断.
% [Result,DetailProcess] = BT_RSImean( Slip,StartMoney,Fee,Date,Scode,MeanCost5,MeanCost10,MeanCost20,MeanCost40,MeanCost80,MeanCost160,MeanCost320,RSIValue,Price,TOR,Period);
%% 算法3
Period=350; 
[Result,DetailProcess] = BT_Boll(Slip,StartMoney,Fee,Date,Scode,Price,TOR,Period,UpperLine,MiddleLine,LowerLine);
%%算法4
%[Result,DetailProcess] =BT_BPtrain(Slip,StartMoney,Fee,Date,Scode,Price,)
%%算法5
%%算法6
%%算法7
%%算法8
%%保存个股具体的回测数据
save(FileString,'DetailProcess', '-v7.3');
end

