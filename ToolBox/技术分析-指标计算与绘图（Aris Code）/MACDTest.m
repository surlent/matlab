%%%��ȡ����
load HS300Data
%����MACD
[macdvec, nineperma] = macd(ClosePrice);
%��ͼ
subplot(2,1,1) %����300���̼�ͼ
plot(Date,ClosePrice);
legend('ClosePrice')
dateaxis('x',12);
subplot(2,1,2);%����300MACDָ��
plot(Date,macdvec,'r');
hold on
plot(Date,nineperma,'b--');
legend('Macdvec','Nineperma')
dateaxis('x',12);
