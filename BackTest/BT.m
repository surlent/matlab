function [Result]=BT(ResourceStr,FileString,Scode)
%% ������������ȡָ����Ϣ��,����������ز⺯��,�ڱ������б������Ļز�����,���ظ��ɵĻز����
try
    load(ResourceStr);  
catch
    disp('û�ж�Ӧ���ļ�')
    return
end
%%��ʼ��������,�����в�������
Slip=0.001;      %����1%�����Ҳ��õ��ճɽ�ƽ���۸���Ϊ����,�������ó��ڿ��Ա���Щ,���ڿ�ʵ���������,Ӧ����������۸��׼ҪСЩ,��Ϊ���ܳɽ��������Ҫ����һЩ.
StartMoney=100000;  %��ʼ��Ǯ
Fee=0.00025;    %������
%% �����������
Date=StockIndicators(:,1);
Price=StockIndicators(:,2);
Open=StockIndicators(:,3);
High=StockIndicators(:,4);
Low=StockIndicators(:,5);
Close=StockIndicators(:,6);
Volume=StockIndicators(:,7);
Amount=StockIndicators(:,8);
TOR=StockIndicators(:,11);
%% ��������ָ������
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
%% ����������Ļز��㷨
%% �㷨1
%[Result,DetailProcess]=BT_macd2(Slip,StartMoney,Fee,Price,DIF,DEA,Scode,Date);%result={1Scode,2�껯������,3���ձ���,4���س�,5alpha,6beta}��1����,2�껯������,3���ձ���,4���س�,5alpha,6beta
%% �㷨2
% Period=350;             %����,����100,С��350,ʹ�ö����ڿ��Թ��˵�MeanCost160,MeanCost320����,����ʹ�ÿ�ֵ�����ж�.
% [Result,DetailProcess] = BT_RSImean( Slip,StartMoney,Fee,Date,Scode,MeanCost5,MeanCost10,MeanCost20,MeanCost40,MeanCost80,MeanCost160,MeanCost320,RSIValue,Price,TOR,Period);
%% �㷨3
Period=350; 
[Result,DetailProcess] = BT_Boll(Slip,StartMoney,Fee,Date,Scode,Price,TOR,Period,UpperLine,MiddleLine,LowerLine);
%%�㷨4
%[Result,DetailProcess] =BT_BPtrain(Slip,StartMoney,Fee,Date,Scode,Price,)
%%�㷨5
%%�㷨6
%%�㷨7
%%�㷨8
%%������ɾ���Ļز�����
save(FileString,'DetailProcess', '-v7.3');
end

