function [my_field,sc_ave]=generateSCave(type,scale_range,data,method,period1)

    if type=="wcoh"
        my_field = strcat('wcoh','_M',num2str(method),'scave',num2str(scale_range(1)),'_',num2str(scale_range(end)));

    elseif type=="xw"
        my_field = strcat('xw','_M',num2str(method),'scave',num2str(scale_range(1)),'_',num2str(scale_range(end)));

    else
        error('wrong type input')
    end

    [No_rows,No_col]=size(data);
%     disp(No_rows)
%       disp(No_col)
    sc_ave=cell(size(data));
    if method==1
        count=0;
        for io=1:No_rows
            for i=1:No_col
                 if ~isempty(data{io,i})
                count=count+1;
                ave=mean(abs(data{io,i}(scale_range,:)));
                %ave=mean(wcoh{io,i}(scale_range,:));
                sc_ave{io,i}=ave;
                
                 end
            end
        end
    % if there is another method to calculate average scale power
    elseif method==2

        for io=1:No_rows
            if ~isempty(data{io,1})
                F=1./time2num(period1(scale_range));
                ave=(abs(data{io,1}(scale_range,:))'*F)/sum(F);
                sc_ave{io,i}=ave';

            end
        end

    else
        error('method input do not exist')

    end

end