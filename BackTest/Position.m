function [Position] = Position(winrate,EMIncrease,stoploss)
%%��������ʽ�����λ.
%winrate=ʤ��,EMIncrease=Ԥ��������,stoplos=ֹ��.

Position=winrate/stoploss-(1-winrate)/EMIncrease;

end

