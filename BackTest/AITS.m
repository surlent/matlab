function AITS(Flag,Mod)
%%基于narx网络的时间序列机器学习拟合
if nargin<1
    Flag=input(['请输入测试模式' 10 '1,只做学习不回测' 10 '2,只回测不学习' 10 '3,学习并回测' 10 '4,预测明日买卖信号' 10]);
    Mod=input(['请输入测试对象' 10 '1,股票' 10 '2,指数' 10 ]);
end

%% 计算股票net
if Mod==1
    
    FolderStr = '.\DataBase\Net\TSStock\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    FolderStr = '.\DataBase\BackTestResult\AITS\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    d=dir('.\DataBase\Index\DayIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    for i=1:len
        StockCode{i}(end-17:end)=[];
    end
    
    debug=0;     %调试模式0关闭,1通过性,2效率
    if debug == 1
        len=5;
    elseif debug == 2
        len=500;
    end
    
    if Flag~=4
        result=cell(len,8);
    else
        result=cell(len,10);
    end
    
    parfor i=1:len
        RunIndex = i;
        Scode = StockCode{i};
        strdisp=['时间序列神经网络学习中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
        disp(strdisp)
        result(i,:) = TStrain(Scode,Flag);
    end
    
    if Flag~=1 && Flag~=4
        temp=cell2mat(result(:,2:end));
        temp(any(temp==0,2),:)=[];          %去除0值
        temp=mean(temp);
        temp=num2cell(temp);                %计算平均值
        Mean=[{'平均总收益'},{'平均年化收益率'},{'平均夏普比率'},{'平均最大回撤'},{'平均胜率'},{'平均交易次数'},{'平均交易长度'};temp];
        save( '.\DataBase\BackTestResult\AITS\Result.mat','result', '-v7.3');%文件用来保存回测结果
        save( '.\DataBase\BackTestResult\AITS\Mean.mat','Mean', '-v7.3');%文件用来保存汇总
    end
    if Flag==4
        disp('汇总预测结果生成xls文件')
        temp=load('.\DataBase\BackTestResult\AITS\Result.mat');   %读取历史回测评价指标
        temp=struct2cell(temp);
        reference=temp{1,1};
        Len=length(result);
        code=result(:,1);
        LastDay=max(cell2mat(result(:,2)));
        for i=Len:-1:1
            if result{i,2}~=LastDay
                result(i,:)=[];
                continue
            else
                result{i,5}=reference{strncmp(code(i),reference,8),3};
                result{i,6}=reference{strncmp(code(i),reference,8),4};
                result{i,7}=reference{strncmp(code(i),reference,8),5};
                result{i,8}=reference{strncmp(code(i),reference,8),6};
                result{i,9}=reference{strncmp(code(i),reference,8),7};
                result{i,10}=reference{strncmp(code(i),reference,8),8};
            end
        end
        LastDate=num2str(max(cell2mat(result(:,2))));
        xlswrite(['.\BackTest\AIForcast\SubTotal' LastDate ],{'代码','最后预测日期','建议','预计涨跌幅%','回测期望年化收益率','回测期望夏普比率','最大回撤','历史胜率','历史交易次数(越多越好)','交易长度(越多越好)'},'时间序列回测结果','A1');
        xlswrite(['.\BackTest\AIForcast\SubTotal' LastDate ],result,'时间序列回测结果','A2');
    end
end

%% 计算指数net
if Mod==2
    
    FolderStr = '.\DataBase\Net\TSIndex\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    FolderStr = '.\DataBase\BackTestResult\AITS_Index\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    d=dir('.\DataBase\Index\IndexIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    for i=1:len
        StockCode{i}(end-5:end)=[];
    end
    
    debug=0;     %调试模式0关闭,1通过性,2效率
    if debug == 1
        len=5;
    elseif debug == 2
        len=500;
    end
    
    if Flag~=4
        result=cell(len,8);
    else
        result=cell(len,10);
    end
    
    parfor i=1:len
        RunIndex = i;
        Scode = StockCode{i};
        strdisp=['神经网络学习中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
        disp(strdisp)
        result(i,:) = TStrainIndex(Scode,Flag);
        %Flag=1,只做学习不回测
        %Flag=2,只回测不学习
        %Flag=3,学习并回测
    end
    
    if Flag~=1 && Flag~=4
        temp=cell2mat(result(:,2:end));
        temp(any(temp==0,2),:)=[];          %去除0值
        temp=mean(temp);
        temp=num2cell(temp);                %计算平均值
        Mean=[{'平均总收益'},{'平均年化收益率'},{'平均夏普比率'},{'平均最大回撤'},{'平均胜率'},{'平均交易次数'},{'平均交易长度'};temp];
        save( '.\DataBase\BackTestResult\AITS_Index\Result.mat','result', '-v7.3');%文件用来保存回测结果
        save( '.\DataBase\BackTestResult\AITS_Index\Mean.mat','Mean', '-v7.3');%文件用来保存汇总
    end
    if Flag==4
        disp('汇总预测结果生成xls文件')
        temp=load('.\DataBase\BackTestResult\AITS_Index\Result.mat');   %读取历史回测评价指标
        temp=struct2cell(temp);
        reference=temp{1,1};
        Len=length(result);
        code=result(:,1);
        LastDay=max(cell2mat(result(:,2)));
        for i=Len:-1:1
            if result{i,2}~=LastDay
                result(i,:)=[];
                continue
            else
                result{i,5}=reference{strncmp(code(i),reference,8),3};
                result{i,6}=reference{strncmp(code(i),reference,8),4};
                result{i,7}=reference{strncmp(code(i),reference,8),5};
                result{i,8}=reference{strncmp(code(i),reference,8),6};
                result{i,9}=reference{strncmp(code(i),reference,8),7};
                result{i,10}=reference{strncmp(code(i),reference,8),8};
            end
        end
        LastDate=num2str(max(cell2mat(result(:,2))));
        xlswrite(['.\BackTest\AIForcast_Index\SubTotal' LastDate ],{'代码','最后预测日期','建议','预计涨跌幅','回测期望年化收益率','回测期望夏普比率','最大回撤','历史胜率(可能存在过拟合)','历史交易次数(越多越好)','交易长度(越多越好)'},'时间序列回测结果','A1');
        xlswrite(['.\BackTest\AIForcast_Index\SubTotal' LastDate ],result,'时间序列回测结果','A2');
    end
    clear
end

end

