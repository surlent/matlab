function [NewsDataCell] = SinaSearchAdvanced(StringIncludeAll,BeginDate,EndDate,ChannelFlag)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%{
http://search.sina.com.cn/?c=news
&q=600588&range=all
&time=custom&stime=2014-12-23&etime=2014-12-31
&num=20&col=1_7
%}
%% �������Ԥ����
Charset = 'gb2312';
if nargin < 4 || isempty(ChannelFlag)
    % ��������Ƶ��ѡ�� 1-�ƾ�Ƶ�� 2-����Ƶ��
    ChannelFlag = 1;
end
if nargin < 3 || isempty(EndDate)
    EndDate = '2014-12-26';
end
if nargin < 2 || isempty(BeginDate)
    BeginDate = '2014-12-26';
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
http://search.sina.com.cn/?c=news
&q=600588&range=all
&time=custom&stime=2014-12-23&etime=2014-12-31
&num=20&col=1_7
%}

% "��������ȫ���Ĺؼ���"��Ӧ�������ַ��������ַ���Ҫת����GB2312����
temp = Unicode2URLHexCode_Ch(StringIncludeAll);
q = temp;

% ��ʼ����
stime = BeginDate;
% ��������
etime = EndDate;

% ���������ʾ����(ѡ�����������ʾ������)
num = '20';
% ��������Ƶ��ѡ��
if ChannelFlag == 1
    col = '1_7';
end
if ChannelFlag == 2
    col = '1_3';
end

%{
http://search.sina.com.cn/?c=news
&q=600588&range=all
&time=custom&stime=2014-12-23&etime=2014-12-31
&num=20&col=1_7
%}

URL = ['http://search.sina.com.cn/?c=news', ...
    '&q=',q,'&range=all&time=custom&stime=',stime,...
    '&etime=',etime,'&num=',num,'&col=',col];


%% ���ݻ�ȡ

if verLessThan('matlab', '8.3')
    [URLchar, status] = urlread_General(URL, 'Charset', Charset, 'TimeOut', 60);
else
    [URLchar, status] = urlread(URL, 'Charset', Charset, 'TimeOut', 60);
end
if status == 0
    str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
    disp(str);
    return;
end

URLString = java.lang.String(URLchar);
%% ������

DataCell = SinaURLcharParse(URLchar);

%% ��ȡ����ҳ����������

DCell = [];

expr = ['<!-- ��ҳ begin -->','.*?', ...
    '<!-- ��ҳ end -->'];
PageStr = regexpi(URLchar, expr,'match');
PageStr = PageStr{1};

expr = ['<a href=','.*?', ...
        '</a>'];

MatchStr = regexpi(PageStr, expr,'match');
Len = numel(MatchStr);

if Len > 0

    for i = 1:Len-1
        temp = MatchStr{i};
        expr = ['"'];
        out = regexpi(temp, expr,'split');
        out = out{2};  
        
        tURL = ['http://search.sina.com.cn/',out];
        tURL = regexprep(tURL,'&amp;','&');
        
        if verLessThan('matlab', '8.3')
            [URLchar, status] = urlread_General(tURL, 'Charset', Charset, 'TimeOut', 60);
        else
            [URLchar, status] = urlread(tURL, 'Charset', Charset, 'TimeOut', 60);
        end
        
        if status == 0
            str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
            disp(str);
            URLchar = [];
        end
        
        tData = SinaURLcharParse(URLchar);
        DCell = [DCell;tData(2:end,:)];
    end
    
end

%% ���

NewsDataCell = [DataCell;DCell];

temp1 = NewsDataCell(1,:);
temp2 = NewsDataCell(end:(-1):2,:);

NewsDataCell = [temp1;temp2];
end

% [EOF_Main]

%% Sub Function
function DataCell = SinaURLcharParse(URLchar)
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
expr = ['<!-- ��������.*?begin -->','.*?',...
    '<!-- ��������.*?end --> '];
[matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = ...
    regexpi(URLchar, expr);
Len = numel(matchstring);
if Len>1
    ColNum = 4;
    DataCell = cell(Len, ColNum);
    % Head = {'DateTime','Title','Source','URL'};
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
        
        
        expr = ['<span class="fgray_time">','.*?',...
            '</span>'];
        AuthorDate = regexpi(StringTemp, expr,'match');
        AuthorDate = AuthorDate{1};
        expr = ['>','.*?',...
            '</span>'];
        out = regexpi(AuthorDate, expr,'match');
        out = out{1};
        temp = out(2:end-7);
        
        expr = [' '];
        out = regexpi(temp, expr,'split');
        if numel(out) == 3
            %��Author Source
            DataCell{i,3} = out{1};
            % DateTime
            DataCell{i,1} = [out{2},' ',out{3}];
        else
            % �еĿ���û��Author i.e. ��վ���ƣ��������ƣ�û��
            %��Author Source
            DataCell{i,3} = [];
            % DateTime
            DataCell{i,1} = [out{1},' ',out{2}];
        end
    end
    Head = {'DateTime','Title','Source','URL'};
    DataCell = [Head;DataCell];
    
    
end

end