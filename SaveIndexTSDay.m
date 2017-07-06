function [SaveLog,ProbList,NewList] = SaveIndexTSDay(IndexList)
%% �������Ԥ����
if nargin < 1 || isempty(IndexList)
    load IndexList.mat;
end

SaveLog = [];
ProbList = [];
NewList = [];

Len = size(IndexList, 1);
StockCode = IndexList(:,2);
StockName = IndexList(:,1);

Date_G = '19900101';
%% Get Data
FolderStr = ['./DataBase/Stock/Index_Day_mat'];
if ~isdir( FolderStr )
    mkdir( FolderStr );
end

ticID = tic;
for i = 1:Len
    RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        strdisp=['��ȡ��...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
        disp(strdisp)
    
    FileString = [FolderStr,'/',StockCode{i},'_D.mat'];
    FileExist = 0;
    if exist(FileString, 'file') == 2
        FileExist = 1;
    end
    
    % % �������ݴ��ڣ�����β���������
    if 1 == FileExist
        try
            MatObj = matfile(FileString,'Writable',true);
            [nrows, ncols]=size(MatObj,'IndexData');
            
            OffSet = 4;
            
            if nrows-OffSet>1
                len = nrows;
                Temp = MatObj.IndexData(len-OffSet,1);
                DateTemp = datestr( datenum(num2str(Temp),'yyyymmdd'),'yyyymmdd' );
                
                StockCodeInput = Scode;
                BeginDate = DateTemp;
                EndDate = datestr(today, 'yyyymmdd');
                
                [newIndexData] = GetIndexTSDay_Web(StockCodeInput,BeginDate,EndDate);
                if isempty(newIndexData)
                    str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ��޸������ݣ����飡' ];
                    disp(str);
                    LenTemp = size( ProbList,1 )+1;
                    ProbList{LenTemp,1} = Sname;
                    ProbList{LenTemp,2} = Scode
                    continue;
                end
                
                MatObj.IndexData = ...
                    [MatObj.IndexData(1:nrows-OffSet-1,:);newIndexData];
                
            else % % �������ݴ��ڣ���Ϊ��
                % % ��ȡ��������
                StockCodeInput = Scode;
                BeginDate = '20140101';
                EndDate = datestr(today, 'yyyymmdd');
                [~,InitialDate] = GetIndexTSDay_Web(StockCodeInput,BeginDate,EndDate,1);
                DateTemp = InitialDate;
                
                LenTemp = size( NewList,1 )+1;
                NewList{LenTemp,1} = Sname;
                NewList{LenTemp,2} = Scode
                
                StockCodeInput = Scode;
                BeginDate = DateTemp;
                EndDate = datestr(today, 'yyyymmdd');
                
                [newIndexData] = GetIndexTSDay_Web(StockCodeInput,BeginDate,EndDate);
                if isempty(newIndexData)
                    str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ��޸������ݣ����飡' ];
                    disp(str);
                    LenTemp = size( ProbList,1 )+1;
                    ProbList{LenTemp,1} = Sname;
                    ProbList{LenTemp,2} = Scode
                    continue;
                end
                
                MatObj.IndexData = newIndexData;
                
            end
        catch
            str = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܻ�����ԭ�����ݸ���ʧ�ܣ��������������ݣ�' ];
            disp(str);
            FileExist = 0;
        end
    end
    
    % % �������ݲ�����
    if 0 == FileExist
        % % ��ȡ��������
        StockCodeInput = Scode;
        BeginDate = '20140101';
        EndDate = datestr(today, 'yyyymmdd');
        [~,InitialDate] = GetIndexTSDay_Web(StockCodeInput,BeginDate,EndDate,1);
        DateTemp = InitialDate;
        
        LenTemp = size( NewList,1 )+1;
        NewList{LenTemp,1} = Sname;
        NewList{LenTemp,2} = Scode
        
        StockCodeInput = Scode;
        BeginDate = DateTemp;
        EndDate = datestr(today, 'yyyymmdd');
        
        [newIndexData] = GetIndexTSDay_Web(StockCodeInput,BeginDate,EndDate);
        if isempty(newIndexData)
            str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ��޸������ݣ����飡' ];
            disp(str);
            LenTemp = size( ProbList,1 )+1;
            ProbList{LenTemp,1} = Sname;
            ProbList{LenTemp,2} = Scode
            continue;
        end
        
        IndexData = newIndexData;
        save(FileString,'IndexData', '-v7.3');
        
    end
    
    NewListLen = size(NewList,1);
    ProbListLen = size(ProbList,1);
    
end
