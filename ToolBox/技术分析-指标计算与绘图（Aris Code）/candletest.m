%��ȡ����
load HS300Data
%����������ͼ��һ����2010��ģ�һ��2010��6�µ�
subplot(2,1,1)
%2010������ݣ�����ʱ�����ݵ�����ж�
Idx2010=find(year(Date)==2010);
candle(HighPrice(Idx2010), LowPrice(Idx2010), ClosePrice(Idx2010),...
    OpenPrice(Idx2010),[],Date(Idx2010),12);%ʱ���ʽΪ ����/�ꡱ
title('2010��K��')
%2010��6�µ�K��
subplot(2,1,2)
%��2010���ʱ��������ѡȡ�·�Ϊ6������
Idx=find(month(Date(Idx2010))==6);
Idx2010_06=Idx2010(Idx);
candle(HighPrice(Idx2010_06), LowPrice(Idx2010_06), ClosePrice(Idx2010_06),...
    OpenPrice(Idx2010_06),[],Date(Idx2010_06),12);%ʱ���ʽΪ ����/�ꡱ
title('2010��6��K��')
