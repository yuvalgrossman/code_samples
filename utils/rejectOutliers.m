function [y,yind]=rejectOutliers(X,method,d)
% Find outlires of a vector dataset X using optimization of standard
% deviation, until reaching difference of d

y=X;
switch method
    case 'std_dif'
        std_dif=d*2;
        while std_dif>d
            old_std=std(y);
            [~,ind]=max(abs(y-mean(y)));
            y(ind)=[];
            fprintf('Outliered point index %d\n',ind)
            std_dif=abs(std(y)-old_std);
        end
    case 'num'
        [~,ind]=sort(abs(y-mean(y)),'descend');
        y(ind(1:d))=[];
        fprintf('Outliered point indexs %d\n',ind(1:d))
end
end
