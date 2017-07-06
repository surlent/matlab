function URLHexCode = Unicode2URLHexCode(unicodestr,encoding)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/01/01
%% �������Ԥ����
if nargin < 2
    encoding = 'GB2312';
end
if nargin < 1
    unicodestr = '�ٶ�һ��';
end

URLHexCode = [];
%% ת��

temp = unicode2native(unicodestr,encoding);

HexTemp = dec2hex(temp);

StrTemp =[];
for i = 1:size(HexTemp,1)
    
    StrTemp = [StrTemp,'%',HexTemp(i,:)];
end

URLHexCode = StrTemp;