function [KValue,DValue,JValue]=KDJ(High,Low,Close,N,M,L,S)
%----------------------�˺�����������KDJָ��(���ָ��)---------------------
%----------------------------------��д��--------------------------------
%Lian Xiangbin(����,785674410@qq.com),DUFE,2014
%----------------------------------�ο�----------------------------------
%[1]����֤ȯ.���ڴ�����ָ��Ķ�����ѡ��ģ��,2014-04-11
%[2]���֤ȯ.����ָ��ϵ�У�һ������KDJ�Ż�ָ�꣬6���ۻ�����17.5��,2012-05-07
%[3]����֤ȯ.����ָ���Ż���ʱ��10��30������,2010-12-23
%[4]MBA�ǿ�ٿ�.KDJ����
%[5]����ʤ.ָ�꾫�ͣ����似��ָ�꾫��������.������ѧ������,2004��01�µ�1��
%----------------------------------���----------------------------------
%KDJָ�꣬��George Lane�״������������ڻ��г���������Ҫ���������ǣ����۸�����ʱ
%�����м������ڽӽ����ռ۸�������϶ˣ��෴�����½����������м������ڽӽ����ռ�
%��������¶ˡ����ָ��(KDJ)һ���Ǹ���ͳ��ѧ��ԭ����ͨ��һ���ض��������ڳ��ֹ�
%����߼ۡ���ͼۼ����һ���������ڵ����̼ۼ�������֮��ı�����ϵ�����������һ��
%�������ڵ�δ�������ֵRSV��Ȼ�����ƽ���ƶ�ƽ���ߵķ���������Kֵ��Dֵ��Jֵ��
%----------------------------------�����÷�------------------------------
%1)��KD����80ʱ�������źţ���KD����20ʱ�����ź�
%2)��K�ϴ�Dʱ���룬��K�´�Dʱ����
%3)J����100����С��0����
%----------------------------------���ú���------------------------------
%[KValue,DValue,JValue]=KDJ(High,Low,Close,N,M,L,S)
%----------------------------------����----------------------------------
%High-ÿ��Bar����߼�����
%Low-ÿ��Bar����ͼ�����
%Close-ÿ��Bar�����̼�����
%N-����RSVʱ�����ǵ����ڣ�RSV���������ڵļ۸��ڹ�ȥn���λ�������,����14
%M-����Kֵʱ�Ĳ���,����3
%L-����Dֵʱ�Ĳ���,����3
%S-����Jֵʱ�Ĳ���,����3
%----------------------------------���----------------------------------
%KValue-Kֵ
%DValue-Dֵ
%JValue-Jֵ
RSV=zeros(length(High),1);
KValue=zeros(length(High),1);
DValue=zeros(length(High),1);
JValue=zeros(length(High),1);
RSV(1:N-1)=50;
KValue(1:N-1)=50;
DValue(1:N-1)=50;
for i=N:length(High)
    RSV(i)=(Close(i)-min(Low(i-N+1:i)))/(max(High(i-N+1:i))-min(Low(i-N+1:i)))*100;
    KValue(i)=(M-1)/M*KValue(i-1)+1/M*RSV(i);
    DValue(i)=(L-1)/L*DValue(i-1)+1/L*KValue(i);
end
JValue=S*DValue-(S-1)*KValue;
end







