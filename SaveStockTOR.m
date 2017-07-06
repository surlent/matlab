function []=SaveStockTOR(~)
%��ȡ���й�Ʊ����ͨ��A��Ϣ,��ʱ����Ų�
%�ṹ���ƶ�ȡ���й�Ʊ��Ϣ���浵

FolderStr = './DataBase/Stock/Floating stock_mat';


if ~isdir( FolderStr )
    mkdir( FolderStr );
end
  
d=dir ('./DataBase/Stock/Day_ForwardAdj_mat');%���������Ϣ�ļ�����Ϣ�����ݽṹ

d(1:2,:)=[];
d=struct2cell(d);
d=d';
StockCode=d(:,1);
len=size(StockCode,1);
SaveCode=cell(len,1);

debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��

if debug == 1
    len=5;
elseif debug == 2
    len=500;
end
tic
for i=1:len
StockCode{i}(end-16:end)=[];
SaveCode{i}=StockCode{i};
str=['���ڻ�ȡ' SaveCode{i} '��ͨ����Ϣ'];
disp(str)
StockCode{i}(1:2)=[];
URL=['http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_StockStructureHistory/stockid/' StockCode{i} '/stocktype/LiuTongA.phtml'];%���˵Ĳ�ѯҳ��
[~,TableCell] = GetTableFromWeb(URL);
if ~exist('TableCell','var')
    disp('��ȡʧ��,�ȴ�3������...')
    pause(3);
    [~,TableCell] = GetTableFromWeb(URL);
end
if ~exist('TableCell','var')
    disp('ʧ������')
    continue;
end

TableCell=TableCell(19:end);%ֻ����������������ͨ����Ϣ
FloatingStock=[TableCell{1};TableCell{2};TableCell{3}];%ƴ����ͨ����Ϣ���cell
Length = size(FloatingStock,1);%�����������cell�ĳ���
    for j=Length:-1:1
        if strcmp(FloatingStock{j,2},'���й���')%���ĳ�еڶ��а������й���,������ɾ��
           FloatingStock(j,:)=[];
        else
            FloatingStock{j,2}(end-1:end)=[];%���ı���ʽ����ͨ�ɵ�������ֵ.
            FloatingStock{j,2}=str2double(FloatingStock{j,2})*10000;%��λ�ǹɲ�����,�������㻻���ʵ�ʱ�����.
        end
    end

save(['./DataBase/Stock/Floating stock_mat/' SaveCode{i}],'FloatingStock','-v7.3');
end
toc
end


