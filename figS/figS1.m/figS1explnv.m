lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
list=[];
a=[];
for i=1:size(lengt,2)
    length_i=lengt{i};
    time_i=time{i};
    width_i=width{i};
    if size(length_i,2) <= 3
        continue
    end
    if any(isnan(width_i) | width_i == 0)
        continue
    end
    volume_i=(lengt{i}.*((width{i}/2).^2)-(2/3)*((width{i}/2).^3))*pi;
    a=[a,volume_i(1)];
    vo=log(volume_i(1:end-1));
    list=[list,[vo;diff(log(volume_i))]];
end
%%
close all
binnumber=25;
bin=zeros(1,binnumber+4);
%bin2=zeros(1,binnumber+4);
timescale=list(1,:)-log(mean(a));
leng=list(2,:);
for n=-7:binnumber-4
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+8)=mean(len);
    %bin2(n+8)=std(len)/sqrt(length(len));
    length(len)
end
plot(-13/(2*binnumber):1/binnumber:1-7/(2*binnumber),bin,"-o")
%h=errorbar(-13/(2*binnumber):1/binnumber:1-7/(2*binnumber),bin,bin2,'-o');
%set(h, 'CapSize', 4, 'LineWidth', 1, 'MarkerFaceColor', 'w');
xlabel('$\ln(V/ \bar{V}_b)$','Interpreter','latex')
ylabel('Growth Rate','Interpreter','tex')
title('Growth Rate as a Function of Cell Volume','Interpreter','tex')
ylim([0,0.08])
xlim([-0.28,0.88])