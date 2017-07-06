function []=SaveStockTOR(~)
%读取所有股票的流通股A信息,按时间段排布
%结构类似读取所有股票信息并存档

FolderStr = './DataBase/Stock/Floating stock_mat';


if ~isdir( FolderStr )
    mkdir( FolderStr );
end
  
d=dir ('./DataBase/Stock/Day_ForwardAdj_mat');%获得日线信息文件夹信息的数据结构

d(1:2,:)=[];
d=struct2cell(d);
d=d';
StockCode=d(:,1);
len=size(StockCode,1);
SaveCode=cell(len,1);

debug=0;     %调试模式0关闭,1通过性,2效率

if debug == 1
    len=5;
elseif debug == 2
    len=500;
end
tic
for i=1:len
StockCode{i}(end-16:end)=[];
SaveCode{i}=StockCode{i};
str=['正在获取' SaveCode{i} '流通股信息'];
disp(str)
StockCode{i}(1:2)=[];
URL=['http://vip.stock.finance.sina.com.cn/corp/go.php/vCI_StockStructureHistory/stockid/' StockCode{i} '/stocktype/LiuTongA.phtml'];%新浪的查询页面
[~,TableCell] = GetTableFromWeb(URL);
if ~exist('TableCell','var')
    disp('获取失败,等待3秒重试...')
    pause(3);
    [~,TableCell] = GetTableFromWeb(URL);
end
if ~exist('TableCell','var')
    disp('失败跳过')
    continue;
end

TableCell=TableCell(19:end);%只有最后三个表格是流通股信息
FloatingStock=[TableCell{1};TableCell{2};TableCell{3}];%拼接流通股信息相关cell
Length = size(FloatingStock,1);%获得上条生成cell的长度
    for j=Length:-1:1
        if strcmp(FloatingStock{j,2},'持有股数')%如果某行第二列包含持有股数,则将这行删除
           FloatingStock(j,:)=[];
        else
            FloatingStock{j,2}(end-1:end)=[];%将文本形式的流通股调整成数值.
            FloatingStock{j,2}=str2double(FloatingStock{j,2})*10000;%单位是股不是手,用来计算换手率的时候调整.
        end
    end

save(['./DataBase/Stock/Floating stock_mat/' SaveCode{i}],'FloatingStock','-v7.3');
end
toc
end


