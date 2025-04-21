function free_pathloss = free_pathloss_cal(distance,fc)
%PATHLOSS_CAL 自由空间衰减
free_pathloss = 20 * log10(distance / 1e3) + 20 * log10(fc / 1e6) + 32.5;
end

