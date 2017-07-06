classdef fGetRTQuotes < handle
    %% fGetRTQuotes
    % ��ȡʵʱ�ֱ�����
    % by LiYang_faruto
    % Email:farutoliyang@foxmail.com
    % 2015/6/1
    %% properties
    properties
        
        
        Code = '600036';
        
    end
    %% properties(SetAccess = private, GetAccess = public)
    properties(SetAccess = private, GetAccess = public)
        
        
    end
    
    %% properties(Access = protected)
    properties(Access = protected)
        
    end
    
    %% properties(Access = private)
    properties(Access = private)
        
    end
    
    %% methods
    
    methods
        %% fGetIndex()
        function obj = fGetIndex( varargin )
            
            
        end
        
        %% GetRTQuotes()
        function DataCell_Output = GetRTQuotes(obj)
            % % ��ȡʵʱ�ֱ�����
            % % ��Ʊ���ڻ�ʵʱ�ֱ�����
            % % �����������������ʵʱ����
            
            StockNameList =  { ...
                '����';'����';'������';'��ǰ��';'�����';'�����';...
                '����ۣ�������һ������';'�����ۣ�������һ������'; ...
                '�ɽ�������λ���ɡ�';'�ɽ����λ��Ԫ��';...
                '��һ��';'��һ��';'�����';'�����';'������';'������';...
                '������';'���ļ�';'������';'�����'; ...
                '��һ��';'��һ��';'������';'������';'������';'������';...
                '������';'���ļ�';'������';'�����'; ...
                '����';'ʱ��'};
            
            FutureNameList = { ...
                '����';'Unknown';'���̼�';'��߼�';'��ͼ�';'�������̼� ';...
                '����ۣ�������һ������';'�����ۣ�������һ������'; ...
                '���¼ۣ������̼�';'�����';...
                '�����';'����';'����';'�ֲ���';'�ɽ���';'��Ʒ���������';...
                'Ʒ�������';'����';};

            FutureCFFNameList = { ...
                '���̼�';'��߼�';'��ͼ�';'�������̼� ';...
                '�ɽ���';'Unknown'; ...
                '�ֲ���';'���¼�';...
                };
            
            
            % % % Code����
            if ~iscell(obj.Code)
                temp{1,1} = obj.Code;
                obj.Code = temp;
            end
            Len = length(obj.Code);
            DataCell_Output = cell(Len,1);
            MarketType = cell(Len,1);
            URL = ['http://hq.sinajs.cn/list='];
            for i = 1:Len
                tCode = obj.Code{i};
                Ft = tCode(1);
                Ft = str2num(Ft);
                if ~isempty(Ft) && isnumeric(Ft)
                    MarketType{i,1} = 'Stock';
                    ListTemp = {'6','5'};
                    if ismember(tCode(1),ListTemp)
                        
                        tCode = ['sh',tCode];
                    end
                    ListTemp = {'0','3','1'};
                    if ismember(tCode(1),ListTemp)
                        
                        tCode = ['sz',tCode];
                    end
                else
                    ListTemp = {'SH','SZ'};
                    if ismember(lower(tCode(1:2)),lower(ListTemp))
                        
                        MarketType{i,1} = 'Stock';
                        
                    else
                        
                        MarketType{i,1} = 'Futures';
                        ListTemp = {'IF','TF','IC','IH'};
                        if ismember(lower(tCode(1:2)),lower(ListTemp))
                            tCode = ['CFF_RE_',tCode];
                            
                            MarketType{i,1} = 'Futures_CFF';
                        end
                    end
                    
                end
                
                if strcmpi(MarketType{i,1}, 'Stock')
                    tCode = lower(tCode);
                end
                
                if i == 1
                    URL = [URL,tCode];
                else
                    URL = [URL,',',tCode];
                end
                
            end
            
            URLChar = urlread(URL);
            R = textscan(URLChar,'%s','delimiter', ';');
            R = R{1,1};
            for i = 1:Len
                DataCell_Output{i,1} = [];
                
                tR = R{i,1};
                tData = textscan(tR,'%s','delimiter', ',');
                tData = tData{1,1};
                
                if strcmpi(MarketType{i,1}, 'Stock')

                    DataCell = tData;
                    Data = cellfun(@str2double, DataCell(2:30));
                    
                    temp = cell2mat(DataCell(1));
                    ind = find(temp=='"');
                    temp = temp(ind+1:end);
                    DataCell{1,1} = temp;
                    
                    tDate = cell2mat( DataCell(31) );
                    tTime = cell2mat( DataCell(32) );

                    DataCell(2:30) = mat2cell( Data, ones(length(Data), 1) );
                    DataCell{31, 1} = tDate;
                    DataCell{32, 1} = tTime;
                    
                    DataCell(end) = [];
                    
                    DataCell_Output{i,1} = [DataCell,StockNameList];
                end
                
                
                if strcmpi(MarketType{i,1}, 'Futures')
                    
                    DataCell = tData;
                    Data = cellfun(@str2double, DataCell(2:15));
                    
                    temp = cell2mat(DataCell(1));
                    ind = find(temp=='"');
                    temp = temp(ind+1:end);
                    DataCell{1,1} = temp;
                    
                    t1 = cell2mat( DataCell(16) );
                    t2 = cell2mat( DataCell(17) );
                    t3 = cell2mat( DataCell(18) );                    
                    
                    DataCell(2:15) = mat2cell( Data, ones(length(Data), 1) );
                    DataCell{16, 1} = t1;
                    DataCell{17, 1} = t2;
                    DataCell{18, 1} = t3;
                    
                    DataCell(19:end) = [];
                    
                    DataCell_Output{i,1} = [DataCell,FutureNameList];                    
                    
                end
                
                if strcmpi(MarketType{i,1}, 'Futures_CFF')
                    DataCell = tData;
                    
                    temp = cell2mat(DataCell(1));
                    ind = find(temp=='"');
                    temp = temp(ind+1:end);
                    DataCell{1,1} = temp;
                    
%                     Data = cellfun(@str2double, DataCell(2:16));
%                     t1 = cell2mat( DataCell(31) );
%                     t2 = cell2mat( DataCell(32) );
%                     
%                     DataCell(2:16) = mat2cell( Data, ones(length(Data), 1) );
%                     DataCell{17, 1} = t1;
%                     DataCell{18, 1} = t2;
%                     
%                     DataCell(end) = [];

                    tCell = cell(length(DataCell(1:38)),2);
                    tCell(:,1) = DataCell(1:38);
                    tCell(1:length(FutureCFFNameList),2) = FutureCFFNameList;
                    
                    tCell(end-1,2) = {'����'};
                    tCell(end,2) = {'ʱ��'};                    
                    
                    DataCell_Output{i,1} = tCell;                     
                    

                end                
                
            end
            
            if Len == 1
                
                DataCell_Output = DataCell_Output{1,1};
            end
        end
        
        
        %% ���������麯��
        function Flag = ParaCheck(obj, varargin )
            Flag = 1;
            
            % %===���������� ��ʼ===
            
            %             checkflag = ismember( lower(obj.DownUpSampling),lower(obj.DownUpSampling_ParaList) );
            %             if checkflag ~= 1
            %                 str = ['DownUpSampling��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
            %                 disp(str);
            %                 ParaList = obj.DownUpSampling_ParaList
            %                 Flag = 0;
            %                 return;
            %             end
            
            % %===���������� ���===
        end
        
        
        
        
        
    end
    
end
