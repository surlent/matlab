%%��ȡ����
load HS300Data
%�����ƶ�ƽ��ֵ
Lead=3;
lag=20;
Alpha=0;
[Short, Long] = movavg(ClosePrice, Lead, lag, Alpha);
%��ͼ
plot(Date,ClosePrice);
hold on
plot(Date(Lead:end),Short(Lead:end),'r--');
plot(Date(lag:end),Long(lag:end),'b.-');
dateaxis('x',12)
%�������
legend('ClosePrcie','ShortMovavg','LongMovavg')
%X������
xlabel('date')
%Y������
ylabel('price')
%����
title('Movavg')
