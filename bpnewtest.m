net = feedforwardnet(19);
net.numInputs=5;
net.numLayers=2;
net.inputConnect= [1 1 1 1 1;0 0 0 0 0];
stockcode='sh600000';
[DetailProcess,FloatingStock,StockData,StockFinInd,StockIndicators,StockInfo,StockSheet3]=loads(stockcode);
temp = StockIndicators;                %准备去除不需要的列
Len=size(temp,1);
if Len<=320 && Flag~=4
    disp('错误01:样本数据不足导致输入输出维度过低,退出本条神经网络训练,并删除历史网络')
    Result={stockcode,0,0,0,0,0,0,0};
    try
        delete(['./DataBase/Net/Stock/' stockcode '_net.mat']);
        disp('删除成功')
    catch
        disp('无旧网络文件,跳过删除.')
    end
end

TestData=temp;
temp (any(temp==0,2),:)=[];
inPut=temp(:,11:end-5)';
outPut=(temp(:,end-2).*100)';

net.trainFcn = 'trainbr';
net.layers{1}.transferFcn = 'logsig';
net.divideParam.trainRatio=0.5;
net.divideParam.valRatio=0.25;
net.divideParam.testRatio=0.25;
% net.trainparam.show=NaN;
% net.trainparam.showWindow=0;
net.trainparam.epochs = 5000 ;
net.trainparam.goal = 0.001 ;
net.trainParam.lr = 0.01 ;
net.trainParam.max_fail=200;
inPut = mapminmax(inPut);
inPut1=inPut(1:2,:);
inPut2=inPut(3:5,:);
inPut3=inPut(6:9,:);
inPut4=inPut(10:14,:);
inPut5=inPut(15:24,:);
input=cell(5,1);
input{1}=inPut1;
input{2}=inPut2;
input{3}=inPut3;
input{4}=inPut4;
input{5}=inPut5;
output=cell(1,1);
output{1,1}=outPut;
net=train(net,input,output);




