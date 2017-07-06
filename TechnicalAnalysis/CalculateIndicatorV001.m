function CalculateIndicatorV001(Scode,FileString,Flag,IndexIndicatorsSH,IndexIndicatorsSZ)
%%����ָ�꺯��
%5��28�ո���
%������ƽ��ֵָ�������û�п���ǰ��Ȩ����ֱ��ʹ���ܶ���Ϊ���ӵĴ���.
%������obvָ�������ѭ����ֵ������һ�μ������,���¼�����n��ȷn+1����ȷ������.
%�ĵ�:��ǰ��ӯ�ʵĵ���,��ʵ������Ӫ�����������ÿ��������(��֮��Ӧ���Ƿֺ���),ӯ��������δ��Ԥ����������һ���Ƚϳ�Զ�Ĺ���(�е���õĳɷ�),�ֺ�������ʵ�����ʿ��ԶԱ��ծ������.
%% �����������
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

%% �����Ʊָ��
if Flag==1
    try
        load(['.\DataBase\Stock\FinancialIndicators_mat\' Scode '_FinIndicator.mat'],'StockFinInd');%�������ָ��
        load(['.\DataBase\Stock\StockInfo_mat\' Scode '_StockInfo.mat'],'StockInfo');%���������Ϣ��
        load(['.\DataBase\Stock\Floating stock_mat\' Scode '.mat'],'FloatingStock');%������ͨ����Ϣ
        load(['.\DataBase\Stock\Day_ForwardAdj_mat\' Scode '_D_ForwardAdj.mat'],'StockData');%��Ȩ��Ϣ����
    catch
        disp('�������ݲ�ȫ,�����ָ���ļ�,����������')
        try
            delete(['./DataBase/Index/DayIndicator_mat/' Scode '_Fwd_Indicator.mat']);
            disp('ɾ���ɹ�')
        catch
            disp('�޾�ָ���ļ�,����ɾ��.')
        end
        return;
    end
    
    %% �ֽ�StockData
    Start=20050101;                     %����ָ������,����鷢��ǰ���д�����������,����Ҳ����,��������.ָ���2005�꿪ʼ,���ǻز��������
    Date = StockData(:,1);                  %������
    StartRow=find(Date>=Start,1);        %�ҵ���ʼ��
    if isempty(StartRow)            % ��������Ҳ�������startdate����,���ܱ�����startdateǰ�Ѿ�����
        disp('2005��֮ǰ����,�����ָ���ļ�,����������')
        try
            delete(['./DataBase/Index/DayIndicator_mat/' Scode '_Fwd_Indicator.mat']);
            disp('ɾ���ɹ�')
        catch
            disp('�޾�ָ���ļ�,����ɾ��.')
        end
        return;
    end
    Date = StockData(StartRow:end,1);                  %������20050101��,��ͬ
    Open = StockData(StartRow:end,2);                  %���̼�
    High = StockData(StartRow:end,3);                  %��߼�
    Low = StockData(StartRow:end,4);                   %��ͼ�
    Close = StockData(StartRow:end,5);                 %���̼�
    Volume = StockData(StartRow:end,6);                %�ɽ���
    Amount = StockData(StartRow:end,7);                %�ɽ���
    Xrd = StockData(StartRow:end,8);                   %ǰ��Ȩϵ��
    MaxXrd=Xrd(end,1);
    Price = Amount./Volume./MaxXrd.*Xrd;    %ǰ��Ȩ��ƽ���ɽ��۸�
    Len=length(Date);
    Col=39;
    StockIndicators=zeros(size(Open,1),Col);%��������
    StockIndicators(:,1) = Date;            % ��һ��ʱ��
    StockIndicators(:,9) = Xrd;           % ĩ��ǰ��Ȩϵ��
    StockIndicators(:,8)=Amount;        %ֱ��д������ļ���,�������ز�
    StockIndicators(:,7)=Volume;
    StockIndicators(:,6)=Close;
    StockIndicators(:,5)=Low;
    StockIndicators(:,4)=High;
    StockIndicators(:,3)=Open;
    StockIndicators(:,2)=Price;      %ǰ��Ȩ��ƽ���ɽ��۸�
    %% ��д��ͨ��
    End=Date(end);
    for j=length(FloatingStock):-1:1
        Start=str2double([FloatingStock{j,1}(1:4),FloatingStock{j,1}(6:7),FloatingStock{j,1}(9:10)]);
        StockIndicators(Date>=Start & Date<=End,10)=FloatingStock{j,2};
        End=Start-1;
    end
    %% ���㻻����(��ͨ��)
    StockIndicators(:,11)=StockIndicators(:,7)./StockIndicators(:,10);
    %% �۳��Ǿ�������������ӯ�� �ʲ���ծ����,ÿ������,ÿ�ɾ��ʲ�,���ʲ�������,�ֺ���(���ݲ�ȫ����).
    LenFin=length(StockFinInd);
    temp=zeros(LenFin,4);
    for i=1:LenFin
        if length(StockFinInd{i,2})~=1 
            BalanceMonth=str2double(StockFinInd{i,2}{2,2}(6:7));
            if BalanceMonth==12 || LenFin==1            %���ֻ�в���һ��Ĳ�����Ϣ,�ǲ���������������ģ���,Ҳû��������Ϣ���ο����㱾��ȫ������,����ֱ��д��(����Ҳ����).
                temp(i,1)=str2double([StockFinInd{i,2}{2,2}(1:4),StockFinInd{i,2}{2,2}(6:7),StockFinInd{i,2}{2,2}(9:10)]);%����
                temp(i,2)=StockFinInd{i,2}{7,2};                                                                          %ÿ������
                if isnan(temp(i,2))|| temp(i,2)==0
                    temp(i,2)=StockFinInd{i,2}{6,2};
                    if isnan(temp(i,2))|| temp(i,2)==0
                        temp(i,2)=StockFinInd{i,2}{5,2};
                        if isnan(temp(i,2))|| temp(i,2)==0
                            temp(i,2)=StockFinInd{i,2}{4,2};
                        end
                    end
                end
                temp(i,3)=StockFinInd{i,2}{9,2};                                                                          %ÿ�ɾ��ʲ�
                temp(i,4)=StockFinInd{i,2}{32,2};                                                                         %���ʲ�������
            elseif BalanceMonth~=12                     %���ĳһ������û�е�����ĩ������(�����ų���һ��),����������Ǵ����갴��������,���������̫�����,����ֱ�Ӱ���������.
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
    
    %% ������!�ɽ�ƽ���ɱ� maû������,macdǰ�����������Խ�������������ݲ�һ��Ȩ��Խ��.����������ɱ��䶯���.1)5��������,2)10��������,3)20��������,4)40��������,5)80��������,6)160��������,7)320��������   ��ֹ�ڰ���
    Length=5;                   %ϵ������
    if Len>=Length
        MeanCost5=zeros(Len,1);
        for i=Length:Len
            MeanCost5(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,15)=MeanCost5;
        clear MeanCost5;
    end
    Length=10;                   %ϵ������
    if Len>=Length
        MeanCost10=zeros(Len,1);
        for i=Length:Len
            MeanCost10(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,16)=MeanCost10;
        clear MeanCost10;
    end
    Length=20;                   %ϵ������
    if Len>=Length
        MeanCost20=zeros(Len,1);
        for i=Length:Len
            MeanCost20(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,17)=MeanCost20;
        clear MeanCost20;
    end
    Length=40;                   %ϵ������
    if Len>=Length
        MeanCost40=zeros(Len,1);
        for i=Length:Len
            MeanCost40(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,18)=MeanCost40;
        clear MeanCost40;
    end
    Length=80;                   %ϵ������
    if Len>=Length
        MeanCost80=zeros(Len,1);
        for i=Length:Len
            MeanCost80(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,19)=MeanCost80;
        clear MeanCost80;
    end
    Length=160;                   %ϵ������
    if Len>=Length
        MeanCost160=zeros(Len,1);
        for i=Length:Len
            MeanCost160(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,20)=MeanCost160;
        clear MeanCost160;
    end
    Length=320;                   %ϵ������
    if Len>=Length
        MeanCost320=zeros(Len,1);
        for i=Length:Len
            MeanCost320(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        StockIndicators(:,21)=MeanCost320;
        clear MeanCost320;
    end
    %% ����RSI
    Price30=Price;
    Length30=14;
    if Len>=Length30
        RSIValue=RSI(Price30,Length30);
        StockIndicators(:,22)=RSIValue;
        clear RSIValue;
    end
    %% ����Boll
    Price7=Price;
    Length7=20;        %ϵ������
    Width7=2;           %���㲼�����Ϲ���¹�Ŀ�ȣ������ٸ���׼�����2
    Type7=0;            %ϵ������
    if Len>=Length7
        [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
        StockIndicators(Length7:end,23)=Price(Length7:end)./UpperLine(Length7:end)-1;
        clear UpperLine;
        StockIndicators(Length7:end,24)=Price(Length7:end)./MiddleLine(Length7:end)-1;
        clear MiddleLine;
        StockIndicators(Length7:end,25)=Price(Length7:end)./LowerLine(Length7:end)-1;
        clear LowerLine;
    end
    %% ����ָ֤���������ָ���ı䶯���д���Ʊ����,��ʾ��ۻ���ǿ��.
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
    %% 20��/40����ߵ����͵�30-33��
    for i=21:Len
    StockIndicators(i,30)=max(High(i-20:i))/Price(i)-1;
    StockIndicators(i,31)=min(Low(i-20:i))/Price(i)-1;
    end
    for i=41:Len
    StockIndicators(i,32)=max(High(i-40:i))/Price(i)-1;
    StockIndicators(i,33)=min(Low(i-40:i))/Price(i)-1;
    end
    %% OBVָ��34��
    obvtemp=OBV(Price,Volume);
    for i=3:Len
    StockIndicators(i,34)=obvtemp(i,1)/obvtemp(i-1,1)-1;
    end
    clear obvtemp;
    StockIndicators(1:2,34)=0;
    %% ����N�������պ���ǵ�����(��max����mean,�о�mean����һЩ)��Ϊ���������Ľ��ֵ,�������ز⻮��,�ڽ���������,���ĳ�������������漸��ֵΪ0Ϊ��,�򲻲������,��Ϊ����������������ڸ������ڵ���ͣ��û�����ݻ������в���100��
    if length(Price)>=41
        for l=length(Price):-1:41
            StockIndicators(l-2,end-4)= mean(Price(l-1:l))/Price(l-2)-1;         %����-2��
            StockIndicators(l-5,end-3)= mean(Price(l-4:l))/Price(l-5)-1;         %1��-5��
            StockIndicators(l-10,end-2)= mean(Price(l-9:l))/Price(l-10)-1;         %1��-10��
            StockIndicators(l-20,end-1)= mean(Price(l-19:l))/Price(l-20)-1;         %1��-20��
            StockIndicators(l-40,end)= mean(Price(l-39:l))/Price(l-40)-1;         %1��-40��,Լ2����
        end
    end
    save(FileString,'StockIndicators', '-v7.3');                            %����ָ����Ϣ
end








%% ����ָ��ָ��
if Flag==2
    try
        load(['.\DataBase\Stock\Index_Day_mat\' Scode '_D.mat'],'IndexData');%����ָ������
    catch
        disp('�������ݲ�ȫ,��������')
        return
    end
    Start=20050101;                     %����ָ������,����鷢��ǰ���д�����������,����Ҳ����,��������.ָ���2005�꿪ʼ,���ǻز��������
    IndexData(any(IndexData==0,2),:)=[];    %�в���ָ��2004��֮ǰֻ��һ�����̼�,����Ϊ0
    Date = IndexData(:,1);                  %������
    StartRow=find(Date>=Start,1);        %�ҵ���ʼ��
    Date = IndexData(StartRow:end,1);                  %������20000101��,��ͬ
    Open = IndexData(StartRow:end,2);                  %���̼�
    High = IndexData(StartRow:end,3);                  %��߼�
    Low = IndexData(StartRow:end,4);                   %��ͼ�
    %     Close = IndexData(StartRow:end,5);                 %���̼�
    Volume = IndexData(StartRow:end,6);                %�ɽ���
    Amount = IndexData(StartRow:end,7);                %�ɽ���
    Price = Amount./Volume;                            %ƽ���ɽ��۸�
    Len=length(Date);
    Col=23;
    IndexIndicators=zeros(size(Open,1),Col);            %��������
    IndexIndicators(:,1)=Date;
    IndexIndicators(:,2)=Price;
    %% ������!�ɽ�ƽ���ɱ� maû������,macdǰ�����������Խ�������������ݲ�һ��Ȩ��Խ��.����������ɱ��䶯���.1)5��������,2)10��������,3)20��������,4)40��������,5)80��������,6)160��������,7)320��������
    Length=5;                   %ϵ������
    if Len>=Length
        MeanCost5=zeros(Len,1);
        for i=Length:Len
            MeanCost5(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,3)=MeanCost5;
        clear MeanCost5;
    end
    Length=10;                   %ϵ������
    if Len>=Length
        MeanCost10=zeros(Len,1);
        for i=Length:Len
            MeanCost10(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,4)=MeanCost10;
        clear MeanCost10;
    end
    Length=20;                   %ϵ������
    if Len>=Length
        MeanCost20=zeros(Len,1);
        for i=Length:Len
            MeanCost20(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,5)=MeanCost20;
        clear MeanCost20;
    end
    Length=40;                   %ϵ������
    if Len>=Length
        MeanCost40=zeros(Len,1);
        for i=Length:Len
            MeanCost40(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,6)=MeanCost40;
        clear MeanCost40;
    end
    Length=80;                   %ϵ������
    if Len>=Length
        MeanCost80=zeros(Len,1);
        for i=Length:Len
            MeanCost80(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,7)=MeanCost80;
        clear MeanCost80;
    end
    Length=160;                   %ϵ������
    if Len>=Length
        MeanCost160=zeros(Len,1);
        for i=Length:Len
            MeanCost160(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,8)=MeanCost160;
        clear MeanCost160;
    end
    Length=320;                   %ϵ������
    if Len>=Length
        MeanCost320=zeros(Len,1);
        for i=Length:Len
            MeanCost320(i,1)=Price(i)/(sum(Volume(i-Length+1:i).*Price(i-Length+1:i))/sum(Volume(i-Length+1:i)))-1;
        end
        IndexIndicators(:,9)=MeanCost320;
        clear MeanCost320;
    end
    %% ����RSI
    Price30=Price;
    Length30=14;
    if Len>=Length30
        RSIValue=RSI(Price30,Length30);
        IndexIndicators(:,10)=RSIValue;
        clear RSIValue;
    end
    %% ����Boll
    Price7=Price;
    Length7=20;        %ϵ������
    Width7=2;           %���㲼�����Ϲ���¹�Ŀ�ȣ������ٸ���׼�����2
    Type7=0;            %ϵ������
    if Len>=Length7
        [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
        IndexIndicators(Length7:end,11)=Price(Length7:end)./UpperLine(Length7:end)-1;
        clear UpperLine;
        IndexIndicators(Length7:end,12)=Price(Length7:end)./MiddleLine(Length7:end)-1;
        clear MiddleLine;
        IndexIndicators(Length7:end,13)=Price(Length7:end)./LowerLine(Length7:end)-1;
        clear LowerLine;
    end
    %% 20��/40����ߵ����͵�30-33��
    for i=21:Len
    IndexIndicators(i,14)=max(High(i-20:i))/Price(i)-1;
    IndexIndicators(i,15)=min(Low(i-20:i))/Price(i)-1;
    end
    for i=41:Len
    IndexIndicators(i,16)=max(High(i-40:i))/Price(i)-1;
    IndexIndicators(i,17)=min(Low(i-40:i))/Price(i)-1;
    end
    %% OBVָ��
    obvtemp=OBV(Price,Volume);
    for i=3:Len
    IndexIndicators(i,18)=obvtemp(i,1)/obvtemp(i-1,1)-1;
    end
    clear obvtemp;
    IndexIndicators(1:2,18)=0;
    %% ����N�������պ���ǵ�����(��max����mean,�о�mean����һЩ)��Ϊ���������Ľ��ֵ,�������ز⻮��,�ڽ���������,���ĳ�������������漸��ֵΪ0Ϊ��,�򲻲������,��Ϊ����������������ڸ������ڵ���ͣ��û�����ݻ������в���100��
    if length(Price)>=41
        for l=length(Price):-1:41
            IndexIndicators(l-2,end-4)= mean(Price(l-1:l))/Price(l-2)-1;         %����-2��
            IndexIndicators(l-5,end-3)= mean(Price(l-4:l))/Price(l-5)-1;         %1��-5��
            IndexIndicators(l-10,end-2)= mean(Price(l-9:l))/Price(l-10)-1;         %1��-10��
            IndexIndicators(l-20,end-1)= mean(Price(l-19:l))/Price(l-20)-1;         %1��-20��
            IndexIndicators(l-40,end)= mean(Price(l-39:l))/Price(l-40)-1;         %1��-40��,Լ2����
        end
    end
    save(FileString,'IndexIndicators', '-v7.3');
    
end

end

%% ���㿪������
% flag2=0;%����0ֵ����
% flag3=0;%�ĸ��۸�һ����������ͻ����
% flag4=0;
% flag5=0;
% flag6=0;
% flag7=0;
% flag8=0;
% flag9=0;
% flag10=0;%��Щ��Ʊ����N���ĸ��۸�һ��,�ͻ����
% flag11=0;%��Щ��Ʊ����N���ĸ��۸�һ��,�ͻ����
% flag12=0;
% flag13=0;
% flag14=0;
% flag15=0;
% flag16=0;%����0ֵ����
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
% flag35=0;%��Щ��Ʊ����N���ĸ��۸�һ��,�ͻ����
% flag36=0;
% flag37=0;
% flag38=0;
%% ������ԭָ�����,�������,����Ҫ��ʱ�����ó�����.
% %% 2����AD
% if flag2==1
% StockIndicators(:,2) = AD(High,Low,Close,Volume);
% end
% %% 3����ARBR
% Length3=26;                              %ϵ������
% if flag3==1 && Len>=Length3
% [AR,BR]=ARBR(Open,High,Low,Close,Length3);
% StockIndicators(:,3)=AR;
% clear AR;
% StockIndicators(:,4)=BR;
% clear BR;
% end
% %% 4����AROON
% Length4=20;                              %ϵ������
% if flag4==1 && Len>=Length4
% [UpAroon,DownAroon] =AROON(High,Low,Length4);
% StockIndicators(:,5)=UpAroon;
% clear UpAroon;
% StockIndicators(:,6)=DownAroon;
% clear DownAroon;
% end
% %% 5����ATR
% Length5=14;                   %ϵ������
% Type5=0;                      %ϵ������
% if flag5==1 && Len>=Length5
% ATRValue=ATR(High,Low,Close,Length5,Type5);
% StockIndicators(:,7)=ATRValue;
% clear ATRValue;
% end
% %% 6����BIAS
% Price6=Price;
% Length6=6;           %ϵ������
% % Length6=12;        %ϵ������
% % Length6=24;        %ϵ������
% Type6=0;
% if flag6==1 && Len>=Length6
% BIASValue=BIAS(Price6,Length6,Type6);
% StockIndicators(:,8)=BIASValue;
% clear BIASValue;
% end
% %% 7����BOLL
% Price7=Price;
% Length7=20;        %ϵ������
% Width7=2;           %���㲼�����Ϲ���¹�Ŀ�ȣ������ٸ���׼�����2
% Type7=0;            %ϵ������
% if flag7==1 && Len>=Length7
% [UpperLine, MiddleLine, LowerLine]=BOLL(Price7,Length7,Width7,Type7);
% StockIndicators(:,9)=UpperLine;
% clear UpperLine;
% StockIndicators(:,10)=MiddleLine;
% clear MiddleLine;
% StockIndicators(:,11)=LowerLine;
% clear LowerLine;
% end
% %% 8����CCI
% Length8=4;        %ϵ������
% if flag8==1 && Len>=Length8
% CCIValue=CCI(High,Low,Close,Length8);
% StockIndicators(:,12)=CCIValue;
% clear CCIValue;
% end
% %% 9����CMO
% Length9=20;                %����ʱ�����ǵ�ʱ�����ڣ�����14��20��Bar
% Price9=Price;
% if flag9==1 && Len>=Length9
% CMOValue=CMO(Price9,Length9);
% StockIndicators(:,13)=CMOValue;
% clear CMOValue;
% end
% %% 10����CR
% Length10=26;            %ϵ������
% if flag10==1 && Len>=Length10
% CRValue=CR(High,Low,Close,Length10);
% StockIndicators(:,14)=CRValue;
% clear CRValue;
% end
% %% 11����CV
% Length11=10;            %ϵ������
% if flag11==1 && Len>=Length11
% CVValue=CV(High,Low,Length11);
% StockIndicators(:,15)=CVValue;
% clear CVValue;
% end
% %% 12����DMA
% Price12=Price;
% FastLength12=10;            %ϵ������
% SlowLength12=50;            %ϵ������
% SmoothLength12=10;            %ϵ������
% if flag12==1 && Len>=SlowLength12
% [DMAValue,AMAValue]=DMA(Price12,FastLength12,SlowLength12,SmoothLength12);
% StockIndicators(:,16)=DMAValue;
% clear DMAValue;
% StockIndicators(:,17)=AMAValue;
% clear AMAValue;
% end
% %% 13����DMI
% N13=26;                 %ϵ������
% if flag13==1 && Len>=N13
% [PosDI,NegDI,ADX]=DMI(High,Low,Close,N13);
% StockIndicators(:,18)=PosDI;
% clear PosDI;
% StockIndicators(:,19)=NegDI;
% clear NegDI;
% StockIndicators(:,20)=ADX;
% clear ADX;
% end
% %% 14����DPO
% Length14=20;            %ϵ������
% Price14=Price;
% if flag14==1 && Len>=Length14
% DPOValue=DPO(Price14,Length14);
% StockIndicators(:,21)=DPOValue;
% clear DPOValue;
% end
% %% 15����EMA
% Price15=Price;
% Length15=15;            %ϵ������
% if flag15==1 && Len>=Length15
% EMAValue=EMA(Price15,Length15);
% StockIndicators(:,22)=EMAValue;
% clear EMAValue;
% end
% %% 16����EMV
% N16=14;                 %ϵ������
% M16=9;                 %ϵ������
% if flag16==1 && Len>=N16 && Len>=M16
% [EMVValue,MAEMVValue]=EMV(High,Low,Volume,N16,M16);
% StockIndicators(:,23)=EMVValue;
% clear EMVValue;
% StockIndicators(:,24)=MAEMVValue;
% clear MAEMVValue;
% end
% %% 17����ENV
% Price17=Price;                 %ϵ������
% Length17=14;                 %ϵ������
% Width17=2;                 %ϵ������
% Type17=0;                 %ϵ������
% if flag17==1 && Len>=Length17
% [UpperLine,MiddleLine,LowerLine]=ENV(Price17,Length17,Width17,Type17);
% StockIndicators(:,25)=UpperLine;
% clear UpperLine;
% StockIndicators(:,26)=MiddleLine;
% clear MiddleLine;
% StockIndicators(:,27)=LowerLine;
% clear LowerLine;
% end
% %% 18����ForceIndex
% Price18=Price;                 %ϵ������
% if flag18==1
% ForceIndexValue=ForceIndex(Price18,Volume);
% StockIndicators(:,28)=ForceIndexValue;
% clear ForceIndexValue;
% end
% %% 19����KDJ
% N19=14;                 %ϵ������
% M19=3;                 %ϵ������
% L19=3;                 %ϵ������
% S19=3;                 %ϵ������
% if flag19==1 && Len>=N19
% [KValue,DValue,JValue]=KDJ(High,Low,Close,N19,M19,L19,S19);
% StockIndicators(:,29)=KValue;
% clear KValue;
% StockIndicators(:,30)=DValue;
% clear DValue;
% StockIndicators(:,31)=JValue;
% clear JValue;
% end
% %% 20����MA (��Ҫ)
% Length20=28;                   %ϵ������
% Price20=Price;                 %ϵ������
% if flag20==1 && Len>=Length20
% MAValue=MA(Price20,Length20);
% StockIndicators(:,32)=MAValue;
% clear MAValue;
% end
% %% 21����MACD (��Ҫ)
% FastLength21=12;                 %ϵ������
% SlowLength21=26;                 %ϵ������
% DEALength21=9;                   %ϵ������
% Price21=Price;                   %ϵ������
% if flag21==1 && Len>=SlowLength21
% [DIF,DEA,MACDValue]=MACD(Price21,FastLength21,SlowLength21,DEALength21);
% StockIndicators(:,33)=DIF;
% clear DIF;
% StockIndicators(:,34)=DEA;
% clear DEA;
% StockIndicators(:,35)=MACDValue;
% clear MACDValue;
% end
% %% 22����MFI
% Length22=14;                 %ϵ������
% if flag22==1 && Len>=Length22
% MFIValue=MFI(High,Low,Close,Volume,Length22);
% StockIndicators(:,36)=MFIValue;
% clear MFIValue;
% end
% %% 23����MIKE
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
% %% 24����MFI
% Length24=12;
% Price24=Price;
% if flag24==1 && Len>=Length24
% MTMValue=MTM(Price24,Length24);
% StockIndicators(:,43)=MTMValue;
% clear MTMValue;
% end
% %% 25����NVI
% if flag25==1
% NVIValue=NVI(Close,Volume);
% StockIndicators(:,44)=NVIValue;
% clear NVIValue;
% end
% %% 26����OBV
% Price26=Price;
% if flag26==1
% OBVValue=OBV(Price26,Volume);
% StockIndicators(:,45)=OBVValue;
% clear OBVValue;
% end
% %% 27����PSY
% Price27=Price;
% Length27=12;
% if flag27==1 && Len>=Length27
% PSYValue=PSY(Price27,Length27);
% StockIndicators(:,46)=PSYValue;
% clear PSYValue;
% end
% %% 28����PVI
% if flag28==1
% PVIValue=PVI(Close,Volume);
% StockIndicators(:,47)=PVIValue;
% clear PVIValue;
% end
% %% 29����ROC
% Price29=Price;
% Length29=12;
% if flag29==1  && Len>=Length29
% ROCValue=ROC(Price29,Length29);
% StockIndicators(:,48)=ROCValue;
% clear ROCValue;
% end
% %% 30����RSI
% Length30=14;
% Price30=Price;
% if flag30==1  && Len>=Length30
% RSIValue=RSI(Price30,Length30);
% StockIndicators(:,49)=RSIValue;
% clear RSIValue;
% end
% %% 31����RVI
% Price31=Price;
% stdLength31=10;
% Length31=14;
% if flag31==1  && Len>=Length31
% RVIValue=RVI(Price31,stdLength31,Length31);
% StockIndicators(:,50)=RVIValue;
% clear RVIValue;
% end
% %% 32����SAR ���Ҹ���������ڽ���
% % [SARofCurBar,SARofNextBar,Position,Transition]=SAR(a,b)
% %% 33����TRIX ��ָ�����ڽϳ�
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
% %% 34����VHF
% Price34=Price;
% Length34=5;
% if flag34==1  && Len>=Length34
% VHFValue=VHF(Price34,Length34);
% StockIndicators(:,57)=VHFValue;
% clear VHFValue;
% end
% %% 35����VR
% Price35=Price;
% Length35=26;
% if flag35==1  && Len>=Length35
% VRValue=VR(Price35,Volume,Length35);
% StockIndicators(:,58)=VRValue;
% clear VRValue;
% end
% %% 36����WAD
% if flag36==1
% WADValue=WAD(High,Low,Close);
% StockIndicators(:,59)=WADValue;
% clear WADValue;
% end
% %% 37����WMS
% N37=14;
% if flag37==1  && Len>=N37
% WMSValue=WMS(High,Low,Close,N37);
% StockIndicators(:,60)=WMSValue;
% clear WMSValue;
% end
% %% 38����WVAD
% Length38=24;
% if flag38==1  && Len>=Length38
% WVADValue=WVAD(Open,High,Low,Close,Volume,Length38);
% StockIndicators(:,61)=WVADValue;
% clear WVADValue;
% end

