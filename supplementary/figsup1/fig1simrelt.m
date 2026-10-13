clear
close all;
rng('shuffle');
list=[];
list1=[];
list2=[];
deltat=0.05;
binnumber=25;
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
    list=[list,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(l0))*1/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
    v=b/2;
end
%% 
bin=zeros(1,binnumber);
timescale=list(1,:);
leng=list(2,:);
weight=list(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
end
plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"-o")
hold on
%% 
xlabel('Relative Age','Interpreter','tex')
ylabel('Growth Rate','Interpreter','tex')
title('Simulated Growth Rate vs. Relative Age','Interpreter','tex');
ylim([0,0.08])