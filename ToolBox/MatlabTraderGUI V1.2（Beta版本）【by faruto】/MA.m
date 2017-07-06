function MA_value = MA(Price, MAlen)
% �ƶ�ƽ����
% by liyang 2011/12/13
% farutoliyang@gmail.com
% Input:
%       Price: ���������
%       MAlen: ��������
% Output:
%       MA_value: ����ľ��߷���ֵ

%% ����������
if nargin < 2
    % Ĭ�Ͼ�������Ϊ5��5�����ߡ�5���ߣ�
    MAlen = 5;
end
error(nargchk(1, 2, nargin));
if MAlen <= 0
    error('The length of MA must >= 1');
end
%% ��ʼ��
len = numel(Price);
MA_value = zeros(len, 1);
Price = Price(:);
%% �������
MA_value(1:MAlen-1) = Price(1:MAlen-1);
for i = MAlen:len
     MA_value(i) = sum( Price(i-MAlen+1:i) )/MAlen;
end
%% 
if nargout == 0
    figure;
    hold on;
    plot(Price);
    plot(MA_value, 'r');
    grid on;
    str = ['MA',num2str(MAlen)];
    legend('Price', str);
    hold off;
end
