close all;
list=[];
deltat=0.1;
k_prime=0.04;
a=0;
for num=1:40000
    v=1;
    l=[1];
    k=0.026;
    for i=1:267
        v=exp(log(v)+k*deltat+k_prime*sqrt(deltat)*randn);
        l=[l,v];
    end
    v
    if abs(v-2)<0.01 && a<5
        plot(0:0.1:26.7,log(l), 'LineWidth', 2.0)
        a=a+1;
        hold on;
    end
end
yline(log(2), 'k--', 'LineWidth', 2.0);
xlabel('Elapsed Time (minutes)','Interpreter','tex')
ylabel('$\ln(V/ \bar{V}_b)$','Interpreter','latex')
title('Logarithm volume vs. Elapsed Time','Interpreter','tex')