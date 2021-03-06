function EMAValue=EMA(Price,Length)
%------------------------此函数用来计算指数移动平均------------------------
%----------------------------------编写者--------------------------------
%Lian Xiangbin(连长,785674410@qq.com),DUFE,2014
%----------------------------------参考----------------------------------
%[1]招商证券.基于纯技术指标的多因子选股模型,2014-04-11
%[2]百度百科.移动平均线词条
%[3]Elder.以交易为生.机械工业出版社，2010年4月第1版
%----------------------------------简介----------------------------------
%移动平均线是由著名的美国投资专家葛兰碧于20世纪中期提出来的。均线理论是当今应用
%最普遍的技术指标之一，它帮助交易者确认现有趋势、判断将出现的趋势等。指数移动平
%均线是比较流行的一种移动平均线，它认为较近的价格更有价值。也就是说，它赋予较近
%的价格更大的权重
%----------------------------------基本用法------------------------------
%1)均线与价格形成金叉买入，形成死叉卖出
%2)短期均线与长期均线形成金叉买入，形成死叉卖出
%----------------------------------调用函数------------------------------
%EMAValue=EMA(Price,Length)
%----------------------------------参数----------------------------------
%Price-目标价格序列
%Length-计算指数移动平均的周期
%----------------------------------输出----------------------------------
%EMAValue：指数移动平均值
%测试用load('E:\FQuantToolBox\DataBase\Stock\Day_ForwardAdj_mat\sh600000_D_ForwardAdj.mat')
%测试用Price=StockData(:,3)
EMAValue=zeros(length(Price),1);
Length=input('请输入周期');  %自定义的周期
K=2/(Length+1);
indexlength=length(Price);
for i=1:indexlength
    if i==1
        EMAValue(i)=Price(i);
    else
        EMAValue(i)=Price(i)*K+EMAValue(i-1)*(1-K);
    end
end
end

