function EMAValue=EMA(Price,Length)
%------------------------�˺�����������ָ���ƶ�ƽ��------------------------
%----------------------------------��д��--------------------------------
%Lian Xiangbin(����,785674410@qq.com),DUFE,2014
%----------------------------------�ο�----------------------------------
%[1]����֤ȯ.���ڴ�����ָ��Ķ�����ѡ��ģ��,2014-04-11
%[2]�ٶȰٿ�.�ƶ�ƽ���ߴ���
%[3]Elder.�Խ���Ϊ��.��е��ҵ�����磬2010��4�µ�1��
%----------------------------------���----------------------------------
%�ƶ�ƽ������������������Ͷ��ר�Ҹ�������20��������������ġ����������ǵ���Ӧ��
%���ձ�ļ���ָ��֮һ��������������ȷ���������ơ��жϽ����ֵ����Ƶȡ�ָ���ƶ�ƽ
%�����ǱȽ����е�һ���ƶ�ƽ���ߣ�����Ϊ�Ͻ��ļ۸���м�ֵ��Ҳ����˵��������Ͻ�
%�ļ۸�����Ȩ��
%----------------------------------�����÷�------------------------------
%1)������۸��γɽ�����룬�γ���������
%2)���ھ����볤�ھ����γɽ�����룬�γ���������
%----------------------------------���ú���------------------------------
%EMAValue=EMA(Price,Length)
%----------------------------------����----------------------------------
%Price-Ŀ��۸�����
%Length-����ָ���ƶ�ƽ��������
%----------------------------------���----------------------------------
%EMAValue��ָ���ƶ�ƽ��ֵ

EMAValue=zeros(length(Price),1);
K=2/(Length+1);
indexlength=length(Price);
for i=1:indexlength
    if i==1
        EMAValue(i)=Price(i);
    else
        EMAValue(i)=Price(i)*K+EMAValue(i-1)*(1-K);
    end
end
end
