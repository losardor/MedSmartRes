load('doc_db.mat')
statarray = grpstats(doctor_db, 'distnum');
statarray.mean_DataID = [];
statarray.mean_peterID = [];
statarray.Properties.VariableNames{2} = 'docnum';
load('mods.mat')
for i = 1:24
Values(i,:) = mods(i).fit.Coefficients.Estimate';
end
for i = 26:121
Values(i,:) = mods(i).fit.Coefficients.Estimate';
end
statarray.fragility = 1+Values(:,1)./Values(:,2);
for i = 1:9
   statarray.fragility(statarray.mean_fedstate == i) = (statarray.fragility(statarray.mean_fedstate == i)-mean(statarray.fragility(statarray.mean_fedstate==i), 'omitnan'))/std(statarray.fragility(statarray.mean_fedstate==i), 'omitnan');
end
logvars = [statarray.Properties.VariableNames([4,10])];
RegressionData = [statarray varfun(@log, statarray(:,logvars))];

RegressionData(find(isinf(RegressionData.log_mean_betweennes)),:)=[];
RegressionData(:,logvars)=[];

novars = {'distnum'};
RegressionData(:,novars) = [];
RegressionData = RegressionData(:,[1:7 13 8:12]);
RegressionData = RegressionData(:,[1:2 13 3:12]);
Preds=RegressionData.Properties.VariableNames(1:end-1);

models = struct;
h = figure;set(h);
for i = 1:numel(Preds)
    models(i).lm=fitlm(RegressionData, ['fragility ~' Preds{i}]);
    plot(models(i).lm);
    h1=get(gca,'title');
    filename = ['models_frag', h1.String,'.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end


scale = [ ' + ' Preds{1} ' + ' Preds{2} ' + ' Preds{3} ];
modelscale = struct;
for i = 4:numel(Preds)
    modelscale(i).lm = fitlm(RegressionData, ['fragility ~ ' Preds{i} scale]);
    plot(modelscale(i).lm);
    h1=get(gca,'title');
    filename = ['modelscale_frag', h1.String,'.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)
end

net = [scale ' + ' Preds{5} ' + ' Preds{6} ' + ' Preds{7} ' + ' Preds{8} ' + ' Preds{9} ];
modelnet = struct;
for i = 10:numel(Preds)
    modelnet(i).lm = fitlm(RegressionData, ['fragility ~ ' Preds{i} net]);
    plot(modelnet(i).lm);
    h1=get(gca,'title');
    filename = ['modelnet_frag', h1.String,'.fig'];
    filename = filename(find(~isspace(filename)));
    savefig(filename)        
end



models_s = struct;
h = figure;set(h);
for i = 1:9
    models_s(i).lm=fitlm(RegressionData, ['mean_mean_disp ~' Preds{i}]);
    plot(models_s(i).lm);
%     h1=get(gca,'title');
%     filename = ['models_slope', h1.String,'.fig'];
%     filename = filename(find(~isspace(filename)));
    %savefig(filename)
end


scale = [ ' + ' Preds{1} ' + ' Preds{2} ' + ' Preds{3} ];
modelscale_s = struct;
for i = 4:9
    modelscale_s(i).lm = fitlm(RegressionData, ['mean_mean_disp ~ ' Preds{i} scale]);
    plot(modelscale_s(i).lm);
%     h1=get(gca,'title');
%     filename = ['modelscale_slope', h1.String,'.fig'];
%     filename = filename(find(~isspace(filename)));
    %savefig(filename)
end