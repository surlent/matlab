function ATRValue=ATR(High,Low,Close,Length,Type)
%--------------------此函数用来计算ATR指标(平均真实幅度)-------------------
%----------------------------------编写者--------------------------------
%Lian Xiangbin(连长,785674410@qq.com),DUFE,2014
%----------------------------------参考----------------------------------
%[1]Wilder.《技术交易系统新概念》
%[2]来自网络.波动幅度ATR的用法大全
%[3]交易开拓者(TB).ATR指标算法
%----------------------------------简介----------------------------------
%真实波动幅度均值(ATR)是由威尔斯·威尔德(J.Welles Wilder)在其1978年所著
%的《技术交易系统新概念》("New concepts in Technical Trading Systems")
%一书中首先提出的，这一指标主要用来衡量证券价格的波动。因此，这一技术指标
%并不能直接反映价格走向及其趋势稳定性，而只是表明价格波动的程度。真实波动
%幅度均值(ATR)是优秀的交易系统设计者的一个不可缺少的工具，它称得上是技术指
%标中的一匹真正的劲马。每一位系统交易者都应当熟悉ATR及其具有的许多有用功能。
%其众多应用包括：参数设置，入市，止损，获利等，甚至是资金管理中的一个非常
%有价值的辅助工具。
%----------------------------------基本用法------------------------------
%ATR用法较多，详见参考资料
%----------------------------------调用函数------------------------------
%ATRValue=ATR(High,Low,Close,Length,Type)
%----------------------------------参数----------------------------------
%High-每个Bar的最高价序列
%Low-每个Bar的最低价序列
%Close-每个Bar的收盘价序列
%Length-计算ATR值所考虑的周期数，即求真实幅度多少个Bar的移动平均,常用14
%Type-计算ATR采用的移动平均类型，0表示简单平均，1表示指数平均，默认为0
%----------------------------------输出----------------------------------
%ATRValue-平均真实幅度

if nargin==4
    Type=0;
end
ATRValue=zeros(length(High),1);
TRValue=zeros(length(High),1);
TRValue(2:end)=max([High(2:end)-Low(2:end) abs(High(2:end)-Close(1:end-1)) abs(Low(2:end)-Close(1:end-1))],[],2);
if Type==0
    ATRValue=MA(TRValue,Length);
end
if Type==1
    ATRValue=EMA(TRValue,Length);
end
end

