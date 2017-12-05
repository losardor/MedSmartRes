function [ models, modelscale, modelnet, modelLost, modelscaleLost, modelnetLost ] = RegressionFedState( Fednum )
%REGRESSIONFEDSTATE Calculates the regression models for a given federal
%state
%   models is the mixed effects linear regression for the corse model,
%   modelscale corrected for scale variables and modelnet corrected for
%   network properties. The "-Lost" indicates results for the average
%   number of lost patients as opposed to the average number of
%   displacements

load('DistNet_db.mat')
logvars = {'mean_patients', 'betweennes', 'relative_number_patients', 'mean_disp', 'mean_losts', 'suscettivity'};
RegressionData = [distNet_db varfun(@log, distNet_db(:,logvars))];

RegressionData(find(isinf(RegressionData.log_mean_disp)),:)=[];
RegressionData(find(isinf(RegressionData.log_betweennes)),:)=[];
RegressionData(:,logvars)=[];
RegressionFed = RegressionData(RegressionData.fedState == Fednum,:);

novars = {'distnum', 'DataID', 'iscity', 'fedState'};
RegressionFed(:,novars) = [];
RegressionFed = RegressionFed(:,[1:2 13 3:12 14:end]);
RegressionFed = RegressionFed(:,[1:3 15 4:14 16:end]);
RegressionFed = RegressionFed(:,[1:9 15 10:14 16:end]);
Preds=RegressionFed.Properties.VariableNames(2:end-2);

models = struct;
for i = 1:numel(Preds)
    models(i).lm=fitlm(RegressionFed, ['log_mean_disp ~' Preds{i}]);
end

scale = [ ' + ' Preds{1} ' + ' Preds{2} ' + ' Preds{3}];
modelscale = struct;
for i = 4:numel(Preds)
    modelscale(i).lm = fitlm(RegressionFed, ['log_mean_disp ~ ' Preds{i} scale]);
end
net = [scale ' + ' Preds{4} ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8} ' + ' Preds{9}];
for i = 10:numel(Preds)
    modelnet(i).lm = fitlm(RegressionFed, ['log_mean_disp ~ ' Preds{i} net]);
end

modelLost = struct;
for i = 1:numel(Preds)
modelLost(i).lm=fitlm(RegressionFed, ['log_mean_losts ~' Preds{i}]);
end

modelscaleLost = struct;
for i = 4:numel(Preds)
modelscaleLost(i).lm = fitlm(RegressionFed, ['log_mean_losts ~ ' Preds{i} scale]);
end

modelnetLost = struct;
for i = 10:numel(Preds)
modelnetLost(i).lm = fitlm(RegressionFed, ['log_mean_losts ~ ' Preds{i} net]);
end

end

