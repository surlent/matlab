function [FIndCell,YearList] = GetStockFinIndicators_Web(StockCode,Year)
% ��ȡ����ָ��
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
%% �������Ԥ����
if nargin < 2 || isempty(Year)
    Year = '2017';
end
if nargin < 1 || isempty(StockCode)
    StockCode = '600000';
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'
if strcmpi(StockCode(1),'s') 
    StockCode = StockCode(3:end);
end
if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
    StockCode = StockCode(1:end-2);
end

FIndCell = [];
YearList = [];
%% ��ȡ����

URL = ['http://money.finance.sina.com.cn/corp/go.php/vFD_FinancialGuideLine/stockid/' ...
    StockCode,'/ctrl/',Year,'/displaytype/4.phtml'];

[TableTotalNum,TableCell] = GetTableFromWeb(URL);

if iscell( TableCell ) && ~isempty(TableCell)
    TableInd = 20;
    FIndCell = TableCell{TableInd};
    
    TableInd = 19;
    YearList = TableCell{TableInd};
else
    return;
end
%% �����ٴ���-FIndCell
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