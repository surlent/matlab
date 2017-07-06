stockcode='sh600000';
load(['.\DataBase\Index\DayIndicator_mat\' stockcode '_Fwd_Indicator.mat']);
temp = StockIndicators;                %准备去除不需要的列
Len=size(temp,1);
if Len<=320 && Flag~=4
    disp('样本数据不足导致输入输出维度过低,退出本条神经网络训练')
    Result={stockcode,0,0,0,0,0,0,0};
    return
end

TestData=temp;
temp (any(temp==0,2),:)=[];
inPut=temp(:,11:end-5)';
outPut=(temp(:,end-2).*100)';
inPut = mapminmax(inPut);
inPut = con2seq(inPut);
outPut = con2seq(outPut);
inputDelays = 1:40;
feedbackDelays = 11:15;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);
[inPut,inputStates,layerStates,outPut] = preparets(net,inPut,{},outPut);
net.trainFcn = 'trainbr';
net.layers{1}.transferFcn = 'tansig';
net.divideParam.trainRatio=0.6;
net.divideParam.valRatio=0.2;
net.divideParam.testRatio=0.2;
% net.trainparam.show=NaN;
% net.trainparam.showWindow=0;
net.trainparam.epochs = 5000 ;
net.trainparam.goal = 0.001 ;
net.trainParam.lr = 0.01 ;
net.trainParam.max_fail=200;
net = train(net,inPut,outPut,inputStates,layerStates);