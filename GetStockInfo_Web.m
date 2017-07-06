function [StockInfo] = GetStockInfo_Web(StockCode)
% ��ȡ��Ʊ������Ϣ�Լ�������ҵ��飨֤�����ҵ���ࣩ�����������飨���˲ƾ����壩
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
% ��˾��飺http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_CorpInfo/stockid/600588.phtml
% �����Ϣ��http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_CorpOtherInfo/stockid/600588/menu_num/2.phtml
%% �������Ԥ����
if nargin < 1 || isempty(StockCode)
    StockCode = '600588';
end

% ��Ʊ����Ԥ����Ŀ�����demo '600588'
% ��Ʊ����Ԥ����Ŀ�����demo '600588'
if strcmpi(StockCode(1),'s')
    StockCode = StockCode(3:end);
end
if strcmpi(StockCode(end),'h') ||  strcmpi(StockCode(end),'z')
    StockCode = StockCode(1:end-2);
end
StockInfo = [];
%% ��ȡ��˾���
URL = ['http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_CorpInfo/stockid/',StockCode,'.phtml'];

[~,TableCell] = GetTableFromWeb(URL);

if iscell( TableCell ) && ~isempty(TableCell)
    TableInd = 4;
    FIndCell = TableCell{TableInd};
else
    FIndCell = [];
end

StockInfo.CompanyIntro = FIndCell;

temp = StockInfo.CompanyIntro{3,4};
if ~isempty(temp)
    temp = str2double( datestr(datenum(temp,'yyyy-mm-dd'),'yyyymmdd') );
    StockInfo.IPOdate = temp;
else
    StockInfo.IPOdate = [];
end

temp = StockInfo.CompanyIntro{4,2};
temp = str2double( temp );
StockInfo.IPOprice = temp;
%% ��ȡ�����Ϣ
% http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_CorpOtherInfo/stockid/600588/menu_num/2.phtml
URL = ...
    ['http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_CorpOtherInfo/stockid/',StockCode,'/menu_num/2.phtml'];

[~,TableCell] = GetTableFromWeb(URL);

if iscell( TableCell ) && ~isempty(TableCell)
    TableInd = 4;
    tIndustrySector = TableCell{TableInd};
    TableInd = 5;
    tConceptSector_Sina = TableCell{TableInd};
else
    tIndustrySector = [];
    tConceptSector_Sina = [];
    return;
end

temp = tIndustrySector{3,1};
StockInfo.IndustrySector = temp;

temp = tConceptSector_Sina(3:end,1);
StockInfo.ConceptSector_Sina = temp;
if strcmpi(temp,'�Բ�����ʱû����ظ�������Ϣ')
    StockInfo.ConceptSector_Sina = [];
end
