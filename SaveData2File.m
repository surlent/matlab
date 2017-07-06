function [Status, Message] = SaveData2File(Data, FileName, ColNamesCell,varargin)
%% SaveData2File
% by LiYang_faruto
% Email:farutoliyang@foxmail.com
% 2015/05/01
%% �������Ԥ����
Status = 1;
Message = [];
if nargin < 3 || isempty(ColNamesCell)
    ColNamesCell = [];
end
if nargin < 2 || isempty(FileName)
    FileName = 'OutData.xlsx';
end
if nargin < 1 || isempty(Data)
    Status = 0;
    Message = 'ȱ��������������������������ݣ�';
    disp(Message);
    return;
end

% ColNamesCell ����
[Rlen, Clen] = size(Data);
if ~isempty(ColNamesCell)
    tlen = length(ColNamesCell);
    if tlen < Clen
        for i = tlen+1:Clen
            str = ['VarName',num2str(i)];
            ColNamesCell{i} = str;
        end
    end
    
    if tlen > Clen
        ColNamesCell = ColNamesCell(1:Clen);
    end
end

% FileName ��鴦��
ind = find(FileName == '.', 1,'last');
if isempty(ind)
    FileName = [FileName,'.xlsx'];
    ind = find(FileName == '.', 1,'last');
end
ExtCell = {'.txt','.dat','.csv','.xls','.xlsb','.xlsx','.xlsm'};

ExtName = FileName(ind:end);
if ~ismember(ExtName, ExtCell)
    Status = 0;
    Message = '����������ļ���չ��������֧��������չ����';
    disp(Message);
    disp(ExtCell);
    return;
end

tExtCell = {'.xls','.xlsb','.xlsx','.xlsm'};
if ismember(ExtName, tExtCell)
    warning('off')
end

%% Main

switch class( Data )
    case 'double'
        
        [tS, tM] = Double2File(Data, FileName, ColNamesCell,varargin{:});
        
    case 'cell'
        
        [tS, tM] = Cell2File(Data, FileName, ColNamesCell,varargin{:});
        
    case 'struct'
        
        [tS, tM] = Struct2File(Data, FileName, ColNamesCell,varargin{:});
        
    otherwise
        Status = 0;
        Message = '������������δ֪�����飡';
        disp(Message);
        return;
end

end
%% sub fun-Double2File
function [tS, tM] = Double2File(Data, FileName, ColNamesCell,varargin)

tS = 1;
tM = [];

tCell = num2cell(Data);
if ~isempty( ColNamesCell )
    tCell = [ColNamesCell;tCell];
end
Fun = @(x)( num2str(x) );
tCell = cellfun( Fun,tCell, 'UniformOutput', false);

T = cell2table(tCell);
writetable(T,FileName,'WriteVariableNames',false,varargin{:});

end

%% sub fun-Cell2File
function [tS, tM] = Cell2File(Data, FileName, ColNamesCell,varargin)

tS = 1;
tM = [];

tCell = Data;
if ~isempty( ColNamesCell )
    tCell = [ColNamesCell;tCell];
end
Fun = @(x)( num2str(x) );
tCell = cellfun( Fun,tCell, 'UniformOutput', false);

T = cell2table(tCell);
writetable(T,FileName,'WriteVariableNames',false,varargin{:});

end

%% sub fun-Struct2File
function [tS, tM] = Struct2File(Data, FileName, ColNamesCell,varargin)

tS = 1;
tM = [];

[tS, tM] = Cell2File(Data, FileName, ColNamesCell,varargin{:});

end