function AI(Flag,Mod)
%%��ǰ�汾V000
if nargin<1
    Flag=input(['���������ģʽ' 10 '1,ֻ��ѧϰ���ز�' 10 '2,ֻ�زⲻѧϰ' 10 '3,ѧϰ���ز�' 10 '4,Ԥ�����������ź�' 10]);
    Mod=input(['��������Զ���' 10 '1,��Ʊ' 10 '2,ָ��' 10 ]);
end

%% �����Ʊnet
if Mod==1
    
    FolderStr = '.\DataBase\Net\Stock\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    FolderStr = '.\DataBase\BackTestResult\AI\';
    
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
    
    debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��
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
        strdisp=['������ѧϰ��...','���:',num2str(RunIndex),'   ','����:',Scode];
        disp(strdisp)
        result(i,:) = BPtrain(Scode,Flag);
    end
    
    if Flag~=1 && Flag~=4                   %flag2.3��Ҫ����result����,1û��result����,4��result����Ϊ���ղ��Խ���,��ʽ��ͬ
        temp=cell2mat(result(:,2:end));
        temp(any(temp==0,2),:)=[];          %ȥ��0ֵ
        temp=mean(temp);
        temp=num2cell(temp);                %����ƽ��ֵ
        Mean=[{'ƽ��������'},{'ƽ���껯������'},{'ƽ�����ձ���'},{'ƽ�����س�'},{'ƽ��ʤ��'},{'ƽ�����״���'},{'ƽ�����׳���'};temp];
        save( '.\DataBase\BackTestResult\AI\Result.mat','result', '-v7.3');%�ļ���������ز���
        save( '.\DataBase\BackTestResult\AI\Mean.mat','Mean', '-v7.3');%�ļ������������
    end
    if Flag==4
        disp('����Ԥ��������xls�ļ�')
        temp=load('.\DataBase\BackTestResult\AI\Result.mat');
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
        xlswrite(['.\BackTest\AIForcast\SubTotal' LastDate ],{'����','���Ԥ������','����','Ԥ���ǵ���%','�ز������껯������','�ز��������ձ���','���س�','��ʷʤ��','��ʷ���״���(Խ��Խ��)','���׳���(Խ��Խ��)'},'�ز���','A1');
        xlswrite(['.\BackTest\AIForcast\SubTotal' LastDate ],result,'�ز���','A2');
    end
end

%% ����ָ��net
if Mod==2
    
    FolderStr = '.\DataBase\Net\Index\';
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    FolderStr = '.\DataBase\BackTestResult\AI_Index\';
    
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
    
    debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��
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
        strdisp=['������ѧϰ��...','���:',num2str(RunIndex),'   ','����:',Scode];
        disp(strdisp)
        result(i,:) = BPtrainIndex(Scode,Flag);
        %Flag=1,ֻ��ѧϰ���ز�
        %Flag=2,ֻ�زⲻѧϰ
        %Flag=3,ѧϰ���ز�
    end
    
    if Flag~=1 && Flag~=4
        temp=cell2mat(result(:,2:end));
        temp(any(temp==0,2),:)=[];          %ȥ��0ֵ
        temp=mean(temp);
        temp=num2cell(temp);                %����ƽ��ֵ
        Mean=[{'ƽ��������'},{'ƽ���껯������'},{'ƽ�����ձ���'},{'ƽ�����س�'},{'ƽ��ʤ��'},{'ƽ�����״���'},{'ƽ�����׳���'};temp];
        save( '.\DataBase\BackTestResult\AI_Index\Result.mat','result', '-v7.3');%�ļ���������ز���
        save( '.\DataBase\BackTestResult\AI_Index\Mean.mat','Mean', '-v7.3');%�ļ������������
    end
    if Flag==4
        disp('����Ԥ��������xls�ļ�')
        temp=load('.\DataBase\BackTestResult\AI_Index\Result.mat');
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
        xlswrite(['.\BackTest\AIForcast_Index\SubTotal' LastDate ],{'����','���Ԥ������','����','Ԥ���ǵ���','�ز������껯������','�ز��������ձ���','���س�','��ʷʤ��(���ܴ��ڹ����)','��ʷ���״���(Խ��Խ��)','���׳���(Խ��Խ��)'},'�ز���','A1');
        xlswrite(['.\BackTest\AIForcast_Index\SubTotal' LastDate ],result,'�ز���','A2');
    end
    clear
end

end

