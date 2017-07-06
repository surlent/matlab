function [U,V] = HC_fcm(X,c,alpha)
% HC_fcm:Horizontal Collaborative fcm by liyang @BNU Math 315
% Email:farutoliyang@gmail.com
% 2009.09.25
% //input:
% X  = cell(1,num_dataset),X是细胞矩阵
% [num_sample,num_attribute(ii)] = size(X{ii}),ii=1,2,...,P
% let N = num_sample,P = num_dataset,n(ii) = num_attribute(ii)
% c:classnumber
% alpha : P*P,协作矩阵
% //output:
% U = cell(1,P),U是细胞矩阵
% U{ii} : c*N,ii=1,2,...,P
% V = cell(1,P),P是细胞矩阵
% V{ii} : c*n(ii),ii=1,2,...,P
% interation:迭代次数
% ======问题描述=======
% Problem:
% min Q(ii) = sum(i=1,...,c)sum(k=1,...,N)( U(i,k,ii)^2 *
% distance(X(k,:,ii),V(i,:,ii))^2 ) + sum(jj=1,...,P,jj~=ii)alpha(ii,jj)*sum(i=1,...,c)sum(k=1,...,N)
% ( U(i,k,ii)-U(i,k,jj) )^2*distance(X(k,:,ii),V(i,:,ii))^2
% subject to sum(j=1,...,c)U(j,t,ii) = 1
% for each t = 1,2,...,N and ii = 1,2,...,P
% solve in the Euclidean distance sense
% U(s,t,ii) = fai(s,t,ii)/(1+psai(ii)) + ( 1-sum(j=1,...,c)fai(j,t,ii)/(1+psai(ii)) ) / ( sum(j=1,...,c)ED(V(s,:,ii),X(t,:,ii))/ED(V(j,:,ii),X(t,:,ii)) )
% where fai(s,t,ii) = sum(jj~=ii)alpha(ii,jj)U(s,t,jj)
%       psai(ii) = sum(jj~=ii)alpha(ii,jj)
% V(s,t,ii) = ( A(s,t,ii)+C(s,t,ii) ) / ( B(s,ii)+D(s,ii) )
% where A,B,C,D are as follows:
% A(s,t,ii) = sum(k=1,...,N)U(s,k,ii)^2*X(k,t,ii)
% B(s,ii) = sum(k=1,...,N)U(s,k,ii)^2
% C(s,t,ii) =
% sum(jj=1,...,P,jj~=ii)alpha(ii,jj)*sum(k=1,...,N)(U(s,k,ii)-U(s,k,jj))^2*
% X(k,t,ii)
% D(s,ii) =
% sum(jj=1,...,P,jj~=ii)alpha(ii,jj)sum(k=1,...,N)(U(s,k,ii)-U(s,k,jj))^2

num_dataset = length(X);
P = num_dataset;
num_attribute = zeros(1,P);
for ii = 1:P
    [num_sample,num_attribute(ii)] = size(X{ii});
end
N = num_sample;
n = num_attribute;

%% initialization
epsilon = 0.001;
iteration = 1;
U = cell(1,P);
V = cell(1,P);

%% Phase I

for ii = 1:P
    [U{ii},V{ii}] = std_fcm(X{ii},c);
end

%% Phase II

for ii = 1:P
    
    while(1)
        
        % calculate new V
             
        for s = 1:c
            for t = 1:n(ii)
                A = 0;
                for k = 1:N
                    A = A + U{ii}(s,k)^2 * X{ii}(k,t);
                end
                 
                B = sum(U{ii}(s,:).^2);
                
                C = 0;
                for jj = 1:P
                    if jj == ii
                        continue;
                    end
                    
                    temp = 0;
                    for k = 1:N
                        temp = temp + (U{ii}(s,k)-U{jj}(s,k))^2*X{ii}(k,t);
                    end
                    C = C+alpha(ii,jj)*temp;
                end
                
                D = 0;
                for jj = 1:P
                    if jj == ii
                        continue;
                    end
                    
                    temp = 0;
                    for k = 1:N
                        temp = temp + (U{ii}(s,k)-U{jj}(s,k))^2;
                    end
                    D = D+alpha(ii,jj)*temp;
                end
                
                V{ii}(s,t) = (A+C) / (B+D);
            
            end
        end
        
        % calculat new U
        
        fai = zeros(c,N);
        for s = 1:c
            for t = 1:N
                for jj = 1:P
                    if jj == ii
                        continue;
                    end
                    fai(s,t) = fai(s,t)+alpha(ii,jj)*U{jj}(s,t);
                end
            end
        end
        psai = sum(alpha(ii,:)) - alpha(ii,ii);
        
        for s = 1:c
            for t = 1:N
                temp_numerator =  1 - (sum(fai(:,t))) / (1+psai);
                
                temp_denominator = 0;
                for j = 1:c
                    temp_denominator = temp_denominator + ( ED(V{ii}(s,:),X{ii}(t,:))/ED(V{ii}(j,:),X{ii}(t,:)) )^2;
                end
                
                temp = temp_numerator / temp_denominator;
                new_U(s,t) = fai(s,t)/(1+psai) + temp;
            end
        end
        
        % while循环终止条件
        if max(max(abs(U{ii}-new_U))) < epsilon
            break;
        end
        
        U{ii} = new_U;
    end
    
end


%% Euclidean distance function
function d = ED(x,y)
d = sum((x-y).^2).^0.5;