function [FileListCell,SaveLog,ProbList,NewList] = SaveStockNotice(StockList)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%% �������Ԥ����
if nargin < 1 || isempty(StockList)
    load StockList.mat;
end

FileListCell = [];
SaveLog = [];
ProbList = [];
NewList = [];

Len = size(StockList, 1);
StockCode = StockList(:,2);
StockName = StockList(:,1);

Date_G = '20050101';
%% ��Ȩʱ������

ticID = tic;
% 1:Len
% 1:1041
% 1042:2286
% 2287:Len
for i = 1:Len
    disp('======')
    RunIndex = i
    Scode = StockCode{i}
    Sname = StockName{i}
    disp('============')
    
    % % DebugMode
    DebugMode_OnOff = 0;
    if 1 == DebugMode_OnOff
       if strcmpi(Scode,'sh600009')~=1
           continue;
       end
    end    
    
    FolderStr = ['./DataBase/Stock/StockNotice_file/',StockCode{i},'_NoticeFile'];
    if ~isdir( FolderStr )
        mkdir( FolderStr );
    end
    
    FileString = [FolderStr,'/',StockCode{i},'_NoticeFile.mat'];
    FileExist = 0;
    if exist(FileString, 'file') == 2
        FileExist = 1;
    end
    
    % % �������ݴ��ڣ�����β���������
    if 1 == FileExist
        try

            MatObj = matfile(FileString,'Writable',true);
            [nrows, ncols]=size(MatObj,'FileListCell');
            
            if nrows>1
                len = nrows;
                Temp = MatObj.FileListCell(len,2);
                Temp = Temp{1};
                DateTemp = datestr( datenum(num2str(Temp),'yyyymmddHHMM')+1,'yyyy-mm-dd' );
                
                StockCodeInput = Scode;
                BeginDate = DateTemp;
                EndDate = datestr(today, 'yyyymmdd');
                
                [NoticeDataCell] = GetStockNotice_Web(StockCodeInput,BeginDate,EndDate);
                if isempty(NoticeDataCell)
                    str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ�û�����¹��棬���飡' ];
                    disp(str);
                    LenTemp = size( ProbList,1 )+1;
                    ProbList{LenTemp,1} = Sname;
                    ProbList{LenTemp,2} = Scode;
%                     continue;
                end
                
                newFileListCell = NoticeDataCell2FileListCell(NoticeDataCell);
                
                MatObj.FileListCell = [MatObj.FileListCell;newFileListCell(2:end,:)];
                
                
            else % % �������ݴ��ڣ���Ϊ��
                % % ��ȡ��������
                FolderStr_StockInfo = ['./DataBase/Stock/StockInfo_mat'];
                FileString_StockInfo = [FolderStr_StockInfo,'/',StockCode{i},'_StockInfo.mat'];
                if exist(FileString_StockInfo, 'file') == 2
                    str = ['load ',FileString_StockInfo];
                    eval(str);
                    if ~isempty( StockInfo.IPOdate )
                        IPOdate = StockInfo.IPOdate;
                    else
                        IPOdate = Date_G;
                    end
				else
					IPOdate = Date_G;
				end
                DateTemp = datestr( datenum(num2str(IPOdate),'yyyymmdd'),'yyyy-mm-dd' );
                
                LenTemp = size( NewList,1 )+1;
                NewList{LenTemp,1} = Sname;
                NewList{LenTemp,2} = Scode;
                
                StockCodeInput = Scode;
                BeginDate = DateTemp;
                EndDate = datestr(today, 'yyyymmdd');
                
                [NoticeDataCell] = GetStockNotice_Web(StockCodeInput,BeginDate,EndDate);
                if isempty(NoticeDataCell)
                    str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ�û�����¹��棬���飡' ];
                    disp(str);
                    LenTemp = size( ProbList,1 )+1;
                    ProbList{LenTemp,1} = Sname;
                    ProbList{LenTemp,2} = Scode;
%                     continue;
                end
                
                newFileListCell = NoticeDataCell2FileListCell(NoticeDataCell);
                
                MatObj.FileListCell = newFileListCell;
                
            end
        catch
            str = [ StockCode{i},'-',StockName{i}, ' ��������ʧ�ܻ�����ԭ�����ݸ���ʧ�ܣ��������������ݣ�' ];
            disp(str);
            FileExist = 0;
        end
    end
    
    % % �������ݲ�����
    if 0 == FileExist
        % % ��ȡ��������
        FolderStr_StockInfo = ['./DataBase/Stock/StockInfo_mat'];
        FileString_StockInfo = [FolderStr_StockInfo,'/',StockCode{i},'_StockInfo.mat'];
        if exist(FileString_StockInfo, 'file') == 2
            str = ['load ',FileString_StockInfo];
            eval(str);
            if ~isempty( StockInfo.IPOdate )
                IPOdate = StockInfo.IPOdate;
            else
                IPOdate = Date_G;
            end
        else
            IPOdate = Date_G;
        end
        DateTemp = datestr( datenum(num2str(IPOdate),'yyyymmdd'),'yyyy-mm-dd' );
        
        LenTemp = size( NewList,1 )+1;
        NewList{LenTemp,1} = Sname;
        NewList{LenTemp,2} = Scode;
        
        StockCodeInput = Scode;
        BeginDate = DateTemp;
        EndDate = datestr(today, 'yyyymmdd');
        
        [NoticeDataCell] = GetStockNotice_Web(StockCodeInput,BeginDate,EndDate);
        if isempty(NoticeDataCell)
            str = [ StockCode{i},'-',StockName{i}, ' ���ݻ�ȡʧ�ܻ�û�����¹��棬���飡' ];
            disp(str);
            LenTemp = size( ProbList,1 )+1;
            ProbList{LenTemp,1} = Sname;
            ProbList{LenTemp,2} = Scode;
            continue;
        end
        
        newFileListCell = NoticeDataCell2FileListCell(NoticeDataCell);
        
        FileListCell = newFileListCell;
        save(FileString, 'FileListCell','-v7.3');
    end
    
    
    % % �����ļ����������ݿ�
%     if ~isempty(newFileListCell)
%         str = ['===FileSave2LocalDB Begin==='];
%         disp(str);
%         str = ['�����ļ�������'];
%         disp(str);      
%         
%         tLen = size(newFileListCell,1);
%         for tR = 2:tLen
%             temp = newFileListCell{tR,7};
%             
%             tFileString = [FolderStr,'/',temp]
%             
%             tURL = newFileListCell{tR,5}
%             
%             try
%                 outfilename = websave(tFileString,tURL);
%             catch err
%                 str = ['����ʱ�䣺',datestr(now),' �����ļ�ʧ�ܣ�',err.message];
%                 fprintf('%s\n',str);
%                 for i = 1:size(err.stack,1)
%                     str = ['FunName��',err.stack(i).name,' Line��',num2str(err.stack(i).line)];
%                     fprintf('%s\n',str);
%                 end
%             end
%         end
%         str = ['===FileSave2LocalDB End==='];
%         disp(str);         
%     end
    
    % % �����ļ����������ݿ�-ȫ�ļ��б���
    if 1 == FileExist
        FileListCellFull = MatObj.FileListCell;
    else
        FileListCellFull = newFileListCell;
    end
    if ~isempty(FileListCellFull)
        str = ['===FileSave2LocalDB_Full Begin==='];
        disp(str);
        str = ['�����ļ�������'];
        disp(str);      
        
        tLen = size(FileListCellFull,1);
        for tR = 2:tLen
            temp = FileListCellFull{tR,7};
            
            % �ļ�����飬�ļ������ܰ��� / \ : * �� " < > |
            CheckChar = {'\';'/';':';'*';'?';'"';'<';'>';'|';char(26)};
            CFlag = 0;
            for Ti = 1:length(CheckChar)
                if sum( temp==CheckChar{Ti} ) ~= 0
                    temp( temp==CheckChar{Ti} ) = '_';
                    CFlag = 1;
                end
            end
            if 1 == FileExist && 1 == CFlag
                tCell = {temp};
                MatObj.FileListCell(tR,7) = tCell;
            end
            
            tFileString = [FolderStr,'/',temp];
            if exist(tFileString, 'file') ~= 2
                FileSave = tFileString
                tURL = FileListCellFull{tR,5};
                
                try
                    options = weboptions('Timeout',60);
                    outfilename = websave(tFileString,tURL,options);
                catch err
                    str = ['����ʱ�䣺',datestr(now),' �����ļ�ʧ�ܣ�',err.message];
                    fprintf('%s\n',str);
                    for i = 1:size(err.stack,1)
                        str = ['FunName��',err.stack(i).name,' Line��',num2str(err.stack(i).line)];
                        fprintf('%s\n',str);
                    end
                end
                
            end
        end
        str = ['===FileSave2LocalDB_Full End==='];
        disp(str);         
    end

    
    NewListLen = size(NewList,1)
    ProbListLen = size(ProbList,1)
    
    elapsedTimeTemp = toc(ticID);
    str = [ 'ѭ���Ѿ��ۼƺ�ʱ', num2str(elapsedTimeTemp), ' seconds(',num2str(elapsedTimeTemp/60), ' minutes)',...
        '(',num2str(elapsedTimeTemp/60/60), ' hours)',];
    disp(str);
    str = ['Now Time:',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    disp(str);
end

end
% % % [EOF_Main]


%% sub function - NoticeDataCell2FileListCell
function newFileListCell = NoticeDataCell2FileListCell(NoticeDataCell)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%% �������Ԥ����
if isempty(NoticeDataCell)
    newFileListCell = [];
    return;
end
% Head = {'StockCode','DateTime'[Str],'Title','NoticeType','FileURL','FileSize'};
% 2
% Head = {'StockCode','DateTime'[Double],'Title','NoticeType','FileURL','FileSize','FileName'};
newFileListCell = cell(size(NoticeDataCell,1),size(NoticeDataCell,2)+1);
newFileListCell(:,1:size(NoticeDataCell,2)) = NoticeDataCell;
newFileListCell{1,size(newFileListCell,2)} = 'FileName';
%% loop
for i = 2:size(NoticeDataCell,1)
    temp = NoticeDataCell{i,2};
    temp = datestr(datenum(temp),'yyyymmddHHMM');
    temp = str2double(temp);
    newFileListCell{i,2} = temp;
    
    tURL = NoticeDataCell{i,5};
    NameExt = GetExtName(tURL);
    
    Fstr = [NoticeDataCell{i,1},'_',num2str(newFileListCell{i,2}),'_',NoticeDataCell{i,3},NameExt];
    
    % �ļ�����飬�ļ������ܰ��� / \ : * �� " < > | 
    CheckChar = {'\';'/';':';'*';'?';'"';'<';'>';'|';char(26)};
    for Ti = 1:length(CheckChar)
        if sum( Fstr==CheckChar{Ti} ) ~= 0
            Fstr( Fstr==CheckChar{Ti} ) = '_';
        end;
    end
    
    newFileListCell{i,7} = Fstr;
    
end

end
% % % [EOF_NoticeDataCell2FileListCell]

%% sub function-GetExtName
function ExtName = GetExtName(URL)
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/01/01
%% �������Ԥ����
ExtName = '.ExtensionNotKnown';
if isempty(URL)
    return;
end

%%
ExtNameCell = {'.pdf',...
    '.doc','.docx','.xls','.xlsx',...
    '.ppt','.pptx',...
    '.txt','.html',...
    '.mat',...
    '.jpg','.png','.tiff','.bmp','.jpeg','gif'};

% for i = 1:length(ExtNameCell)
%     expr = ExtNameCell{i};
%     out = regexpi(URL, expr,'match');
%     if ~isempty( out )
%         ExtName = out{1};
%         if strcmpi(expr,'.doc') || strcmpi(expr,'.ppt') || strcmpi(expr,'.xls')
%             ExtName = [ExtName,'X'];
%         end        
%         break;
%     end
% end

ind = find( URL =='/' );
if ~isempty(ind)
    ind = ind(end);
    Tind = find( URL =='?' );
    if ~isempty(Tind) && Tind(1)>ind
        Tind = Tind(1);
        DotInd = find(URL(ind:Tind) == '.',1);
        if ~isempty(DotInd)
            temp = URL(ind:Tind);
            ExtName = temp(DotInd:end-1);
        end
    end
end

if strcmpi(ExtName, '.ExtensionNotKnown')
    ind = find( URL == '.' );
    if ~isempty(ind)
        ind = ind(end);
        Temp = URL(ind:end);
        if strcmpi(Temp,'.cn') || strcmpi(Temp,'.com') || ...
                strcmpi(Temp,'.net') || strcmpi(Temp,'.org')
            ExtName = '.html';
        end
    end
end

end
% % % [EOF_GetExtName]
