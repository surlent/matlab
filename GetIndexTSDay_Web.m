function [Data,InitialDate] = GetIndexTSDay_Web(StockCode,BeginDate,EndDate,GetInitialDateFlag)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
% Input:
% StockCode:�ַ������ͣ���ʾ֤ȯ���룬��sh000001
% BeginDate:�ַ������ͣ���ʾϣ����ȡ��Ʊ��������ʱ�εĿ�ʼ���ڣ���20140101
% EndDate:�ַ������ͣ���ʾϣ����ȡ��Ʊ��������ʱ�εĽ������ڣ���20150101
% Output:
% Data: ���� �� �� �� �� ��(��) ��(Ԫ)

% ��ȡ������ʹ�õ�URL
% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/000001/type/S.phtml?year=1990&jidu=4
% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/000300/type/S.phtml?year=2014&jidu=4
%% �������Ԥ����
if nargin < 4 || isempty(GetInitialDateFlag)
    GetInitialDateFlag = 0;
end
if nargin < 3 || isempty(EndDate)
    EndDate = '20150101';
end
if nargin < 2 || isempty(BeginDate)
    BeginDate = '20140101';
end
if nargin < 1 || isempty(StockCode)
    StockCode = 'sh000001';
end

% ����Ԥ����Ŀ�����demo '000001'
if strcmpi(StockCode(1),'s')
    StockCode = StockCode(3:end);
end
if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
    StockCode = StockCode(1:end-2);
end

% ����ʱ��Ԥ����Ŀ����ʽ '20140101'
BeginDate(BeginDate == '-') = [];
EndDate(EndDate == '-') = [];

Data = [];
InitialDate = '19900101';

charset = 'gb2312';
%% ��ȡ��ʼ����
if 1 == GetInitialDateFlag
    URL = ...
        ['http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/' ...
        StockCode '/type/S.phtml?year=2014&jidu=4'];
    
    if verLessThan('matlab', '8.3')
        [URLchar, status] = urlread_General(URL, 'Charset', charset, 'TimeOut', 60);
    else
        [URLchar, status] = urlread(URL, 'Charset', charset, 'TimeOut', 60);
    end
    if status == 0
        str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
        disp(str);
        return;
    end
    
    URLString = java.lang.String(URLchar);
    
    expr = ['<select name="year">','.*?', ...
        '</select>'];
    Content = regexpi(URLchar, expr,'match');
    if ~isempty( Content )
        Content = Content{1};
        expr = ['<option value=','.*?', ...
            '</option>'];
        tContent = regexpi(Content, expr,'match');
        if ~isempty( tContent )
            tContent = tContent{length(tContent)};
            expr = ['>','.*?', ...
                '<'];
            tC = regexpi(tContent, expr,'match');
            tC = tC{1};
            temp = tC(2:length(tC)-1);
            InitialDate = [temp,'0101'];
        end
    end
end
%% Get Data

% http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/000300/type/S.phtml?year=2014&jidu=4

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
DTemp = cell(Len,7);
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
            ['http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/' ...
            StockCode '/type/S.phtml?year=' num2str(i) '&jidu=' num2str(j)];
        
        [~,TableCell] = GetTableFromWeb(URL);
        
        if iscell( TableCell ) && ~isempty(TableCell) && size(TableCell,1)>4
            TableInd = 5;
            FIndCell = TableCell{TableInd};
        else
            FIndCell = [];
        end
        
        % ���� �� �� �� �� �� ��
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
% ���������л������ԭ��DTempΪ��
if isempty(DTemp)
    return;
end
% ���� �� �� �� �� �� ��
% ������
% ���� �� �� �� �� �� ��
Low = DTemp(:,5);
Close = DTemp(:,4);
DTemp = [ DTemp(:,1:3),Low,Close,DTemp(:,6:end) ];

sTemp = cell2mat(DTemp(:,1));
sTemp = datestr( datenum(sTemp,'yyyy-mm-dd'),'yyyymmdd' );
Date = str2num( sTemp );

Temp = DTemp(:,2:end);
Data = cellfun(@str2double,Temp);

DTemp = [Date, Data];

% BeginDate,EndDate
sDate = str2double(BeginDate);
eDate = str2double(EndDate);

[~,sInd] = min( abs(DTemp(:,1)-sDate) );
[~,eInd] = min( abs(DTemp(:,1)-eDate) );

Data = DTemp(sInd:eInd,:);
