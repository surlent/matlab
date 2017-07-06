function Combine(Flag)
%% Flag=1表示3维数组,Flag=2表示2维数组拼接
if nargin<1
    Flag=2;
end

if Flag==1
    %% 打算编制从2005年开始所有股票的日切面数据,用来做回测,否则很难再个股间跳转,查看整体板块动向.后期可以做周,月的截面数据
    FolderStr = '.\DataBase\Index\OrderByDate\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    d=dir('.\DataBase\Index\DayIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    clear d
    for i=1:len
        StockCode{i}(end-17:end)=[];
        StockCode{i,2}=i;
    end
    %% 构建3维数组
    load('.\DataBase\Index\IndexIndicator_mat\sh000001_D.mat');     %通过指数指标确定日期长度
    Date=IndexIndicators(:,1);
    IndexIndicators=IndexIndicators(Date>=20050101,1);              %2005年开始
    clear Date
    len1=size(IndexIndicators,1);
    len2=len;                                                       %通过文件目录获得股票指标个数,这些指标不包含已经退市的文件,所以有幸存者偏差,但由于我只选择roe>5%的股票,所以基本没有影响.
    load('.\DataBase\Index\DayIndicator_mat\sh600000_Fwd_Indicator.mat');
    len3=size(StockIndicators,2);                                   %通过个股的指标文件获得指标列数
    clear StockIndicators
    
    IndicatorOBD=zeros(len1,len2+1,len3);                         %建立三维数组
    for i=1:len3
        IndicatorOBD(:,1,i)=IndexIndicators(:,1);                             %填写日期
    end
    temp=cell2mat(StockCode(:,2));
    for i=1:len1
        IndicatorOBD(i,2:end,1)=temp;                                           %填写代码序号
    end
    clear temp
    %% 读取并填入指标信息
    for i=1:len2
        RunIndex = i;
        Scode = StockCode{i,1};
        strdisp=['合并中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
        disp(strdisp)
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);
        StockIndicators(any(StockIndicators==0,2),:)=[];
        StockIndicators(StockIndicators(:,1)<20050101,:)=[];
        LoadSheet=IndicatorOBD(:,i+1,:);
        LoadSheet=reshape(LoadSheet,len1,len3);
        LoadSheet(:,1)=IndexIndicators(:,1);
        LoadSheet(ismember(LoadSheet(:,1),StockIndicators(:,1)),2:end)=StockIndicators(:,2:end);
        IndicatorOBD(:,i+1,2:end)=LoadSheet(:,2:end);
    end
    save([FolderStr 'IndicatorOBD.mat'],'IndicatorOBD','-v7.3');
    save([FolderStr 'CodeIndex.mat'],'StockCode','-v7.3');
end






%% 如果Flag==2,则生成二维汇总表格.
if Flag==2
    FolderStr = '.\DataBase\Index\2D All\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    d=dir('.\DataBase\Index\DayIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    clear d
    for i=1:len
        StockCode{i}(end-17:end)=[];
        StockCode{i,2}=i;
    end
    %% 读取并填入指标信息
    lenAll=0;
    for i=1:len
        Scode = StockCode{i,1};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);
        load(['.\DataBase\Stock\StockInfo_mat\' Scode '_StockInfo.mat']);
        %过滤股票,条件:1)
        if StockIndicators(end,14)<0 || StockIndicators(end,1)<20160630 || strcmp('ST',StockInfo.CompanyIntro{12,2})
            continue
        end
        StockIndicators(any(StockIndicators==0,2),:)=[];
        StockIndicators(StockIndicators(:,1)<20050101,:)=[];
        lenTemp=size(StockIndicators,1);
        lenAll=lenAll+lenTemp;
    end
    load('.\DataBase\Index\DayIndicator_mat\sh600000_Fwd_Indicator.mat');
    len3=size(StockIndicators,2);
    clear StockIndicators;
    TwoDAll=zeros(lenAll,len3);
    lenStart=1;
    for i=1:len
        Scode = StockCode{i,1};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);
        load(['.\DataBase\Stock\StockInfo_mat\' Scode '_StockInfo.mat']);
        %过滤股票,条件:1)
        if StockIndicators(end,14)<0 || StockIndicators(end,1)<20160630 || strcmp('ST',StockInfo.CompanyIntro{12,2})
            continue
        end
        StockIndicators(any(StockIndicators==0,2),:)=[];
        StockIndicators(StockIndicators(:,1)<20050101,:)=[];
        lenTemp=size(StockIndicators,1);
        lenEnd=lenStart+lenTemp-1;
        TwoDAll(lenStart:lenEnd,:)=StockIndicators(:,:);
        lenStart=lenEnd+1;
    end
    save([FolderStr 'TwoDAll.mat'],'TwoDAll','-v7.3');
end

end

