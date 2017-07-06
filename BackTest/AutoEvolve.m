function [ perform ] = AutoEvolve(Mode)
%%用来自动优化神经网络参数
if nargin<1
    Mode=1;
end

%% Mode=1 用来优化股票ai参数
if Mode==1
    stockcode='sh600000';
    Flag=1;
    loopTimes=20;
    unitNumberTested=20;
    perform=zeros(unitNumberTested,loopTimes);
    i=1;
    while i<=loopTimes
        parfor j=1:unitNumberTested
            unit=j+14;
            [~,tp] = BPtrain(stockcode,Flag,unit);
            perform(j,i)=tp.best_tperf;                 %循环数是列(每个循环都是独立的),隐含层单元数是行
        end
        i=i+1;
    end
    save('.\performStatics3.mat','perform','-v7.3');
end
%% Mode=2 用来优化指数ai参数
if Mode==2
    stockcode='sh000001';
    Flag=1;
    loopTimes=20;
    unitNumberTested=20;
    perform=zeros(unitNumberTested,loopTimes);
    i=1;
    while i<=loopTimes
        parfor j=1:unitNumberTested
            unit=j+14;
            [~,tp] = BPtrainIndex(stockcode,Flag,unit);
            perform(j,i)=tp.best_tperf;
        end
        i=i+1;
    end
    save('.\performStatics.mat','perform','-v7.3');
end




end








