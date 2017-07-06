%% ��ջ������������
clear;
clc;

%% ��������

% �����½ǵ��ඨ��Ϊ��һ��,���Ͻǵ��ඨ��Ϊ�ڶ���
c = 2;
X=[1 1.5 1.7 1.7 2 2.1 2.2 2.4 2.7 3 5 5.2 5.5 5.8 5.8 6 6.3 6.4 6.5 7
  3 3.5 4.8 4.3 4 4.5 3.2 5.4 3.8 5 7 8.5 7.8 7.2 6.4 8 7.2 5.8 8.7 9];
X = X';
figure;
hold on;
title('��������');
plot(X(:,1),X(:,2),'*');

% %% ��׼FCM�㷨����,��std_fcm.mʵ��
% [U,V,iteration] = std_fcm(X,c); 
% figure;
% hold on;
% title('standard fcm');
% plot(X(:,1),X(:,2),'*');
% plot(V(1,1),V(1,2),'ro');
% plot(V(2,1),V(2,2),'go');
% hold off;
% figure;
% if U(1,20) > U(2,20)
%     flag = 1;
% else
%     flag = 2;
% end
% bar(U(flag,:));
% axis([1 20 0 1]);
% title('�ڶ����������');

%% ��������(5.1)ʽ��ΪĿ�꺯����Partial Supervision FCM�����㷨,��PS1_fcm.mʵ��
F = rand(c,20);
F(1,4) = 0.5;
F(2,4) = 0.5;
F(1,17) = 0;
F(2,17) = 1;
b = zeros(1,20);
b(4) = 1;
b(17) = 1;
alpha = 3;
[U,V,iteration] = PS1_fcm(X,c,F,b,alpha);
figure;
hold on;
title('Partial Supervision fcm');
plot(X(:,1),X(:,2),'*');
plot(V(1,1),V(1,2),'ro');
plot(V(2,1),V(2,2),'go');
figure;
if U(1,20) > U(2,20)
    flag = 1;
else
    flag = 2;
end
bar(U(flag,:));
axis([1 20 0 1]);
title('�ڶ����������');

%% ���鲻ͬ��alpha
alpha = 0;
[U0,V0,iteration] = PS1_fcm(X,c,F,b,alpha);
alpha = 0.5;
[U05,V05,iteration] = PS1_fcm(X,c,F,b,alpha);
alpha = 3;
[U3,V3,iteration] = PS1_fcm(X,c,F,b,alpha);
alpha = 5;
[U5,V5,iteration] = PS1_fcm(X,c,F,b,alpha);
figure;
hold on;
subplot(2,2,1);
if U0(1,20) > U0(2,20)
    flag0 = 1;
else
    flag0 = 2;
end
bar(U0(flag0,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 0 �ڶ����������');
subplot(2,2,2);
if U05(1,20) > U05(2,20)
    flag05 = 1;
else
    flag05 = 2;
end
bar(U05(flag05,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 0.5 �ڶ����������');
subplot(2,2,3);
if U3(1,20) > U3(2,20)
    flag3 = 1;
else
    flag3 = 2;
end
bar(U3(flag3,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 3 �ڶ����������');
subplot(2,2,4);
if U5(1,20) > U5(2,20)
    flag5 = 1;
else
    flag5 = 2;
end
bar(U5(flag5,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 5 �ڶ����������');

%% ��������(5.3)ʽ��ΪĿ�꺯����Partial Supervision FCM�����㷨,��PS2_fcm.mʵ��
alpha = 3;
[U,V,iteration] = PS2_fcm(X,c,F,b,alpha);
figure;
hold on;
title('Partial Supervision fcm');
plot(X(:,1),X(:,2),'*');
plot(V(1,1),V(1,2),'ro');
plot(V(2,1),V(2,2),'go');
figure;
if U(1,20) > U(2,20)
    flag = 1;
else
    flag = 2;
end
bar(U(flag,:));
axis([1 20 0 1]);
title('�ڶ����������');

%% ���鲻ͬ��alpha
alpha = 0;
[U0,V0,iteration] = PS2_fcm(X,c,F,b,alpha);
alpha = 0.5;
[U05,V05,iteration] = PS2_fcm(X,c,F,b,alpha);
alpha = 3;
[U3,V3,iteration] = PS2_fcm(X,c,F,b,alpha);
alpha = 5;
[U5,V5,iteration] = PS2_fcm(X,c,F,b,alpha);
figure;
hold on;
subplot(2,2,1);
if U0(1,20) > U0(2,20)
    flag0 = 1;
else
    flag0 = 2;
end
bar(U0(flag0,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 0 �ڶ����������');
subplot(2,2,2);
if U05(1,20) > U05(2,20)
    flag05 = 1;
else
    flag05 = 2;
end
bar(U05(flag05,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 0.5 �ڶ����������');
subplot(2,2,3);
if U3(1,20) > U3(2,20)
    flag3 = 1;
else
    flag3 = 2;
end
bar(U3(flag3,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 3 �ڶ����������');
subplot(2,2,4);
if U5(1,20) > U5(2,20)
    flag5 = 1;
else
    flag5 = 2;
end
bar(U5(flag5,:));
axis([1 20 0 1]);
title('PS fcm with alpha = 5 �ڶ����������');

   
