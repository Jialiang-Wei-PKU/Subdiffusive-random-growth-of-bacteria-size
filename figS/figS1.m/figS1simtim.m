close all;
list=[];
list1=[];
list2=[];
deltat=0.05;
k_prime=sqrt(0.0014);
v=1+0.12*randn;
k=0.026;
for num=1:18524
    num
    l=[];
    c=v;
    b=1+sqrt(3)*0.12*randn+c;
    while v<b
        l=[l,v];
        v=exp(log(v)+k*deltat+k_prime*sqrt(deltat)*randn);
    end
    l0=l(1:20:end);
    siz=size(l0,2);
    list=[list,[0.5:siz-1.5;diff(log(l0))]];
    v=b/2;
end
%% 
binnumber=32;
bin=zeros(1,binnumber);
timescale=list(1,:);
leng=list(2,:);
for n=0.5:31.5
    len=leng(timescale==n);
    bin(n+0.5)=mean(len);
end
plot(0.5:31.5,bin,"-o")
hold on
%% 
xlabel('Elapsed Time (min)','Interpreter','tex')
ylabel('Growth Rate','Interpreter','tex')
title('Simulated Growth Rate vs. Elapsed Time','Interpreter','tex')
ylim([0,0.08])
xlim([0,32])