function [U,V,iteration,beta] = std_NERFCM(R,c)
% std_NERFCM:standard Non-Euclidean relational fcm by liyang @BNU Math 315
% Email:farutoliyang@gmail.com
% 2009.11.28
% \\input================
% R:N*N relational matrix
% c:classnumber
% \\output===============
% U : c*N
% V : N*c
% V = (V(:,1),V(:,2),...,V(:,c))
% Problem:
% min Q(U,V) = sum(i=1,...,c)sum(k=1,...,N)( u(i,k)^2 * distance(x(k),v(i))^2 )
% subject to sum(j=1,...,c)u(j,t) = 1, for each t = 1,2,...,N
% where in the relational clustering
% d(i,k) = ( Rbeta*V(:,i) )(k)-1/2*V(:,i)'*Rbeta*V(:,i)
% Rbeta(i,j) = R(i,j)+beta if i ~= j
%              0           if i == j
% U(s,t) = (sum(j=1,..,c) d(i,k)^2/d(j,k)^2)^(-1)

N = length(R);

%% initialization 
epsilon = 0.001;
iteration = 1;

% 扩散因子
beta = 0;

U = rand(c,N);
V = zeros(N,c);

%% 主体循环

while(1)
    
    % calculate new V
    for s = 1:c
        V(:,s) = U(s,:)'/sum(U(s,:));
    end
    
    % calculate Rbeta
    Rbeta = zeros(N,N);
    
    M = ones(N,N);
    I = diag( diag(ones(N,N)) );
    Rbeta = R + beta*(M-I);
% i.e.
%     for i = 1:N
%         for j = 1:N
%             if i ~= j
%                 Rbeta(i,j) = R(i,j)+beta;
%             else
%                 Rbeta(i,j) = 0;
%             end
%         end
%     end
    
    % calculate distance D for i=1:c and k=1:N
    for i = 1:c
        for k = 1:N
            temp = Rbeta*V(:,i);
            D(i,k) = temp(k) - 1/2*V(:,i)'*Rbeta*V(:,i);       
        end
    end
    
    % check wheter there are i & k,s.t. D(i,k) < 0
    flag = 0;
    for i = 1:c
        for k = 1:N
            if D(i,k) < 0
                flag = 1;
                break;
            end
        end
    end
    
    if flag == 1
        
        detaBeta = -inf;
        for ii = 1:c
            for kk = 1:N
                e = zeros(N,1);
                e(kk) = 1;
                target = -2*D(ii,kk)/ED(V(:,ii),e)^2;
                if target > detaBeta
                    detaBeta = target;
                end
            end
        end
        
        for i = 1:c
            for k = 1:N
                E = zeros(N,1);
                E(k) = 1;
                D(i,k) = D(i,k)+detaBeta/2*ED(V(:,i),E)^2;
            end
        end
        
        beta = beta+detaBeta;
        
    end
    
    % calculate new U
    for k = 1:N
        
        if sum( D(:,k)>0 ) == c
            for i=1:c
                
                temp_denominator = 0;
                for j = 1:c
                    temp_denominator = temp_denominator + D(i,k)/D(j,k);
                end
                
                new_U(i,k) = (temp_denominator)^(-1);
                
            end
        else
            for i = 1:c
                if D(i,k) > 0
                    new_U(i,k) = 0;
                end
            end
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