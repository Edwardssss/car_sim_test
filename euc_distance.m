function ab_euc_distance = euc_distance(a,b)
%EUC_DISTANCE 计算两个位置的欧氏距离
    ab_euc_distance = sqrt(sum((a - b) .^ 2));
end

