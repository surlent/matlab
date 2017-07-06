function [StockDataDouble,adjfactor] = GetStockTSDay_Web(StockCode,BeginDate,EndDate)
% Input:
% StockCode:�ַ������ͣ���ʾ֤ȯ���룬��sh600000
% BeginDate:�ַ������ͣ���ʾϣ����ȡ��Ʊ��������ʱ�εĿ�ʼ���ڣ���20140101
% EndDate:�ַ������ͣ���ʾϣ����ȡ��Ʊ��������ʱ�εĽ������ڣ���20150101
% Output:
% StockDataDouble: ���� �� �� �� �� ��(��) ��(Ԫ) ��Ȩ���ӣ���Ȩ���ӣ�
% ǰ��Ȩ���� ���� ��Ȩ���� �ĵ�������
% �ǵ�����Ȩ��ʽ
% ��Ȩ�۸� = ���׼�*��Ȩ����
% ǰ��Ȩ�۸� = ���׼�/ǰ��Ȩ����

% ��ȡ������ʹ�õ�URL
% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/000562.phtml?year=1994&jidu=1
% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_FuQuanMarketHistory/stockid/000562.phtml?year=1995&jidu=4
% http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=sz000562&end_date=20150101&begin_date=19940101
%% URLѡ���趨

URLflag = 2;

% 1 ʹ������URL��ȡ���ݣ������ֻ�ܻ�ȡ��20000101֮������ݣ����޷���ȡ�ɽ���͸�Ȩ���ӣ���������ȱʧ
% http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=sz000562&end_date=20150101&begin_date=19940101
% 2 ʹ������URL��ȡ���ݣ����Ի�ȡ�������տ�ʼ���������ݺ͸�Ȩ���� 19900101 ��������Ҳ��ȱʧ 
% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_FuQuanMarketHistory/stockid/000562.phtml?year=1995&jidu=4
% ���Ƶ������������˵�����Դ�����в�������ȱʧ
%% �������Ԥ����
if nargin < 3 || isempty(EndDate)
    EndDate = '20150101';
end
if nargin < 2 || isempty(BeginDate)
    BeginDate = '20100101';
end
if nargin < 1 || isempty(StockCode)
    StockCode = 'sh600588';
end

% ��Ʊ����Ԥ����Ŀ�����demo 'sh600588'
if 1 == URLflag
    if StockCode(1,1) == '6'
        StockCode = ['sh',StockCode];
    end
    if StockCode(1,1) == '0'|| StockCode(1,1) == '3'
        StockCode = ['sz',StockCode];
    end
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'
if 2 == URLflag
    StockCode(StockCode=='.') = [];
    if strcmpi(StockCode(1),'s')
        StockCode = StockCode(3:end);
    end
    if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
        StockCode = StockCode(1:end-2);
    end
end

% ��������Ԥ����
if ~ischar( BeginDate )
    BeginDate = num2str(BeginDate);
end
BeginDate(BeginDate == '-') = [];
if ~ischar( EndDate )
    EndDate = num2str(EndDate);
end
EndDate(EndDate == '-') = [];

StockDataDouble = [];
adjfactor = [];

%% URLflag = 2
if 2 == URLflag
    % % http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_FuQuanMarketHistory/stockid/000562.phtml?year=1995&jidu=4
    
    sYear = str2double(BeginDate(1:4));
    eYear = str2double(EndDate(1:4));
    sM = str2double(BeginDate(5:6));
    eM = str2double(EndDate(5:6));
    for i = 1:4
        if sM>=3*i-2 && sM<=3*i
            sJiDu = i;
        end
        if eM>=3*i-2 && eM<=3*i
            eJiDu = i;
        end
    end

    Len = (eYear-sYear)*240+250;
    DTemp = cell(Len,8);
    rLen = 1;
    for i = sYear:eYear
        for j = 1:4
%             YearDemo = i
%             JiDuDemo = j
            if i == sYear && j < sJiDu
                continue;
            end
            if i == eYear && j > eJiDu
                continue;
            end           
%             YearDemo = i
%             JiDuDemo = j            
            
            URL = ...
                ['http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_FuQuanMarketHistory/stockid/' ...
                StockCode '.phtml?year=' num2str(i) '&jidu=' num2str(j)];

            [~,TableCell] = GetTableFromWeb(URL);
            
            if iscell( TableCell ) && ~isempty(TableCell)
                TableInd = 20;
                FIndCell = TableCell{TableInd};
            else
                FIndCell = [];
            end

            % ���� �� �� �� �� �� �� ��Ȩ����
            FIndCell = FIndCell(3:end,:);
            FIndCell = FIndCell(end:(-1):1,:);
            
            if ~isempty(FIndCell)
                LenTemp = size(FIndCell,1);
                
                DTemp(rLen:(rLen+LenTemp-1),:) = FIndCell;
                rLen = rLen+LenTemp;
            end
        end
    end
    DTemp(rLen:end,:) = [];
    % �����¹ɸ����л������ԭ��DTempΪ��
    if isempty(DTemp)
        disp('����Ϊ��')
        return;
    end
    % ���� �� �� �� �� �� �� ��Ȩ����
    % ������
    % ���� �� �� �� �� �� �� ��Ȩ����
    Low = DTemp(:,5);
    Close = DTemp(:,4);
    DTemp = [ DTemp(:,1:3),Low,Close,DTemp(:,6:end) ];
    
    sTemp = cell2mat(DTemp(:,1));
    sTemp = datestr( datenum(sTemp,'yyyy-mm-dd'),'yyyymmdd' );
    Date = str2num( sTemp );
    
    Temp = DTemp(:,2:end);
    Data = cellfun(@str2double,Temp);
    
    % �ɺ�Ȩ���ݷ������� ��Ȩ��Ϣ����
    for i = 1:4
        Data(:,i) = Data(:,i)./Data(:,7);
    end
    Data(:,1:4) = round( Data(:,1:4)*100 )/100;
    
    DTemp = [Date, Data];
    
    % BeginDate,EndDate
    sDate = str2double(BeginDate);
    eDate = str2double(EndDate);
    
    [~,sInd] = min( abs(DTemp(:,1)-sDate) );
    [~,eInd] = min( abs(DTemp(:,1)-eDate) );
    
    StockDataDouble = DTemp(sInd:eInd,:);
    adjfactor = StockDataDouble(:,end);
end
%% URLflag = 1
if 1 == URLflag
    URL=['http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=' StockCode '&end_date=' EndDate '&begin_date=' BeginDate];
    
    [URLchar, status] = urlread(URL,'TimeOut', 60);
    if status == 0
        str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
        disp(str);
        return;
    end
    URLString = java.lang.String(URLchar);
    
    expr = ['<content d=','.*?',...
        'bl="" />'];
    [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = regexpi(URLchar, expr);
    Len = numel(matchstring);
    StockDataDouble = zeros(Len,6);
    
    for i = 1:Len
        strtemp = matchstring{i};
        
        [sind, eind] = regexpi(strtemp, 'd=.*? o');
        temp = strtemp(sind+3:eind-3);
        temp = temp([1:4,6:7,9:10]);
        StockDataDouble(i,1) = str2num(temp);
        
        [sind, eind] = regexpi(strtemp, 'o=.*? h');
        temp = strtemp(sind+3:eind-3);
        StockDataDouble(i,2) = str2num(temp);
        
        [sind, eind] = regexpi(strtemp, 'h=.*? c');
        temp = strtemp(sind+3:eind-3);
        StockDataDouble(i,3) = str2num(temp);
        
        [sind, eind] = regexpi(strtemp, 'l=.*? v');
        temp = strtemp(sind+3:eind-3);
        StockDataDouble(i,4) = str2num(temp);
        
        [sind, eind] = regexpi(strtemp, 'c=.*? l');
        temp = strtemp(sind+3:eind-3);
        StockDataDouble(i,5) = str2num(temp);
        
        [sind, eind] = regexpi(strtemp, 'v=.*? b');
        temp = strtemp(sind+3:eind-3);
        StockDataDouble(i,6) = str2num(temp);
    end
end