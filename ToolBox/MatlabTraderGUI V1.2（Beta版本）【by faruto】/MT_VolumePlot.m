function MT_VolumePlot(Open, High, Low, Close, Vol)
% ��������
% �ɽ���ͼ��չʾ
% Last Modified by LiYang 2011/12/29
% Email:faruto@163.com
% ����ʵ�ֲ�����ʹ�õ�MATLAB�汾��MATLAB R2011b(7.13)
% ������������������в��ˣ������ȼ����MATLAB�İ汾�ţ��Ƽ�ʹ�ý��°汾��MATLAB��
%%
len = length(Open);

for i = 1:len
    if Close(i) >= Open(i)
        bar(i,Vol(i),'w','EdgeColor','r');
        hold on;
    else
        bar(i,Vol(i),'g','EdgeColor','g');
        hold on;
    end
end
