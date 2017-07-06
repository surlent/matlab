function [Result,tp] = BPtrain(stockcode,Flag,unit)
%% 读取训练数据,并修剪包含0值的矩阵.
%Flag=1,只做学习不回测
%Flag=2,只回测不学习
%Flag=3,学习并回测
%Flag=4,预测下一个交易日买卖建议
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

load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);%读入指标列表

temp = StockIndicators;                %准备去除不需要的列
Len=size(temp,1);
if Len<=320 && Flag~=4
    disp('错误01:样本数据不足导致输入输出维度过低,退出本条神经网络训练,并删除历史网络')
    Result={stockcode,0,0,0,0,0,0,0};
    try
        delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
        disp('删除成功')
    catch
        disp('无旧网络文件,跳过删除.')
    end
    return
end

TestData=temp;

if Flag==1 || Flag==3
    temp (any(temp==0,2),:)=[];            %去除包含0的行
    %% 读取结果数据,生成input,output.
    try
        inPut=temp(:,11:end-5)';
        outPut=(temp(:,end-2).*100)';
        if isempty(inPut)||isempty(outPut)
            disp('错误02:样本数据不足导致输入输出维度过低,退出本条神经网络训练')
            Result={stockcode,0,0,0,0,0,0,0};
            try
                delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
                disp('删除成功')
            catch
                disp('无旧网络文件,跳过删除.')
            end
            return
        end
    catch
        disp('错误03:样本数据不足导致输入输出维度过低,退出本条神经网络训练')
        Result={stockcode,0,0,0,0,0,0,0};
        try
            delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
            disp('删除成功')
        catch
            disp('无旧网络文件,跳过删除.')
        end
        return
    end
    clear temp;
    %% 特征值归一化
    inPut = mapminmax(inPut);
    %% 创建神经网络
    net = feedforwardnet(unit);
    %% 设置训练参数
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
    %% 保存训练网络
    save( ['.\DataBase\Net\Stock\' stockcode '_net.mat'],'net', '-v7.3');%文件用来保存回测结果
    save( ['.\DataBase\Net\Stock\' stockcode '_tp.mat'],'tp', '-v7.3');%文件用来保存回测结果
    if Flag==1
        Result={stockcode,0,0,0,0,0,0,0};
    end
end


%% 读取测试数据进行回测
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
                disp(['错误04:无神经网络文件,尝试学习生成' stockcode '神经网络'])
                [Result]=BPtrain(stockcode,1);
                load(['.\DataBase\Net\Stock\' stockcode '_net.mat']);
            catch
                disp(['错误05:尝试学习生成' stockcode '神经网络失败,退出本条神经网络训练'])
                Result={stockcode,0,0,0,0,0,0,0};
                try
                    delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
                    disp('删除成功')
                catch
                    disp('无旧网络文件,跳过删除.')
                end
                return
            end
        end
    end
    ForCast = sim(net, TestData);
    ForCast = ForCast';
    %% 回测基础参数
    Slip=0.001;      %滑点1%由于我采用当日成交平均价格作为参数,滑点设置初期可以保守些,后期看实际情况调整,应当相对其他价格标准要小些,因为可能成交交个相对要更优一些.
    StartMoney=100000;  %初始金钱
    Fee=0.00025;    %手续费
    Len=size(Price,1);
    Position=zeros(Len,1);          %仓位,先只有0,1两种位置即满仓和空仓
    TradePrice=zeros(Len,2);        %购入买入价格包含费用等一系列中间成本
    %ForCastPrice=zeros(Len,1);      %预计价格
    StockAmount=zeros(Len,1);       %持仓量
    Cash=zeros(Len,1);              %现金
    Cash(:,1)=StartMoney;           %先全部调整为初始资金
    Assets=zeros(Len,1);            %总资产
    ProfitPerTrade=zeros(Len,1);    %单笔盈利/亏损
    TradeTimes=0;
    WinTimes=0;
    %% 仿真回测
    for i=2:Len                   %全都是有效数据从第二天开始
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
        elseif (signalSell==1 && Position(i-1)==1)% || (stopLoss==1 && Position(i-1)==1) %|| (stopWin==1 && Position(i-1)==1) %或者符号后方为止损,止盈条件
            Position(i)=0;
            TradePrice(i,2)=Price(i)*(1-Slip)*(1-Fee-0.001);            %0.001是印花税
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
        SharpRate=0;                                                      %如果一只股票超过Period天交易日,但是由于没有买点,导致收益为0,总资产不变,继而导致标准差为0,这种情况会导致年化夏普比率为负无穷.所以直接按0计算.
    else
        SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05年化无风险收益率,夏普比率基本要求是大于1,然后越大越好,小于1表示单位风险大于单位超额收益,小于0表示收益率低于无风险收益.
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
        disp(['错误06:代码' stockcode '无神经网络,退出本条预测'])
        Result={stockcode,0,'无神经网络',0,0,0,0,0,0,0};
        return
    end
    TestData =[TestData(:,1:2),TestData(:,11:end-5)];
    TestData(any(TestData==0,2),:)=[];
    if isempty(TestData)
        disp(['错误07:代码' stockcode '测试数据不足,退出本条预测'])
        Result={stockcode,0,'无测试数据',0,0,0,0,0,0,0};
        return
    end
    Date=TestData(end,1);
    ROE=TestData(end,6);
    TestData=TestData(:,3:end)';
    TestData = mapminmax(TestData);
    TestData = TestData(:,end);
    ForCast = sim(net, TestData);
    
    if ForCast>5 && ROE>5
        Result={stockcode,Date,'下一交易日可购入,10日预计涨幅:',ForCast,'','','','','',''};              %(代码,日期,建议,幅度,历史年化收益率,历史最大回撤)今后还要增加历史准确率的数值,或者直接算期望值,YearlyProfitRate,SharpRate,MaxDrawDownRate
    elseif ForCast<0
        Result={stockcode,Date,'下一交易日建议卖出,10日预计跌幅:',ForCast,'','','','','',''};
    elseif ForCast<=5 && ForCast>=0
        Result={stockcode,Date,'中性,10日预计:',ForCast,'','','','','',''};
    elseif ForCast>5 && ROE<=5
        Result={stockcode,Date,'中性,因净资产收益率过低被排除',ForCast,'','','','','',''};
    end
    
end




