function [Result,DetailProcess] = BT_macd2(Slip,StartMoney,Fee,Price,DIF,DEA,Scode,Date)
%%回测某代码数据的
Len=length(Price);
if Len<=100
   Result={Scode,0,0,0,0};
   DetailProcess=[0,0,0,0,0,0,0];
   return
end

Position=zeros(Len,1);          %仓位,先只有0,1两种位置即满仓和空仓
TradePrice=zeros(Len,2);        %购入买入价格包含费用等一系列中间成本
StockAmount=zeros(Len,1);       %持仓量
Cash=zeros(Len,1);              %现金
Cash(:,1)=StartMoney;           %先全部调整为初始资金
Assets=zeros(Len,1);            %总资产
ProfitPerTrade=zeros(Len,1);    %单笔盈利/亏损
%%新建策略只需要引入其他变量,并对if后面的语句进行调整.
for i=100:Len                   %过滤掉新股阶段
    if DIF(i)>DEA(i) && DIF(i-1)<=DEA(i-1) && Position(i-1)==0
       Position(i)=1;
       TradePrice(i,1)=Price(i)*(1+Slip)*(1+Fee);
       StockAmount(i)=floor(Cash(i-1)/(TradePrice(i,1)*100));
       Cash(i)=Cash(i-1)-StockAmount(i)*TradePrice(i,1)*100;
       Assets(i)=Cash(i)+StockAmount(i)*Price(i)*100;
    elseif DIF(i)<DEA(i) && DIF(i-1)>=DEA(i-1) && Position(i-1)==1
       Position(i)=0;
       TradePrice(i,2)=Price(i)*(1-Slip)*(1-Fee-0.001);            %0.001是印花税
       Cash(i)=Cash(i-1)+StockAmount(i-1)*TradePrice(i,2)*100;
       StockAmount(i)=0;
       Assets(i)=Cash(i);
       ProfitPerTrade(i)=Assets(i)/Assets(i-1)-1;
    else
       Position(i)=Position(i-1); 
       StockAmount(i)=StockAmount(i-1);
       Cash(i)=Cash(i-1);
       Assets(i)=Cash(i)+StockAmount(i)*Price(i)*100;
    end
end
DetailProcess=[Date,Position,StockAmount,Cash,Assets,TradePrice];
TotalProfit=Assets(Len)-Assets(100);
TotalProfitRate=Assets(Len)/Assets(100)-1;
YearPassed=(datenum(num2str(Date(Len)),'yyyymmdd')-datenum(num2str(Date(100)),'yyyymmdd'))/365;
YearlyProfitRate=TotalProfitRate/YearPassed;
Std=std(Assets(100:Len));
Avg=mean(Assets(100:Len));
if Std==0
    SharpRate=0;                                                      %如果一只股票超过100天交易日,但是由于没有买点,导致收益为0,总资产不变,继而导致标准差为0,这种情况会导致年化夏普比率为负无穷.所以直接按0计算.
else
    SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05年化无风险收益率,夏普比率基本要求是大于1,然后越大越好,小于1表示单位风险大于单位超额收益,小于0表示收益率低于无妨先收益.
end
DrawDownRate=zeros(length(Assets),1);
for t=1:length(Assets)
	DrawDownRate(t)=(Assets(t)-min(Assets(t:end)))/Assets(t);
end;
MaxDrawDownRate=max(DrawDownRate);
Result={Scode,TotalProfit,YearlyProfitRate,SharpRate,MaxDrawDownRate};   
end

