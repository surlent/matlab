function [SaveLog,ProbList,NewList] = SaveStockTick(StockList,DateList,PList,CheckFlag)
% ��ȡ��Ʊÿ�ս�����ϸ���ݲ��洢������
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
%% �������Ԥ����
if nargin < 4 || isempty(CheckFlag)
    CheckFlag = 0;
end
if nargin < 3 || isempty(PList)
    PList = [];
end
if nargin < 2 || isempty(DateList)
    DtempEnd = datenum(datestr(date,'yyyymmdd'),'yyyymmdd');
    DtempStart = datenum('20050101', 'yyyymmdd');
    Dtemp = (DtempStart:DtempEnd)';
    DateList = str2num( datestr(Dtemp,'yyyymmdd') );
end
if nargin < 1 || isempty(StockList)
    load StockList.mat;
end

Len = size(StockList, 1);
StockCode = StockList(:,2);
StockName = StockList(:,1);

SaveLog = [];
ProbList = cell(Len,3);
NewList = cell(Len,3);

ProbDateList = [];
%% ��ȡ����-CheckFlag = 0
if 0 == CheckFlag
    FolderStrD = ['./DataBase/Stock/Day_ExDividend_mat'];
    
    ticID = tic;
    for i = 1:Len
        %     disp('======')
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        %     disp('============')
        ProbDateList = [];
        ProbList{i,1} = Sname;
        ProbList{i,2} = Scode;
        ProbList{i,3} = [];
        
        % % ��ȡ��������
        FolderStr_StockInfo = ['./DataBase/Stock/StockInfo_mat'];
        FileString_StockInfo = [FolderStr_StockInfo,'/',StockCode{i},'_StockInfo.mat'];
        if exist(FileString_StockInfo, 'file') == 2
            str = ['load ',FileString_StockInfo];
            eval(str);
            if ~isempty( StockInfo.IPOdate )
                temp = StockInfo.IPOdate;
                DtempStart = datenum(num2str(temp), 'yyyymmdd');
                DtempEnd = datenum(datestr(date,'yyyymmdd'),'yyyymmdd');
                
                Dtemp = (DtempStart:DtempEnd)';
                DateList = str2num( datestr(Dtemp,'yyyymmdd') );
            end
        end
        
        DLen = size( DateList,1 );
        for j = 1:DLen
            DateTemp = DateList(j,1);
            
            if DateTemp<20050101
                continue;
            end
            
            % % % debug block
            Debug_OnOff = 0;
            if 1 == Debug_OnOff
                if DateTemp<20130318
                    continue;
                end
            end            
            
            disp('======')
            RunIndex = i
            Scode = StockCode{i}
            Sname = StockName{i}
            DIndex = j
            str = ['���ڣ�',num2str( DateTemp )];
            disp(str);
            disp('============')
            
            FolderStr = ['./DataBase/Stock/Tick_mat/',StockCode{i},'_Tick'];
            if ~isdir( FolderStr )
                mkdir( FolderStr );
            end
            BeginDate = num2str( DateTemp );
            FileString = [FolderStr,'/',StockCode{i},'_Tick_',BeginDate,'.mat'];
            FileExist = 0;
            if exist(FileString, 'file') == 2
                FileExist = 1;
            end
            
            % % �������ݴ��ڣ�����β���������
            if 1 == FileExist
                try
                    str = ['load ',FileString];
                    eval(str);
                    
                    if ~isempty(StockTick)
                        str = [ StockCode{i},'-',StockName{i}, ...
                            ' ���ڣ�',num2str( DateTemp ),' ���������Ѵ���' ];
                        disp(str);
                        
                        % % % �����쳣���
                        Pcheck = StockTick(:,2);
                        Zsum = sum( Pcheck == 0 );
                        if Zsum == length(Pcheck)
                            str = [ StockCode{i},'-',StockName{i}, ...
                                ' ���ڣ�',num2str( DateTemp ),' �������ݼ۸��д����쳣�����������أ�' ];
                            disp(str);
                            FileExist = 0;
                        end
                        
                    else % % �������ݴ��ڣ���Ϊ��
                        
                        NewList{i,1} = Sname;
                        NewList{i,2} = Scode;
                        
                        StockCodeInput = Scode;
                        
                        BeginDate = num2str( DateTemp );
                        SaveFlag = 0;
                        [StockTick,Header,StatusStr] = GetStockTick_Web(StockCodeInput,BeginDate,SaveFlag);
                        if isempty(StockTick)
                            str = [ StockCode{i},'-',StockName{i}, ...
                                ' ���ڣ�',num2str( DateTemp ),' ���ݻ�ȡʧ�ܣ����飡' ];
                            disp(str);
                            ProbDateList = [ProbDateList;DateTemp];
                            ProbList{i,1} = Sname;
                            ProbList{i,2} = Scode;
                            continue;
                        end
                        
                        save(FileString,'StockTick','Header','-v7.3');
                    end
                catch
                    str = [ StockCode{i},'-',StockName{i}, ...
                        ' ���ڣ�',num2str( DateTemp ),' ��������ʧ�ܣ��������������ݣ�' ];
                    disp(str);
                    FileExist = 0;
                end
            end
            
            % % �������ݲ�����
            if 0 == FileExist
                NewList{i,1} = Sname;
                NewList{i,2} = Scode;
                
                StockCodeInput = Scode;
                
                BeginDate = num2str( DateTemp );
                SaveFlag = 0;
                [StockTick,Header,StatusStr] = GetStockTick_Web(StockCodeInput,BeginDate,SaveFlag);
                if isempty(StockTick)
                    str = [ StockCode{i},'-',StockName{i}, ...
                        ' ���ڣ�',num2str( DateTemp ),' ���ݻ�ȡʧ�ܣ����飡' ];
                    disp(str);
                    ProbDateList = [ProbDateList;DateTemp];
                    ProbList{i,1} = Sname;
                    ProbList{i,2} = Scode;
                    continue;
                end
                
                save(FileString,'StockTick','Header','-v7.3');
            end

            NewListLen = size(NewList)
            ProbListLen = size(ProbList)
            DateListLen = size(ProbDateList)
            
            elapsedTimeTemp = toc(ticID);
            str = [ 'ѭ���Ѿ��ۼƺ�ʱ', num2str(elapsedTimeTemp), ' seconds(',num2str(elapsedTimeTemp/60), ' minutes)',...
                '(',num2str(elapsedTimeTemp/60/60), ' hours)',];
            disp(str);
            
        end
        ProbList{i,3} = ProbDateList;
    end
end
%% ��ȡ����-CheckFlag = 1
if 1 == CheckFlag && ~isempty(PList)
    
    StockList = PList(:,1:2);
    Len = size(StockList, 1);
    StockCode = StockList(:,2);
    StockName = StockList(:,1);
    
    SaveLog = [];
    ProbList = cell(Len,3);
    NewList = cell(Len,3);
    
    ticID = tic;
    for i = 1:Len
        %     disp('======')
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        %     disp('============')
        
        temp = PList{i,1};
        if isempty( temp )
            continue;
        end
        temp = PList{i,3};
        if isempty( temp )
            continue;
        end          

        ProbDateList = [];
        ProbList{i,1} = Sname;
        ProbList{i,2} = Scode;
        ProbList{i,3} = [];

        % % ��ȡ��������
        FolderStr_StockInfo = ['./DataBase/Stock/StockInfo_mat'];
        FileString_StockInfo = [FolderStr_StockInfo,'/',StockCode{i},'_StockInfo.mat'];
        DtempStart = [];
        if exist(FileString_StockInfo, 'file') == 2
            str = ['load ',FileString_StockInfo];
            eval(str);
            if ~isempty( StockInfo.IPOdate )
                temp = StockInfo.IPOdate;
                DtempStart = temp;
            end
        end
        
        DListNew = PList{i,3};
        if ~isempty( DtempStart )
            ind = find( DListNew(:,1)<=DtempStart );
            if ~isempty(ind)
                DListNew = DListNew(ind(end):end,:);
            end
        end
        
        temp = DListNew;
        DLen = size( temp,1 );
        DateData = temp;
        for j = 1:DLen
            DateTemp = DateData(j,1);
            
            if DateTemp<20050101
                continue;
            end
            
            disp('======')
            RunIndex = i
            Scode = StockCode{i}
            Sname = StockName{i}
            DIndex = j
            str = ['���ڣ�',num2str( DateTemp )];
            disp(str);
            disp('============')
            
            FolderStr = ['./DataBase/Stock/Tick_mat/',StockCode{i},'_Tick'];
            if ~isdir( FolderStr )
                mkdir( FolderStr );
            end
            BeginDate = num2str( DateTemp );
            FileString = [FolderStr,'/',StockCode{i},'_Tick_',BeginDate,'.mat'];
            FileExist = 0;
            if exist(FileString, 'file') == 2
                FileExist = 1;
            end
            
            % % �������ݴ��ڣ�����β���������
            if 1 == FileExist
                try
                    str = ['load ',FileString];
                    eval(str);
                    
                    if ~isempty(StockTick)
                        str = [ StockCode{i},'-',StockName{i}, ...
                            ' ���ڣ�',num2str( DateTemp ),' ���������Ѵ���' ];
                        disp(str);
                        
                        % �쳣���ݼ��
                        Pcheck = StockTick(:,2);
                        Zsum = sum(Pcheck == 0);
                        if Zsum == length(Pcheck)
                            str = [ StockCode{i},'-',StockName{i}, ...
                                ' ���ڣ�',num2str( DateTemp ),' �������ݼ۸��������⣬�����»�ȡ��' ];
                            disp(str);
                            FileExist = 0;
                        end
                        
                    else % % �������ݴ��ڣ���Ϊ��
                        
                        NewList{i,1} = Sname;
                        NewList{i,2} = Scode;
                        
                        StockCodeInput = Scode;
                        DateTemp = DateData(j,1);
                        BeginDate = num2str( DateTemp );
                        SaveFlag = 0;
                        [StockTick,Header,StatusStr] = GetStockTick_Web(StockCodeInput,BeginDate,SaveFlag);
                        if isempty(StockTick)
                            str = [ StockCode{i},'-',StockName{i}, ...
                                ' ���ڣ�',num2str( DateTemp ),' ���ݻ�ȡʧ�ܣ����飡' ];
                            disp(str);
                            ProbDateList = [ProbDateList;DateTemp];
                            ProbList{i,1} = Sname;
                            ProbList{i,2} = Scode;
                            continue;
                        end
                        
                        save(FileString,'StockTick','Header','-v7.3');
                    end
                catch
                    str = [ StockCode{i},'-',StockName{i}, ...
                        ' ���ڣ�',num2str( DateTemp ),' ��������ʧ�ܣ��������������ݣ�' ];
                    disp(str);
                    FileExist = 0;
                end
            end
            
            % % �������ݲ�����
            if 0 == FileExist
                NewList{i,1} = Sname;
                NewList{i,2} = Scode;
                
                StockCodeInput = Scode;
                DateTemp = DateData(j,1);
                BeginDate = num2str( DateTemp );
                SaveFlag = 0;
                [StockTick,Header,StatusStr] = GetStockTick_Web(StockCodeInput,BeginDate,SaveFlag);
                if isempty(StockTick)
                    str = [ StockCode{i},'-',StockName{i}, ...
                        ' ���ڣ�',num2str( DateTemp ),' ���ݻ�ȡʧ�ܣ����飡' ];
                    disp(str);
                    ProbDateList = [ProbDateList;DateTemp];
                    ProbList{i,1} = Sname;
                    ProbList{i,2} = Scode;
                    continue;
                end
                
                save(FileString,'StockTick','Header','-v7.3');
            end

            NewListLen = size(NewList)
            ProbListLen = size(ProbList)
            DateListLen = size(ProbDateList)
            
            elapsedTimeTemp = toc(ticID);
            str = [ 'ѭ���Ѿ��ۼƺ�ʱ', num2str(elapsedTimeTemp), ' seconds(',num2str(elapsedTimeTemp/60), ' minutes)',...
                '(',num2str(elapsedTimeTemp/60/60), ' hours)',];
            disp(str);
            
        end
        ProbList{i,3} = ProbDateList;
    end
end
%% �����ʼ�֪ͨ

% str = datestr(now,'yyyy-mm-dd HH:MM:SS');
% if AdjFlag == 1
%     subject = [str,' ��Ʊ�������ݣ�ǰ��Ȩ���������'];
% else
%     subject = [str,' ��Ʊ�������ݣ�����Ȩ���������'];
% end
%
% content = [];
% content{1,1} = [str,' ��Ʊ�������ݸ������'];
%
% Temp = StockD.DataCell;
% Temp = Temp(end,1);
% if iscell(Temp)
%     Temp = Temp{1};
% end
% str = [ '��Ʊ���������Ѹ�����', num2str(Temp) ];
% content{length(content)+1,1} = str;
% if ~isempty(IndNew)
%     content{length(content)+1,1} = '�����Ӹ��ɣ�';
%     for i = 1: length(IndNew);
%         content{length(content)+1,1} = cell2mat( StockList(IndNew(i),:) );
%     end
% end
% str = [ '����ʱ', num2str(elapsedTime), ' seconds(',num2str(elapsedTime/60), ' minutes)', ...
%        '(',num2str(elapsedTime/60/60), ' hours)'];
% content{length(content)+1,1} = str;
% str = [ '��������Ϊ', num2str(length(StockList)) ];
% content{length(content)+1,1} = str;
%
% TargetAddress = 'faruto@foxmail.com'; %Ŀ�������ַ
% MatlabSentMail(subject, content, TargetAddress);
