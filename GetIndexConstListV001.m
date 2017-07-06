function GetIndexConstListV001
%%6��3�ո�������ָ��ɷֹ�,��������wind

w=windmatlab;
pause(5);
FolderStr='.\DataBase\Stock\IndexConstList\';
if ~isdir(FolderStr)
    mkdir(FolderStr);
end
load('.\IndexList.mat');
IndexCode=IndexList(:,2);
IndexList(:,3)=[];
len=size(IndexCode,1);
for i=1:len
    IndexCode{i}=[IndexCode{i}(3:end),'.',IndexCode{i}(1:2)];
end

for i=1:len
    disp(['�����������������',IndexCode{i},'ָ���ɷݹ���Ϣ'])
    formatOut = 'yyyymmdd';
    temp1=datestr(now,formatOut);
    parament=['date=',temp1,';windcode=',IndexCode{i}];
    ConstList=w.wset('IndexConstituent',parament);
    if size(ConstList,1)==1
        disp([IndexCode{i},'δ�����ص�ָ���ɷݹ���Ϣ'])
        IndexList{i,3}=('������');
    end
    save([FolderStr,IndexCode{i},'_ConstList.mat'],'ConstList','-v7.3');
end
save('.\IndexListMask.mat','IndexList','-v7.3');
end

%%000�汾��������
%%����ָ��ɷֹ�
% %�������������ط�����
% %��ָ֤����000001-000188,���Ի����� http://www.sse.com.cn/market/sseindex/indexlist/constlist/index.shtml?COMPANY_CODE=XXXXXX&INDEX_Code=XXXXXX
% %��ָ֤����399001-399615,���Թ�ָ֤�� http://www.cnindex.com.cn/docs/yb_XXXXXX.xls
% %��ָ֤����399701-399706,�ֹ��������վ����excel�ļ�,��ָ֤��û��
% %��ָ֤����000300-����,��ָ֤����399707-��������:��֤ ftp://115.29.204.48/webdata/XXXXXXcons.xls
% diary on
% FolderStr='.\DataBase\Stock\IndexConstList\';
% if ~isdir(FolderStr)
%     mkdir(FolderStr);
% end
% load('.\IndexList.mat');
% IndexCode=IndexList(:,2);
% len=size(IndexCode,1);
% for i=1:len
%     IndexCode{i}=IndexCode{i}(3:end);
% end
% point1=find(strcmp(IndexCode,'000300'));
% point2=find(strcmp(IndexCode,'399001'));
% point3=find(strcmp(IndexCode,'399701'));
% point4=find(strcmp(IndexCode,'399707'));
%
% for i=1:len
%     if i<point1
%         %http://www.sse.com.cn/market/sseindex/indexlist/s/iXXXXXX/const_list.shtml
%         url=['http://www.sse.com.cn/market/sseindex/indexlist/s/i' IndexCode{i} '/const_list.shtml' ];
%         try
%             table=getTableFromWeb_mod(url,2);
%         catch
%             disp([IndexCode{i} '��ȡҳ����Ϣ����'])
%         end
%         size1=size(table,1);
%         size2=size(table,2);
%         newLen=size1*size2;
%         ConstList=reshape(table,[newLen,1]);
%         for j=1:newLen
%             if isempty(ConstList{j})
%                 continue
%             end
%             ConstList{j}=[ConstList{j}(1:4),ConstList{j}(end-6:end-1)];
%         end
%         save([FolderStr,IndexCode{i},'.mat'],'ConstList','-v7.3');
%     elseif i>=point1 && i<point2 || i>=point4
%         %ftp://115.29.204.48/webdata/XXXXXXcons.xls
%         url=['ftp://115.29.204.48/webdata/' IndexCode{i} 'cons.xls' ];
%         filename=[FolderStr,IndexCode{i},'.xls']; %������ļ���
%         [~,status]=urlwrite(url,filename);%��������
%         if status==1
%             disp('���سɹ�');
%         else
%             disp([IndexCode{i},'����ʧ��']);
%         end
%         pause(10);
%     elseif i>=point2 && i<point3
%         %http://www.cnindex.com.cn/docs/yb_XXXXXX.xls
%         url=['http://www.cnindex.com.cn/docs/yb_' IndexCode{i} '.xls' ];
%         filename=[FolderStr,IndexCode{i},'.xls']; %������ļ���
%         [~,status]=urlwrite(url,filename);%��������
%         if status==1
%             disp('���سɹ�');
%         else
%             disp([IndexCode{i},'����ʧ��']);
%         end
%         pause(10);
%     else
%         %�ֹ�����
%         continue
%     end
%
% end
% diary off
%
% end