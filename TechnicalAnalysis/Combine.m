function Combine(Flag)
%% Flag=1��ʾ3ά����,Flag=2��ʾ2ά����ƴ��
if nargin<1
    Flag=2;
end

if Flag==1
    %% ������ƴ�2005�꿪ʼ���й�Ʊ������������,�������ز�,��������ٸ��ɼ���ת,�鿴�����鶯��.���ڿ�������,�µĽ�������
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
    %% ����3ά����
    load('.\DataBase\Index\IndexIndicator_mat\sh000001_D.mat');     %ͨ��ָ��ָ��ȷ�����ڳ���
    Date=IndexIndicators(:,1);
    IndexIndicators=IndexIndicators(Date>=20050101,1);              %2005�꿪ʼ
    clear Date
    len1=size(IndexIndicators,1);
    len2=len;                                                       %ͨ���ļ�Ŀ¼��ù�Ʊָ�����,��Щָ�겻�����Ѿ����е��ļ�,�������Ҵ���ƫ��,��������ֻѡ��roe>5%�Ĺ�Ʊ,���Ի���û��Ӱ��.
    load('.\DataBase\Index\DayIndicator_mat\sh600000_Fwd_Indicator.mat');
    len3=size(StockIndicators,2);                                   %ͨ�����ɵ�ָ���ļ����ָ������
    clear StockIndicators
    
    IndicatorOBD=zeros(len1,len2+1,len3);                         %������ά����
    for i=1:len3
        IndicatorOBD(:,1,i)=IndexIndicators(:,1);                             %��д����
    end
    temp=cell2mat(StockCode(:,2));
    for i=1:len1
        IndicatorOBD(i,2:end,1)=temp;                                           %��д�������
    end
    clear temp
    %% ��ȡ������ָ����Ϣ
    for i=1:len2
        RunIndex = i;
        Scode = StockCode{i,1};
        strdisp=['�ϲ���...','���:',num2str(RunIndex),'   ','����:',Scode];
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






%% ���Flag==2,�����ɶ�ά���ܱ��.
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
    %% ��ȡ������ָ����Ϣ
    lenAll=0;
    for i=1:len
        Scode = StockCode{i,1};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);
        load(['.\DataBase\Stock\StockInfo_mat\' Scode '_StockInfo.mat']);
        %���˹�Ʊ,����:1)
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
        %���˹�Ʊ,����:1)
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

