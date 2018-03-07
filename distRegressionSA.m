load('doc_dbSA.mat')
statarray = grpstats(doctor_dbSA, 'distnum');
statarray.mean_DataID = [];
statarray.mean_peterID = [];
statarray.Properties.VariableNames{2} = 'docnum';
load('mods.mat')
% for i = 1:24
% Values(i,:) = mods(i).fit.Coefficients.Estimate';
% end
% for i = 26:121
% Values(i,:) = mods(i).fit.Coefficients.Estimate';
% end
% statarray.fragility = 1+Values(:,1)./Values(:,2);
% for i = 1:9
%    statarray.fragility(statarray.mean_fedstate == i) = (statarray.fragility(statarray.mean_fedstate == i)-mean(statarray.fragility(statarray.mean_fedstate==i), 'omitnan'))/std(statarray.fragility(statarray.mean_fedstate==i), 'omitnan');
% end
logvars = [statarray.Properties.VariableNames([4,12,13,15,16])];
RegressionData = [statarray varfun(@log, statarray(:,logvars))];

RegressionData(find(isinf(RegressionData.log_mean_betweennes)),:)=[];
RegressionData(:,logvars)=[];

novars = {'distnum'};
RegressionData = RegressionData(:,[1:3 13 4:12 14:end]);
RegressionData = RegressionData(:,[1:11 14 12:13 15:end]);
RegressionData = RegressionData(:,[1:12 15 13:14 16:end]);
RegressionData(:,novars) = [];
Preds=RegressionData.Properties.VariableNames(1:end-2);

models = struct;
h = figure;set(h);
for i = 1:numel(Preds)
    models(i).lm=fitlm(RegressionData, ['log_mean_mean_disp ~' Preds{i}]);
    plot(models(i).lm);
    h1=get(gca,'title');
    filename = ['models_frag', h1.String,'.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end


scale = [ ' + ' Preds{1} ' + ' Preds{2} ' + ' Preds{3} ];
modelscale = struct;
for i = 4:numel(Preds)
    modelscale(i).lm = fitlm(RegressionData, ['log_mean_mean_disp ~ ' Preds{i} scale]);
end

net = [scale ' + ' Preds{4} ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8}  '+ ' Preds{9} ' + ' Preds{10} ' + ' Preds{11} ' + ' Preds{12} ' + ' Preds{13}];
modelnet = struct;
for i = 14:numel(Preds)
    modelnet(i).lm = fitlm(RegressionData, ['log_mean_mean_disp ~ ' Preds{i} net]);
end



models_s = struct;
h = figure;set(h);
for i = 1:numel(Preds)
    models_s(i).lm=fitlm(RegressionData, ['log_mean_mean_losts ~' Preds{i}]);
    plot(models_s(i).lm);
    h1=get(gca,'title');
    filename = ['models_slope', h1.String,'.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end


modelscale_s = struct;
for i = 4:numel(Preds)
    modelscale_s(i).lm = fitlm(RegressionData, ['log_mean_mean_losts ~ ' Preds{i} scale]);
end

modelnet_s = struct;
for i = 14:numel(Preds)
    modelnet_s(i).lm = fitlm(RegressionData, ['log_mean_mean_losts ~ ' Preds{i} scale net]);
end
