clc;
a=GetStockList_Web;
save StockList a;
clear all;
load StockList.mat;
a(:,1) = [];
a(:,2) = [];
StockList =a;
clear a;
a=dir('e:\FQuantToolBox\DataBase\Stock\Tick_mat');
b=numel(a);
c=cell(b-2,1);
%str1='e:\FQuantToolBox\DataBase\Stock\Tick_mat\'
for i=3:b
    temp=a(i).name;
    temp(end-4:end)=[];
    c{i-2}=temp;
    %str=[str1,temp];
end
StockList=setdiff(StockList,c)
clear a b c diff i temp;
