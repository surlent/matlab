function [U,V,iteration] = std_fcm(X,c)
% std_fcm:standard fcm by liyang @BNU Math 315
% Email:farutoliyang@gmail.com
% 2009.09.25
% input: 
% [num_sample,num_attribute] = size(X) let N = num_sample
% X = (x(1);x(2);...;x(num_sample));
% c:classnumber
% output:
% U : c*num_sample
% V = (v(1);v(2);...;v(c)) : c*num_attribute
% Problem:
% min Q(U,V) = sum(i=1,...,c)sum(k=1,...,N)( u(i,k)^2 * distance(x(k),v(i))^2 )
% subject to sum(j=1,...,c)u(j,t) = 1, for each t = 1,2,...,N
% solve in the Euclidean distance sense
% u(s,t) = 1 / ( sum(j=1,...,c)(distance(v(s),x(t))/distance(v(j)-x(t)))^2 )
% v(s) = ( sum(k=1,...,N)( u(s,k)^2*x(k) ) ) / ( sum(k=1,...,N)( u(s,k)^2 ) )

[num_sample,num_attribute] = size(X);
N = num_sample;

%% initialization 
epsilon = 0.001;
iteration = 1;

U = rand(c,N);
V = zeros(c,num_attribute);

%% 主体循环

while(1)
    
    % calculate new V
    for s = 1:c
        temp_numerator = 0;
        for k = 1:N
            temp_numerator = temp_numerator + U(s,k)^2 * X(k,:);
        end
        V(s,:) = temp_numerator ./ sum( U(s,:).^2 );
    end
    
    % calculat new U
    for s = 1:c
        for t = 1:N
            temp_denominator = 0;
            for j = 1:c
                temp_denominator = temp_denominator + ( ED(V(s,:),X(t,:))/ED(V(j,:),X(t,:)) )^2;
            end
            new_U(s,t) = (temp_denominator)^(-1);
        end
    end
    
    % 主体循环终止条件
    if max(max(abs(U-new_U))) < epsilon 
        break;
    end
    
    U = new_U;
    iteration = iteration + 1;
end



%% Euclidean distance function
function d = ED(x,y)
d = sum((x-y).^2).^0.5;