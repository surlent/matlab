function [NewsDataCell] = BaiduSearchAdvancedNews(StringIncludeAll,StringIncludeAny,BeginDate,EndDate)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%{
http://news.baidu.com/ns?from=news
&cl=2&bt=1419436800&y0=2014&m0=12&d0=25&y1=2014&m1=12&d1=26&et=1419609599
&q1=600588%D3%C3%D3%D1%C8%ED%BC%FEIncludeTermAll
&submit=%B0%D9%B6%C8%D2%BB%CF%C2
&q3=IncludeTermAny
&q4=NotInclude
&mt=0&lm=&s=2
&begin_date=2014-12-25&end_date=2014-12-26
&tn=newsdy&ct1=1&ct=1&rn=100
&q6=NewSource
%}
%% �������Ԥ����
if nargin < 4 || isempty(EndDate)
    EndDate = '2014-12-26';
end
if nargin < 3 || isempty(BeginDate)
    BeginDate = '2014-12-26';
end
if nargin < 2 
    StringIncludeAny = [];
end
if nargin < 1 || isempty(StringIncludeAll)
    StringIncludeAll = '600588';
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'

if strcmpi(StringIncludeAll(1),'s')
    StringIncludeAll = StringIncludeAll(3:end);
end
if strcmpi(StringIncludeAll(end),'h') ||  strcmpi(StringIncludeAll(end),'z')
    StringIncludeAll = StringIncludeAll(1:end-2);
end


% ����Ԥ����Ŀ����ʽ2014-12-29
ind = find( BeginDate == '-',1 );
if isempty(ind)
    BeginDate = [BeginDate(1:4),'-',BeginDate(5:6),'-',BeginDate(7:end)];
end
ind = find( EndDate == '-',1 );
if isempty(ind)
    EndDate = [EndDate(1:4),'-',EndDate(5:6),'-',EndDate(7:end)];
end

NewsDataCell = [];
%% ����ѭ������
SDnum = datenum( BeginDate,'yyyy-mm-dd' );
EDnum = datenum( EndDate,'yyyy-mm-dd' );

DayInterval = 1;

for i = SDnum:DayInterval:EDnum
    
    tBeginDate = datestr(i,'yyyy-mm-dd');
    tEndDate = tBeginDate;
    
    [tNewsDataCell] = subBaiduSearchAdvancedNews(StringIncludeAll,StringIncludeAny,tBeginDate,tEndDate);
    
    if ~isempty(tNewsDataCell)
        tNewsDataCell = tNewsDataCell(2:end,:);
        NewsDataCell = [NewsDataCell;tNewsDataCell];
    end
end


end
% [EOF_subBaiduSearchAdvancedNews]

%% sub function - subBaiduSearchAdvancedNews
function [NewsDataCell] = subBaiduSearchAdvancedNews(StringIncludeAll,StringIncludeAny,BeginDate,EndDate)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%{
http://news.baidu.com/ns?from=news
&cl=2&bt=1419436800&y0=2014&m0=12&d0=25&y1=2014&m1=12&d1=26&et=1419609599
&q1=600588%D3%C3%D3%D1%C8%ED%BC%FEIncludeTermAll
&submit=%B0%D9%B6%C8%D2%BB%CF%C2
&q3=IncludeTermAny
&q4=NotInclude
&mt=0&lm=&s=2
&begin_date=2014-12-25&end_date=2014-12-26
&tn=newsdy&ct1=1&ct=1&rn=100
&q6=NewSource
%}
%% �������Ԥ����
if nargin < 4 || isempty(EndDate)
    EndDate = '2014-12-26';
end
if nargin < 3 || isempty(BeginDate)
    BeginDate = '2014-12-26';
end
if nargin < 2 
    StringIncludeAny = [];
end
if nargin < 1 || isempty(StringIncludeAll)
    StringIncludeAll = '600588';
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'

if strcmpi(StringIncludeAll(1),'s')
    StringIncludeAll = StringIncludeAll(3:end);
end
if strcmpi(StringIncludeAll(end),'h') ||  strcmpi(StringIncludeAll(end),'z')
    StringIncludeAll = StringIncludeAll(1:end-2);
end


% ����Ԥ����Ŀ����ʽ2014-12-29
ind = find( BeginDate == '-',1 );
if isempty(ind)
    BeginDate = [BeginDate(1:4),'-',BeginDate(5:6),'-',BeginDate(7:end)];
end
ind = find( EndDate == '-',1 );
if isempty(ind)
    EndDate = [EndDate(1:4),'-',EndDate(5:6),'-',EndDate(7:end)];
end

NewsDataCell = [];
%% URL����

%{
http://news.baidu.com/ns?from=news
&cl=2&bt=1419436800&y0=2014&m0=12&d0=25&y1=2014&m1=12&d1=26&et=1419609599
&q1=600588%D3%C3%D3%D1%C8%ED%BC%FEIncludeTermAll
&submit=%B0%D9%B6%C8%D2%BB%CF%C2
&q3=IncludeTermAny
&q4=NotInclude
&mt=0&lm=&s=2
&begin_date=2014-12-25&end_date=2014-12-26
&tn=newsdy&ct1=1&ct=1&rn=100
&q6=NewSource
%}


cl = '2';
temp = Unicode2URLHexCode_Ch('�ٶ�һ��');
submit = temp;
% ����Դ(�޶�Ҫ����������Դ��)  ���磺������
q6 = [];
% "��������ȫ���Ĺؼ���"��Ӧ�������ַ��������ַ���Ҫת����GB2312����
temp = Unicode2URLHexCode_Ch(StringIncludeAll);
q1 = temp;
% "������������һ���ؼ���"��Ӧ�������ַ��������ַ���Ҫת����GB2312����
temp = [];
if ~isempty( StringIncludeAny )
    temp = Unicode2URLHexCode_Ch(StringIncludeAny);
end
q3 = temp;
% "���������¹ؼ���"��Ӧ�������ַ��������ַ���Ҫת����GB2312����
temp = [];
q4 = temp;
% �޶�Ҫ���������ŵ�ʱ����ʱ������
s = '2';
% ��ʼ����
begin_date = BeginDate;
% ��������
end_date = EndDate;
% 1970-01-01��begin_date������-28800
temp = datenum(begin_date,'yyyy-mm-dd')-datenum('1970-01-01','yyyy-mm-dd');
temp = temp*24*60*60-28800;
bt = num2str(temp);
% 1970-01-01��end_date������-28800+86399
temp = datenum(end_date,'yyyy-mm-dd')-datenum('1970-01-01','yyyy-mm-dd');
temp = temp*24*60*60-28800+86399;
et = num2str(temp);
% begin_date���� �� ��
y0 = begin_date(1:4);
m0 = begin_date(6:7);
d0 = begin_date(9:end);
% end_date �� ��
y1 = end_date(1:4);
m1 = end_date(6:7);
d1 = end_date(9:end);
% �ؼ���λ�ã���ѯ�ؼ���λ�ڣ�'newsdy'������ȫ���У�'newstitledy'�������ű�����
tn = 'newsdy';
% �����������ʽ���޶��������������ʽ�ǣ���1-���������� 0-��ʱ������
ct1 = '0';
ct = ct1;
% ���������ʾ����(ѡ�����������ʾ������)
rn = '100';
%
lm = [];
mt = '0';

%{
http://news.baidu.com/ns?from=news
&cl=2&bt=1419436800&y0=2014&m0=12&d0=25&y1=2014&m1=12&d1=26&et=1419609599
&q1=600588%D3%C3%D3%D1%C8%ED%BC%FEIncludeTermAll
&submit=%B0%D9%B6%C8%D2%BB%CF%C2
&q3=IncludeTermAny
&q4=NotInclude
&mt=0&lm=&s=2
&begin_date=2014-12-25&end_date=2014-12-26
&tn=newsdy&ct1=1&ct=1&rn=100
&q6=NewSource
%}

URL = ['http://news.baidu.com/ns?from=news', ...
    '&cl=',cl,'&bt=',bt,'&y0=',y0,'&m0=',m0,'&d0=',d0,...
    '&y1=',y1,'&m1=',m1,'&d1=',d1,...
    '&et=',et,'&q1=',q1,'&submit=',submit,...
    '&q3=',q3,'&q4=',q4,'&mt=',mt,'&lm=',lm,...
    '&s=',s,'&begin_date=',begin_date,'&end_date=',end_date,...
    '&tn=',tn,'&ct1=',ct1,'&ct=',ct,'&rn=',rn,...
    '&q6=',q6];


%% ���ݻ�ȡ

if verLessThan('matlab', '8.3')
    [URLchar, status] = urlread_General(URL, 'Charset', 'utf-8', 'TimeOut', 60);
else
    [URLchar, status] = urlread(URL, 'Charset', 'utf-8', 'TimeOut', 60);
end
if status == 0
    str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
    disp(str);
    return;
end

URLString = java.lang.String(URLchar);
%% ������

DataCell = URLcharParse(URLchar);

%% ��ȡ����ҳ����������

DCell = [];

expr = ['<p id="page">','.*?', ...
    '</p>'];
PageStr = regexpi(URLchar, expr,'match');
if ~isempty(PageStr)
    PageStr = PageStr{1};
    
    expr = ['<a href="/ns','.*?', ...
        '<i class="c-icon c-icon-bear-pn"></i></span><span class="pc">\d*</span></a>'];
    
    MatchStr = regexpi(PageStr, expr,'match');
    Len = numel(MatchStr);
else
    Len = 0;
end

if Len > 0

    for i = 1:Len
        temp = MatchStr{i};
        expr = ['"'];
        out = regexpi(temp, expr,'split');
        out = out{2};  
        
        tURL = ['http://news.baidu.com',out];
        
        if verLessThan('matlab', '8.3')
            [URLchar, status] = urlread_General(tURL, 'Charset', 'utf-8', 'TimeOut', 60);
        else
            [URLchar, status] = urlread(tURL, 'Charset', 'utf-8', 'TimeOut', 60);
        end
        
        if status == 0
            str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
            disp(str);
            URLchar = [];
        end
        
        tData = URLcharParse(URLchar);
        DCell = [DCell;tData(2:end,:)];
    end
    
end

%% ���

NewsDataCell = [DataCell;DCell];

if ~isempty( NewsDataCell )
    
    temp1 = NewsDataCell(1,:);
    temp2 = NewsDataCell(end:(-1):2,:);
    
    NewsDataCell = [temp1;temp2];
    
end
end

% [EOF_subBaiduSearchAdvancedNews]

%% Sub Function - URLcharParse
function DataCell = URLcharParse(URLchar)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%% �������Ԥ����
if isempty( URLchar )
    DataCell = [];
    return;
end
DataCell = [];
%% 

% &rsv_page=2
expr = ['<li class="result" id=.*?>','.*?',...
    '</li>'];
[matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = ...
    regexpi(URLchar, expr);
Len = numel(matchstring);
if Len>=1
    ColNum = 4;
    DataCell = cell(Len, ColNum);
    for i = 1:Len
        StringTemp = matchstring{i};
        
        expr = ['<a href=','.*?',...
            '</a>'];
        TitleURL = regexpi(StringTemp, expr,'match');
        TitleURL = TitleURL{1};
        
        expr = ['>','.*?',...
            '</a>'];
        out = regexpi(TitleURL, expr,'match');
        out = out{1};
        temp = out(2:end-4);
        % % % ����Ԥ������ϴ���޳�<em> </em>
        expr = ['<.*?em>'];
        replace = '';
        temp = regexprep(temp,expr,replace);
        % Title
        DataCell{i,2} = temp;
        
        expr = ['"'];
        out = regexpi(TitleURL, expr,'split');
        out = out{2};
        temp = out;
        % URL
        DataCell{i,4} = temp;
        
        
        expr = ['<p class="c-author">','.*?',...
            '</p>'];
        AuthorDate = regexpi(StringTemp, expr,'match');
        AuthorDate = AuthorDate{1};
        expr = ['>','.*?',...
            '</p>'];
        out = regexpi(AuthorDate, expr,'match');
        out = out{1};
        temp = out(2:end-4);
        
        expr = ['&nbsp;&nbsp;'];
        out = regexpi(temp, expr,'split');
        if numel(out) == 2
            %��Author Source
            DataCell{i,3} = out{1};
            % DateTime
            DataCell{i,1} = out{2};
        else
            % �еĿ���û��Author i.e. ��վ���ƣ��������ƣ�û��
            %��Author Source
            DataCell{i,3} = [];
            % DateTime
            DataCell{i,1} = out{1};
        end
    end
    Head = {'DateTime','Title','Source','URL'};
    DataCell = [Head;DataCell];
    
    
end

end