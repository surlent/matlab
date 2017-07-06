function [Data, DataCell]=SinaData(StockCode)
% by LiYang(faruto) @http://www.matlabsky.com
% �������ǻ��� ariszheng @http://www.ariszheng.com/ ����غ��������޸Ķ���
% ����ͨ��sina��ȡ��Ʊʵʱ����
%% �������
% StockCode ֤ȯ���루�Ϻ�sh+code ���� sz+code)
%% ���Ժ���
%��ȡ���� �������У��Ϻ���������
% StockCode='sh600036';
% [Data, DataCell]=SinaData(StockCode);

%% Sina URL
url2Read=['http://hq.sinajs.cn/list=',StockCode];
s=urlread_General(url2Read);

result=textscan(s,'%s','delimiter', ',');

result = result{1,1};
DataCell = result;
Data = cellfun(@str2double, DataCell(2:30));

temp = cell2mat(DataCell(1));
StockName = temp(22:end);
StockID = temp(12:19);

DataCell{1, 1} = [StockName, '_', StockID];

StockDate = cell2mat( DataCell(31) );
StockTime = cell2mat( DataCell(32) );

DataCell{2, 1} = StockDate;
DataCell{3, 1} = StockTime;

DataCell(4:end-1) = mat2cell( Data, ones(length(Data), 1) );

temp = DataCell(1:32);
DataCell = temp;

ind = 1;
DataCell{ind, 2}  = '��Ʊ���ƴ���';
ind = ind + 1;
DataCell{ind, 2}  = '����';
ind = ind + 1;
DataCell{ind, 2}  = 'ʱ��';
ind = ind + 1;
DataCell{ind, 2}  = '����';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '��ǰ��';
ind = ind + 1;
DataCell{ind, 2}  = '�����';
ind = ind + 1;
DataCell{ind, 2}  = '�����';
ind = ind + 1;
DataCell{ind, 2}  = '����ۣ�������һ������';
ind = ind + 1;
DataCell{ind, 2}  = '�����ۣ�������һ������';
ind = ind + 1;
DataCell{ind, 2}  = '�ɽ�������λ���ɡ�';
ind = ind + 1;
DataCell{ind, 2}  = '�ɽ����λ��Ԫ��';
ind = ind + 1;
DataCell{ind, 2}  = '��һ��';
ind = ind + 1;
DataCell{ind, 2}  = '��һ��';
ind = ind + 1;
DataCell{ind, 2}  = '�����';
ind = ind + 1;
DataCell{ind, 2}  = '�����';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '���ļ�';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '�����';
ind = ind + 1;
DataCell{ind, 2}  = '��һ��';
ind = ind + 1;
DataCell{ind, 2}  = '��һ��';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '���ļ�';
ind = ind + 1;
DataCell{ind, 2}  = '������';
ind = ind + 1;
DataCell{ind, 2}  = '�����';

end