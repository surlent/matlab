function [Result,tp] = BPtrain(stockcode,Flag,unit)
%% ��ȡѵ������,���޼�����0ֵ�ľ���.
%Flag=1,ֻ��ѧϰ���ز�
%Flag=2,ֻ�زⲻѧϰ
%Flag=3,ѧϰ���ز�
%Flag=4,Ԥ����һ����������������
if nargin<1
    stockcode='sh600000';
    Flag=1;
    unit=18;
elseif nargin<2
    Flag=1;
    unit=18;
elseif nargin<3
    unit=18;
end

load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);%����ָ���б�

temp = StockIndicators;                %׼��ȥ������Ҫ����
Len=size(temp,1);
if Len<=320 && Flag~=4
    disp('����01:�������ݲ��㵼���������ά�ȹ���,�˳�����������ѵ��,��ɾ����ʷ����')
    Result={stockcode,0,0,0,0,0,0,0};
    try
        delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
        disp('ɾ���ɹ�')
    catch
        disp('�޾������ļ�,����ɾ��.')
    end
    return
end

TestData=temp;

if Flag==1 || Flag==3
    temp (any(temp==0,2),:)=[];            %ȥ������0����
    %% ��ȡ�������,����input,output.
    try
        inPut=temp(:,11:end-5)';
        outPut=(temp(:,end-2).*100)';
        if isempty(inPut)||isempty(outPut)
            disp('����02:�������ݲ��㵼���������ά�ȹ���,�˳�����������ѵ��')
            Result={stockcode,0,0,0,0,0,0,0};
            try
                delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
                disp('ɾ���ɹ�')
            catch
                disp('�޾������ļ�,����ɾ��.')
            end
            return
        end
    catch
        disp('����03:�������ݲ��㵼���������ά�ȹ���,�˳�����������ѵ��')
        Result={stockcode,0,0,0,0,0,0,0};
        try
            delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
            disp('ɾ���ɹ�')
        catch
            disp('�޾������ļ�,����ɾ��.')
        end
        return
    end
    clear temp;
    %% ����ֵ��һ��
    inPut = mapminmax(inPut);
    %% ����������
    net = feedforwardnet(unit);
    %% ����ѵ������
    net.trainFcn = 'trainbr';
    net.layers{1}.transferFcn = 'logsig';
    net.divideParam.trainRatio=0.5;
    net.divideParam.valRatio=0.25;
    net.divideParam.testRatio=0.25;
%     net.trainparam.show=NaN;
%     net.trainparam.showWindow=0;
    net.trainparam.epochs = 5000 ;
    net.trainparam.goal = 0.001 ;
    net.trainParam.lr = 0.01 ;
    net.trainParam.max_fail=200;
    [net,tp] = train(net,inPut,outPut);
    %% ����ѵ������
    save( ['.\DataBase\Net\Stock\' stockcode '_net.mat'],'net', '-v7.3');%�ļ���������ز���
    save( ['.\DataBase\Net\Stock\' stockcode '_tp.mat'],'tp', '-v7.3');%�ļ���������ز���
    if Flag==1
        Result={stockcode,0,0,0,0,0,0,0};
    end
end


%% ��ȡ�������ݽ��лز�
if Flag==2 || Flag==3
    TestData =[TestData(:,1:2),TestData(:,11:end-5)];
    TestData(any(TestData==0,2),:)=[];
    Date=TestData(:,1);
    Price=TestData(:,2);
    ROE=TestData(:,6);
    TestData=TestData(:,3:end)';
    TestData = mapminmax(TestData);
    if Flag==2
        try
            load(['.\DataBase\Net\Stock\' stockcode '_net.mat']);
        catch
            try
                disp(['����04:���������ļ�,����ѧϰ����' stockcode '������'])
                [Result]=BPtrain(stockcode,1);
                load(['.\DataBase\Net\Stock\' stockcode '_net.mat']);
            catch
                disp(['����05:����ѧϰ����' stockcode '������ʧ��,�˳�����������ѵ��'])
                Result={stockcode,0,0,0,0,0,0,0};
                try
                    delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
                    disp('ɾ���ɹ�')
                catch
                    disp('�޾������ļ�,����ɾ��.')
                end
                return
            end
        end
    end
    ForCast = sim(net, TestData);
    ForCast = ForCast';
    %% �ز��������
    Slip=0.001;      %����1%�����Ҳ��õ��ճɽ�ƽ���۸���Ϊ����,�������ó��ڿ��Ա���Щ,���ڿ�ʵ���������,Ӧ����������۸��׼ҪСЩ,��Ϊ���ܳɽ��������Ҫ����һЩ.
    StartMoney=100000;  %��ʼ��Ǯ
    Fee=0.00025;    %������
    Len=size(Price,1);
    Position=zeros(Len,1);          %��λ,��ֻ��0,1����λ�ü����ֺͿղ�
    TradePrice=zeros(Len,2);        %��������۸�������õ�һϵ���м�ɱ�
    %ForCastPrice=zeros(Len,1);      %Ԥ�Ƽ۸�
    StockAmount=zeros(Len,1);       %�ֲ���
    Cash=zeros(Len,1);              %�ֽ�
    Cash(:,1)=StartMoney;           %��ȫ������Ϊ��ʼ�ʽ�
    Assets=zeros(Len,1);            %���ʲ�
    ProfitPerTrade=zeros(Len,1);    %����ӯ��/����
    TradeTimes=0;
    WinTimes=0;
    %% ����ز�
    for i=2:Len                   %ȫ������Ч���ݴӵڶ��쿪ʼ
        signalBuy= ForCast(i-1)>5 && ROE(i)>5;
        signalSell= ForCast(i-1)<0;
        %stopLoss=(Price(i)<TradePrice(i-1,1)*0.9);
        %         stopWin=Price(i)>ForCastPrice(i);
        if signalBuy==1 && Position(i-1)==0
            Position(i)=1;
            TradePrice(i,1)=Price(i)*(1+Slip)*(1+Fee);
            %ForCastPrice(i)=Price(i)*(ForCast(i)+1);
            StockAmount(i)=floor(Cash(i-1)/(TradePrice(i,1)*100));
            Cash(i)=Cash(i-1)-StockAmount(i)*TradePrice(i,1)*100;
            Assets(i)=Cash(i)+StockAmount(i)*Price(i)*100;
        elseif (signalSell==1 && Position(i-1)==1)% || (stopLoss==1 && Position(i-1)==1) %|| (stopWin==1 && Position(i-1)==1) %���߷��ź�Ϊֹ��,ֹӯ����
            Position(i)=0;
            TradePrice(i,2)=Price(i)*(1-Slip)*(1-Fee-0.001);            %0.001��ӡ��˰
            Cash(i)=Cash(i-1)+StockAmount(i-1)*TradePrice(i,2)*100;
            StockAmount(i)=0;
            Assets(i)=Cash(i);
            ProfitPerTrade(i)=Assets(i)/Assets(i-1)-1;
            TradeTimes=TradeTimes+1;
            if TradePrice(i,2)>TradePrice(i-1,1)
                WinTimes=WinTimes+1;
            end
        else
            Position(i)=Position(i-1);
            TradePrice(i,1)=TradePrice(i-1,1);
            %ForCastPrice(i)=ForCastPrice(i-1);
            StockAmount(i)=StockAmount(i-1);
            Cash(i)=Cash(i-1);
            Assets(i)=Cash(i)+StockAmount(i)*Price(i)*100;
        end
    end
    DetailProcess=[Date,Position,StockAmount,Cash,Assets,TradePrice,ForCast,Price];
    save(['.\DataBase\BackTestResult\AI\' stockcode '_DetailProcess.mat'],'DetailProcess', '-v7.3');
    TotalProfit=Assets(Len)-Assets(2);
    TotalProfitRate=Assets(Len)/Assets(2)-1;
    YearPassed=(datenum(num2str(Date(Len)),'yyyymmdd')-datenum(num2str(Date(1)),'yyyymmdd'))/365;
    YearlyProfitRate=TotalProfitRate/YearPassed;
    Std=std(Assets(2:Len));
    Avg=mean(Assets(2:Len));
    
    if TradeTimes~=0
        WinRate=WinTimes/TradeTimes;
    else
        WinRate=0;
    end
    
    if Std==0
        SharpRate=0;                                                      %���һֻ��Ʊ����Period�콻����,��������û�����,��������Ϊ0,���ʲ�����,�̶����±�׼��Ϊ0,��������ᵼ���껯���ձ���Ϊ������.����ֱ�Ӱ�0����.
    else
        SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05�껯�޷���������,���ձ��ʻ���Ҫ���Ǵ���1,Ȼ��Խ��Խ��,С��1��ʾ��λ���մ��ڵ�λ��������,С��0��ʾ�����ʵ����޷�������.
    end
    DrawDownRate=zeros(size(Assets,1),1);
    for t=2:size(Assets,1)
        DrawDownRate(t)=(Assets(t)-min(Assets(t:end)))/Assets(t);
    end;
    MaxDrawDownRate=max(DrawDownRate);
    Result={stockcode,TotalProfit,YearlyProfitRate,SharpRate,MaxDrawDownRate,WinRate,TradeTimes,Len};
end

if Flag==4
    try
        load(['.\DataBase\Net\Stock\' stockcode '_net.mat']);
    catch
        disp(['����06:����' stockcode '��������,�˳�����Ԥ��'])
        Result={stockcode,0,'��������',0,0,0,0,0,0,0};
        return
    end
    TestData =[TestData(:,1:2),TestData(:,11:end-5)];
    TestData(any(TestData==0,2),:)=[];
    if isempty(TestData)
        disp(['����07:����' stockcode '�������ݲ���,�˳�����Ԥ��'])
        Result={stockcode,0,'�޲�������',0,0,0,0,0,0,0};
        return
    end
    Date=TestData(end,1);
    ROE=TestData(end,6);
    TestData=TestData(:,3:end)';
    TestData = mapminmax(TestData);
    TestData = TestData(:,end);
    ForCast = sim(net, TestData);
    
    if ForCast>5 && ROE>5
        Result={stockcode,Date,'��һ�����տɹ���,10��Ԥ���Ƿ�:',ForCast,'','','','','',''};              %(����,����,����,����,��ʷ�껯������,��ʷ���س�)���Ҫ������ʷ׼ȷ�ʵ���ֵ,����ֱ��������ֵ,YearlyProfitRate,SharpRate,MaxDrawDownRate
    elseif ForCast<0
        Result={stockcode,Date,'��һ�����ս�������,10��Ԥ�Ƶ���:',ForCast,'','','','','',''};
    elseif ForCast<=5 && ForCast>=0
        Result={stockcode,Date,'����,10��Ԥ��:',ForCast,'','','','','',''};
    elseif ForCast>5 && ROE<=5
        Result={stockcode,Date,'����,���ʲ������ʹ��ͱ��ų�',ForCast,'','','','','',''};
    end
    
end




