function SaveIndicator(Flag)
%%��ǰָ����㺯���汾V001
%% ��ȡ������DataBase/Stock/Day_ForwardAdj_mat�ļ���������mat�ļ��ļ���ָ��
if nargin<1
    Flag=input(['������ָ�����ģʽ' 10 '1,��Ʊ' 10 '2,ָ��' 10 ]);
end
%% �����Ʊָ��

if Flag==1
    
    FolderStr = './DataBase/Index/DayIndicator_mat';
    d=dir ('./DataBase/Stock/Day_ForwardAdj_mat');
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    Code=d(:,1);
    for i=1:len
        Code{i}(end-16:end)=[];
    end
    
    debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��
    
    if debug == 1
        len=5;
    elseif debug == 2
        len=500;
    end
    load('.\DataBase\Index\IndexIndicator_mat\sh000001_D.mat');
    IndexIndicatorsSH=IndexIndicators;
    load('.\DataBase\Index\IndexIndicator_mat\sz399001_D.mat');
    IndexIndicatorsSZ=IndexIndicators;
    clear IndexIndicators
    
    parfor i=1:len
        RunIndex = i;
        Scode = Code{i};
        strdisp=['������...','���:',num2str(RunIndex),'   ','����:',Scode];
        disp(strdisp)
        FileString = [FolderStr,'/',Code{i},'_Fwd_Indicator.mat'];
        CalculateIndicatorV001(Scode,FileString,Flag,IndexIndicatorsSH,IndexIndicatorsSZ);
    end
    CheckIndicator;
    clc
end
%% ����ָ��ָ��

if Flag==2
    FolderStr = './DataBase/Index/IndexIndicator_mat';
    d=dir ('./DataBase/Stock/Index_Day_mat');
    
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    
    d(1:2,:)=[];
    d=struct2cell(d);
    d=d';
    len=size(d,1);
    Code=d(:,1);
    for i=1:len
        Code{i}(end-5:end)=[];
    end
    
    debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��
    
    if debug == 1
        len=5;
    elseif debug == 2
        len=500;
    end
    
    parfor i=1:len
        RunIndex = i;
        Scode = Code{i};
        strdisp=['������...','���:',num2str(RunIndex),'   ','����:',Scode];
        disp(strdisp)
        FileString = [FolderStr,'/',Code{i},'_D.mat'];
        CalculateIndicatorV001(Scode,FileString,Flag);
    end
    clc
end

end



