function [ models, modelscale, modelnet ] = RegressionFedState( Fednum )
%REGRESSIONFEDSTATE Calculates the regression models for a given federal
%state
%   models is the mixed effects linear regression for the corse model,
%   modelscale corrected for scale variables and modelnet corrected for
%   network properties. The "-Lost" indicates results for the average
%   number of lost patients as opposed to the average number of
%   displacements

load('DistNet_db.mat')
logvars = {'mean_patients', 'betweennes', 'mean_disp', 'mean_losts', 'suscettivity'};
RegressionData = [doctor_db varfun(@log, doctor_db(:,logvars))];

RegressionData(find(isinf(RegressionData.log_suscettivity)),:)=[];
RegressionData(find(isinf(RegressionData.log_betweennes)),:)=[];
RegressionData(:,logvars)=[];
RegressionFed = RegressionData(RegressionData.fedstate == Fednum,:);

novars = {'distnum', 'DataID', 'fedstate'};
RegressionFed(:,novars) = [];
RegressionFed = RegressionFed(:,[1 9 2:8 10:end]);
RegressionFed = RegressionFed(:,[1:8 10 9 11:end]);
RegressionFed = RegressionFed(:,[1:9 11 10 12:end]);
RegressionFed = RegressionFed(:,[1:10 12 11 end]);
RegressionFed = RegressionFed(:,[1:11 13 12]);
Preds=RegressionFed.Properties.VariableNames(2:end-2);

models = struct;
for i = 1:numel(Preds)
    models(i).lm=fitlm(RegressionFed, ['log_suscettivity ~' Preds{i}]);
end

scale = [ ' + ' Preds{1} ' + ' Preds{2} ];
modelscale = struct;
for i = 3:numel(Preds)
    modelscale(i).lm = fitlm(RegressionFed, ['log_suscettivity ~ ' Preds{i} scale]);
end
net = [scale ' + ' Preds{4} ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8} ];
for i = 9:numel(Preds)
    modelnet(i).lm = fitlm(RegressionFed, ['log_suscettivity ~ ' Preds{i} net]);
end
end

