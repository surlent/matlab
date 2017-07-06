function [Position] = Position(winrate,EMIncrease,stoploss)
%%按凯利公式测算仓位.
%winrate=胜率,EMIncrease=预期收益率,stoplos=止损.

Position=winrate/stoploss-(1-winrate)/EMIncrease;

end

