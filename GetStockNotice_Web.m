function [NoticeDataCell] = GetStockNotice_Web(StockCode,BeginDate,EndDate)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%{
http://www.cninfo.com.cn/search/stockfulltext.jsp?
orderby=date11
&noticeType=0107&keyword=
&startTime=2005-01-01&endTime=2014-12-31
&stockCode=600588&pageNo=1
%}
%% 输入输出预处理
Charset = 'gb2312';
if nargin < 3 || isempty(EndDate)
    EndDate = '2014-06-01';
end
if nargin < 2 || isempty(BeginDate)
    BeginDate = '2015-01-01';
end
if nargin < 1 || isempty(StockCode)
    StockCode = '600588';
end

% 股票代码预处理，目标代码demo '600588'
if strcmpi(StockCode(1),'s')
    StockCode = StockCode(3:end);
end
if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
    StockCode = StockCode(1:end-2);
end

% 日期预处理，目标形式2014-12-29
ind = find( BeginDate == '-',1 );
if isempty(ind)
    BeginDate = [BeginDate(1:4),'-',BeginDate(5:6),'-',BeginDate(7:end)];
end
ind = find( EndDate == '-',1 );
if isempty(ind)
    EndDate = [EndDate(1:4),'-',EndDate(5:6),'-',EndDate(7:end)];
end

NoticeDataCell = [];
%% NoticeTypeCell

NoticeTypeCell = {'010301','年度报告'; ...
    '010303','半年度报告'; ...
    '010305','一季度报告'; ...
    '010307','三季度报告'; ...
    '0102','首次公开发行及上市'; ...
    '0105','配股'; ...
    '0107','增发'; ...
    '0109','可转换债券'; ...
    '0110','权证相关公告'; ...
    '0111','其它融资'; ...
    '0113','权益及限制出售股份'; ...
    '0115','股权变动'; ...
    '0117','交易'; ...
    '0119','股东大会'; ...
    '0121','澄清、风险、业绩预告'; ...
    '0125','特别处理和退市'; ...
    '0127','补充及更正'; ...
    '0129','中介机构报告'; ...
    '0131','上市公司制度'; ...
    '0123','其它重大事项'; ...
    };
%% NoticeDataCell

Head = {'StockCode','DateTime','Title','NoticeType','FileURL','FileSize'};
NoticeDataCell = [Head;NoticeDataCell];
Rnum = size(NoticeTypeCell,1);

% 1:Rnum
for i = 1:Rnum
    
    str = ['========='];
    disp(str);
    i
    NoticeTypeCell{i,2}
    str = ['============'];
    disp(str);
    
    NoticeType = NoticeTypeCell{i,1};
    %     NoticeType = [];
    tCell = subGetStockNotice_Web(StockCode,BeginDate,EndDate,NoticeType);
    NoticeDataCell = [NoticeDataCell;tCell(2:end,:)];
end

if size(NoticeDataCell,1) == 1
    NoticeDataCell = [];
    return;
end
%%  NoticeDataCell按照时间进行排序
tH = NoticeDataCell(1,:);
tD = NoticeDataCell(2:end,:);

Temp = cellfun( @Dstr2Dnum,tD(:,2) );
[~,I] = sort(Temp);

temp = tD(I,:);
NoticeDataCell = [tH;temp];

end

% % % [EOF_GetStockNotice_Web]

%% sub func-Dstr2Dnum
function y = Dstr2Dnum(Dstr)
ind = find(Dstr == ':',1);
if isempty(ind)
    y = datenum( Dstr,'yyyy-mm-dd' );
else
    y = datenum( Dstr,'yyyy-mm-dd HH:MM' );
end
end
% % % [EOF_Dstr2Dnum]

%% sub function-subGetStockNotice_Web
function tCell = subGetStockNotice_Web(StockCode,BeginDate,EndDate,NoticeType)
%% 初始化
tCell = [];
if strcmpi(NoticeType,'All')
    NoticeType = [];
end

Head = {'StockCode','DateTime','Title','NoticeType','FileURL','FileSize'};
NoticeTypeCell = {'010301','年度报告'; ...
    '010303','半年度报告'; ...
    '010305','一季度报告'; ...
    '010307','三季度报告'; ...
    '0102','首次公开发行及上市'; ...
    '0105','配股'; ...
    '0107','增发'; ...
    '0109','可转换债券'; ...
    '0110','权证相关公告'; ...
    '0111','其它融资'; ...
    '0113','权益及限制出售股份'; ...
    '0115','股权变动'; ...
    '0117','交易'; ...
    '0119','股东大会'; ...
    '0121','澄清、风险、业绩预告'; ...
    '0125','特别处理和退市'; ...
    '0127','补充及更正'; ...
    '0129','中介机构报告'; ...
    '0131','上市公司制度'; ...
    '0123','其它重大事项'; ...
    };
if ~isempty(NoticeType)
    Temp = cellfun(@(x)strcmpi(x,NoticeType),NoticeTypeCell(:,1));
    NoticeTypeWord = NoticeTypeCell{Temp,2};
else
    NoticeTypeWord = [];
end
%% URL生成

%{
http://www.cninfo.com.cn/search/stockfulltext.jsp?
orderby=date11
&noticeType=0107&keyword=
&startTime=2005-01-01&endTime=2014-12-31
&stockCode=600588&pageNo=1
%}


URL = ['http://www.cninfo.com.cn/search/stockfulltext.jsp?orderby=date11', ...
    '&noticeType=',NoticeType,'&keyword=',...
    '&startTime=',BeginDate,'&endTime=',EndDate,'&stockCode=',StockCode, ...
    '&pageNo=1'];

%% 数据获取
Charset = 'gb2312';
if verLessThan('matlab', '8.3')
    [URLchar, status] = urlread_General(URL, 'Charset', Charset, 'TimeOut', 60);
else
    [URLchar, status] = urlread(URL, 'Charset', Charset, 'TimeOut', 60);
end
if status == 0
    str = ['urlread error:网页读取失败！请检查输入的网址或网络连接情况！'];
    disp(str);
    return;
end

% URLString = java.lang.String(URLchar);

expr = ['<span class="count"','.*?', ...
    '</span>'];
Temp = regexpi(URLchar, expr,'match');
Temp = Temp{1};

expr = ['共','.*?', ...
    '条'];
Temp = regexpi(URLchar, expr,'match');
Temp = Temp{1};
Temp = Temp(2:end-1);
Temp = str2num(Temp);
if Temp == 0
    return;
end
%% 正则处理

DataCell = subURLcharParse(URLchar,StockCode,NoticeTypeWord);

%% 获取其他页码的搜索结果

DCell = [];

expr = ['onclick=','''','goPage(','.*?', ...
    '<'];
PageStr = regexpi(URLchar, expr,'match');
if ~isempty(PageStr)
    PageStr = PageStr(end);
    PageStr = PageStr{1};
    
    expr = ['>','.*?', ...
        '<'];
    MatchStr = regexpi(PageStr, expr,'match');
    MatchStr = MatchStr{1};
    MatchStr = regexprep(MatchStr,'>','');
    MatchStr = regexprep(MatchStr,'<','');
    Len = str2double(MatchStr);
else
    Len = 0;
end

if Len > 1
    % 2:Len
    for i = 2:Len
        
        PageNumDebug = i
        
        tURL = ['http://www.cninfo.com.cn/search/stockfulltext.jsp?orderby=date11', ...
            '&noticeType=',NoticeType,'&keyword=',...
            '&startTime=',BeginDate,'&endTime=',EndDate,'&stockCode=',StockCode, ...
            '&pageNo=',num2str(i)];
        
        if verLessThan('matlab', '8.3')
            [URLchar, status] = urlread_General(tURL, 'Charset', Charset, 'TimeOut', 60);
        else
            [URLchar, status] = urlread(tURL, 'Charset', Charset, 'TimeOut', 60);
        end
        
        if status == 0
            str = ['urlread error:网页读取失败！请检查输入的网址或网络连接情况！'];
            disp(str);
            URLchar = [];
        end
        
        tData = subURLcharParse(URLchar,StockCode,NoticeTypeWord);
        DCell = [DCell;tData(2:end,:)];
    end
    
end

%% 输出

tCell = [DataCell;DCell];

if isempty(tCell)
    return;
end

temp1 = tCell(1,:);
temp2 = tCell(end:(-1):2,:);

tCell = [temp1;temp2];
end

% % % [EOF_subGetStockNotice_Web]

%% Sub Function
function DataCell = subURLcharParse(URLchar,StockCode,NoticeTypeWord)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%% 输入输出预处理
if isempty( URLchar )
    DataCell = [];
    return;
end
DataCell = [];
Head = {'StockCode','DateTime','Title','NoticeType','FileURL','FileSize'};
%%

% &rsv_page=2
expr = ['<td class="qsgg">','.*?',...
    '</tr>'];
[matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = ...
    regexpi(URLchar, expr);
Len = numel(matchstring);
if Len>0
    
    ColNum = length(Head);
    DataCell = cell(Len, ColNum);
    % Head = {'DateTime','StockCode','Title','NoticeType','FileURL','FileSize'};
    for i = 1:Len
        
        DebugItermNum = i
        
        DataCell{i,1} = StockCode;
        DataCell{i,4} = NoticeTypeWord;
        StringTemp = matchstring{i};
        
        expr = ['<a href=','.*?',...
            '</a>'];
        TitleURL = regexpi(StringTemp, expr,'match');
        if ~isempty(TitleURL)
            TitleURL = TitleURL{1};
            
            expr = ['>','.*?',...
                '</a>'];
            out = regexpi(TitleURL, expr,'match');
            out = out{1};
            temp = out(2:end-length('</a>'));
            % % % 简易预处理清洗，剔除<em> </em>
            expr = ['<.*?em>'];
            replace = '';
            temp = regexprep(temp,expr,replace);
            % Title
            DataCell{i,3} = temp;
            
            expr = ['"'];
            out = regexpi(TitleURL, expr,'split');
            out = out{2};
            temp = out;
            % URL
            DataCell{i,5} = ['http://www.cninfo.com.cn/',temp];
        else
             % Title
            DataCell{i,3} = [];      
            % URL
            DataCell{i,5} = [];            
        end
        
        % % FileSize
        expr = ['<img','.*?',...
            '</td>'];
        out = regexpi(StringTemp, expr,'match');
        if ~isempty(out)
            out = out{1};
            expr = ['width=16> (','.*?',...
                ') </td>'];
            out = regexpi(out, expr,'match');
            out = out{1};
            ind = (1+length('width=16> (')):(length(out)-length(') </td>'));
            temp = out(ind);
        else
            temp = [];
        end
        DataCell{i,6} = temp;
        
        % % DateTime
        expr = ['<td class="ggsj"','.*?',...
            '</td>'];
        DateTime = regexpi(StringTemp, expr,'match');
        if ~isempty(DateTime)
            DateTime = DateTime{1};
            expr = ['>','.*?',...
                '</td>'];
            out = regexpi(DateTime, expr,'match');
            out = out{1};
            expr = ['&nbsp;'];
            out = regexprep(out, expr,'');
            temp = out(2:end-length('</td>'));
        else
            temp = [];
        end
        DataCell{i,2} = temp;
    end
    
    DataCell = [Head;DataCell];
    
    
end

end
% % % [EOF_subURLcharParse]