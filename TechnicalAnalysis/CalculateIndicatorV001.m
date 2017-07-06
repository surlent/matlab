function CalculateIndicatorV001(Scode,FileString,Flag,IndexIndicatorsSH,IndexIndicatorsSZ)
%%计算指标函数
%5月28日更新
%调整了平均值指标计算中没有考虑前复权因素直接使用总额作为分子的错误.
%调整了obv指标计算中循环赋值覆盖下一次计算变量,导致计算结果n正确n+1不正确的问题.
%心得:当前市盈率的倒数,其实等于以营利能力计算的每股收益率(与之对应的是分红率),盈利能力是未来预期收益率是一个比较长远的估计(有点虚幻的成分),分红率是现实收益率可以对标国债收益率.
%% 读入相关数据
if nargin<1
    Scode='sh600000';
    FileString=['./DataBase/Index/DayIndicator_mat/' Scode '_Fwd_Indicator.mat'];
    Flag=1;
    load('.\DataBase\Index\IndexIndicator_mat\sh000001_D.mat');
    IndexIndicatorsSH=IndexIndicators;
    load('.\DataBase\Index\IndexIndicator_mat\sz399001_D.mat');
    IndexIndicatorsSZ=IndexIndicators;
    clear IndexIndicators
end

%% 计算股票指标
if Flag==1
    try
        load(['.\DataBase\Stock\FinancialIndicators_mat\' Scode '_FinIndicator.mat'],'StockFinInd');%读入财务指标
        load(['.\DataBase\Stock\StockInfo_mat\' Scode '_StockInfo.mat'],'StockInfo');%读入基本信息表
        load(['.\DataBase\Stock\Floating stock_mat\' Scode '.mat'],'FloatingStock');%读入流通股信息
        load(['.\DataBase\Stock\Day_ForwardAdj_mat\' Scode '_D_ForwardAdj.mat'],'StockData');%除权除息数据
    catch
        disp('基础数据不全,清理旧指标文件,并跳过计算')
        try
            delete(['./DataBase/Index/DayIndicator_mat/' Scode '_Fwd_Indicator.mat']);
            disp('删除成功')
        catch
            disp('无旧指标文件,跳过删除.')
        end
        return;
    end
    
    %% 分解StockData
    Start=20050101;                     %计算指标的起点,经检查发现前期有大量错误数据,意义也不大,所以舍弃.指标从2005年开始,但是回测可以略晚
    Date = StockData(:,1);                  %总日期
    StartRow=find(Date>=Start,1);        %找到起始行
    if isempty(StartRow)            % 如果发生找不到大于startdate的行,可能表明在startdate前已经退市
        disp('2005年之前退市,清理旧指标文件,并跳过计算')
        try
            delete(['./DataBase/Index/DayIndicator_mat/' Scode '_Fwd_Indicator.mat']);
            disp('删除成功')
        catch
            disp('无旧指标文件,跳过删除.')
        end
        return;
    end
    Date = StockData(StartRow:end,1);                  %日期自20050101起,下同
    Open = StockData(StartRow:end,2);                  %开盘价
    High = StockData(StartRow:end,3);                  %最高价
    Low = StockData(StartRow:end,4);                   %最低价
    Close = StockData(StartRow:end,5);                 %收盘价
    Volume = StockData(StartRow:end,6);                %成交量
    Amount = StockData(StartRow:end,7);                %成交额
    Xrd = StockData(StartRow:end,8);                   %前复权系数
    MaxXrd=Xrd(end,1);
    Price = Amount./Volume./MaxXrd.*Xrd;    %前复权的平均成交价格
    Len=length(Date);
    Col=39;
    StockIndicators=zeros(size(Open,1),Col);%创建矩阵
    StockIndicators(:,1) = Date;            % 第一列时间
    StockIndicators(:,9) = Xrd;           % 末列前复权系数
    StockIndicators(:,8)=Amount;        %直接写在这个文件里,方便做回测
    StockIndicators(:,7)=Volume;
    StockIndicators(:,6)=Close;
    StockIndicators(:,5)=Low;
    StockIndicators(:,4)=High;
    StockIndicators(:,3)=Open;
    StockIndicators(:,2)=Price;      %前复权的平均成交价格
    %% 填写流通股
    End=Date(end);
    for j=length(FloatingStock):-1:1
        Start=str2double([FloatingStock{j,1}(1:4),FloatingStock{j,1}(6:7),FloatingStock{j,1}(9:10)]);
        StockIndicators(Date>=Start & Date<=End,10)=FloatingStock{j,2};
        End=Start-1;
    end
    %% 计算换手率(流通股)
    StockIndicators(:,11)=StockIndicators(:,7)./StockIndicators(:,10);
    %% 扣除非经常性损益后的市盈率 资产负债表日,每股收益,每股净资产,净资产收益率,分红率(数据不全暂无).
    LenFin=length(StockFinInd);
    temp=zeros(LenFin,4);
    for i=1:LenFin
        if length(StockFinInd{i,2})~=1 
            BalanceMonth=str2double(StockFinInd{i,2}{2,2}(6:7));
            if BalanceMonth==12 || LenFin==1            %如果只有不满一年的财务信息,是不会进入神经网络测算模块的,也没有上年信息做参考计算本年全年数据,所以直接写上(空着也可以).
                temp(i,1)=str2double([StockFinInd{i,2}{2,2}(1:4),StockFinInd{i,2}{2,2}(6:7),StockFinInd{i,2}{2,2}(9:10)]);%日期
                temp(i,2)=StockFinInd{i,2}{7,2};                                                                          %每股收益
                if isnan(temp(i,2))|| temp(i,2)==0
                    temp(i,2)=StockFinInd{i,2}{6,2};
                    if isnan(temp(i,2))|| temp(i,2)==0
                        temp(i,2)=StockFinInd{i,2}{5,2};
                        if isnan(temp(i,2))|| temp(i,2)==0
                            temp(i,2)=StockFinInd{i,2}{4,2};
                        end
                    end
                end
                temp(i,3)=StockFinInd{i,2}{9,2};                                                                          %每股净资产
                temp(i,4)=StockFinInd{i,2}{32,2};                                                                         %净资产收益率
            elseif BalanceMonth~=12                     %如果某一行数据没有当年年末的数据(并且排除第一年),理论上最好是从上年按比例推算,但上年情况太多变了,所以直接按比例乘算.
                Times=12/BalanceMonth;
                temp(i,1)=str2double([StockFinInd{i,2}{2,2}(1:4),'12','31']);
                temp(i,2)=StockFinInd{i,2}{7,2}*Times;
                if isnan(temp(i,2))|| temp(i,2)==0
                    temp(i,2)=StockFinInd{i,2}{6,2}*Times;
                    if isnan(temp(i,2))|| temp(i,2)==0
                        temp(i,2)=StockFinInd{i,2}{5,2}*Times;
                        if isnan(temp(i,2))|| temp(i,2)==0
                            temp(i,2)=StockFinInd{i,2}{4,2}*Times;
                        end
                    end
                end
                temp(i,3)=StockFinInd{i,2}{9,2};
                temp(i,4)=StockFinInd{i,2}{32,2}*Times;
            end
        else
            continue
        end
    end
    temp(all(temp==0,2),:)=[];
    temp(any(isnan(temp),2),:)=[];
    k=length(temp);
    for i=2:k
        StockIndicators(Date>temp(i-1,1) & Date<=temp(i,1),12)=temp(i,2);
        StockIndicators(Date>temp(i-1,1) & Date<=temp(i,1),13)=temp(i,3);
        StockIndicators(Date>temp(i-1,1) & Date<=temp(i,1),14)=temp(i,4);
    end
    StockIndicators(:,12)=StockIndicators(:,12)./Price;
    StockIndicators(:,13)=StockIndicators(:,13)./Price;
    
    %% 趋势类!成交平均成本 ma没有意义,macd前提假设有问题越靠近的日期数据不一定权重越高.不体现总体成本变动情况.1)5个交易日,2)10个交易日,3)20个交易日,4)40个交易日,5)80个交易日,6)160个交易日,7)320个交易日   截止第八列
    Length=5;                   %系数设置
    if Len>=Length
        MeanCost5=zeros(Len,1);
        for i=Length:Len
            MeanCost5(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,15)=MeanCost5;
        clear MeanCost5;
    end
    Length=10;                   %系数设置
    if Len>=Length
        MeanCost10=zeros(Len,1);
        for i=Length:Len
            MeanCost10(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,16)=MeanCost10;
        clear MeanCost10;
    end
    Length=20;                   %系数设置
    if Len>=Length
        MeanCost20=zeros(Len,1);
        for i=Length:Len
            MeanCost20(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,17)=MeanCost20;
        clear MeanCost20;
    end
    Length=40;                   %系数设置
    if Len>=Length
        MeanCost40=zeros(Len,1);
        for i=Length:Len
            MeanCost40(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,18)=MeanCost40;
        clear MeanCost40;
    end
    Length=80;                   %系数设置
    if Len>=Length
        MeanCost80=zeros(Len,1);
        for i=Length:Len
            MeanCost80(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,19)=MeanCost80;
        clear MeanCost80;
    end
    Length=160;                   %系数设置
    if Len>=Length
        MeanCost160=zeros(Len,1);
        for i=Length:Len
            MeanCost160(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,20)=MeanCost160;
        clear MeanCost160;
    end
    Length=320;                   %系数设置
    if Len>=Length
        MeanCost320=zeros(Len,1);
        for i=Length:Len
            MeanCost320(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,21)=MeanCost320;
        clear MeanCost320;
    end
    %% 计算RSI
    Price30=Price;
    Length30=14;
    if Len>=Length30
        RSIValue=RSI(Price30,Length30);
        StockIndicators(:,22)=RSIValue;
        clear RSIValue;
    end
    %% 计算Boll
    Price7=Price;
    Length7=20;        %系数设置
    Width7=2;           %计算布林线上轨和下轨的宽度，即多少个标准差，常用2
    Type7=0;            %系数设置
    if Len>=Length7
        [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
        StockIndicators(Length7:end,23)=Price(Length7:end)./UpperLine(Length7:end)-1;
        clear UpperLine;
        StockIndicators(Length7:end,24)=Price(Length7:end)./MiddleLine(Length7:end)-1;
        clear MiddleLine;
        StockIndicators(Length7:end,25)=Price(Length7:end)./LowerLine(Length7:end)-1;
        clear LowerLine;
    end
    %% 将上证指数或者深成指数的变动情况写入股票参数,表示宏观环境强弱.
    if strcmp(Scode(1:2),'sh')
       IndexDate=IndexIndicatorsSH(:,1);
       for i=1:Len
       StockIndicators(i,26)=IndexIndicatorsSH(Date(i,1)==IndexDate,2);
       StockIndicators(i,27)=IndexIndicatorsSH(Date(i,1)==IndexDate,3);
       StockIndicators(i,28)=IndexIndicatorsSH(Date(i,1)==IndexDate,4);
       StockIndicators(i,29)=IndexIndicatorsSH(Date(i,1)==IndexDate,5);
       end
    end    
    if strcmp(Scode(1:2),'sz')
       IndexDate=IndexIndicatorsSZ(:,1);
       for i=1:Len
       StockIndicators(i,26)=IndexIndicatorsSZ(Date(i,1)==IndexDate,2);
       StockIndicators(i,27)=IndexIndicatorsSZ(Date(i,1)==IndexDate,3);
       StockIndicators(i,28)=IndexIndicatorsSZ(Date(i,1)==IndexDate,4);
       StockIndicators(i,29)=IndexIndicatorsSZ(Date(i,1)==IndexDate,5);
       end
    end
    %% 20日/40日最高点和最低点30-33列
    for i=21:Len
    StockIndicators(i,30)=max(High(i-20:i))/Price(i)-1;
    StockIndicators(i,31)=min(Low(i-20:i))/Price(i)-1;
    end
    for i=41:Len
    StockIndicators(i,32)=max(High(i-40:i))/Price(i)-1;
    StockIndicators(i,33)=min(Low(i-40:i))/Price(i)-1;
    end
    %% OBV指标34列
    obvtemp=OBV(Price,Volume);
    for i=3:Len
    StockIndicators(i,34)=obvtemp(i,1)/obvtemp(i-1,1)-1;
    end
    clear obvtemp;
    StockIndicators(1:2,34)=0;
    %% 计算N个交易日后的涨跌幅度(用max还是mean,感觉mean更好一些)作为样本向量的结果值,用来做回测划分,在截面数据中,如果某样本向量的下面几个值为0为空,则不参与计算,因为发生这种情况是由于该样本在当日停牌没有数据或者上市不到100天
    if length(Price)>=41
        for l=length(Price):-1:41
            StockIndicators(l-2,end-4)= mean(Price(l-1:l))/Price(l-2)-1;         %次日-2日
            StockIndicators(l-5,end-3)= mean(Price(l-4:l))/Price(l-5)-1;         %1日-5日
            StockIndicators(l-10,end-2)= mean(Price(l-9:l))/Price(l-10)-1;         %1日-10日
            StockIndicators(l-20,end-1)= mean(Price(l-19:l))/Price(l-20)-1;         %1日-20日
            StockIndicators(l-40,end)= mean(Price(l-39:l))/Price(l-40)-1;         %1日-40日,约2个月
        end
    end
    save(FileString,'StockIndicators', '-v7.3');                            %保存指标信息
end








%% 计算指数指标
if Flag==2
    try
        load(['.\DataBase\Stock\Index_Day_mat\' Scode '_D.mat'],'IndexData');%读入指标数据
    catch
        disp('基础数据不全,跳过计算')
        return
    end
    Start=20050101;                     %计算指标的起点,经检查发现前期有大量错误数据,意义也不大,所以舍弃.指标从2005年开始,但是回测可以略晚
    IndexData(any(IndexData==0,2),:)=[];    %有部分指数2004年之前只有一个收盘价,其他为0
    Date = IndexData(:,1);                  %总日期
    StartRow=find(Date>=Start,1);        %找到起始行
    Date = IndexData(StartRow:end,1);                  %日期自20000101起,下同
    Open = IndexData(StartRow:end,2);                  %开盘价
    High = IndexData(StartRow:end,3);                  %最高价
    Low = IndexData(StartRow:end,4);                   %最低价
    %     Close = IndexData(StartRow:end,5);                 %收盘价
    Volume = IndexData(StartRow:end,6);                %成交量
    Amount = IndexData(StartRow:end,7);                %成交额
    Price = Amount./Volume;                            %平均成交价格
    Len=length(Date);
    Col=23;
    IndexIndicators=zeros(size(Open,1),Col);            %创建矩阵
    IndexIndicators(:,1)=Date;
    IndexIndicators(:,2)=Price;
    %% 趋势类!成交平均成本 ma没有意义,macd前提假设有问题越靠近的日期数据不一定权重越高.不体现总体成本变动情况.1)5个交易日,2)10个交易日,3)20个交易日,4)40个交易日,5)80个交易日,6)160个交易日,7)320个交易日
    Length=5;                   %系数设置
    if Len>=Length
        MeanCost5=zeros(Len,1);
        for i=Length:Len
            MeanCost5(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,3)=MeanCost5;
        clear MeanCost5;
    end
    Length=10;                   %系数设置
    if Len>=Length
        MeanCost10=zeros(Len,1);
        for i=Length:Len
            MeanCost10(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,4)=MeanCost10;
        clear MeanCost10;
    end
    Length=20;                   %系数设置
    if Len>=Length
        MeanCost20=zeros(Len,1);
        for i=Length:Len
            MeanCost20(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,5)=MeanCost20;
        clear MeanCost20;
    end
    Length=40;                   %系数设置
    if Len>=Length
        MeanCost40=zeros(Len,1);
        for i=Length:Len
            MeanCost40(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,6)=MeanCost40;
        clear MeanCost40;
    end
    Length=80;                   %系数设置
    if Len>=Length
        MeanCost80=zeros(Len,1);
        for i=Length:Len
            MeanCost80(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,7)=MeanCost80;
        clear MeanCost80;
    end
    Length=160;                   %系数设置
    if Len>=Length
        MeanCost160=zeros(Len,1);
        for i=Length:Len
            MeanCost160(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,8)=MeanCost160;
        clear MeanCost160;
    end
    Length=320;                   %系数设置
    if Len>=Length
        MeanCost320=zeros(Len,1);
        for i=Length:Len
            MeanCost320(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,9)=MeanCost320;
        clear MeanCost320;
    end
    %% 计算RSI
    Price30=Price;
    Length30=14;
    if Len>=Length30
        RSIValue=RSI(Price30,Length30);
        IndexIndicators(:,10)=RSIValue;
        clear RSIValue;
    end
    %% 计算Boll
    Price7=Price;
    Length7=20;        %系数设置
    Width7=2;           %计算布林线上轨和下轨的宽度，即多少个标准差，常用2
    Type7=0;            %系数设置
    if Len>=Length7
        [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
        IndexIndicators(Length7:end,11)=Price(Length7:end)./UpperLine(Length7:end)-1;
        clear UpperLine;
        IndexIndicators(Length7:end,12)=Price(Length7:end)./MiddleLine(Length7:end)-1;
        clear MiddleLine;
        IndexIndicators(Length7:end,13)=Price(Length7:end)./LowerLine(Length7:end)-1;
        clear LowerLine;
    end
    %% 20日/40日最高点和最低点30-33列
    for i=21:Len
    IndexIndicators(i,14)=max(High(i-20:i))/Price(i)-1;
    IndexIndicators(i,15)=min(Low(i-20:i))/Price(i)-1;
    end
    for i=41:Len
    IndexIndicators(i,16)=max(High(i-40:i))/Price(i)-1;
    IndexIndicators(i,17)=min(Low(i-40:i))/Price(i)-1;
    end
    %% OBV指标
    obvtemp=OBV(Price,Volume);
    for i=3:Len
    IndexIndicators(i,18)=obvtemp(i,1)/obvtemp(i-1,1)-1;
    end
    clear obvtemp;
    IndexIndicators(1:2,18)=0;
    %% 计算N个交易日后的涨跌幅度(用max还是mean,感觉mean更好一些)作为样本向量的结果值,用来做回测划分,在截面数据中,如果某样本向量的下面几个值为0为空,则不参与计算,因为发生这种情况是由于该样本在当日停牌没有数据或者上市不到100天
    if length(Price)>=41
        for l=length(Price):-1:41
            IndexIndicators(l-2,end-4)= mean(Price(l-1:l))/Price(l-2)-1;         %次日-2日
            IndexIndicators(l-5,end-3)= mean(Price(l-4:l))/Price(l-5)-1;         %1日-5日
            IndexIndicators(l-10,end-2)= mean(Price(l-9:l))/Price(l-10)-1;         %1日-10日
            IndexIndicators(l-20,end-1)= mean(Price(l-19:l))/Price(l-20)-1;         %1日-20日
            IndexIndicators(l-40,end)= mean(Price(l-39:l))/Price(l-40)-1;         %1日-40日,约2个月
        end
    end
    save(FileString,'IndexIndicators', '-v7.3');
    
end

end

%% 计算开关设置
% flag2=0;%出现0值导致
% flag3=0;%四个价格一样持续几天就会出错
% flag4=0;
% flag5=0;
% flag6=0;
% flag7=0;
% flag8=0;
% flag9=0;
% flag10=0;%有些股票连续N天四个价格一样,就会出错
% flag11=0;%有些股票连续N天四个价格一样,就会出错
% flag12=0;
% flag13=0;
% flag14=0;
% flag15=0;
% flag16=0;%出现0值导致
% flag17=0;
% flag18=0;
% flag19=0;
% flag20=0;
% flag21=0;
% flag22=0;
% flag23=0;
% flag24=0;
% flag25=0;
% flag26=0;
% flag27=0;
% flag28=0;
% flag29=0;
% flag30=0;
% flag31=0;
% %flag32=1;
% flag33=0;
% flag34=0;
% flag35=0;%有些股票连续N天四个价格一样,就会出错
% flag36=0;
% flag37=0;
% flag38=0;
%% 下面是原指标计算,多而不精,有需要的时候再拿出来算.
% %% 2调用AD
% if flag2==1
% StockIndicators(:,2) = AD(High,Low,Close,Volume);
% end
% %% 3调用ARBR
% Length3=26;                              %系数设置
% if flag3==1 && Len>=Length3
% [AR,BR]=ARBR(Open,High,Low,Close,Length3);
% StockIndicators(:,3)=AR;
% clear AR;
% StockIndicators(:,4)=BR;
% clear BR;
% end
% %% 4调用AROON
% Length4=20;                              %系数设置
% if flag4==1 && Len>=Length4
% [UpAroon,DownAroon] =AROON(High,Low,Length4);
% StockIndicators(:,5)=UpAroon;
% clear UpAroon;
% StockIndicators(:,6)=DownAroon;
% clear DownAroon;
% end
% %% 5调用ATR
% Length5=14;                   %系数设置
% Type5=0;                      %系数设置
% if flag5==1 && Len>=Length5
% ATRValue=ATR(High,Low,Close,Length5,Type5);
% StockIndicators(:,7)=ATRValue;
% clear ATRValue;
% end
% %% 6调用BIAS
% Price6=Price;
% Length6=6;           %系数设置
% % Length6=12;        %系数设置
% % Length6=24;        %系数设置
% Type6=0;
% if flag6==1 && Len>=Length6
% BIASValue=BIAS(Price6,Length6,Type6);
% StockIndicators(:,8)=BIASValue;
% clear BIASValue;
% end
% %% 7调用BOLL
% Price7=Price;
% Length7=20;        %系数设置
% Width7=2;           %计算布林线上轨和下轨的宽度，即多少个标准差，常用2
% Type7=0;            %系数设置
% if flag7==1 && Len>=Length7
% [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
% StockIndicators(:,9)=UpperLine;
% clear UpperLine;
% StockIndicators(:,10)=MiddleLine;
% clear MiddleLine;
% StockIndicators(:,11)=LowerLine;
% clear LowerLine;
% end
% %% 8调用CCI
% Length8=4;        %系数设置
% if flag8==1 && Len>=Length8
% CCIValue=CCI(High,Low,Close,Length8);
% StockIndicators(:,12)=CCIValue;
% clear CCIValue;
% end
% %% 9调用CMO
% Length9=20;                %计算时所考虑的时间周期，常用14或20个Bar
% Price9=Price;
% if flag9==1 && Len>=Length9
% CMOValue=CMO(Price9,Length9);
% StockIndicators(:,13)=CMOValue;
% clear CMOValue;
% end
% %% 10调用CR
% Length10=26;            %系数设置
% if flag10==1 && Len>=Length10
% CRValue=CR(High,Low,Close,Length10);
% StockIndicators(:,14)=CRValue;
% clear CRValue;
% end
% %% 11调用CV
% Length11=10;            %系数设置
% if flag11==1 && Len>=Length11
% CVValue=CV(High,Low,Length11);
% StockIndicators(:,15)=CVValue;
% clear CVValue;
% end
% %% 12调用DMA
% Price12=Price;
% FastLength12=10;            %系数设置
% SlowLength12=50;            %系数设置
% SmoothLength12=10;            %系数设置
% if flag12==1 && Len>=SlowLength12
% [DMAValue,AMAValue]=DMA(Price12,FastLength12,SlowLength12,SmoothLength12);
% StockIndicators(:,16)=DMAValue;
% clear DMAValue;
% StockIndicators(:,17)=AMAValue;
% clear AMAValue;
% end
% %% 13调用DMI
% N13=26;                 %系数设置
% if flag13==1 && Len>=N13
% [PosDI,NegDI,ADX]=DMI(High,Low,Close,N13);
% StockIndicators(:,18)=PosDI;
% clear PosDI;
% StockIndicators(:,19)=NegDI;
% clear NegDI;
% StockIndicators(:,20)=ADX;
% clear ADX;
% end
% %% 14调用DPO
% Length14=20;            %系数设置
% Price14=Price;
% if flag14==1 && Len>=Length14
% DPOValue=DPO(Price14,Length14);
% StockIndicators(:,21)=DPOValue;
% clear DPOValue;
% end
% %% 15调用EMA
% Price15=Price;
% Length15=15;            %系数设置
% if flag15==1 && Len>=Length15
% EMAValue=EMA(Price15,Length15);
% StockIndicators(:,22)=EMAValue;
% clear EMAValue;
% end
% %% 16调用EMV
% N16=14;                 %系数设置
% M16=9;                 %系数设置
% if flag16==1 && Len>=N16 && Len>=M16
% [EMVValue,MAEMVValue]=EMV(High,Low,Volume,N16,M16);
% StockIndicators(:,23)=EMVValue;
% clear EMVValue;
% StockIndicators(:,24)=MAEMVValue;
% clear MAEMVValue;
% end
% %% 17调用ENV
% Price17=Price;                 %系数设置
% Length17=14;                 %系数设置
% Width17=2;                 %系数设置
% Type17=0;                 %系数设置
% if flag17==1 && Len>=Length17
% [UpperLine,MiddleLine,LowerLine]=ENV(Price17,Length17,Width17,Type17);
% StockIndicators(:,25)=UpperLine;
% clear UpperLine;
% StockIndicators(:,26)=MiddleLine;
% clear MiddleLine;
% StockIndicators(:,27)=LowerLine;
% clear LowerLine;
% end
% %% 18调用ForceIndex
% Price18=Price;                 %系数设置
% if flag18==1
% ForceIndexValue=ForceIndex(Price18,Volume);
% StockIndicators(:,28)=ForceIndexValue;
% clear ForceIndexValue;
% end
% %% 19调用KDJ
% N19=14;                 %系数设置
% M19=3;                 %系数设置
% L19=3;                 %系数设置
% S19=3;                 %系数设置
% if flag19==1 && Len>=N19
% [KValue,DValue,JValue]=KDJ(High,Low,Close,N19,M19,L19,S19);
% StockIndicators(:,29)=KValue;
% clear KValue;
% StockIndicators(:,30)=DValue;
% clear DValue;
% StockIndicators(:,31)=JValue;
% clear JValue;
% end
% %% 20调用MA (重要)
% Length20=28;                   %系数设置
% Price20=Price;                 %系数设置
% if flag20==1 && Len>=Length20
% MAValue=MA(Price20,Length20);
% StockIndicators(:,32)=MAValue;
% clear MAValue;
% end
% %% 21调用MACD (重要)
% FastLength21=12;                 %系数设置
% SlowLength21=26;                 %系数设置
% DEALength21=9;                   %系数设置
% Price21=Price;                   %系数设置
% if flag21==1 && Len>=SlowLength21
% [DIF,DEA,MACDValue]=MACD(Price21,FastLength21,SlowLength21,DEALength21);
% StockIndicators(:,33)=DIF;
% clear DIF;
% StockIndicators(:,34)=DEA;
% clear DEA;
% StockIndicators(:,35)=MACDValue;
% clear MACDValue;
% end
% %% 22调用MFI
% Length22=14;                 %系数设置
% if flag22==1 && Len>=Length22
% MFIValue=MFI(High,Low,Close,Volume,Length22);
% StockIndicators(:,36)=MFIValue;
% clear MFIValue;
% end
% %% 23调用MIKE
% Length23=12;
% if flag23==1 && Len>=Length23
% [WR,MR,SR,WS,MS,SS]=MIKE(High,Low,Close,Length23);
% StockIndicators(:,37)=WR;
% clear WR;
% StockIndicators(:,38)=MR;
% clear MR;
% StockIndicators(:,39)=SR;
% clear SR;
% StockIndicators(:,40)=WS;
% clear WS;
% StockIndicators(:,41)=MS;
% clear MS;
% StockIndicators(:,42)=SS;
% clear SS;
% end
% %% 24调用MFI
% Length24=12;
% Price24=Price;
% if flag24==1 && Len>=Length24
% MTMValue=MTM(Price24,Length24);
% StockIndicators(:,43)=MTMValue;
% clear MTMValue;
% end
% %% 25调用NVI
% if flag25==1
% NVIValue=NVI(Close,Volume);
% StockIndicators(:,44)=NVIValue;
% clear NVIValue;
% end
% %% 26调用OBV
% Price26=Price;
% if flag26==1
% OBVValue=OBV(Price26,Volume);
% StockIndicators(:,45)=OBVValue;
% clear OBVValue;
% end
% %% 27调用PSY
% Price27=Price;
% Length27=12;
% if flag27==1 && Len>=Length27
% PSYValue=PSY(Price27,Length27);
% StockIndicators(:,46)=PSYValue;
% clear PSYValue;
% end
% %% 28调用PVI
% if flag28==1
% PVIValue=PVI(Close,Volume);
% StockIndicators(:,47)=PVIValue;
% clear PVIValue;
% end
% %% 29调用ROC
% Price29=Price;
% Length29=12;
% if flag29==1  && Len>=Length29
% ROCValue=ROC(Price29,Length29);
% StockIndicators(:,48)=ROCValue;
% clear ROCValue;
% end
% %% 30调用RSI
% Length30=14;
% Price30=Price;
% if flag30==1  && Len>=Length30
% RSIValue=RSI(Price30,Length30);
% StockIndicators(:,49)=RSIValue;
% clear RSIValue;
% end
% %% 31调用RVI
% Price31=Price;
% stdLength31=10;
% Length31=14;
% if flag31==1  && Len>=Length31
% RVIValue=RVI(Price31,stdLength31,Length31);
% StockIndicators(:,50)=RVIValue;
% clear RVIValue;
% end
% %% 32调用SAR 等我搞清楚参数在进行
% % [SARofCurBar,SARofNextBar,Position,Transition]=SAR(a,b)
% %% 33调用TRIX 该指标周期较长
% Price33=Price;
% Length33=15;
% SmoothLength33=5;
% if flag33==1  && Len>=Length33*SmoothLength33
% [TRIXValue,MATRIXValue]=TRIX(Price33,Length33,SmoothLength33);
% StockIndicators(:,55)=TRIXValue;
% clear TRIXValue;
% StockIndicators(:,56)=MATRIXValue;
% clear MATRIXValue;
% end
% %% 34调用VHF
% Price34=Price;
% Length34=5;
% if flag34==1  && Len>=Length34
% VHFValue=VHF(Price34,Length34);
% StockIndicators(:,57)=VHFValue;
% clear VHFValue;
% end
% %% 35调用VR
% Price35=Price;
% Length35=26;
% if flag35==1  && Len>=Length35
% VRValue=VR(Price35,Volume,Length35);
% StockIndicators(:,58)=VRValue;
% clear VRValue;
% end
% %% 36调用WAD
% if flag36==1
% WADValue=WAD(High,Low,Close);
% StockIndicators(:,59)=WADValue;
% clear WADValue;
% end
% %% 37调用WMS
% N37=14;
% if flag37==1  && Len>=N37
% WMSValue=WMS(High,Low,Close,N37);
% StockIndicators(:,60)=WMSValue;
% clear WMSValue;
% end
% %% 38调用WVAD
% Length38=24;
% if flag38==1  && Len>=Length38
% WVADValue=WVAD(Open,High,Low,Close,Volume,Length38);
% StockIndicators(:,61)=WVADValue;
% clear WVADValue;
% end

