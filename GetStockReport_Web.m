function [ReportList] = GetStockReport_Web(StockCode, varargin)
% [ReportList] = GetStockReport_Web(StockCode, 'PropertyName',PropertyValue, ...)
% [ReportList] = GetStockReport_Web(StockCode, 'BeginDate',BeginDate,'EndDate',EndDate)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/02/11
% % % !!! δȫ����ɣ�����
% Example:
%{
StockCode = '600588';
BeginDate = '20140101';
EndDate = '20150101';
[ReportList] = GetStockReport_Web(StockCode, 'BeginDate',BeginDate,'EndDate',EndDate);
%}
%% Para Parse
ReportList = [];

p = inputParser;

vFcn = @(x)( ischar(x) && ~isempty(x) );
p.addRequired('StockCode',vFcn);

DV = datestr(today-20,'yyyy-mm-dd');
vFcn = @(x)( ischar(x) || isnumeric(x) );
p.addParameter('BeginDate',DV,vFcn);

DV = datestr(today,'yyyy-mm-dd');
vFcn = @(x)( ischar(x) || isnumeric(x) );
p.addParameter('EndDate',DV,vFcn);

p.parse(StockCode, varargin{:});

Para = p.Results;
StockCode = Para.StockCode;
BeginDate = Para.BeginDate;
EndDate = Para.EndDate;

% ��Ʊ����Ŀ����ʽ��'600588'
if StockCode(1) == 's'
    StockCode = StockCode(3:end);
end
if StockCode(end) == 'h' || StockCode(end) == 'z'
    StockCode = StockCode(1:end-2);
end

% ����Ŀ����ʽ��'2015-01-01'
if isempty(BeginDate)
    BeginDate = datestr(today-20,'yyyy-mm-dd');
end
if isempty(EndDate)
    EndDate = datestr(today,'yyyy-mm-dd');
end
if ~ischar( BeginDate )
    BeginDate = num2str(BeginDate);
end
if ~ischar( EndDate )
    EndDate = num2str(EndDate);
end
if isempty(find( BeginDate=='-',1 ))
    BeginDate = [BeginDate(1:4),'-',BeginDate(5:6),'-',BeginDate(7:8)];
end
if isempty(find( EndDate=='-',1 ))
    EndDate = [EndDate(1:4),'-',EndDate(5:6),'-',EndDate(7:8)];
end
%% GetURLList
%{
http://www.microbell.com/superareport.asp?
report=0&doctype=Company_Code&doctime1=2014-01-01&doctime2=2015-01-01&dockey=600588 &x=39&y=7

&paget=2&from=
%}

StopFlag = 0;
URLList = [];
tLen = 1;

PageNum = 1;
while 0 == StopFlag
    
    URL = ['http://www.microbell.com/superareport.asp?' ...
        'report=0&doctype=Company_Code&doctime1=',BeginDate,'&doctime2=',EndDate,'&dockey=',StockCode, ...
        '&paget=',num2str(PageNum),'&from='];
    PageNum = PageNum + 1;
    UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0';
    TimeOut = 60;
    Charset = 'gb2312';
    [URLchar,status] = urlread(URL,'UserAgent',UserAgent,'TimeOut',TimeOut,'Charset',Charset);
    
    if status == 0
        str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
        disp(str);
        URLchar = [];
        StopFlag = 1;
        continue;
    end
    
    % URLString = java.lang.String(URLchar);
    expr = ['�������ҳ����Χ���뷵�أ�'];
    MatchStr = regexpi(URLchar, expr,'match');
    if ~isempty(MatchStr)
        %         str = [StockCode,'�������ҳ����Χ���뷵�أ�'];
        %         disp(str);
        StopFlag = 1;
        continue;
    end
    
    expr = ['<a href="docdetail','.*?', ...
        '>'];
    MatchStr = regexpi(URLchar, expr,'match');
    if isempty(MatchStr)
        str = [StockCode,'��ָ��ʱ�䷶Χ��������б��������������'];
        disp(str);
        StopFlag = 1;
        continue;
    end
    
    Len = numel(MatchStr);
    for i = 1:Len
        tStr = MatchStr{i};
        
        expr = ['docdetail_','.*?', ...
            '.html'];
        tMatchStr = regexpi(tStr, expr,'match');
        URLList{tLen,1} = ['http://www.microbell.com/',tMatchStr{1}];
        
        expr = ['title="','.*?', ...
            '">'];
        sLen = length('title="');
        eLen = length('">');
        tMatchStr = regexpi(tStr, expr,'match');
        URLList{tLen,2} = tMatchStr{1}(sLen+1:end-eLen);
        
        tLen = tLen + 1;
    end
    
end


%% Detail Parse

% tReportList = [];
if ~isempty(URLList)
    Len = size(URLList, 1);
    for i = 1:Len
        
        URL = URLList{i,1};
        Title = URLList{i,2};
        
        Detail = GetReportDetail_Web( URL,Title );
        
        if ~isempty( Detail )
            tReportList(i,:) = Detail; 
        end
    end
    
    if exist('tReportList','var')
        Head = {'�ϴ�ʱ��','��Ʊ����','��Ʊ����','�������','�Ƽ�����','�б�����','��������','�б�����','�б�ժҪ','�б���С' ...
            '�б�ҳ��','�б�����'};
        tReportList = tReportList(end:(-1):1,:);
        ReportList = [Head; tReportList];
    end
end
%% sub func-GetReportDetail_Web
function Detail = GetReportDetail_Web( URL,Title )
Detail = [];

UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0';
TimeOut = 60;
Charset = 'gb2312';
[URLchar,status] = urlread(URL,'UserAgent',UserAgent,'TimeOut',TimeOut,'Charset',Charset);
% URLString = java.lang.String(URLchar);
if status == 0
    str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
    disp(str);
    URLchar = [];
    return;
end

Tind = 1;
% Head = {'�ϴ�ʱ��','��Ʊ����','��Ʊ����','�������','�Ƽ�����','�б�����','��������','�б�����','�б�ժҪ','�б���С' ...
%    '�б�ҳ��','�б�����'};
% �ϴ�ʱ��
expr = ['�ϴ�ʱ�䣺\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['>','.*?', ...
        '<'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    temp = temp(2:end-1);
    temp = str2double( datestr( datenum(temp,'yyyy-mm-dd HH:MM:SS'),'yyyymmddHHMMSS' ) );
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1; 

% ��Ʊ����
expr = ['��Ʊ���룺\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['>','\d+', ...
        '<'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    temp = temp(2:end-1);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% ��Ʊ����
expr = ['��Ʊ���ƣ�\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['">','.*?', ...
        '</a>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('</a>');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �������
Detail{1, Tind} = Title;
Tind = Tind + 1;

% �Ƽ�����
expr = ['�Ƽ�������\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['">','.*?', ...
        '</a>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('</a>');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б�����
expr = ['�б�������\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['">','.*?', ...
        '</a>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('</a>');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% ��������
expr = ['�б���Ŀ��\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['">','.*?', ...
        '</a>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('</a>');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б�����
expr = ['�б����ߣ�\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['">','.*?', ...
        '</a>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('</a>');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б�ժҪ
expr = ['<font style="font-size','.*?', ...
    '</p>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['>','.*?', ...
        '</p>'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('>');
    eLen = length('</p>');
    temp = temp(sLen+1:end-eLen);
    
    temp = TextClean(temp);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б���С
expr = ['�б���С��\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['>','.*?', ...
        '<'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('">');
    eLen = length('<');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б�ҳ��
expr = ['�б�ҳ����\s*<span\s*>','.*?', ...
    '</span>'];
tMatchStr = regexpi(URLchar, expr,'match');
if ~isempty( tMatchStr )
    tStr = tMatchStr{1};
    expr = ['>','.*?', ...
        '<'];
    tMatchStr = regexpi(tStr, expr,'match');
    temp = tMatchStr{1};
    sLen = length('>');
    eLen = length('<');
    temp = temp(sLen+1:end-eLen);
    
    Detail{1, Tind} = temp;
end
Tind = Tind + 1;

% �б�����
Detail{1, Tind} = URL;

Tind = Tind + 1;

% Head = {'�ϴ�ʱ��','��Ʊ����','��Ʊ����','�������','�Ƽ�����','�б�����','��������','�б�����','�б�ժҪ','�б���С' ...
%    '�б�ҳ��','�б�����'};
%% sub func-TextClean�ı�������ϴ
function TC = TextClean(text)
TC = text;

expr = ['&nbsp;'];
replace = '';
TC = regexprep(TC,expr,replace);

expr = ['<br>'];
replace = ' ';
TC = regexprep(TC,expr,replace);

expr = ['<font style="display:none;">','.*?', ...
    '</font>'];
replace = '';
TC = regexprep(TC,expr,replace);

expr = ['<font.*?>'];
replace = '';
TC = regexprep(TC,expr,replace);

expr = ['</font.*?>'];
replace = '';
TC = regexprep(TC,expr,replace);

expr = ['<.*?em>'];
replace = '';
TC = regexprep(TC,expr,replace);