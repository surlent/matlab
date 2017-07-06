function [Result,DetailProcess] = BT_Boll(Slip,StartMoney,Fee,Date,Scode,Price,TOR,Period,UpperLine,MiddleLine,LowerLine)
%% �ز�ĳ�������ݵ�,�ӵ�100����ʼ,���ⳤ����ָ�����ݲ�����.���ڳ���,������Ϊ350
Len=length(Price);
if Len<=Period
   Result={Scode,0,0,0,0};
   DetailProcess=[0,0,0,0,0,0,0];
   return
end
%% �̶�������������
Position=zeros(Len,1);          %��λ,��ֻ��0,1����λ�ü����ֺͿղ�
TradePrice=zeros(Len,2);        %��������۸�������õ�һϵ���м�ɱ�
StockAmount=zeros(Len,1);       %�ֲ���
Cash=zeros(Len,1);              %�ֽ�
Cash(:,1)=StartMoney;           %��ȫ������Ϊ��ʼ�ʽ�
Assets=zeros(Len,1);            %���ʲ�
ProfitPerTrade=zeros(Len,1);    %����ӯ��/����
%% �½�����ֻ��Ҫ������������,�����жϵ������е���.
for i=100:Len                   %���˵��¹ɽ׶�
    signalBuy= MiddleLine(i-2)<0 && MiddleLine(i-1)>0;
    signalSell= MiddleLine(i-2)>0 && MiddleLine(i-1)<0;
    stopLoss=(Price(i)<TradePrice(i-1,1)*0.9);
    %stopWin=(Price(i)>TradePrice(i-1,1)*1.5);
    if signalBuy==1 && Position(i-1)==0 
       Position(i)=1;
       TradePrice(i,1)=Price(i)*(1+Slip)*(1+Fee);
       StockAmount(i)=floor(Cash(i-1)/(TradePrice(i,1)*100));
       Cash(i)=Cash(i-1)-StockAmount(i)*TradePrice(i,1)*100;
       Assets(i)=Cash(i)+StockAmount(i)*Price(i)*100;
    elseif (signalSell==1 && Position(i-1)==1) || (stopLoss==1 && Position(i-1)==1) %|| (stopWin==1 && Position(i-1)==1) %���߷��ź�Ϊֹ��,ֹӯ����
       Position(i)=0;
       TradePrice(i,2)=Price(i)*(1-Slip)*(1-Fee-0.001);            %0.001��ӡ��˰
       Cash(i)=Cash(i-1)+StockAmount(i-1)*TradePrice(i,2)*100;
       StockAmount(i)=0;
       Assets(i)=Cash(i);
       ProfitPerTrade(i)=Assets(i)/Assets(i-1)-1;
    else
       Position(i)=Position(i-1); 
       TradePrice(i,1)=TradePrice(i-1,1);
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
    SharpRate=0;                                                      %���һֻ��Ʊ����Period�콻����,��������û�����,��������Ϊ0,���ʲ�����,�̶����±�׼��Ϊ0,��������ᵼ���껯���ձ���Ϊ������.����ֱ�Ӱ�0����.
else
    SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05�껯�޷���������,���ձ��ʻ���Ҫ���Ǵ���1,Ȼ��Խ��Խ��,С��1��ʾ��λ���մ��ڵ�λ��������,С��0��ʾ�����ʵ����޷�������.
end
DrawDownRate=zeros(length(Assets),1);
for t=1:length(Assets)
	DrawDownRate(t)=(Assets(t)-min(Assets(t:end)))/Assets(t);
end;
MaxDrawDownRate=max(DrawDownRate);
Result={Scode,TotalProfit,YearlyProfitRate,SharpRate,MaxDrawDownRate}; 
end

