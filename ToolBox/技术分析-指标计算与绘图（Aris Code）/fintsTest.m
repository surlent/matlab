%��ȡ����
load HS300Data
%����תʱ�����и�ʽ
HS300_TS = fints(Date,[OpenPrice HighPrice LowPrice ClosePrice Vol]);
%ʱ������ת���� 
HS300_mat1= fts2mat(HS300_TS);
HS300_mat2= fts2mat(HS300_TS,1);
