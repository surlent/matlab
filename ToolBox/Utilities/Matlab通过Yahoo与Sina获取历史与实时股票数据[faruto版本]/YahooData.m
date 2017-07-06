function [Data, Date_datenum, Head]=YahooData(StockName, StartDate, EndDate, Freq)
% by LiYang(faruto) @http://www.matlabsky.com
% �������ǻ��� ariszheng @http://www.ariszheng.com/ ����غ��������޸Ķ���
% ����ͨ��Yahoo��ȡ��Ʊ��ʷ����
% ��ʷ����ͨ��Yahoo�ӿڻ�� ����ʷ����Ϊδ��Ȩ���ݣ�ʹ��ʱ����ע�⣩
%% �������
% StockName ֤ȯ���루�Ϻ� .ss ���� .sz)
% StartDate, EndDate ʱ��εĿ�ʼ���������
% Freq Ƶ��
%% ���Ժ���
% StockName = '600036.ss';
% StartDate = today-200;
% EndDate = today;
% Freq = 'd';
% [DataYahoo, Date_datenum, Head]=YahooData(StockName, StartDate, EndDate, Freq);

%% ����ʱ������
startdate=StartDate;
enddate=EndDate;
%�ַ����仯
ms=num2str(str2double(datestr(startdate, 'mm'))-1);
ds=datestr(startdate, 'dd');
ys=datestr(startdate, 'yyyy');
me=num2str(str2double(datestr(enddate, 'mm'))-1);
de=datestr(enddate, 'dd');
ye=datestr(enddate, 'yyyy');

% s: ��Ʊ���� (e.g. 002036.SZ 300072.SZ 600036.SS ��)
% c-a-b: ��ʼ�����ꡢ�¡��� (�·ݵ���ʼ����Ϊ0) 2010-5-11 = 2010��6��11��
% f-d-e: ���������ꡢ�¡��� (�·ݵ���ʼ����Ϊ0) 2010-7-23 = 2010��8��23��
% g: ʱ�����ڡ�d=ÿ�գ�w=ÿ�ܣ�m=ÿ�£�v=ֻ���س�Ȩ����
% ʡ�����в�����ֻ�ƶ���Ʊ����ʱ������������ʷ����
url2Read=sprintf(...
    'http://ichart.finance.yahoo.com/table.csv?s=%s&a=%s&b=%s&c=%s&d=%s&e=%s&f=%s&g=%s&ignore=.csv', StockName, ms, ds, ys, me, de, ye, Freq);

s=urlread_General(url2Read);

Head = ['Date Open High Low Close Volume AdjClose'];
Result=textscan(s, '%s %s %s %s %s %s %s', 'delimiter', ',');

temp = Result{1,1};
Date_datestr = temp(2:end);
Date_datestr = Date_datestr(end:(-1):1);

temp = Result{1,2};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
Open = temp;

temp = Result{1,3};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
High = temp;

temp = Result{1,4};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
Low = temp;

temp = Result{1,5};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
Close = temp;

temp = Result{1,6};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
Volume = temp;

temp = Result{1,7};
temp = cellfun(@str2double, temp(2:end));
temp = temp(end:(-1):1);
AdjClose = temp;

Date_datenum = datenum(Date_datestr);
Date_double = str2num( datestr(Date_datenum, 'yyyymmdd') );

Data = [Date_double, Open, High, Low, Close, Volume, AdjClose];

end