%% SinaYahooDataTest
% by LiYang
% Email:farutoliyang@gmail.com
% 2013/11/26
%% A Little Clean Work
tic;
clear;
clc;
close all;
format compact;
%% ��ȡ��ʷ���ݲ���

% ��ʷ����ͨ��Yahoo�ӿڻ�� ����ʷ����Ϊδ��Ȩ���ݣ�ʹ��ʱ����ע�⣩
% Yahoo��֤ȯ����Ϊ ���Ϻ� .ss ���� .sz),�����������У�600036.ss

StockName = '600036.ss';
StartDate = today-200;
EndDate = today;
Freq = 'd';
[DataYahoo, Date_datenum, Head]=YahooData(StockName, StartDate, EndDate, Freq);

% K��չʾ
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);

Open = DataYahoo(:,2);
High = DataYahoo(:,3);
Low = DataYahoo(:,4);
Close = DataYahoo(:,5);
MT_candle(High,Low,Close,Open,[],Date_datenum);
xlim( [0 length(Open)+1] );
title(StockName);
%% ��ȡʵʱ���ݲ���
% Sina��֤ȯ����Ϊ ��sh. �Ϻ� sz.����),������������sh600036

StockCode='sh600036';
[DataSina, DataCell]=SinaData(StockCode);
DataCell
%% Record Time
toc;