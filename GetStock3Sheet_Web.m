function [BalanceSheet,ProfitSheet,CashFlowSheet,YearList] = GetStock3Sheet_Web(StockCode,Year)
% ��ȡ����ָ��
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
% http://money.finance.sina.com.cn/corp/go.php/vFD_BalanceSheet/stockid/600588/ctrl/displaytype/4.phtml
% http://money.finance.sina.com.cn/corp/go.php/vFD_ProfitStatement/stockid/600588/ctrl/2014/displaytype/4.phtml
% http://money.finance.sina.com.cn/corp/go.php/vFD_CashFlow/stockid/600588/ctrl/part/displaytype/4.phtml
%% �������Ԥ����
if nargin < 2 || isempty(Year)
    Year = '2014';
end
if nargin < 1 || isempty(StockCode)
    StockCode = '600588';
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'
if strcmpi(StockCode(1),'s') 
    StockCode = StockCode(3:end);
end
if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
    StockCode = StockCode(1:end-2);
end

BalanceSheet = [];
ProfitSheet = [];
CashFlowSheet = [];
YearList = [];
%% ��ȡ����-BalanceSheet

URL = ['http://money.finance.sina.com.cn/corp/go.php/vFD_BalanceSheet/stockid/' ...
    StockCode,'/ctrl/',Year,'/displaytype/4.phtml'];

[TableTotalNum,TableCell] = GetTableFromWeb(URL);

if iscell( TableCell ) && ~isempty(TableCell)
    TableInd = 20;
    FIndCell = TableCell{TableInd};
    
    TableInd = 19;
    YearList = TableCell{TableInd};
    YearList = YearList{2,1};
else
    return;
end
%% �����ٴ���-YearList
temp = YearList;
YearList = [];
YearList{1,1} = ['��������'];
if iscell(temp)
    temp = temp{1};
end

Yend = str2num( temp(end-3:end) );
CurrenYear = str2num( Year );
for r = Yend:CurrenYear
    expr = [num2str(r)];
    [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = regexpi(temp, expr);
    
    if ~isempty(matchstring)
        if iscell(matchstring)
            matchstring = matchstring{1};
        end
        len = size(YearList,1)+1;
        YearList{len,1} = str2num(matchstring);
        
    end
end
%% �����ٴ���-BalanceSheet
[RowNum,ColNum] = size( FIndCell );

for s = 3:RowNum
    for t = 2:ColNum
        temp = FIndCell{s,t};
        if ~isempty(temp)
            temp = str2double(temp);
            if isnumeric(temp)
                FIndCell{s,t} = temp;
            else
                FIndCell{s,t} = [];
            end

        end
    end
end
BalanceSheet = FIndCell;
%% ��ȡ����-ProfitSheet

URL = ['http://money.finance.sina.com.cn/corp/go.php/vFD_ProfitStatement/stockid/' ...
    StockCode,'/ctrl/',Year,'/displaytype/4.phtml'];

[TableTotalNum,TableCell] = GetTableFromWeb(URL);

TableInd = 20;
FIndCell = TableCell{TableInd};
%% �����ٴ���-ProfitSheet
[RowNum,ColNum] = size( FIndCell );

for s = 3:RowNum
    for t = 2:ColNum
        temp = FIndCell{s,t};
        if ~isempty(temp)
            temp = str2double(temp);
            if isnumeric(temp)
                FIndCell{s,t} = temp;
            else
                FIndCell{s,t} = [];
            end

        end
    end
end
ProfitSheet = FIndCell;
%% ��ȡ����-CashFlowSheet

URL = ['http://money.finance.sina.com.cn/corp/go.php/vFD_CashFlow/stockid/' ...
    StockCode,'/ctrl/',Year,'/displaytype/4.phtml'];

[TableTotalNum,TableCell] = GetTableFromWeb(URL);

TableInd = 20;
FIndCell = TableCell{TableInd};
%% �����ٴ���-CashFlowSheet
[RowNum,ColNum] = size( FIndCell );

for s = 3:RowNum
    for t = 2:ColNum
        temp = FIndCell{s,t};
        if ~isempty(temp)
            temp = str2double(temp);
            if isnumeric(temp)
                FIndCell{s,t} = temp;
            else
                FIndCell{s,t} = [];
            end

        end
    end
end
CashFlowSheet = FIndCell;
