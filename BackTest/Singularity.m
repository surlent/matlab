function Singularity(~)
%% 回测DataBase/Index/DayIndicator_mat文件夹下指标

FolderStr = './DataBase/BackTestResult/';

if ~isdir( FolderStr )
    mkdir( FolderStr );
end
    
d=dir('.\DataBase\Index\DayIndicator_mat');
d(1:2,:)=[];
d=struct2cell(d);
d=d';
len=size(d,1);
StockCode=d(:,1);
for i=1:len
    StockCode{i}(end-17:end)=[];
end

debug=0;     %调试模式0关闭,1通过性,2效率
if debug == 1
    len=5;
elseif debug == 2
    len=500;
end

Strategy=[input('策略名?\n','s'),' in ',datestr(now,30)];
result=cell(len,5);                     %一个回测包含5个指标,{1Scode,2总收益,3年化收益率,4夏普比率,5最大回撤,6alpha,7beta},还有其他的指标,比如平均胜率等,今后再增加.6 7 暂无
mkdir( [FolderStr,Strategy,'/'] );

parfor i=1:len
     RunIndex = i;
     Scode = StockCode{i};
     strdisp=['回测中...','序号:',num2str(RunIndex),'   ','代码:',Scode];
     disp(strdisp)
     FileString = [FolderStr,Strategy,'/',Scode,'_BTR.mat'];%文件用来保存单个具体Scode的回测过程
     ResourceStr=['.\DataBase\Index\DayIndicator_mat\',d{i,1}];
     result(i,:)=BT(ResourceStr,FileString,Scode);
end
temp=cell2mat(result(:,2:end));     
temp(all(temp==0,2),:)=[];          %去除0值
temp=mean(temp);
temp=num2cell(temp);                %计算平均值
Mean=[{'平均总收益'},{'平均年化收益率'},{'平均夏普比率'},{'平均最大回撤'};temp];
save( [FolderStr,Strategy,'/Result_',Strategy,'.mat'],'result', '-v7.3');%文件用来保存回测结果
save( [FolderStr,Strategy,'/Mean_',Strategy,'.mat'],'Mean', '-v7.3');%文件用来保存汇总
clear
clc
end

        
        
        
        