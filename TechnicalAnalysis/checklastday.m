d=dir ('./DataBase/Stock/Day_ForwardAdj_mat');
d(1:2,:)=[];
d=struct2cell(d);
d=d';
len=size(d,1);
StockCode=d(:,1);
for i=1:len
StockCode{i}(end-16:end)=[];
end

CheckResultsLastDay=cell(len,2);
CheckResultsLastDay(:,1)=StockCode;

for i=1:len
    ResourceStr=['./DataBase/Stock/Day_ForwardAdj_mat/',d{i,1}];
    load(ResourceStr);
    CheckResultsLastDay{i,2}=StockData(end,1);
end

xlswrite('./TechnicalAnalysis/CheckResultsLastDay',CheckResultsLastDay);
clear;
clc;