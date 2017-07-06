function GetIndexConstListV001
%%6月3日更新下载指标成分股,数据来自wind

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
    disp(['正在下载最近交易日',IndexCode{i},'指数成份股信息'])
    formatOut = 'yyyymmdd';
    temp1=datestr(now,formatOut);
    parament=['date=',temp1,';windcode=',IndexCode{i}];
    ConstList=w.wset('IndexConstituent',parament);
    if size(ConstList,1)==1
        disp([IndexCode{i},'未能下载到指数成份股信息'])
        IndexList{i,3}=('无内容');
    end
    save([FolderStr,IndexCode{i},'_ConstList.mat'],'ConstList','-v7.3');
end
save('.\IndexListMask.mat','IndexList','-v7.3');
end

%%000版本内容如下
%%下载指标成分股
% %数据来自三个地方如下
% %上证指数从000001-000188,来自沪交所 http://www.sse.com.cn/market/sseindex/indexlist/constlist/index.shtml?COMPANY_CODE=XXXXXX&INDEX_Code=XXXXXX
% %深证指数从399001-399615,来自国证指数 http://www.cnindex.com.cn/docs/yb_XXXXXX.xls
% %深证指数从399701-399706,手工自深交所网站下载excel文件,国证指数没有
% %上证指数从000300-结束,深证指数从399707-结束来自:中证 ftp://115.29.204.48/webdata/XXXXXXcons.xls
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
%             disp([IndexCode{i} '读取页面信息出错'])
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
%         filename=[FolderStr,IndexCode{i},'.xls']; %保存的文件名
%         [~,status]=urlwrite(url,filename);%下载命令
%         if status==1
%             disp('下载成功');
%         else
%             disp([IndexCode{i},'下载失败']);
%         end
%         pause(10);
%     elseif i>=point2 && i<point3
%         %http://www.cnindex.com.cn/docs/yb_XXXXXX.xls
%         url=['http://www.cnindex.com.cn/docs/yb_' IndexCode{i} '.xls' ];
%         filename=[FolderStr,IndexCode{i},'.xls']; %保存的文件名
%         [~,status]=urlwrite(url,filename);%下载命令
%         if status==1
%             disp('下载成功');
%         else
%             disp([IndexCode{i},'下载失败']);
%         end
%         pause(10);
%     else
%         %手工下载
%         continue
%     end
%
% end
% diary off
%
% end