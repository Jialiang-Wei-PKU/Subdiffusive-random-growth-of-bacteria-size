close all;
lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
list1=[];
list2=[];
list3=[];
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
    length_i=lengt{i};
    surface_i=lengt{i}.*width{i}*pi;
    siz=size(volume_i,2);
    list1=[list1,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(volume_i))*1/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
    siz=size(length_i,2);
    list2=[list2,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(length_i))*1/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
    siz=size(surface_i,2);
    list3=[list3,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(surface_i))*1/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
end
bin=zeros(1,binnumber);
timescale=list1(1,:);
leng=list1(2,:);
weight=list1(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
    size(len,2)
end
plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"-o",'MarkerSize',8,'LineWidth', 2)
hold on
bin=zeros(1,binnumber);
timescale=list2(1,:);
leng=list2(2,:);
weight=list2(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
    size(len,2)
end
plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"-o",'MarkerSize',8,'LineWidth', 2)
hold on
bin=zeros(1,binnumber);
timescale=list3(1,:);
leng=list3(2,:);
weight=list3(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
    size(len,2)
end
plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"-o",'MarkerSize',8,'LineWidth', 2)
xlabel('Relative Age','Interpreter','tex', 'FontSize', 14)
ylabel('Growth Rate','Interpreter','tex', 'FontSize', 14)
legend('Volume','Length','Surface area','Interpreter','tex','FontSize',14,'Location','best')
ylim([0,0.08])