function [U,V,L,bestc]=C_SelfAdapt_fcm(X)
% C_SelfAdapt_fcm:standard fcm with self-adapting parameter C 
% by liyang @ BNU Math 315
% Email:farutoliyang@gmail.com
% 2009.09.29
% //input: 
% [num_sample,num_attribute] = size(X) let N = num_sample
% X = (x(1);x(2);...;x(num_sample));
% //output:
% U : c*num_sample
% V = (v(1);v(2);...;v(c)) : c*num_attribute
% L:评价函数的值
% bestc:最佳聚类数
% Problem:
% min Q(U,V) = sum(i=1,...,c)sum(k=1,...,N)( u(i,k)^2 * distance(x(k),v(i))^2 )
% subject to sum(j=1,...,c)u(j,t) = 1, for each t = 1,2,...,N
% solve in the Euclidean distance sense
% u(s,t) = 1 / ( sum(j=1,...,c)(distance(v(s),x(t))/distance(v(j)-x(t)))^2 )
% v(s) = ( sum(k=1,...,N)( u(s,k)^2*x(k) ) ) / ( sum(k=1,...,N)( u(s,k)^2 )
% )

[num_sample,num_attribute] = size(X);
n = num_sample;
m = num_attribute;
 
%% initialization 
L=zeros(1,n-1);

%% 主体循环
for c=2:n-1 
    
    [U,V] = std_fcm(X,c);
    
    xba=zeros(1,m);    
    for i=1:c
        for j=1:n
            xba=xba+(U(i,j)^2).*X(j,:);
        end
    end
    xba=xba/n;
    
    fenzi=0;
    for i=1:c
        fenzi=fenzi+(sum(U(i,:).^2)) * ED(V(i,:),xba)^2;
    end
    fenzi=fenzi/(c-1);
    
    fenmu=0;
    for i=1:c
      for j=1:n
            fenmu=fenmu+U(i,j)^2 * ED(X(j,:),V(i,:))^2;
        end
    end
    
    fenmu=fenmu/(n-c);
    L(c) = fenzi / fenmu;
    
    if c > 2 
        if (L(c-1)>L(c-2)) && (L(c-1)>L(c))
            U = Ulast;
            V = Vlast;
            c = c-1;
            break;
        end
    end
    
    Vlast=V;
    Ulast=U;
    
end

bestc = c;

index = 2;
while L(index) ~= 0
    index = index + 1;
end
L = L(1:index);

%% Euclidean distance function
function d = ED(x,y)
d = sum((x-y).^2).^0.5;
