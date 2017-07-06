a=GetStockList_Web;
save StockList a;
clear all;
load StockList.mat;
StockList =a;
[SaveLog,ProbList,NewList] = SaveStockInfo(StockList);