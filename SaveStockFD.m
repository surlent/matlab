function [SaveLog,ProbList,NewList] = SaveStockFD(StockList,Opt)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
% Opt 0:��ȡ����ָ�� 1:��ȡ3�ű�
%% �������Ԥ����
if nargin < 2 || isempty(Opt)
    Opt = 0;
end
if nargin < 1 || isempty(StockList)
    load StockList.mat;
end

SaveLog = [];
ProbList = [];
NewList = [];

Len = size(StockList, 1);
StockCode = StockList(:,2);
StockName = StockList(:,1);
%% ��ȡ����ָ��
if 0 == Opt
    FolderStr = './DataBase/Stock/FinancialIndicators_mat';
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    
    for i = 1:Len
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        strdisp=['��ȡ����ָ����...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
        disp(strdisp)
        
        FileString = [FolderStr,'/',StockCode{i},'_FinIndicator.mat'];
        FileExist = 0;
        if exist(FileString, 'file') == 2
            FileExist = 1;
        end
        
        % % �������ݴ��ڣ�����β���������
        if 1 == FileExist
            try
                str = ['load ',FileString];
                eval(str);
                
                if ~isempty(StockFinInd)
                    
                    DateTemp = StockFinInd{end,1}-1;
                    StockCodeInput = Scode;
                    YearStart = DateTemp;
                    
                    CurrentYear = year(date);
                    if YearStart<=CurrentYear
                        len = size(StockFinInd,1)-1;
                        for y = YearStart:CurrentYear
                            Year = num2str(y);
                            [FIndCell,YearList] = GetStockFinIndicators_Web(StockCodeInput,Year);
                            if isempty(FIndCell)
                                str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                                disp(str);
                                LenTemp = size( ProbList,1 )+1;
                                ProbList{LenTemp,1} = Sname;
                                ProbList{LenTemp,2} = Scode;
                                continue;
                            end

                            StockFinInd{len,1} = y;
                            StockFinInd{len,2} = FIndCell;
                            len = len + 1;
                        end
                        save(FileString,'StockFinInd', '-v7.3');
                    end
                else % % �������ݴ��ڣ���Ϊ��
                    LenTemp = size( NewList,1 )+1;
                    NewList{LenTemp,1} = Sname;
                    NewList{LenTemp,2} = Scode;
                    
                    StockCodeInput = Scode;
                    Year = num2str( year(date) );
                    [FIndCell,YearList] = GetStockFinIndicators_Web(StockCodeInput,Year);
                    if isempty(FIndCell)
                        str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                        disp(str);
                        LenTemp = size( ProbList,1 )+1;
                        ProbList{LenTemp,1} = Sname;
                        ProbList{LenTemp,2} = Scode;
                        continue;
                    end
                    StockFinInd = [];
                    YearListFull = YearList;
                    for i = 1:length(YearListFull)-1
                        
                        Year = num2str(YearListFull{i+1,1});
                        [FIndCell,YearList] = GetStockFinIndicators_Web(StockCodeInput,Year);
                        
                        StockFinInd{i,1} = YearListFull{i+1};
                        StockFinInd{i,2} = FIndCell;
                    end
                    
                    save(FileString,'StockFinInd', '-v7.3');
                    
                end
            catch
                str = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܣ��������������ݣ�' ];
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
            Year = num2str( year(date) );
            [FIndCell,YearList] = GetStockFinIndicators_Web(StockCodeInput,Year);
            if isempty(FIndCell)
                str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                disp(str);
                LenTemp = size( ProbList,1 )+1;
                ProbList{LenTemp,1} = Sname;
                ProbList{LenTemp,2} = Scode;
                continue;
            end
            StockFinInd = [];
            YearListFull = YearList;
            for i = 1:length(YearListFull)-1
                
                Year = num2str(YearListFull{i+1,1});
                [FIndCell,YearList] = GetStockFinIndicators_Web(StockCodeInput,Year);
                
                StockFinInd{i,1} = YearListFull{i+1};
                StockFinInd{i,2} = FIndCell;
            end
            
            save(FileString,'StockFinInd', '-v7.3');
        end
        
        NewListLen = size(NewList,1);
        ProbListLen = size(ProbList,1);
        
        
    end
end
%% ��ȡ3�ű�
if 1 == Opt
    FolderStr = ['./DataBase/Stock/Sheet3_mat'];
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    
    for i = 1:Len
        RunIndex = i;
        Scode = StockCode{i};
        Sname = StockName{i};
        strdisp=['��ȡ3�󱨱�...','���:',num2str(RunIndex),'   ','����:',Scode,'   ','����:',Sname];
        disp(strdisp)
        
        FileString = [FolderStr,'/',StockCode{i},'_Sheet3.mat'];
        FileExist = 0;
        if exist(FileString, 'file') == 2
            FileExist = 1;
        end
        
        % % �������ݴ��ڣ�����β���������
        if 1 == FileExist
            try
                str = ['load ',FileString];
                eval(str);
                
                if ~isempty(StockSheet3)
                    
                    DateTemp = StockSheet3{end,1};
                    StockCodeInput = Scode;
                    YearStart = DateTemp;
                    
                    CurrentYear = year(date);
                    if YearStart<=CurrentYear
                        len = size(StockSheet3,1);
                        for y = YearStart:CurrentYear
                            Year = num2str(y);
                            [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCodeInput,Year);
                            if isempty(BalanceSheet)
                                str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                                disp(str);
                                LenTemp = size( ProbList,1 )+1;
                                ProbList{LenTemp,1} = Sname;
                                ProbList{LenTemp,2} = Scode;
                                continue;
                            end
                            
                            StockSheet3{len,1} = y;
                            StockSheet3{len,2} = BalanceSheet;
                            StockSheet3{len,3} = ProfitSheet;
                            StockSheet3{len,4} = CashFlowSheet;
                            len = len + 1;
                        end
                        save(FileString,'StockSheet3', '-v7.3');
                    end
                else % % �������ݴ��ڣ���Ϊ��
                    LenTemp = size( NewList,1 )+1;
                    NewList{LenTemp,1} = Sname;
                    NewList{LenTemp,2} = Scode;
                    
                    StockCodeInput = Scode;
                    Year = num2str( year(date) );
                    [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCodeInput,Year);
                    if isempty(BalanceSheet)
                        str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                        disp(str);
                        LenTemp = size( ProbList,1 )+1;
                        ProbList{LenTemp,1} = Sname;
                        ProbList{LenTemp,2} = Scode;
                        continue;
                    end
                    StockSheet3 = [];
                    YearListFull = YearList;
                    for i = 1:length(YearListFull)-1
                        
                        Year = num2str(YearListFull{i+1,1});
                        [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCodeInput,Year);
                        
                        StockFinInd{i,1} = YearListFull{i+1};
                        StockSheet3{i,2} = BalanceSheet;
                        StockSheet3{i,3} = ProfitSheet;
                        StockSheet3{i,4} = CashFlowSheet;
                    end
                    
                    save(FileString,'StockSheet3', '-v7.3');
                    
                end
            catch
                str = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܣ��������������ݣ�' ];
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
            Year = num2str( year(date) );
            [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCodeInput,Year);
            if isempty(BalanceSheet)
                str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܣ����飡' ];
                disp(str);
                LenTemp = size( ProbList,1 )+1;
                ProbList{LenTemp,1} = Sname;
                ProbList{LenTemp,2} = Scode;
                continue;
            end
            StockSheet3 = [];
            YearListFull = YearList;
            for i = 1:length(YearListFull)-1
                
                Year = num2str(YearListFull{i+1,1});
                [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCodeInput,Year);
                
                StockSheet3{i,1} = YearListFull{i+1};
                StockSheet3{i,2} = BalanceSheet;
                StockSheet3{i,3} = ProfitSheet;
                StockSheet3{i,4} = CashFlowSheet;
            end
            
            save(FileString,'StockSheet3', '-v7.3');
        end
        
        NewListLen = size(NewList,1);
        ProbListLen = size(ProbList,1);
        
       
    end
    
end
%% �����ʼ�֪ͨ

% str = datestr(now,'yyyy-mm-dd HH:MM:SS');
% if Opt == 1
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
