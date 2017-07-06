function SaveIndicator(Flag)
%%当前指标计算函数版本V001
%% 读取并计算DataBase/Stock/Day_ForwardAdj_mat文件夹下所有mat文件的技术指标
if nargin<1
    Flag=input(['请输入指标计算模式' 10 '1,股票' 10 '2,指数' 10 ]);
end
%% 计算股票指标

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
    
    debug=0;     %调试模式0关闭,1通过性,2效率
    
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
        strdisp=['计算中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
        disp(strdisp)
        FileString = [FolderStr,'/',Code{i},'_Fwd_Indicator.mat'];
        CalculateIndicatorV001(Scode,FileString,Flag,IndexIndicatorsSH,IndexIndicatorsSZ);
    end
    CheckIndicator;
    clc
end
%% 计算指数指标

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
    
    debug=0;     %调试模式0关闭,1通过性,2效率
    
    if debug == 1
        len=5;
    elseif debug == 2
        len=500;
    end
    
    parfor i=1:len
        RunIndex = i;
        Scode = Code{i};
        strdisp=['计算中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
        disp(strdisp)
        FileString = [FolderStr,'/',Code{i},'_D.mat'];
        CalculateIndicatorV001(Scode,FileString,Flag);
    end
    clc
end

end



