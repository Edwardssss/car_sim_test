% -*- coding: utf-8 -*-
%
% @File    :   scenario_read.m
% @Time    :   2025/04/24 11:11:38
% @Author  :   Edwardssss
% @Version :   1.0
% @Desc    :   None
%
% Copyright (c) 2025, Edwardssss

function PATH_STRUCT = scenario_read(scenario,PAR_STRUCT)
    obj_pos = zeros(length(scenario.Actors),3);
    for l = 1:length(scenario.Actors)
        obj_pos(l,:) = scenario.Actors(l).Position;
    end
    % increase height
    obj_pos(1,:) = obj_pos(1,:) + PAR_STRUCT.car_height;
    obj_pos(4,:) = obj_pos(4,:) + PAR_STRUCT.rsu_height;
    % first propagation path
    straight_signal_path = [euc_distance(obj_pos(1,:),obj_pos(4,:)),euc_distance(obj_pos(2,:),obj_pos(4,:)),...
    euc_distance(obj_pos(3,:),obj_pos(4,:)),euc_distance(obj_pos(5,:),obj_pos(4,:))];
    % total propagation path
    real_path = [straight_signal_path(1) + euc_distance(obj_pos(1,:),obj_pos(1,:)),...
    straight_signal_path(2) + euc_distance(obj_pos(1,:),obj_pos(2,:)),...
    straight_signal_path(3) + euc_distance(obj_pos(1,:),obj_pos(3,:)),...
    straight_signal_path(4) + euc_distance(obj_pos(1,:),obj_pos(5,:))];
    % path delay
    PATH_STRUCT.real_delay = [real_path(1) / PAR_STRUCT.c real_path(2) / PAR_STRUCT.c real_path(3) / PAR_STRUCT.c real_path(4) / PAR_STRUCT.c];
    path_loss_list = [-free_pathloss_cal(real_path(1),PAR_STRUCT.fc) ...
        -free_pathloss_cal(real_path(2),PAR_STRUCT.fc) ...
        -free_pathloss_cal(real_path(3),PAR_STRUCT.fc) ...
        -free_pathloss_cal(real_path(4),PAR_STRUCT.fc)];
    PATH_STRUCT.total_fad_list = [PAR_STRUCT.reflect_decay(1) + path_loss_list(1),...
        PAR_STRUCT.reflect_decay(2) + path_loss_list(2),...
        PAR_STRUCT.reflect_decay(3) + path_loss_list(3),...
        PAR_STRUCT.reflect_decay(4) + path_loss_list(4)];
end