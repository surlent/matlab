function [ Web_XRD_Data , Web_XRD_Cell_1 , Web_XRD_Cell_2 ] = GetStockXRD_Web(StockCode)
% Modified by LiYang_faruto
% based on Chandeman
%% ���ø�ʽ��
%       [ Web_XRD_Data , Web_XRD_Cell_1 , Web_XRD_Cell_2 ] = F_Stock_XRD_DataImport(StockCode,Stock_Name)
% ���룺 StockCode �� ��Ʊ���� StockCode = '600001';
%        Stock_Name �� ��Ʊ����
% ���:  Web_XRD_Data �� ��Ȩ��Ϧ��ֵ������
%        Web_XRD_Cell_1 �� �ֺ��͹��ı�������
%        Web_XRD_Cell_2 �� ����ı�������
% http://vip.stock.finance.sina.com.cn/corp/go.php/vISSUE_ShareBonus/stockid/600083.phtml
% http://stockdata.stock.hexun.com/2009_fhzzgb_600588.shtml
% 
%% �������Ԥ����
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

Web_XRD_Data = [];
Web_XRD_Cell_1 = [];
Web_XRD_Cell_2 = [];
%% ��ҳ��ȡ
URL = ['http://vip.stock.finance.sina.com.cn/corp/'...
    'go.php/vISSUE_ShareBonus/stockid/'...
     StockCode ,'.phtml'];
if verLessThan('matlab', '8.3')
    [Web_Url_Countent, status] = urlread_General(URL, 'TimeOut', 60,'Charset', 'gb2312');
else
    [Web_Url_Countent, status] = urlread(URL, 'TimeOut', 60,'Charset', 'gb2312');
end
if status == 0
    str = ['urlread error:��ҳ��ȡʧ�ܣ������������ַ���������������'];
    disp(str);
    return;
end

Web_Url_Expression = '<tbody>.*</a></td>';
[~,Web_Url_Matches] = ...
regexp(Web_Url_Countent,Web_Url_Expression,'tokens','match');

%% ������ȡ

Web_Ori_Countent = char(Web_Url_Matches);
Web_Ori_Expression = '>';
[~,Web_Ori_Matches] = regexp(Web_Ori_Countent,Web_Ori_Expression,'match','split');

%% ��������

Web_Ori_Matches_length = length(Web_Ori_Matches);
Intermediate_variable_k = Web_Ori_Matches_length;
Intermediate_variable_Matches = char(Web_Ori_Matches);
if isempty(Intermediate_variable_Matches)
    fprintf([StockCode,'�����޳�Ȩ��Ϣ����\n'])
    Web_XRD_Data = [];
    Web_XRD_Cell_1 = [];
    Web_XRD_Cell_2 = [];
    return;
end

% �ҳ��ֺ�����&����ٽ�λ��

for Intermediate_variable_i = 1 : length(Intermediate_variable_Matches(:,1))
    if strcmp(Intermediate_variable_Matches(Web_Ori_Matches_length + 1 - Intermediate_variable_i,1:7) , '<strong')
        Intermediate_variable_k = Web_Ori_Matches_length + 1 - Intermediate_variable_i;
        break
    end
end
 
% �ֺ�

Intermediate_variable_j = 1;
Intermediate_variable_q1 = repmat(1:7,1,ceil(Web_Ori_Matches_length/7))';
for Intermediate_variable_i = 1 : Intermediate_variable_k
    if ~isempty(str2num(Intermediate_variable_Matches(Intermediate_variable_i,1))) || Intermediate_variable_Matches(Intermediate_variable_i,1) == '-'
        Web_XRD_Cell_1{ceil(Intermediate_variable_j/7),Intermediate_variable_q1(Intermediate_variable_j)} =  ...
            Intermediate_variable_Matches(Intermediate_variable_i,1:find(Intermediate_variable_Matches(Intermediate_variable_i,:)=='<')-1);
        Intermediate_variable_j = Intermediate_variable_j + 1;
    end
end

Web_XRD_Cell_1 = [{'��������','�͹ɣ��ɣ�','ת�����ɣ�','��Ϣ��˰ǰ����Ԫ��',...
    '��Ȩ��Ϣ��', '��Ȩ�Ǽ���','���������'};Web_XRD_Cell_1];

% �ҳ���Ч����

[Web_XRD_Cell_1_Row_1,Web_XRD_Cell_1_Column_1] = size(Web_XRD_Cell_1);
Intermediate_variable_j = 0;
Intermediate_variable_l = ones(Web_XRD_Cell_1_Row_1,1);
for Intermediate_variable_i = 1 : Web_XRD_Cell_1_Row_1
    if strcmp(Web_XRD_Cell_1(Intermediate_variable_i,5),'--') || ...
            strcmp(Web_XRD_Cell_1(Intermediate_variable_i,5),'��Ȩ��Ϣ��')
        Intermediate_variable_l(Intermediate_variable_i,1) = 0;
        Intermediate_variable_j = Intermediate_variable_j + 1;
    end
end

% ���ֺ������ı�����ת����ֵ������

temp = Web_XRD_Cell_1(Intermediate_variable_l==1,5);
if isempty( temp )
    fprintf([StockCode,'�����޳�Ȩ��Ϣ����\n'])
    Web_XRD_Data = [];
    Web_XRD_Cell_1 = [];
    Web_XRD_Cell_2 = [];
    return;    
end

Web_XRD_Data = zeros(Web_XRD_Cell_1_Row_1 - Intermediate_variable_j ,6);
Web_XRD_Data(:,1)  = datenum(Web_XRD_Cell_1(Intermediate_variable_l==1,5));          % ��Ȩ��Ϣ��

Web_XRD_Data(:,2)  = cellfun(@str2num,Web_XRD_Cell_1(Intermediate_variable_l==1,2)); % �͹�
Web_XRD_Data(:,3)  = cellfun(@str2num,Web_XRD_Cell_1(Intermediate_variable_l==1,3)); % ת��
Web_XRD_Data(:,4)  = cellfun(@str2num,Web_XRD_Cell_1(Intermediate_variable_l==1,4)); % ��Ϣ

%% ������ݴ���

% ���
[TableTotalNum,TableCell] = GetTableFromWeb(URL);

TableInd = 20;
TempCell = TableCell{TableInd};
TempCell = TempCell(3,:);

if size(TempCell,2) == 1 || strcmpi(TempCell{1,1},'��ʱû�����ݣ�')
    Web_XRD_Cell_2 = [];
else
    TempCell = TempCell(:,1:9);

    Web_XRD_Cell_2 = [{'��������','��ɷ�����ÿ10����ɹ�����','��ɼ۸�Ԫ��',...
        '��׼�ɱ�����ɣ�','��Ȩ��Ϣ��','��Ȩ�Ǽ���','�ɿ���ʼ��','�ɿ���ֹ��',...
        '���������'};TempCell];

    % �ϲ��ֺ��������������

    [Web_XRD_Cell_2_Row,Web_XRD_Cell_2_Column_2] = size(Web_XRD_Cell_2);
    Intermediate_variable_XRDCell2 = zeros(Web_XRD_Cell_2_Row-1,3);
    Intermediate_variable_XRDCell2(:,1) = datenum(Web_XRD_Cell_2(2:end,5));
    Intermediate_variable_XRDCell2(:,2) = cellfun(@str2num,Web_XRD_Cell_2(2:end,2));
    Intermediate_variable_XRDCell2(:,3) = cellfun(@str2num,Web_XRD_Cell_2(2:end,3));

    for Intermediate_variable_i = 1 : Web_XRD_Cell_2_Row-1
        Intermediate_variable_location = ...
            find(Web_XRD_Data(:,1)==Intermediate_variable_XRDCell2(Intermediate_variable_i,1));
        if ~isempty(Intermediate_variable_location)
            Web_XRD_Data(Intermediate_variable_location,5:6) = ...
                Intermediate_variable_XRDCell2(Intermediate_variable_i,2:3);
        else
            Web_XRD_Data(end+1,:) = ...
                [Intermediate_variable_XRDCell2(Intermediate_variable_i,1),0,0,0,...
                Intermediate_variable_XRDCell2(Intermediate_variable_i,2:3)];
        end
    end    
end

% if Intermediate_variable_k ~= Web_Ori_Matches_length
%     
%     Intermediate_variable_j = 1;
%     Intermediate_variable_q2 = repmat(1:9,1,ceil(Web_Ori_Matches_length/9))';
%     for Intermediate_variable_i = Intermediate_variable_k : Web_Ori_Matches_length
%         if ~isempty(str2num(Intermediate_variable_Matches(Intermediate_variable_i,1))) || Intermediate_variable_Matches(Intermediate_variable_i,1) == '-'
%             Web_XRD_Cell_2{ceil(Intermediate_variable_j/9),Intermediate_variable_q2(Intermediate_variable_j)} =  ...
%                 Intermediate_variable_Matches(Intermediate_variable_i,1:find(Intermediate_variable_Matches(Intermediate_variable_i,:)=='<')-1);
%             Intermediate_variable_j = Intermediate_variable_j + 1;
%         end
%     end
% 
%     Web_XRD_Cell_2 = [{'��������','��ɷ�����ÿ10����ɹ�����','��ɼ۸�Ԫ��',...
%         '��׼�ɱ�����ɣ�','��Ȩ��Ϣ��','��Ȩ�Ǽ���','�ɿ���ʼ��','�ɿ���ֹ��',...
%         '���������'};Web_XRD_Cell_2];
% 
%     % �ϲ��ֺ��������������
% 
%     [Web_XRD_Cell_2_Row,Web_XRD_Cell_2_Column_2] = size(Web_XRD_Cell_2);
%     Intermediate_variable_XRDCell2 = zeros(Web_XRD_Cell_2_Row-1,3);
%     Intermediate_variable_XRDCell2(:,1) = datenum(Web_XRD_Cell_2(2:end,5));
%     Intermediate_variable_XRDCell2(:,2) = cellfun(@str2num,Web_XRD_Cell_2(2:end,2));
%     Intermediate_variable_XRDCell2(:,3) = cellfun(@str2num,Web_XRD_Cell_2(2:end,3));
% 
%     for Intermediate_variable_i = 1 : Web_XRD_Cell_2_Row-1
%         Intermediate_variable_location = ...
%             find(Web_XRD_Data(:,1)==Intermediate_variable_XRDCell2(Intermediate_variable_i,1));
%         if ~isempty(Intermediate_variable_location)
%             Web_XRD_Data(Intermediate_variable_location,5:6) = ...
%                 Intermediate_variable_XRDCell2(Intermediate_variable_i,2:3);
%         else
%             Web_XRD_Data(end+1,:) = ...
%                 [Intermediate_variable_XRDCell2(Intermediate_variable_i,1),0,0,0,...
%                 Intermediate_variable_XRDCell2(Intermediate_variable_i,2:3)];
%         end
%     end
% else
%     Web_XRD_Cell_2 = [];
% end

Web_XRD_Data(:,1)  = str2num( datestr(Web_XRD_Data(:,1),'yyyymmdd') ); 

Web_XRD_Data = sortrows(Web_XRD_Data,1);