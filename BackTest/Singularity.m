function Singularity(~)
%% �ز�DataBase/Index/DayIndicator_mat�ļ�����ָ��

FolderStr = './DataBase/BackTestResult/';

if ~isdir( FolderStr )
    mkdir( FolderStr );
end
    
d=dir('.\DataBase\Index\DayIndicator_mat');
d(1:2,:)=[];
d=struct2cell(d);
d=d';
len=size(d,1);
StockCode=d(:,1);
for i=1:len
    StockCode{i}(end-17:end)=[];
end

debug=0;     %����ģʽ0�ر�,1ͨ����,2Ч��
if debug == 1
    len=5;
elseif debug == 2
    len=500;
end

Strategy=[input('������?\n','s'),' in ',datestr(now,30)];
result=cell(len,5);                     %һ���ز����5��ָ��,{1Scode,2������,3�껯������,4���ձ���,5���س�,6alpha,7beta},����������ָ��,����ƽ��ʤ�ʵ�,���������.6 7 ����
mkdir( [FolderStr,Strategy,'/'] );

parfor i=1:len
     RunIndex = i;
     Scode = StockCode{i};
     strdisp=['�ز���...','���:',num2str(RunIndex),'   ','����:',Scode];
     disp(strdisp)
     FileString = [FolderStr,Strategy,'/',Scode,'_BTR.mat'];%�ļ��������浥������Scode�Ļز����
     ResourceStr=['.\DataBase\Index\DayIndicator_mat\',d{i,1}];
     result(i,:)=BT(ResourceStr,FileString,Scode);
end
temp=cell2mat(result(:,2:end));     
temp(all(temp==0,2),:)=[];          %ȥ��0ֵ
temp=mean(temp);
temp=num2cell(temp);                %����ƽ��ֵ
Mean=[{'ƽ��������'},{'ƽ���껯������'},{'ƽ�����ձ���'},{'ƽ�����س�'};temp];
save( [FolderStr,Strategy,'/Result_',Strategy,'.mat'],'result', '-v7.3');%�ļ���������ز���
save( [FolderStr,Strategy,'/Mean_',Strategy,'.mat'],'Mean', '-v7.3');%�ļ������������
clear
clc
end

        
        
        
        