lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
list=[];
binnumber=25;
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
    siz=size(volume_i,2);
    list=[list,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(volume_i))*1/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
end
bin=zeros(1,binnumber);
timescale=list(1,:);
leng=list(2,:);
weight=list(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
    size(len,2)
end
plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"-o")
xlabel('Relative Age','Interpreter','tex')
ylabel('Growth Rate','Interpreter','tex')
title('Growth Rate as a Function of Relative Cell-Cycle Age','Interpreter','tex')
ylim([0,0.08])