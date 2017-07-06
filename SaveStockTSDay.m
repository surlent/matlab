function [SaveLog,ProbList,NewList] = SaveStockTSDay(StockList,AdjFlag,XRDFlag)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
% AdjFlag 0:��Ȩʱ������ 1:ǰ��Ȩʱ������ 2:��Ȩʱ������
% XRDFlag 0:����ȡ��Ȩ��Ϣ��Ϣ 1:��ȡ��Ȩ��Ϣ��Ϣ
%% �������Ԥ����
if nargin < 3 || isempty(XRDFlag)
    XRDFlag = 0;
end
if nargin < 2 || isempty(AdjFlag)
    AdjFlag = 0;
end
if nargin < 1 || isempty(StockList)
    load StockList.mat;
end

SaveLog = {};
ProbList = {};
NewList = {};

Len = size(StockList, 1);
StockCode = StockList(:,2);
StockName = StockList(:,1);

if 1 == XRDFlag
    AdjFlag = 888;
end
Date_G = '19900101';
%% ��Ȩʱ������
if 0 == AdjFlag
    FolderStr = './DataBase/Stock/Day_ExDividend_mat';
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    for i = 1:Len
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        strdisp=['��ȡ��...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
        disp(strdisp)
        %%����һЩ��Ȼû�н������Ч����
        if 1 == strcmp(Scode,'sh600349')||1 == strcmp(Scode,'sh601206') ||1 == strcmp(Scode,'sz000991') ||1 == strcmp(Scode,'sz002257') ||1 == strcmp(Scode,'sz002525')||1 == strcmp(Scode,'sz002710') ||1 == strcmp(Scode,'sz002720') ||...
                1 == strcmp(Scode,'sz300361')||1 == strcmp(Scode,'sh600553')||1 == strcmp(Scode,'sh600709')||1 == strcmp(Scode,'sz000658')||1 == strcmp(Scode,'sz000730')||1 == strcmp(Scode,'sh600087')||1 == strcmp(Scode,'sh600656')...
                %{'��ͨ�Ѻ�'}{'����ʩ'}{'ͨ���߿�'}{'��������'}{'ʤ��ɽ��'}{'�������'}{'�����ɷ�'}{'������'}{'̫��ˮ��'}{'ST��̬'}{'ST����'}{'ST����'}{'���г���'}{'���в�Ԫ'}
            continue;
        end
        % % DebugMode
        DebugMode_OnOff = 0;
        if 1 == DebugMode_OnOff
            if strcmpi(Scode,'sh603011')~=1
                continue;
            end
            
        end
        
        FileString = [FolderStr,'/',StockCode{i},'_D_ExDiv.mat'];
        FileExist = 0;
        if exist(FileString, 'file') == 2
            FileExist = 1;
        end
        
        % % �������ݴ��ڣ�����β���������
        if 1 == FileExist
            try
                
                MatObj = matfile(FileString,'Writable',true);
                [nrows, ncols]=size(MatObj,'StockData');
                
                OffSet = 4;
                
                if nrows-OffSet>1
                    
                    len = nrows;
                    Temp = MatObj.StockData(len-OffSet,1);
                    DateTemp = datestr( datenum(num2str(Temp),'yyyymmdd'),'yyyymmdd' );
                    
                    StockCodeInput = Scode;
                    BeginDate = DateTemp;
                    EndDate = datestr(today, 'yyyymmdd');
                    
                    StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
                    if isempty(StockDataDouble)
                        pause(2);
                        strdisp = [ StockCode{i},'-',StockName{i}, '����' ];
                        disp(strdisp);
                        StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
                    end
                    if isempty(StockDataDouble)
                        strdisp = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                        disp(strdisp);
                        LenTemp = size( ProbList,1 )+1;
                        ProbList{LenTemp,1} = Sname;
                        ProbList{LenTemp,2} = Scode;
                        continue;
                    end
                    
                    MatObj.StockData = ...
                        [MatObj.StockData(1:nrows-OffSet-1,:);StockDataDouble];
                    
                else % % �������ݴ��ڣ���Ϊ��
                    LenTemp = size( NewList,1 )+1;
                    NewList{LenTemp,1} = Sname;
                    NewList{LenTemp,2} = Scode;
                    
                    % % ��ȡ��������
                    StockCodeInput = Scode;
                    IPOdate = GetBasicInfo_Mat(StockCodeInput,[],[],'Stock','IPOdate');
                    if ~isempty(IPOdate)
                        DateTemp = IPOdate;
                    else
                        DateTemp = Date_G;
                    end
                    DateTemp = num2str(DateTemp);
                    
                    StockCodeInput = Scode;
                    BeginDate = DateTemp;
                    EndDate = datestr(today, 'yyyymmdd');
                    
                    StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
                    if isempty(StockDataDouble)
                        pause(2);
                        strdisp = [ StockCode{i},'-',StockName{i}, '����' ];
                        disp(strdisp);
                        StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
                    end
                    if isempty(StockDataDouble)
                        strdisp = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                        disp(strdisp);
                        LenTemp = size( ProbList,1 )+1;
                        ProbList{LenTemp,1} = Sname;
                        ProbList{LenTemp,2} = Scode;
                        continue;
                    end
                    
                    %                     StockData = StockDataDouble;
                    %
                    %                     save(FileString,'StockData', '-v7.3');
                    MatObj.StockData = StockDataDouble;
                    
                end
            catch
                strdisp = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܻ�����ԭ�����ݸ���ʧ�ܣ��������������ݣ�' ];
                disp(strdisp);
                FileExist = 0;
            end
        end
        
        % % �������ݲ�����
        if 0 == FileExist
            LenTemp = size( NewList,1 )+1;
            NewList{LenTemp,1} = Sname;
            NewList{LenTemp,2} = Scode;
            
            % % ��ȡ��������
            StockCodeInput = Scode;
            IPOdate = GetBasicInfo_Mat(StockCodeInput,[],[],'Stock','IPOdate');
            if ~isempty(IPOdate)
                DateTemp = IPOdate;
            else
                DateTemp = Date_G;
            end
            DateTemp = num2str(DateTemp);
            
            StockCodeInput = Scode;
            BeginDate = DateTemp;
            EndDate = datestr(today, 'yyyymmdd');
            
            StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
            if isempty(StockDataDouble)
                pause(2);
                strdisp = [ StockCode{i},'-',StockName{i}, '����' ];
                disp(strdisp);
                StockDataDouble = GetStockTSDay_Web(StockCodeInput,BeginDate,EndDate);
            end
            if isempty(StockDataDouble)
                strdisp = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                disp(strdisp);
                LenTemp = size( ProbList,1 )+1;
                ProbList{LenTemp,1} = Sname;
                ProbList{LenTemp,2} = Scode;
                continue;
            end
            
            StockData = StockDataDouble;
            
            save(FileString,'StockData', '-v7.3');
            
        end
        
        NewListLen = size(NewList,1);
        ProbListLen = size(ProbList,1);
        
       end
    
end
%% ǰ��Ȩʱ������
if 1 == AdjFlag
    FolderStrD_Ex = './DataBase/Stock/Day_ExDividend_mat';
    FolderStr = './DataBase/Stock/Day_ForwardAdj_mat';
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    for i = 1:Len
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        strdisp=['����ǰ��Ȩ��...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
        disp(strdisp)
        
        FileStringD_Ex = [FolderStrD_Ex,'/',StockCode{i},'_D_ExDiv.mat'];
        FileString = [FolderStr,'/',StockCode{i},'_D_ForwardAdj.mat'];
        
        FileExist = 0;
        if exist(FileStringD_Ex, 'file') == 2
            FileExist = 1;
        end
        
        % % �������ݴ��ڣ�����β���������
        if 1 == FileExist
            try
                strdisp = ['load ',FileStringD_Ex];
                eval(strdisp);
                
                if ~isempty(StockData)
                    
                    XRD_Data = [];
                    
                    [StockDataXRD, factor] = CalculateStockXRD(StockData, XRD_Data, AdjFlag);
                    StockData = StockDataXRD;
                    save(FileString,'StockData', '-v7.3');
                end
            catch
                strdisp = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܻ�����ԭ�����ݸ���ʧ��' ];
                disp(strdisp);
                FileExist = 0;
            end
        end
        
        NewListLen = size(NewList,1);
        ProbListLen = size(ProbList,1);
                
    end
end

%% �����ʼ�֪ͨ

% str = datestr(now,'yyyy-mm-dd HH:MM:SS');
% if AdjFlag == 1
%     subject = [str,' ��Ʊ�������ݣ�ǰ��Ȩ���������'];
% else
%     subject = [str,' ��Ʊ�������ݣ�����Ȩ���������'];
% end
% content = [];
% content{1,1} = [str,' ��Ʊ�������ݸ������'];%��һ��
% 
% str = [ '����ʱ', num2str(elapsedTimeTemp), ' seconds(',num2str(elapsedTimeTemp/60), ' minutes)', ...
%        '(',num2str(elapsedTimeTemp/60/60), ' hours)'];
% content{length(content)+1,1} = str;%�ڶ���
% 
% str = [ '��������Ϊ', num2str(length(StockList)) ];
% content{length(content)+1,1} = str;%������
% 
% str =['�����Ʊ����',num2str(ProbListLen)];
% content{length(content)+1,1} = str;
% %content=[content;ProbList(:,1)];
% 
% str =['������Ʊ����',num2str(NewListLen)];
% content{length(content)+1,1} = str;
% %content=[content;NewList(:,1)];
% 
% Mail2Me(subject,content);
