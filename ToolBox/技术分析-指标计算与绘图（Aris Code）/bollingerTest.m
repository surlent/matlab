%%��ȡ����
load HS300Data
%�����ƶ�ƽ��ֵ
wsize=20;
wts=0; 
nstd=2;
[mid, uppr, lowr] = bollinger(ClosePrice, wsize, wts, nstd);
%��ͼ
plot(Date,ClosePrice,'k');
hold on
plot(Date(wsize:end),mid(wsize:end),'b-');
plot(Date(wsize:end),uppr(wsize:end),'r.-');
plot(Date(wsize:end),lowr(wsize:end),'r.-');
dateaxis('x',12)
%�������
legend('ClosePrcie','mid','uppr','lowr')
%X������
xlabel('date')
%Y������
ylabel('price')
%����
title('bollinger')
