%��ȡ����
filename='HS300.xls';
[num,txt,raw] = xlsread(filename);
%txt�ĵ�һ��Ϊ��������
Date=datenum(txt(4:length(txt),1));
%num������Ϊ{'���̼�','��߼�','��ͼ�','���̼�','�ɽ���';}
OpenPrice=num(:,1);
HighPrice=num(:,2);
LowPrice=num(:,3);
ClosePrice=num(:,4);
Vol=num(:,5);
%�洢������HS300Data�ļ���
save HS300Data Date OpenPrice HighPrice LowPrice ClosePrice Vol