subjs = fieldnames(alldata);
nsubjs = length(subjs);

%%
varNames = {'Reward Probability Difference', 'High Reward Probability Difference', 'Expected Value Difference', 'Number of Rewards Difference', 'Total Points Difference'};

vari = 5;

all_rt = nan*ones(2,2,nsubjs);
spatialPerf = [];
for subji = 1:nsubjs
    subj = subjs{subji};
    
    all_rt(:,:,subji) = alldata.(subj).meanRT;
    spatialPerf = [spatialPerf; alldata.(subj).spatial{vari}.y];
end

rt = mean(all_rt,3);
se = std(all_rt,[],3)/sqrt(nsubjs);

figure;

congNames = {'Incongruent','Congruent'};

barwitherr(se', rt');
set(gca, 'XTickLabel', congNames);
ylabel('RT (sec)');

'Congruent stats'
[h,p,ci,stats] = ttest(squeeze(all_rt(1,2,:)), squeeze(all_rt(2,2,:)))

'Incongruent stats'
[h,p,ci,stats] = ttest(squeeze(all_rt(1,1,:)), squeeze(all_rt(2,1,:)))


figure;

x = [.125 .375 .625 .875];
y = mean(spatialPerf,1);
se = std(spatialPerf,[],1)/sqrt(nsubjs);
errorbar(x,y,se)
hold on
plot([0 max(x)], [.5 .5], 'k--');
axis([0 1 0 1]);
xlabel(['Quartile (' varNames{vari} ')']);
ylabel('% correct');


%% incremental from movement data
var = 'pHigherExpVal';

allLearning = [];
for subji = 1:nsubjs
    subj = subjs{subji};
    allLearning = [allLearning; alldata.(subj).moveLearning.(var)];
end

x = 1:6;
y = nanmean(allLearning, 1);
se = nanstd(allLearning, [], 1)/sqrt(size(allLearning,1));

barwitherr(se', y');
hold on
plot([0 max(x)], [.5 .5], 'k--');
xlabel('Block #');
ylabel('% moves to higher expected value');
axis([0 7 0 1])