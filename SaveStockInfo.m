function [SaveLog,ProbList,NewList] = SaveStockInfo(StockList)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
%% �������Ԥ����
if nargin < 1 || isempty(StockList)
    load StockList.mat;
end

SaveLog = [];
ProbList = [];
NewList = [];

Len = size(StockList, 1);
StockCode = StockList(:,2);
StockName = StockList(:,1);

%% ��ȡ����
FolderStr = ['./DataBase/Stock/StockInfo_mat'];
if ~isdir( FolderStr )
    mkdir( FolderStr );
end

ticID = tic;
for i = 1:Len
    RunIndex = i;
    Scode = StockCode{i};
    Sname = StockName{i};
    strdisp=['��ȡ��Ʊ��Ϣ��...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
    disp(strdisp)
    
    FileString = [FolderStr,'/',StockCode{i},'_StockInfo.mat'];
    FileExist = 0;
    if exist(FileString, 'file') == 2
        FileExist = 1;
    end
    
    % % �������ݴ��ڣ�����β���������
    if 1 == FileExist
        try
            str = ['load ',FileString];
            eval(str);
            
            if ~isempty(StockInfo)
                
                str = [ StockCode{i},'-',StockName{i}, ' ���������Ѵ���' ];
                disp(str);
                
                % % ���ݼ��
                if isempty( StockInfo.IPOdate )
                    str = [ StockCode{i},'-',StockName{i}, ' ��Ʊ��������Ϊ�գ��������������ݣ�' ];
                    disp(str);
                    FileExist = 0;
                end
                
            else % % �������ݴ��ڣ���Ϊ��
                LenTemp = size( NewList,1 )+1;
                NewList{LenTemp,1} = Sname;
                NewList{LenTemp,2} = Scode;
                
                StockCodeInput = Scode;
                [StockInfo] = GetStockInfo_Web(StockCodeInput);
                if isempty(StockInfo)
                    str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                    disp(str);
                    LenTemp = size( ProbList,1 )+1;
                    ProbList{LenTemp,1} = Sname;
                    ProbList{LenTemp,2} = Scode;
                    continue;
                end
                
                save(FileString,'StockInfo', '-v7.3');
                
            end
        catch
            str = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܻ�����ԭ�����ݸ���ʧ�ܣ��������������ݣ�' ];
            disp(str);
            FileExist = 0;
        end
    end
    
    % % �������ݲ�����
    if 0 == FileExist
        LenTemp = size( NewList,1 )+1;
        NewList{LenTemp,1} = Sname;
        NewList{LenTemp,2} = Scode;
        
        StockCodeInput = Scode;
        [StockInfo] = GetStockInfo_Web(StockCodeInput);
        if isempty(StockInfo)
            str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
            disp(str);
            LenTemp = size( ProbList,1 )+1;
            ProbList{LenTemp,1} = Sname;
            ProbList{LenTemp,2} = Scode;
            continue;
        end
        
        save(FileString,'StockInfo', '-v7.3');
        
    end
    
    NewListLen = size(NewList,1);
    ProbListLen = size(ProbList,1);
    
end
