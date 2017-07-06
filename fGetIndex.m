classdef fGetIndex < handle
    %% fGetIndex
    % ��ȡָ���������
    % ��ȡָ���ɷֹ�
    % by LiYang_faruto
    % Email:farutoliyang@foxmail.com
    % 2015/6/1
    %% properties
    properties
        
        isSave = 1;
        Code = '000300';
        
    end
    %% properties(SetAccess = private, GetAccess = public)
    properties(SetAccess = private, GetAccess = public)
        
        
    end
    
    %% properties(Access = protected)
    properties(Access = protected)
        
    end
    
    %% properties(Access = private)
    properties(Access = private)
        
    end
    
    %% methods
    
    methods
        %% fGetIndex()
        function obj = fGetIndex( varargin )
            
            
        end
        
        %% Fun()
        function [OutputData,dStr] = GetCons(obj,varargin )
            OutputData = [];
            dStr = [];
            % %===���������� ��ʼ===
            Flag = ParaCheck(obj);
            if 0 == Flag
                str = ['������������Ƿ���ȷ��'];
                disp(str)
                return;
            end
            
            % %===���������� ���===
    
            % 399704��֤���� 399705��֤���� 399706��֤����
            % 399701��֤F60 399702��֤F120 399703��֤F200
            SpecialList = {'399704';'399705';'399706';'399701';'399702';'399703';};
            
            CustomList = {};
            
            FolderStr = ['./IndexCons'];
            if ~isdir( FolderStr )
                mkdir( FolderStr );
            end
            
            FileName = [obj.Code,'�ɷֹ�'];
            FileString = [FolderStr,'/',FileName,'.xls'];
            FileExist = 0;
            if exist(FileString, 'file') == 2
                FileExist = 1;
            end
            if 1 == FileExist
                FileString = [FolderStr,'/',FileName,'(1)','.xls'];
            end
            
            if obj.Code(1) == '3' && ~ismember(obj.Code,SpecialList)
                % http://www.cnindex.com.cn/docs/yb_399005.xls
                URL = ['http://www.cnindex.com.cn/docs/yb_',obj.Code,'.xls'];
                
                try
                    outfilename = websave(FileString,URL);
                catch
                    str = ['���ݻ�ȡʧ�ܣ����������ָ�����룡',obj.Code];
                    disp(str);
                    return;
                end
                
                [num,txt,raw] = xlsread(outfilename);
                
                dStr = raw{1,8};
                
                OutputData = raw(:,3:6);
                OutputData(1,:) = {'Code','Name','Weight','Industry'};                
                
            else
                
                URL = ['http://www.csindex.com.cn/sseportal/ps/zhs/hqjt/csi/',obj.Code,'cons.xls'];
                
                try
                    outfilename = websave(FileString,URL);
                catch
                    str = ['���ݻ�ȡʧ�ܣ����������ָ�����룡',obj.Code];
                    disp(str);
                    return;
                end
                
                [status,sheets] = xlsfinfo(outfilename);
                dStr = ['����ʱ�䣺',sheets{1,1}];
                
                [num,txt,raw] = xlsread(outfilename);
                
                OutputData = raw;
                OutputData(1,:) = {'Code','Name','Name(Eng)','Exchange'};
                
            end
            
            
            if obj.isSave == 0
            
                delete(FileString);
                
            else
                
                str = [obj.Code,'ָ���ɷֹ������ѱ�����',FileString];
                disp(str);
                
            end
            
        end
        
        
        %% ���������麯��
        function Flag = ParaCheck(obj, varargin )
            Flag = 1;
            
            % %===���������� ��ʼ===
            
%             checkflag = ismember( lower(obj.DownUpSampling),lower(obj.DownUpSampling_ParaList) );
%             if checkflag ~= 1
%                 str = ['DownUpSampling��������������飡��ѡ�Ĳ����б�Ϊ����Сд���У���'];
%                 disp(str);
%                 ParaList = obj.DownUpSampling_ParaList
%                 Flag = 0;
%                 return;
%             end
            
             % %===���������� ���===
        end    
        
        
        
        
        
    end
    
end
