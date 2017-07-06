function URLHexCode = Unicode2URLHexCode_Ch(InputString,encoding)
% ����������ַ����е������ַ�ת����GB2312����
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2014/12/12
%% �������Ԥ����
if nargin < 2
    encoding = 'GB2312';
end
if nargin < 1
    InputString = 'BD�ٶ�Ttһ��SS';
end
if isempty(InputString)
    URLHexCode = [];
    return;
end

URLHexCode = [];
%% ת��
Len = length(InputString);
isFlag = isChineseChar(InputString,encoding);
for i = 1:Len
    if isFlag(i) == 1

        temp = unicode2native(InputString(i),encoding);
        
        HexTemp = dec2hex(temp);
        
        StrTemp =[];
        for i = 1:size(HexTemp,1)
            
            StrTemp = [StrTemp,'%',HexTemp(i,:)];
        end
        
        URLHexCode = [URLHexCode,StrTemp];
        
    else
        URLHexCode = [URLHexCode,InputString(i)];
    end
end