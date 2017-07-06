function BPtrainAllinOne(Flag)
%%本函数不需要通过ai启动,因为不需要重复读取个股数据,而是运行完combine函数后,将所有指标汇总,直接对一个合并的样本进行训练.(并非时间序列)
%运算结果很不理想,我想是因为个股中有很多梯度很大的数据流,让神经元极为迟钝,不再对之后的变化有反应,反应在结果上:所有输入都产生一个输出,神经网络权值怎么调整都无效.
%暂时不适用这种方式
if nargin<1
    Flag=input(['请输入测试模式' 10 '1,只做学习不回测' 10 '2,只回测不学习' 10 '3,学习并回测' 10 '4,预测明日买卖信号' 10]);
end

FolderStr1 = '.\DataBase\Net\AllinOne\';

if ~isdir( FolderStr1 )
    mkdir( FolderStr1 );
end

FolderStr2 = '.\DataBase\BackTestResult\AI_AllinOne\';

if ~isdir( FolderStr2 )
    mkdir( FolderStr2 );
end


if Flag==1 || Flag==3
    
    
    net = feedforwardnet([5,2]);
    net.trainFcn = 'trainbr';
    net.layers{1}.transferFcn = 'tansig';
    net.divideParam.trainRatio=0.5;
    net.divideParam.valRatio=0.25;
    net.divideParam.testRatio=0.25;
    net.trainparam.epochs = 50000;
    net.trainparam.goal = 0.001;
    net.trainParam.lr = 0.01;
    net.trainParam.max_fail=500;
    
    
    load('.\DataBase\Index\2D All\TwoDAll.mat');            %合并的方式有两种,一个是所有个股组成一个三维数组,这种方式训练还要还原,所以不采用,而是采用2维数组的合并(2D样本汇总)
    inPut=TwoDAll(:,11:end-5)';
    outPut=(TwoDAll(:,end-1)*100)';
    
    inPut = mapminmax(inPut);
    net = train(net,inPut,outPut);
    save( '.\DataBase\Net\AllinOne\AllinOne_net.mat','net', '-v7.3');
end

if Flag==2 || Flag==3
    %% 读入指标,并根据net输出预计值
    d=dir('.\DataBase\Index\DayIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    for i=1:len
        StockCode{i}(end-17:end)=[];
    end
    result=cell(len,5);             %回测输出结果
    try
        load('.\DataBase\Net\AllinOne\AllinOne_net.mat');
    catch
        disp('无汇总神经网络')
    end
    for i=1:len
        Scode = StockCode{i};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);%读入指标列表
        disp(['当前进行中' Scode] )
        TestData=StockIndicators;
        TestData =[TestData(:,1:2),TestData(:,11:end-5)];
        TestData(any(TestData==0,2),:)=[];      %去除不需要的行
        if isempty(TestData) || size(TestData,1)<2
            disp('测试数据过少跳出')
            continue
        end
        Date=TestData(:,1);
        Price=TestData(:,2);
        ROE=TestData(:,6);
        TestData=TestData(:,3:end)';
        TestData = mapminmax(TestData);         %归一化
        ForCast = sim(net, TestData);
        ForCast = ForCast';
        %% 回测设置
        Slip=0.001;      %滑点1%由于我采用当日成交平均价格作为参数,滑点设置初期可以保守些,后期看实际情况调整,应当相对其他价格标准要小些,因为可能成交交个相对要更优一些.
        StartMoney=100000;  %初始金钱
        Fee=0.00025;    %手续费
        Len=length(Price);
        Position=zeros(Len,1);          %仓位,先只有0,1两种位置即满仓和空仓
        TradePrice=zeros(Len,2);        %购入买入价格包含费用等一系列中间成本
        %ForCastPrice=zeros(Len,1);      %预计价格
        StockAmount=zeros(Len,1);       %持仓量
        Cash=zeros(Len,1);              %现金
        Cash(:,1)=StartMoney;           %先全部调整为初始资金
        Assets=zeros(Len,1);            %总资产
        ProfitPerTrade=zeros(Len,1);    %单笔盈利/亏损
        %% 时间序列仿真回测
        for j=2:Len                   %全都是有效数据从第二天开始
            signalBuy= ForCast(j-1)>5 && ROE(j)>5;
            signalSell= ForCast(j-1)<0;
            %         stopLoss=0;    %(Price(i)<TradePrice(i-1,1)*0.85);卖出过于频繁
            %         stopWin=Price(i)>ForCastPrice(i);
            if signalBuy==1 && Position(j-1)==0
                Position(j)=1;
                TradePrice(j,1)=Price(j)*(1+Slip)*(1+Fee);
                %ForCastPrice(i)=Price(i)*(ForCast(i)+1);
                StockAmount(j)=floor(Cash(j-1)/(TradePrice(j,1)*100));
                Cash(j)=Cash(j-1)-StockAmount(j)*TradePrice(j,1)*100;
                Assets(j)=Cash(j)+StockAmount(j)*Price(j)*100;
            elseif (signalSell==1 && Position(j-1)==1) %|| (stopLoss==1 && Position(i-1)==1) || (stopWin==1 && Position(i-1)==1) %或者符号后方为止损,止盈条件
                Position(j)=0;
                TradePrice(j,2)=Price(j)*(1-Slip)*(1-Fee-0.001);            %0.001是印花税
                Cash(j)=Cash(j-1)+StockAmount(j-1)*TradePrice(j,2)*100;
                StockAmount(j)=0;
                Assets(j)=Cash(j);
                ProfitPerTrade(j)=Assets(j)/Assets(j-1)-1;
            else
                Position(j)=Position(j-1);
                TradePrice(j,1)=TradePrice(j-1,1);
                %ForCastPrice(i)=ForCastPrice(i-1);
                StockAmount(j)=StockAmount(j-1);
                Cash(j)=Cash(j-1);
                Assets(j)=Cash(j)+StockAmount(j)*Price(j)*100;
            end
        end
        DetailProcess=[Date,Position,StockAmount,Cash,Assets,TradePrice];
        save(['.\DataBase\BackTestResult\AI_AllinOne\' Scode '_DetailProcess.mat'],'DetailProcess', '-v7.3');
        TotalProfit=Assets(Len)-Assets(2);
        TotalProfitRate=Assets(Len)/Assets(2)-1;
        YearPassed=(datenum(num2str(Date(Len)),'yyyymmdd')-datenum(num2str(Date(1)),'yyyymmdd'))/365;
        YearlyProfitRate=TotalProfitRate/YearPassed;
        Std=std(Assets(2:Len));
        Avg=mean(Assets(2:Len));
        if Std==0
            SharpRate=0;                                                      %如果一只股票超过Period天交易日,但是由于没有买点,导致收益为0,总资产不变,继而导致标准差为0,这种情况会导致年化夏普比率为负无穷.所以直接按0计算.
        else
            SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05年化无风险收益率,夏普比率基本要求是大于1,然后越大越好,小于1表示单位风险大于单位超额收益,小于0表示收益率低于无风险收益.
        end
        DrawDownRate=zeros(length(Assets),1);
        for t=1:length(Assets)
            DrawDownRate(t)=(Assets(t)-min(Assets(t:end)))/Assets(t);
        end;
        MaxDrawDownRate=max(DrawDownRate);
        result(i,:)={Scode,TotalProfit,YearlyProfitRate,SharpRate,MaxDrawDownRate};
    end
    temp=cell2mat(result(:,2:end));
    temp(all(temp==0,2),:)=[];          %去除0值
    temp=mean(temp);
    temp=num2cell(temp);                %计算平均值
    Mean=[{'平均总收益'},{'平均年化收益率'},{'平均夏普比率'},{'平均最大回撤'};temp];
    save( '.\DataBase\BackTestResult\AI_AllinOne\Result.mat','result', '-v7.3');%文件用来保存回测结果
    save( '.\DataBase\BackTestResult\AI_AllinOne\Mean.mat','Mean', '-v7.3');%文件用来保存汇总
end

if Flag==4
    result=cell(len,7);
    try
        load(['..\DataBase\Net\AllinOne\AllinOne_net.mat']);
    catch
        disp('无汇总神经网络')
    end
    for i=1:len
        Scode = StockCode{i};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);%读入指标列表
        temp = StockIndicators;
        temp (:,all(temp==0,1))=[];             %去除不需要的列
        TestData=temp;
        TestData =[TestData(:,1:2),TestData(:,11:end-5)];
        TestData(any(TestData==0,2),:)=[];      %去除不需要的行
        Date=TestData(:,1);
        Price=TestData(:,2);
        TestData=TestData(:,3:end)';
        TestData = mapminmax(TestData);         %归一化
        TestData = TestData(:,end);
        ForCast = sim(net, TestData);
        if ForCast>0.1
            result(i,:)={stockcode,Date,'下一交易日购入,10日预计涨幅',ForCast,'','',''};              %(代码,日期,建议,幅度,历史年化收益率,历史最大回撤)今后还要增加历史准确率的数值,或者直接算期望值,YearlyProfitRate,SharpRate,MaxDrawDownRate
        elseif ForCast<0
            result(i,:)={stockcode,Date,'下一交易日卖出,10日预计跌幅',ForCast,'','',''};
        else
            result(i,:)={stockcode,Date,'中性,10日预计',ForCast,'','',''};
        end
    end
    disp('汇总预测结果生成xls文件')
    temp=load('.\DataBase\BackTestResult\AI_AllinOne\Result.mat');
    temp=struct2cell(temp);
    reference=temp{1,1};
    Len=length(result);
    code=result(:,1);
    for i=1:Len
        result{i,5}=reference{strncmp(code(i),reference,8),3};
        result{i,6}=reference{strncmp(code(i),reference,8),4};
        result{i,7}=reference{strncmp(code(i),reference,8),5};
    end
    LastDate=num2str(max(cell2mat(result(:,2))));
    xlswrite(['.\BackTest\AIForcast\AllinOne_SubTotal' LastDate ],{'代码','最后预测日期','建议','预计涨跌幅','回测期望年化收益率','回测期望夏普比率','最大回撤'},'回测结果','A1');
    xlswrite(['.\BackTest\AIForcast\AllinOne_SubTotal' LastDate ],result,'回测结果','A2');
end

end