close all;
name=MOPS_glucose_12AA_37C_DChamb_20140212;
lengt=name.L_v_T;
time=name.T_v_T;
width=name.W_v_T;
list=[];
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
    list=[list,[0.5:siz-1.5;diff(log(volume_i))]];
end
binnumber=32;
bin=zeros(1,binnumber);
timescale=list(1,:);
leng=list(2,:);
for n=0.5:31.5
    len=leng(timescale==n);
    bin(n+0.5)=mean(len);
    length(len)
end
plot([0.5:15.5, 17.5:31.5], bin([1:16, 18:end]), "-o")
xlabel('Elapsed Time (minutes)','Interpreter','tex')
ylabel('Growth Rate','Interpreter','tex')
title('Growth Rate as a Function of Elapsed Time','Interpreter','tex')
ylim([0,0.08])
xlim([0,32])