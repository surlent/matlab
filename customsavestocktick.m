clc;
a=GetStockList_Web;
save StockList a;
clear all;
load StockList.mat;
StockList =a;
clear a;
a=dir('.\DataBase\Stock\Tick_mat');   
b=numel(a);
c=input('…œ¥Œ÷–∂œ∫≈','s');
%str1='i:\FQuantToolBox\DataBase\Stock\Tick_mat\'
for i=3:b
    temp=a(i).name;
    temp(end-4:end)=[];
    bb=strncmp(temp,c,8);
    if bb==1;
        continue
    end
    aa=strmatch(temp,StockList(:,2));
    StockList(aa,:)=[];
    %str=[str1,temp];
end
clear a b diff i temp aa bb c;

DtempEnd = datenum(datestr(date,'yyyymmdd'),'yyyymmdd');
DtempStart = datenum('20050101', 'yyyymmdd');
Dtemp = (DtempStart:DtempEnd)';
DateList = str2num( datestr(Dtemp,'yyyymmdd') );
CheckFlag = 0;
PList = [];
[SaveLog,ProbList,NewList] = SaveStockTick(StockList,DateList,PList,CheckFlag);