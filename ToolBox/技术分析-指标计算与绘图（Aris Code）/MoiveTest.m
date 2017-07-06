%%��ȡ����
load HS300Data
%K��ͼ �ƶ�ƽ���� ���ִ� MACD
%ʹ��ѭ����ʽ��ͼ��Ҳ���Բ��ô����ķ�ʽ��
%��2010-2011��ǰ100�������յĶ�̬ͼ������100����������Tick���ݣ�6�룩
%�ӵ�51�����ݿ�ʼ��ͼ��һ���ͼ��Ҫ��ʷ���ݣ�
%��ͼ
figure

for i=51:100
    %�۸�
    subplot(2,2,1)
    plot(Date(1:i),ClosePrice(1:i),'b');
    hold on
    %��ͼ��ĳ����趨Ϊ100�����ݵ�
    %�ɸ���ʵ�����������3��Сʱ��ÿ6��һ�����ݣ����ݳ���Ϊ1800
    plot(Date(100),ClosePrice(100));
    dateaxis('x',12)
    title('�۸�')
    legend('Price')
    drawnow
    %�ƶ�ƽ����
    subplot(2,2,2)
    [Short, Long] = movavg(ClosePrice(1:i), 3, 20, 0);
    %��ͼ
    plot(Date(1:i),ClosePrice(1:i));
    hold on
    plot(Date(3:i),Short(3:i),'r--');
    plot(Date(20:i),Long(20:i),'b.-');
    plot(Date(100),ClosePrice(100));
    dateaxis('x',12)
    %��ͼ��ĳ����趨Ϊ100�����ݵ�
    %�ɸ���ʵ�����������3��Сʱ��ÿ6��һ�����ݣ����ݳ���Ϊ1800
    
    %�������
    legend('ClosePrcie','ShortMovavg','LongMovavg')
    title('�ƶ�ƽ����')
    drawnow
    %���ִ�
    subplot(2,2,3)
    wsize=20;
    [mid, uppr, lowr] = bollinger(ClosePrice(1:i), 20, 0, 2);
    plot(Date(1:i),ClosePrice(1:i),'k');
    hold on
    plot(Date(wsize:i),mid(wsize:i),'b-');
    plot(Date(wsize:i),uppr(wsize:i),'r.-');
    plot(Date(wsize:i),lowr(wsize:i),'r.-');
    %��ͼ��ĳ����趨Ϊ100�����ݵ�
    %�ɸ���ʵ�����������3��Сʱ��ÿ6��һ�����ݣ����ݳ���Ϊ1800
    plot(Date(100),ClosePrice(100));
    dateaxis('x',12)
    %�������
    legend('ClosePrcie','mid','uppr','lowr')
    title('bollinger')
    drawnow
    %MACD
    subplot(2,2,4)
    [macdvec, nineperma] = macd(ClosePrice(1:i));
    plot(Date(1:i),macdvec(1:i),'r');
    hold on
    plot(Date(1:i),nineperma(1:i),'b--');
    legend('Macdvec','Nineperma')
    %��ͼ��ĳ����趨Ϊ100�����ݵ�
    %�ɸ���ʵ�����������3��Сʱ��ÿ6��һ�����ݣ����ݳ���Ϊ1800
    plot(Date(100),0);
    dateaxis('x',12);
    title('MACD')
    drawnow
    
    %��ͣ6S
    pause(6)
    %��ʾ���н׶� 
    sprintf('Now run %d',i)
end