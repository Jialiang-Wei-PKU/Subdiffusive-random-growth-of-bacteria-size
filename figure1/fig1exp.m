lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
l1=[];
l2=[];
a=[];
for i=1:28
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
    l1=[l1,time_i];
    l2=[l2,volume_i];
    a=[a,volume_i(1)];
end
plot(l1,l2/mean(a),'r')
xlabel('Elapsed time (min)', 'Interpreter', 'tex')
ylabel('Cell Volume', 'Interpreter', 'tex')
title('Experimental Single Cell Growth and Division', 'Interpreter', 'tex')
grid on
pbaspect([1 0.3 1])