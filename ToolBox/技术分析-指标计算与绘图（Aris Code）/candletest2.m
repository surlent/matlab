%��ȡ����
load HS300Data
%����������ͼ��һ����2010��ģ�һ��2010��6�µ�
subplot(2,1,1)
%2010������ݣ�����ʱ�����ݵ�����ж�
Idx2010=find(year(Date)==2010);
candle(HighPrice(Idx2010), LowPrice(Idx2010), ClosePrice(Idx2010),...
    OpenPrice(Idx2010),[],Date(Idx2010),12);%ʱ���ʽΪ ����/�ꡱ
title('2010��K��')
%2010�꽻����
subplot(2,1,2)
bar(Date(Idx2010),Vol(Idx2010))
dateaxis('x',12)
%��������ʹ��������ͼ��X�����
axis([Date(Idx2010(1)), Date(Idx2010(end)), 0, max(Vol(Idx2010))])
title('2010�꽻����')


