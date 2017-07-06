function BPtrainAllinOne(Flag)
%%����������Ҫͨ��ai����,��Ϊ����Ҫ�ظ���ȡ��������,����������combine������,������ָ�����,ֱ�Ӷ�һ���ϲ�����������ѵ��.(����ʱ������)
%�������ܲ�����,��������Ϊ�������кܶ��ݶȺܴ��������,����Ԫ��Ϊ�ٶ�,���ٶ�֮��ı仯�з�Ӧ,��Ӧ�ڽ����:�������붼����һ�����,������Ȩֵ��ô��������Ч.
%��ʱ���������ַ�ʽ
if nargin<1
    Flag=input(['���������ģʽ' 10 '1,ֻ��ѧϰ���ز�' 10 '2,ֻ�زⲻѧϰ' 10 '3,ѧϰ���ز�' 10 '4,Ԥ�����������ź�' 10]);
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
    
    
    load('.\DataBase\Index\2D All\TwoDAll.mat');            %�ϲ��ķ�ʽ������,һ�������и������һ����ά����,���ַ�ʽѵ����Ҫ��ԭ,���Բ�����,���ǲ���2ά����ĺϲ�(2D��������)
    inPut=TwoDAll(:,11:end-5)';
    outPut=(TwoDAll(:,end-1)*100)';
    
    inPut = mapminmax(inPut);
    net = train(net,inPut,outPut);
    save( '.\DataBase\Net\AllinOne\AllinOne_net.mat','net', '-v7.3');
end

if Flag==2 || Flag==3
    %% ����ָ��,������net���Ԥ��ֵ
    d=dir('.\DataBase\Index\DayIndicator_mat');
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    StockCode=d(:,1);
    for i=1:len
        StockCode{i}(end-17:end)=[];
    end
    result=cell(len,5);             %�ز�������
    try
        load('.\DataBase\Net\AllinOne\AllinOne_net.mat');
    catch
        disp('�޻���������')
    end
    for i=1:len
        Scode = StockCode{i};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);%����ָ���б�
        disp(['��ǰ������' Scode] )
        TestData=StockIndicators;
        TestData =[TestData(:,1:2),TestData(:,11:end-5)];
        TestData(any(TestData==0,2),:)=[];      %ȥ������Ҫ����
        if isempty(TestData) || size(TestData,1)<2
            disp('�������ݹ�������')
            continue
        end
        Date=TestData(:,1);
        Price=TestData(:,2);
        ROE=TestData(:,6);
        TestData=TestData(:,3:end)';
        TestData = mapminmax(TestData);         %��һ��
        ForCast = sim(net, TestData);
        ForCast = ForCast';
        %% �ز�����
        Slip=0.001;      %����1%�����Ҳ��õ��ճɽ�ƽ���۸���Ϊ����,�������ó��ڿ��Ա���Щ,���ڿ�ʵ���������,Ӧ����������۸��׼ҪСЩ,��Ϊ���ܳɽ��������Ҫ����һЩ.
        StartMoney=100000;  %��ʼ��Ǯ
        Fee=0.00025;    %������
        Len=length(Price);
        Position=zeros(Len,1);          %��λ,��ֻ��0,1����λ�ü����ֺͿղ�
        TradePrice=zeros(Len,2);        %��������۸�������õ�һϵ���м�ɱ�
        %ForCastPrice=zeros(Len,1);      %Ԥ�Ƽ۸�
        StockAmount=zeros(Len,1);       %�ֲ���
        Cash=zeros(Len,1);              %�ֽ�
        Cash(:,1)=StartMoney;           %��ȫ������Ϊ��ʼ�ʽ�
        Assets=zeros(Len,1);            %���ʲ�
        ProfitPerTrade=zeros(Len,1);    %����ӯ��/����
        %% ʱ�����з���ز�
        for j=2:Len                   %ȫ������Ч���ݴӵڶ��쿪ʼ
            signalBuy= ForCast(j-1)>5 && ROE(j)>5;
            signalSell= ForCast(j-1)<0;
            %         stopLoss=0;    %(Price(i)<TradePrice(i-1,1)*0.85);��������Ƶ��
            %         stopWin=Price(i)>ForCastPrice(i);
            if signalBuy==1 && Position(j-1)==0
                Position(j)=1;
                TradePrice(j,1)=Price(j)*(1+Slip)*(1+Fee);
                %ForCastPrice(i)=Price(i)*(ForCast(i)+1);
                StockAmount(j)=floor(Cash(j-1)/(TradePrice(j,1)*100));
                Cash(j)=Cash(j-1)-StockAmount(j)*TradePrice(j,1)*100;
                Assets(j)=Cash(j)+StockAmount(j)*Price(j)*100;
            elseif (signalSell==1 && Position(j-1)==1) %|| (stopLoss==1 && Position(i-1)==1) || (stopWin==1 && Position(i-1)==1) %���߷��ź�Ϊֹ��,ֹӯ����
                Position(j)=0;
                TradePrice(j,2)=Price(j)*(1-Slip)*(1-Fee-0.001);            %0.001��ӡ��˰
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
            SharpRate=0;                                                      %���һֻ��Ʊ����Period�콻����,��������û�����,��������Ϊ0,���ʲ�����,�̶����±�׼��Ϊ0,��������ᵼ���껯���ձ���Ϊ������.����ֱ�Ӱ�0����.
        else
            SharpRate=(YearlyProfitRate-0.05)/(Std/Avg/2/YearPassed);         %0.05�껯�޷���������,���ձ��ʻ���Ҫ���Ǵ���1,Ȼ��Խ��Խ��,С��1��ʾ��λ���մ��ڵ�λ��������,С��0��ʾ�����ʵ����޷�������.
        end
        DrawDownRate=zeros(length(Assets),1);
        for t=1:length(Assets)
            DrawDownRate(t)=(Assets(t)-min(Assets(t:end)))/Assets(t);
        end;
        MaxDrawDownRate=max(DrawDownRate);
        result(i,:)={Scode,TotalProfit,YearlyProfitRate,SharpRate,MaxDrawDownRate};
    end
    temp=cell2mat(result(:,2:end));
    temp(all(temp==0,2),:)=[];          %ȥ��0ֵ
    temp=mean(temp);
    temp=num2cell(temp);                %����ƽ��ֵ
    Mean=[{'ƽ��������'},{'ƽ���껯������'},{'ƽ�����ձ���'},{'ƽ�����س�'};temp];
    save( '.\DataBase\BackTestResult\AI_AllinOne\Result.mat','result', '-v7.3');%�ļ���������ز���
    save( '.\DataBase\BackTestResult\AI_AllinOne\Mean.mat','Mean', '-v7.3');%�ļ������������
end

if Flag==4
    result=cell(len,7);
    try
        load(['..\DataBase\Net\AllinOne\AllinOne_net.mat']);
    catch
        disp('�޻���������')
    end
    for i=1:len
        Scode = StockCode{i};
        load(['.\DataBase\Index\DayIndicator_mat\' Scode '_Fwd_Indicator.mat']);%����ָ���б�
        temp = StockIndicators;
        temp (:,all(temp==0,1))=[];             %ȥ������Ҫ����
        TestData=temp;
        TestData =[TestData(:,1:2),TestData(:,11:end-5)];
        TestData(any(TestData==0,2),:)=[];      %ȥ������Ҫ����
        Date=TestData(:,1);
        Price=TestData(:,2);
        TestData=TestData(:,3:end)';
        TestData = mapminmax(TestData);         %��һ��
        TestData = TestData(:,end);
        ForCast = sim(net, TestData);
        if ForCast>0.1
            result(i,:)={stockcode,Date,'��һ�����չ���,10��Ԥ���Ƿ�',ForCast,'','',''};              %(����,����,����,����,��ʷ�껯������,��ʷ���س�)���Ҫ������ʷ׼ȷ�ʵ���ֵ,����ֱ��������ֵ,YearlyProfitRate,SharpRate,MaxDrawDownRate
        elseif ForCast<0
            result(i,:)={stockcode,Date,'��һ����������,10��Ԥ�Ƶ���',ForCast,'','',''};
        else
            result(i,:)={stockcode,Date,'����,10��Ԥ��',ForCast,'','',''};
        end
    end
    disp('����Ԥ��������xls�ļ�')
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
    xlswrite(['.\BackTest\AIForcast\AllinOne_SubTotal' LastDate ],{'����','���Ԥ������','����','Ԥ���ǵ���','�ز������껯������','�ز��������ձ���','���س�'},'�ز���','A1');
    xlswrite(['.\BackTest\AIForcast\AllinOne_SubTotal' LastDate ],result,'�ز���','A2');
end

end