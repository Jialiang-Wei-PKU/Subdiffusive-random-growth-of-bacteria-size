close all; 
l1=[];
l2=[];
deltat=0.05;
k=0.026;
binnumber=25;
v=1+0.12*randn;
alpha_dist=0.375;
tau_min=0.001;
N=round(1000*(100*tau_min)^(-alpha_dist));
dt=0.001;
exponent=-1/alpha_dist;
t=0;
for num=1:28
    c=v;
    b=1+sqrt(3)*0.12*randn+c;
    U=rand(1,N);
    X=tau_min*(U.^exponent);
    s=zeros(1,N);
    for i=1:10000
        dW=randn*sqrt(dt)/140; 
        s=s.*(1-dt./X)+dW;
    end
    r=sum(s)/(N*alpha_dist*(tau_min^alpha_dist));
    while v<b
        l1=[l1,t];
        l2=[l2,v];
        for i=1:50
            dW=randn*sqrt(dt)/140; 
            s=s.*(1-dt./X)+dW;
        end
        w=sum(s)/(N*alpha_dist*(tau_min^alpha_dist));
        h=w-r;
        r=w;
        v=exp(log(v)+k*deltat+h);
        t=t+0.05;
    end
    v=b/2;
    l1=[l1,t];
    l2=[l2,v];
end
plot(l1(1:20:end),l2(1:20:end))
xlabel('Elapsed time (min)','Interpreter','tex')
ylabel('Cell Volume','Interpreter','tex')
grid on;
ylim([0.5,2.5])
xlim([0,800])