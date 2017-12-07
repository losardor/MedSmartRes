function [ models, modelscale, modelnet, models_r, modelscale_r, modelnet_r ] = RegressionFedState( Fednum )
%REGRESSIONFEDSTATE Calculates the regression models for a given federal
%state
%   models is the mixed effects linear regression for the corse model,
%   modelscale corrected for scale variables and modelnet corrected for
%   network properties. The "-Lost" indicates results for the average
%   number of lost patients as opposed to the average number of
%   displacements

load('DistNet_db.mat')
logvars = {'mean_patients', 'betweennes', 'mean_disp', 'mean_losts', 'suscettivity', 'relative_suscepty'};
RegressionData = [doctor_db varfun(@log, doctor_db(:,logvars))];


RegressionData(find(isinf(RegressionData.log_suscettivity)),:)=[];
RegressionData(find(isinf(RegressionData.log_mean_losts)),:)=[];
RegressionData(find(isinf(RegressionData.log_betweennes)),:)=[];
RegressionData(:,logvars)=[];
RegressionFed = RegressionData(RegressionData.fedstate == Fednum,:);

novars = {'distnum', 'DataID', 'fedstate'};
RegressionFed(:,novars) = [];
RegressionFed = RegressionFed(:,[1 8 2:7 9:end]);
Preds=RegressionFed.Properties.VariableNames(2:end-2);

models = struct;
h = figure;set(h);
for i = 1:numel(Preds)
    models(i).lm=fitlm(RegressionFed, ['log_suscettivity ~' Preds{i}]);
    plot(models(i).lm)
    h1=get(gca,'title');
    filename = ['models ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end


scale = [ ' + ' Preds{1} ' + ' Preds{2} ];
modelscale = struct;
for i = 3:numel(Preds)
    modelscale(i).lm = fitlm(RegressionFed, ['log_suscettivity ~ ' Preds{i} scale]);
    plot(modelscale(i).lm)
    h1=get(gca,'title');
    filename = ['modelscale ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end

net = [scale ' + ' Preds{4} ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8} ];
modelnet = struct;
for i = 9:numel(Preds)
    modelnet(i).lm = fitlm(RegressionFed, ['log_suscettivity ~ ' Preds{i} net]);
    plot(modelnet(i).lm)
    h1=get(gca,'title');
    filename = ['modelnet ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)        
    
end



models_r = struct;
for i = 1:numel(Preds)
    models_r(i).lm=fitlm(RegressionFed, ['log_relative_suscepty ~' Preds{i}]);
    plot(models_r(i).lm)
    h1=get(gca,'title');
    filename = ['models_r ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end
figure
plot(models_r(1).lm)
scale = [ ' + ' Preds{1} ' + ' Preds{2} ];
modelscale_r = struct;
for i = 3:numel(Preds)
    modelscale_r(i).lm = fitlm(RegressionFed, ['log_relative_suscepty ~ ' Preds{i} scale]);
    plot(modelscale_r(i).lm)
    h1=get(gca,'title');
    filename = ['modelscale_r ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end
net = [scale ' + ' Preds{4} ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8} ];
modelnet_r = struct;
for i = 9:numel(Preds)
    modelnet_r(i).lm = fitlm(RegressionFed, ['log_relative_suscepty ~ ' Preds{i} net]);
    plot(modelnet_r(i).lm)
    h1=get(gca,'title');
    filename = ['modelnet_r ', h1.String,'fed', num2str(Fednum), '.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end

end

