function [U,V,iteration] = PS2_fcm(X,c,F,b,alpha)
% PS2_fcm:Partial Supervision fcm by liyang @BNU Math 315
% Email:farutoliyang@gmail.com
% 2009.09.25
% //input: 
% [num_sample,num_attribute] = size(X) let N = num_sample
% X = (x(1);x(2);...;x(num_sample));
% c:classnumber
% F:c*num_sample
% b:1*num_sample
% alpha:权重 
% //output:
% U : c*num_sample
% V = (v(1);v(2);...;v(c)) : c*num_attribute
% interation:迭代次数
% Problem:
% min Q(U,V) = sum(i=1,...,c)sum(k=1,...,N)( u(i,k)^2 *
% distance(x(k),v(i))^2 ) + alpha*sum(i=1,...,c)sum(k=1,...,N)
% ( u(i,k)-f(i,k) )^2*b(k)*distance(x(k),v(i))^2
% subject to sum(j=1,...,c)u(j,t) = 1, for each t = 1,2,...,N
% solve in the Euclidean distance sense
% u(s,t) = (1+alpha*b(t))^(-1) * [ ( 1+alpha*b(t)*(1-sum(i=1,...,c)f(s,t)) ) / 
% ( sum(j=1,...,c)(distance(v(s),x(t))/distance(v(j)-x(t)))^2 ) + alpha*f(s,t)*b(t)]
% v(s) = ( sum(k=1,...,N)( fai(s,k)*x(k) ) ) / ( sum(k=1,...,N)( fai(s,k) ) )
% where fai(i,k) = u(i,k)^2+alpha*b(k)*(u(i,k)-f(i,k))^2

[num_sample,num_attribute] = size(X);
N = num_sample;

%% initialization 
epsilon = 0.001;
iteration = 1;

[Ustd,Vstd] = std_fcm(X,c);

% U = rand(c,N);
% U = F;
U = Ustd;
for k = 1:N
    if b(k) == 1
        [fmax,findex] = max(F(:,k));
        [umin,uindex] = min( abs( U(:,k)-fmax ) ); 
        
        temp = U(findex,:);
        U(findex,:) = U(uindex,:);
        U(uindex,:) = temp;
    end
end
V = zeros(c,num_attribute);

%% 主体循环

while(1)
    
    % calculate new V
    for i = 1:c
        for k = 1:N
            fai(i,k) = U(i,k)^2+alpha*b(k)*(U(i,k)-F(i,k))^2;
        end
    end
    for s = 1:c
        temp_numerator = 0;
        for k = 1:N
            temp_numerator = temp_numerator + fai(s,k) * X(k,:);
        end
        V(s,:) = temp_numerator ./ sum( fai(s,:) );
    end
    
    % calculat new U
    for s = 1:c
        for t = 1:N
            temp_denominator = 0;
            for j = 1:c
                temp_denominator = temp_denominator + ( ED(V(s,:),X(t,:))/ED(V(j,:),X(t,:)) )^2;
            end
            temp_numerator = 1+alpha*b(t)*(1-sum(F(:,t)));
            new_U(s,t) = (1+alpha*b(t))^(-1) * (temp_numerator / temp_denominator + alpha*F(s,t)*b(t));
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