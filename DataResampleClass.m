classdef DataResampleClass < handle
    %% DataResampleClass
    % by LiYang_faruto
    % Email:farutoliyang@foxmail.com
    % 2015/6/1
    %% properties
    properties
        % % ����������������ѡ�����
        % 'DownSampling' 'UpSampling'
        DownUpSampling = 'DownSampling';
        % % ����Ƶ�����ò���
        % 'Nmin' 'Nhour' 'Nday' 'Nsecond' 'Nmillisecond'
        % 'Nweek' 'Nmonth' 'Nquarter' 'Nyear' ...
        Fre = '1min';
        % % �����г��������ò�������ͬ�г�����ʱ�䲻ͬ��
        % 'SHSZ' 'CFFEX' ...
        Market = 'SHSZ';
        % % ���ڲ�������ֵ�ķ���
        % 'OHLC2OHLC' 'OHLCVA2OHLCVA'
        % 'OHLCVA' 'OHLC'
        % 'first' 'last' 'median' 'max' 'min' 'sum' 'prod'
        HowMethod = 'OHLCVA';
        % % ����ȱʧʱ�Ĳ�ֵ�����Լ�������ʱ�Ĳ�ֵ����ѡ��
        % 'ffill' 'bfill' 'nan'
        FillMethod = 'ffill';
        % % �ڽ������У���ʱ��ε���һ���Ǳպϣ�����������
        % 'right' 'left'
        Closed = 'right';
        % % �ڽ������У�������ò�����ı�ǩ��
        % ���� 9:30��9:35֮�����5���ӻᱻ���Ϊ9:30('left')��9:35('right')
        % 'right' 'left'
        Label = 'right';
        % % �������ݵ�ʱ��������ݸ�ʽ
        % Datenum: MATALB��datenum��ʽ��
        % DateNumber = datenum(2015,5,13,9,30,33)
        % datestr(DateNumber) = '13-May-2015 09:30:33'
        % PureDouble: ����201505130930.33
        % 'Datenum' 'PureDouble'
        DateFormatInput = 'PureDouble';
        % % �������ݵ�ʱ��������ݸ�ʽѡ��
        % 'Datenum' 'PureDouble'
        DateFormatOutput = 'PureDouble';
        
        % 1 0 Resample���Ƿ���ͼ
        isPlot = 0;
        % For LabelSet����
        LabelSetStyle = 0;
        XTRot = 55;
    end
    %% properties(Access = protected)
    properties(SetAccess = private, GetAccess = public)
        
        DownUpSampling_ParaList = {'DownSampling';'UpSampling';};
        Fre_ParaList = {'Nmin(s)';'Nhour(s)';'Nday(s)';'Nweek(s)';...
            'Nmonth(s);Nquarter(s);Nyear(s);[�������ַ����벻���붼��]'};
        Market_ParaList = {'SHSZ'};
        HowMethod_ParaList = {'OHLC2OHLC';'OHLCVA2OHLCVA'; ...
            'OHLCVA';'OHLC'; ...
            'first';'last';'median';'max';'min';'sum';'prod'};
        
        FillMethod_ParaList = {'ffill';'bfill';'nan'};
        Closed_ParaList = {'right';'left'};
        Label_ParaList = {'right';'left'};
        DateFormat_ParaList = {'Datenum';'PureDouble'};
        
    end
    
    %% properties(Access = protected)
    properties(Access = protected)
        
    end
    
    %% properties(Access = private)
    properties(Access = private)
        
    end
    
    %% methods
    
    methods
        %% DataResampleClass()
        function obj = DataResampleClass( varargin )
            
        end
        
        %% Resample()
        function OutputData = Resample(obj,InputData, varargin )
            OutputData = [];
            % %===���������� ��ʼ===
            Flag = ParaCheck(obj);
            if 0 == Flag
                str = ['������������Ƿ���ȷ��'];
                disp(str)
                return;
            end
            
            % %===���������� ���===
            
            % % �������ݼ��
            [rL, cL] = size(InputData);
            if strcmpi(obj.HowMethod,'OHLCVA') && cL<4
                str = ['�����������ݣ���HowMethodΪ',obj.HowMethod,...
                    'ʱ������������Ҫ������4�У��ֱ�Ϊ����ʱ�䡢�۸񡢳ɽ������ɽ��'];
                disp(str);
                return;
            end
            if strcmpi(obj.HowMethod,'OHLCVA2OHLCVA') && cL<7
                str = ['�����������ݣ���HowMethodΪ',obj.HowMethod,...
                    'ʱ������������Ҫ������7�У��ֱ�Ϊ����ʱ�䡢�����ߡ��͡��ա��ɽ������ɽ��'];
                disp(str);
                return;
            end   
            if strcmpi(obj.HowMethod,'OHLC') && cL<2
                str = ['�����������ݣ���HowMethodΪ',obj.HowMethod,...
                    'ʱ������������Ҫ������2�У��ֱ�Ϊ����ʱ�䡢�۸�'];
                disp(str);
                return;
            end            
            if strcmpi(obj.HowMethod,'OHLC2OHLC') && cL<5
                str = ['�����������ݣ���HowMethodΪ',obj.HowMethod,...
                    'ʱ������������Ҫ������5�У��ֱ�Ϊ����ʱ�䡢�����ߡ��͡��գ�'];
                disp(str);
                return;
            end
            if ( strcmpi(obj.HowMethod,'first') || strcmpi(obj.HowMethod,'last') || ...
               strcmpi(obj.HowMethod,'median') || strcmpi(obj.HowMethod,'max') || ...
               strcmpi(obj.HowMethod,'min') || strcmpi(obj.HowMethod,'sum') || ...
               strcmpi(obj.HowMethod,'prod') ) && cL<2
                str = ['�����������ݣ���HowMethodΪ',obj.HowMethod,...
                    'ʱ������������Ҫ������2�У��ֱ�Ϊ����ʱ�䡢�۸�'];
                disp(str);
                return;
            end                 
            
            % % ������ȡ
            fYear = @(t_d)( floor(t_d/1e8) );
            fMonth = @(t_d)( floor(mod(t_d,1e8)/1e6) );
            fDay = @(t_d)( floor(mod(t_d,1e6)/1e4) );
            fHour = @(t_d)( floor(mod(t_d,1e4)/1e2) );
            fMinute = @(t_d)( floor(mod(t_d,1e2)/1e0) );
            fSecond = @(t_d)( floor(t_d*1e2-fix(t_d)*1e2) );
            
            fYMD = @(t_d)( floor(t_d/1e4) );
            fYM = @(t_d)( floor(t_d/1e6) );
            
            % ==������==
            if strcmpi(obj.DateFormatInput,'Datenum')
                Temp = str2num( datestr(InputData(:,1),'YYYYMMDD') )*1e4+str2num( datestr(InputData(:,1),'HHMM.SS') );
                InputData(:,1) = Temp;
               
                obj.DateFormatInput = 'PureDouble';
            end
            
            if strcmpi(obj.DateFormatInput,'PureDouble')
                DateTime = InputData(:,1);
                dYear = fYear(DateTime);
                dMonth = fMonth(DateTime);
                dDay = fDay(DateTime);
                dHour = fHour(DateTime);
                dMinute = fMinute(DateTime);
                dSecond = fSecond(DateTime);
                
                dYMD = fYMD(DateTime);
                dYM = fYM(DateTime);
                
                DaysUnique = unique(dYMD);
                DaysUniqueLen = length(DaysUnique);
                
                DateTime_DT = datetime(dYear,dMonth,dDay,dHour,dMinute,dSecond);
            end

            
            % % Ƶ����ȡ
            % 1min 5min
            % 1mins 5mins
            % 1hour 5hour
            % 1hours 5hours
            % 1day 5day
            % 1days 5days
            FreSelectFlag = 1;
            InputStrList = {'min';'mins';'hour';'hours';...
                'minute';'minutes';...
                'second';'seconds';...
                 'milliseconds';'milliseconds';};
            TL = length(InputStrList);
            interval = [];
            for i = 1:TL
                InputStr = InputStrList{i};
                if length(obj.Fre)>=length(InputStr) && ...
                        strcmpi(obj.Fre((end-length(InputStr)+1):end),InputStr)
                    FreNum = str2double(obj.Fre(1:end-length(InputStr)));
                    FreType = InputStr;
                    if FreType(end) ~= 's'
                        FreType = [FreType,'s'];
                    end
                    if strcmpi(FreType,'mins')
                        FreType = 'minutes';
                    end
                    Estr = ['interval = ',FreType,'(FreNum);'];
                    eval(Estr);
                    
                    FreSelectFlag = 1;
                    break;
                end
            end
            
            calendarInputStrList = {'day';'days';...
                'week';'weeks';...
                'month';'months';...
                'quarter';'quarters';...
                'year';'years';};
            TL = length(calendarInputStrList);
            if isempty(interval)
                for i = 1:TL
                    InputStr = calendarInputStrList{i};
                    if length(obj.Fre)>=length(InputStr) && strcmpi(obj.Fre((end-length(InputStr)+1):end),InputStr)
                        FreNum = str2double(obj.Fre(1:end-length(InputStr)));
                        FreType = InputStr;
                        if FreType(end) ~= 's'
                            FreType = ['cal',FreType,'s'];
                        end
                        
                        Estr = ['interval = ',FreType,'(FreNum);'];
                        eval(Estr);
                        
                        FreSelectFlag = 2;
                        break;
                    end
                end
            end
            
            if isempty(interval)
                str = ['���������Fre�����Ƿ���ȷ��'];
                disp(str)
                return;                
            end
            
            if strcmpi(obj.Market,'SHSZ') && strcmpi(obj.Label,'right')
                if 1 == FreSelectFlag
                    DTLabel = [];
                    for i = 1:DaysUniqueLen
                        Idx = find( dYMD == DaysUnique(i)  );
                        dYear_OneDay = dYear(Idx);
                        dMonth_OneDay = dMonth(Idx);
                        dDay_OneDay = dDay(Idx);
                        
                        ts_AM = datetime(dYear_OneDay(1),dMonth_OneDay(1),dDay_OneDay(1),9,30,0)+interval*(interval~=minutes(1));
                        te_AM = datetime(dYear_OneDay(1),dMonth_OneDay(1),dDay_OneDay(1),11,30,0);
                        T_AM = (ts_AM:interval:te_AM)';
                        
                        ts_PM = datetime(dYear_OneDay(1),dMonth_OneDay(1),dDay_OneDay(1),13,0,0)+interval*(interval~=minutes(1));
                        te_PM = datetime(dYear_OneDay(1),dMonth_OneDay(1),dDay_OneDay(1),15,0,0);
                        T_PM = (ts_PM:interval:te_PM)';
                        
                        T = [T_AM; T_PM];
                        
                        DTLabel = [DTLabel;T];
                    end
                end
                
                % % 
                if 2 == FreSelectFlag
                    
                    if DaysUniqueLen>1
                        
                        if strcmpi(FreType,'caldays')
                            if 1 == FreNum
                                ts = datetime(dYear(1),dMonth(1),dDay(1),15,0,0);
                            else
                                ts = datetime(dYear(1),dMonth(1),dDay(1),15,0,0)+interval;
                            end
                            te = datetime(dYear(end),dMonth(end),dDay(end),15,0,0);
                            T = (ts:interval:te)';   
                        end
                        
                        if strcmpi(FreType,'calyears')
                            
                            dYearUnique = unique(dYear);
                            Idx = find( dYear == dYearUnique(1),1,'last' );
                            
                            ts = datetime(dYear(1),dMonth(Idx),dDay(Idx),15,0,0)+calyears(FreNum-1);
                            
                            te = datetime(dYear(end),dMonth(end),dDay(end),15,0,0);
                            T = (ts:interval:te)';   
                            if T(end) ~= te;
                                T = [T;te];
                            end                            
                            
                        end
                        
                        if strcmpi(FreType,'calquarters')
                            tQ = [3,6,9,12];
                            tM = dMonth(1);
                            Idx = find( tM<=tQ,1,'first' );
                            Mtemp = tQ(Idx);
                            Idx = find( dMonth<=Mtemp,1,'last' );
                            
                            ts = datetime(dYear(1),dMonth(Idx),dDay(Idx),15,0,0)+calquarters(FreNum-1);
                            
                            te = datetime(dYear(end),dMonth(end),dDay(end),15,0,0);
                            T = (ts:interval:te)';   
                            if T(end) ~= te;
                                T = [T;te];
                            end                            
                        end                        
                          
                        if strcmpi(FreType,'calmonths')
                            YMUnique = unique(dYM);
                            YMUniqueLen = length(YMUnique);
                            
                            Idx = [];
                            for i = (1+FreNum-1):FreNum:YMUniqueLen
                                tInd = find( dYM==YMUnique(i),1,'last' );
                                Idx = [Idx;tInd];
                            end
                            if Idx(end) ~= length(dYM)
                                Idx = [Idx; YMUniqueLen];
                            end
                            
                            T = DateTime(Idx,:);
                            
                            T = datetime(fYear(T),fMonth(T),fDay(T),fHour(T),fMinute(T),fSecond(T));
                        end                           
                        
                        if strcmpi(FreType,'calweeks')
                            
                            tL = length(DateTime_DT);
                            for i = 1:tL
                                D = DateTime_DT(i);
                                [DayNumber,DayName] = weekday(D);
                                % Find Friday
                                if 6 == DayNumber
                                    Idx = i;
                                    break;
                                end
                            end
                            
                            ts = datetime(dYear(1),dMonth(Idx),dDay(Idx),15,0,0)+calweeks(FreNum-1);
                            
                            te = datetime(dYear(end),dMonth(end),dDay(end),15,0,0);
                            T = (ts:interval:te)';   
                            if T(end) ~= te;
                                T = [T;te];
                            end                            
                        end                        
                        
                    else
                        ts = datetime(dYear(1),dMonth(1),dDay(1),15,0,0);
                        te = datetime(dYear(end),dMonth(end),dDay(end),15,0,0);
                        T = (ts:interval:te)';                        
                    end
                    DTLabel = T;
                end
            end
            % ==������==
            if strcmpi(obj.Market,'SHSZ') && strcmpi(obj.Label,'left')
                
                
                
                
            end            

            % % 
            YYYYMMDDHHMM = @(T)(1e8*year(T) + 1e6*month(T) + 1e4*day(T)...
                +1e2*hour(T) + minute(T));
            if isnumeric(DTLabel)
                Dlabel = DTLabel;  
            else
                Dlabel = YYYYMMDDHHMM(DTLabel);
            end
            
            % % �����ʼ��
            rLTemp = size(DTLabel,1);
            if strcmpi(obj.HowMethod,'OHLCVA') || strcmpi(obj.HowMethod,'OHLCVA2OHLCVA')   
                OutputData = zeros(rLTemp, 7);
            end
            if strcmpi(obj.HowMethod,'OHLC') || strcmpi(obj.HowMethod,'OHLC2OHLC')   
                OutputData = zeros(rLTemp, 5);
            end     
            if strcmpi(obj.HowMethod,'first') || strcmpi(obj.HowMethod,'last') || ...
               strcmpi(obj.HowMethod,'median') || strcmpi(obj.HowMethod,'max') || ...
               strcmpi(obj.HowMethod,'min') || strcmpi(obj.HowMethod,'sum') || ...
               strcmpi(obj.HowMethod,'prod')
                OutputData = zeros(rLTemp, 2);
            end     
            
            if strcmpi(obj.DateFormatOutput,'PureDouble')
                OutputData(:,1) = Dlabel;
            end
            % % 
            if strcmpi(obj.DateFormatOutput,'Datenum')
                Dnum = datenum(DTLabel.Year,DTLabel.Month,DTLabel.Day,...
                    DTLabel.Hour,DTLabel.Minute,DTLabel.Second);
                OutputData(:,1) = Dnum;
            end            
            
            
            % % DownSampling
            if strcmpi(obj.DownUpSampling,'DownSampling')
                % DateTime_DT
                % DTLabel
                Len = length(DTLabel);
                
                if strcmpi(obj.HowMethod,'OHLCVA')
                    for i = 1:Len
                        if i == 1
                            CheckTemp = DateTime_DT<=DTLabel(i);
                            Idx = find(CheckTemp==1,1,'last');
                            if ~isempty(Idx)
                                Open = InputData(1,2);
                                High = max(InputData(1:Idx,2));
                                Low = min(InputData(1:Idx,2));
                                Close = InputData(Idx,2);
                                Vol = sum(InputData(1:Idx,3));
                                Amt = sum(InputData(1:Idx,4));                          
                                
                            else
                                Open = NaN;
                                High = NaN;
                                Low = NaN;
                                Close = NaN;
                                Vol = NaN;
                                Amt = NaN;
                                
                            end
                            
                            OutputData(i,2:end) = [Open High Low Close Vol Amt];
                        else
                            
                            if strcmpi(obj.Closed,'right')
                                
                                % ����15��֮��15:00:16��֮���ʱ����ʱ��Ҳ��������
                                % ����һ��ʱ���΢СУ��
                                TimeAdjEps = seconds(45);
                                CheckTemp = (DateTime_DT>DTLabel(i-1)+TimeAdjEps).*(DateTime_DT<=DTLabel(i)+TimeAdjEps);
                                IdxS = find(CheckTemp==1,1,'first');
                                IdxE = find(CheckTemp==1,1,'last');
                                if ~isempty(IdxS) && ~isempty(IdxE)
                                    Open = InputData(IdxS,2);
                                    High = max(InputData(IdxS:IdxE,2));
                                    Low = min(InputData(IdxS:IdxE,2));
                                    Close = InputData(IdxE,2);
                                    Vol = sum(InputData(IdxS:IdxE,3));
                                    Amt = sum(InputData(IdxS:IdxE,4));
                                    
                                else
                                    if strcmpi(obj.FillMethod,'nan')
                                        Open = NaN;
                                        High = NaN;
                                        Low = NaN;
                                        Close = NaN;
                                        Vol = NaN;
                                        Amt = NaN;
                                    end
                                    if strcmpi(obj.FillMethod,'ffill')
                                        Open = OutputData(i-1,2);
                                        High = OutputData(i-1,3);
                                        Low = OutputData(i-1,4);
                                        Close = OutputData(i-1,5);
                                        Vol = OutputData(i-1,6);
                                        Amt = OutputData(i-1,7);
                                    end     
                                    % ==������==
                                    if strcmpi(obj.FillMethod,'bfill')
                                    
                                    end
                                    
                                end
                                
                                OutputData(i,2:end) = [Open High Low Close Vol Amt];
                                
                            end
                            % ==������==
                            if strcmpi(obj.Closed,'left')
                                
                                
                                
                            end
                            
                        end

                    end
                    
                    if obj.isPlot ~= 0
                        scrsz = get(0,'ScreenSize');
                        figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
                        
                        subplot(211);
                        plot(InputData(:,2));
                        xlim([0 length(InputData)+1]);
                        LabelSet(gca, InputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);
                        str = ['ԭʼ����'];
                        title(str,'FontWeight','Bold');
                        
                        subplot(212);
                        OHLC = OutputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(OutputData)+1]);
                        LabelSet(gca, OutputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);                        
                        str = ['�ز�����-',obj.Fre];
                        title(str,'FontWeight','Bold');                        
                    end
                end
                
                % ==������==
                if strcmpi(obj.HowMethod,'OHLC')
                    for i = 1:Len
                        if i == 1
                            CheckTemp = DateTime_DT<=DTLabel(i);
                            Idx = find(CheckTemp==1,1,'last');
                            if ~isempty(Idx)
                                Open = InputData(1,2);
                                High = max(InputData(1:Idx,2));
                                Low = min(InputData(1:Idx,2));
                                Close = InputData(Idx,2);                        
                                
                            else
                                Open = NaN;
                                High = NaN;
                                Low = NaN;
                                Close = NaN;
                                
                            end
                            
                            OutputData(i,2:end) = [Open High Low Close];
                        else
                            
                            if strcmpi(obj.Closed,'right')
                                CheckTemp = (DateTime_DT>DTLabel(i-1)).*(DateTime_DT<=DTLabel(i));
                                IdxS = find(CheckTemp==1,1,'first');
                                IdxE = find(CheckTemp==1,1,'last');
                                if ~isempty(IdxS) && ~isempty(IdxE)
                                    Open = InputData(IdxS,2);
                                    High = max(InputData(IdxS:IdxE,2));
                                    Low = min(InputData(IdxS:IdxE,2));
                                    Close = InputData(IdxE,2);
                                    
                                else
                                    if strcmpi(obj.FillMethod,'nan')
                                        Open = NaN;
                                        High = NaN;
                                        Low = NaN;
                                        Close = NaN;
                                    end
                                    if strcmpi(obj.FillMethod,'ffill')
                                        Open = OutputData(i-1,2);
                                        High = OutputData(i-1,3);
                                        Low = OutputData(i-1,4);
                                        Close = OutputData(i-1,5);
                                    end     
                                    % ==������==
                                    if strcmpi(obj.FillMethod,'bfill')
                                    
                                    end
                                    
                                end
                                
                                OutputData(i,2:end) = [Open High Low Close];
                                
                            end
                            % ==������==
                            if strcmpi(obj.Closed,'left')
                                
                                
                                
                            end
                            
                        end

                    end
                    
                    if obj.isPlot ~= 0
                        scrsz = get(0,'ScreenSize');
                        figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
                        
                        subplot(211);
                        plot(InputData(:,2));
                        xlim([0 length(InputData)+1]);
                        LabelSet(gca, InputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);
                        str = ['ԭʼ����'];
                        title(str,'FontWeight','Bold');
                        
                        subplot(212);
                        OHLC = OutputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(OutputData)+1]);
                        LabelSet(gca, OutputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);                        
                        str = ['�ز�����-',obj.Fre];
                        title(str,'FontWeight','Bold');                        
                    end
                end     
                
                % ==������==
                if strcmpi(obj.HowMethod,'OHLCVA2OHLCVA')
                    for i = 1:Len
                        if i == 1
                            CheckTemp = DateTime_DT<=DTLabel(i);
                            Idx = find(CheckTemp==1,1,'last');
                            if ~isempty(Idx)
                                Open = InputData(1,2);
                                High = max(InputData(1:Idx,3));
                                Low = min(InputData(1:Idx,4));
                                Close = InputData(Idx,5);
                                Vol = sum(InputData(1:Idx,6));
                                Amt = sum(InputData(1:Idx,7));                          
                                
                            else
                                Open = NaN;
                                High = NaN;
                                Low = NaN;
                                Close = NaN;
                                Vol = NaN;
                                Amt = NaN;
                                
                            end
                            
                            OutputData(i,2:end) = [Open High Low Close Vol Amt];
                        else
                            
                            if strcmpi(obj.Closed,'right')
                                CheckTemp = (DateTime_DT>DTLabel(i-1)).*(DateTime_DT<=DTLabel(i));
                                IdxS = find(CheckTemp==1,1,'first');
                                IdxE = find(CheckTemp==1,1,'last');
                                if ~isempty(IdxS) && ~isempty(IdxE)
                                    Open = InputData(IdxS,2);
                                    High = max(InputData(IdxS:IdxE,3));
                                    Low = min(InputData(IdxS:IdxE,4));
                                    Close = InputData(IdxE,5);
                                    Vol = sum(InputData(IdxS:IdxE,6));
                                    Amt = sum(InputData(IdxS:IdxE,7));
                                    
                                else
                                    if strcmpi(obj.FillMethod,'nan')
                                        Open = NaN;
                                        High = NaN;
                                        Low = NaN;
                                        Close = NaN;
                                        Vol = NaN;
                                        Amt = NaN;
                                    end
                                    if strcmpi(obj.FillMethod,'ffill')
                                        Open = OutputData(i-1,2);
                                        High = OutputData(i-1,3);
                                        Low = OutputData(i-1,4);
                                        Close = OutputData(i-1,5);
                                        Vol = OutputData(i-1,6);
                                        Amt = OutputData(i-1,7);
                                    end     
                                    % ==������==
                                    if strcmpi(obj.FillMethod,'bfill')
                                    
                                    end
                                    
                                end
                                
                                OutputData(i,2:end) = [Open High Low Close Vol Amt];
                                
                            end
                            % ==������==
                            if strcmpi(obj.Closed,'left')
                                
                                
                                
                            end
                            
                        end

                    end                    
                    
                    if obj.isPlot ~= 0
                        scrsz = get(0,'ScreenSize');
                        figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
                        
                        subplot(211);
                        OHLC = InputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(InputData)+1]);
                        LabelSet(gca, InputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);
                        str = ['ԭʼ����'];
                        title(str,'FontWeight','Bold');
                        
                        subplot(212);
                        OHLC = OutputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(OutputData)+1]);
                        LabelSet(gca, OutputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);                        
                        str = ['�ز�����-',obj.Fre];
                        title(str,'FontWeight','Bold');                        
                    end
                end                 
                
                % ==������==
                if strcmpi(obj.HowMethod,'OHLC2OHLC')
                    for i = 1:Len
                        if i == 1
                            CheckTemp = DateTime_DT<=DTLabel(i);
                            Idx = find(CheckTemp==1,1,'last');
                            if ~isempty(Idx)
                                Open = InputData(1,2);
                                High = max(InputData(1:Idx,3));
                                Low = min(InputData(1:Idx,4));
                                Close = InputData(Idx,5);
                            else
                                Open = NaN;
                                High = NaN;
                                Low = NaN;
                                Close = NaN;                             
                            end
                            
                            OutputData(i,2:end) = [Open High Low Close];
                        else
                            
                            if strcmpi(obj.Closed,'right')
                                CheckTemp = (DateTime_DT>DTLabel(i-1)).*(DateTime_DT<=DTLabel(i));
                                IdxS = find(CheckTemp==1,1,'first');
                                IdxE = find(CheckTemp==1,1,'last');
                                if ~isempty(IdxS) && ~isempty(IdxE)
                                    Open = InputData(IdxS,2);
                                    High = max(InputData(IdxS:IdxE,3));
                                    Low = min(InputData(IdxS:IdxE,4));
                                    Close = InputData(IdxE,5);
                                else
                                    if strcmpi(obj.FillMethod,'nan')
                                        Open = NaN;
                                        High = NaN;
                                        Low = NaN;
                                        Close = NaN;
                                    end
                                    if strcmpi(obj.FillMethod,'ffill')
                                        Open = OutputData(i-1,2);
                                        High = OutputData(i-1,3);
                                        Low = OutputData(i-1,4);
                                        Close = OutputData(i-1,5);
                                    end     
                                    % ==������==
                                    if strcmpi(obj.FillMethod,'bfill')
                                    
                                    end
                                    
                                end
                                
                                OutputData(i,2:end) = [Open High Low Close];
                                
                            end
                            % ==������==
                            if strcmpi(obj.Closed,'left')
                                
                                
                                
                            end
                            
                        end

                    end                    
                    
                    if obj.isPlot ~= 0
                        scrsz = get(0,'ScreenSize');
                        figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
                        
                        subplot(211);
                        OHLC = InputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(InputData)+1]);
                        LabelSet(gca, InputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);
                        str = ['ԭʼ����'];
                        title(str,'FontWeight','Bold');
                        
                        subplot(212);
                        OHLC = OutputData(:,2:5);
                        KplotNew(OHLC);
                        xlim([0 length(OutputData)+1]);
                        LabelSet(gca, OutputData(:,1), [], [],obj.LabelSetStyle,obj.XTRot);                        
                        str = ['�ز�����-',obj.Fre];
                        title(str,'FontWeight','Bold');                        
                    end
                end                 
                
            
            end
            
            % % UpSampling-�����ƣ�
            if strcmpi(obj.DownUpSampling,'UpSampling')
                
            
            end    
            
            
            
            
            
        end
        
        
        %% ���������麯��
        function Flag = ParaCheck(obj, varargin )
            Flag = 1;
            
            % %===���������� ��ʼ===
            checkflag = ismember( lower(obj.DownUpSampling),lower(obj.DownUpSampling_ParaList) );
            if checkflag ~= 1
                str = ['DownUpSampling��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.DownUpSampling_ParaList
                Flag = 0;
                return;
            end
            
            checkflag = ismember( lower(obj.HowMethod),lower(obj.HowMethod_ParaList) );
            if checkflag ~= 1
                str = ['HowMethod��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.HowMethod_ParaList
                Flag = 0;
                return;
            end    
            
            checkflag = ismember( lower(obj.FillMethod),lower(obj.FillMethod_ParaList) );
            if checkflag ~= 1
                str = ['FillMethod��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.FillMethod_ParaList
                Flag = 0;
                return;
            end    
            
            checkflag = ismember( lower(obj.Closed),lower(obj.Closed_ParaList) );
            if checkflag ~= 1
                str = ['Closed��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.Closed_ParaList
                Flag = 0;
                return;
            end   
            
            checkflag = ismember( lower(obj.Label),lower(obj.Label_ParaList) );
            if checkflag ~= 1
                str = ['Label��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.Label_ParaList
                Flag = 0;
                return;
            end      
            
            checkflag = ismember( lower(obj.DateFormatInput),lower(obj.DateFormat_ParaList) );
            if checkflag ~= 1
                str = ['DateFormatInput��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.DateFormat_ParaList
                Flag = 0;
                return;
            end   
            
            checkflag = ismember( lower(obj.DateFormatOutput),lower(obj.DateFormat_ParaList) );
            if checkflag ~= 1
                str = ['DateFormatOutput��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
                disp(str);
                ParaList = obj.DateFormat_ParaList
                Flag = 0;
                return;
            end              
            
            
             % %===���������� ���===
        end    
        
        
        
        
        
    end
    
end
