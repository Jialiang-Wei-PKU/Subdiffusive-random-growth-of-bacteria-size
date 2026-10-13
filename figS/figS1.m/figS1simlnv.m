close all;
list=[];
list1=[];
list2=[];
deltat=0.05;
k_prime=sqrt(0.0014);
v=1+0.12*randn;
k=0.026;
binnumber=25;
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
    v0=log(l0(1:end-1));
    list=[list,[v0;diff(log(l0))]];
    v=b/2;
end
%%
close all
bin=zeros(1,binnumber+4);
timescale=list(1,:);
leng=list(2,:);
for n=-7:binnumber-4
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+8)=mean(len);
end
%% 
plot(-13/(2*binnumber):1/binnumber:1-7/(2*binnumber),bin,"-o")
xlabel('$\ln(V/ \bar{V}_b)$','Interpreter','latex')
ylabel('Growth Rate','Interpreter','tex')
title('Simulated Growth Rate vs. Cell Volume','Interpreter','tex')
ylim([0,0.08])
xlim([-0.28,0.88])
hold on