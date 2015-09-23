% RPG analysis

%% load data
clear
clc
%subj = 'julia';
%subj = 'jen';
%subj = 'will';
%subj = 'raj';
%subj = 'scott';
%subj = 'david';
%subj = 'sophie2';
%subj = 'maria';
%subj = 'dani';
%subj = 'scott2';
%subj = 'bart01';
%subj = 'brenden01';%
%subj = 'scott03';
%subj = 'bea';
%subj = 'sub0616';
subj = 'sub0617';

for i = 1:6
    res(i) = load(sprintf('results/results_%s_%d.mat', subj, i));
end

for i = 1:6
    map = res(i).map;

    nVisits = sum(~isnan(map.visitOutcomes),3);
    nRew = sum(map.visitOutcomes>=1,3);
    nHigh = sum(map.visitOutcomes>=2,3);

    pRew = nRew ./ nVisits;
    pHigh = nHigh ./ nVisits;

    expVal = 10*pRew + (50-10)*pHigh;
    pRew(isnan(pRew)) = -1;
end


%% show maps
if 0
    h_maps = figure;
    set(h_maps, 'Position', [537         490        1310         488]);
    for i = 1:6
        subplot(2,4,i+(i>=4)*1)
        map = res(i).map;

        nVisits = sum(~isnan(map.visitOutcomes),3);
        nRew = sum(map.visitOutcomes>=1,3);
        nHigh = sum(map.visitOutcomes>=2,3);

        pRew = nRew ./ nVisits;
        pHigh = nHigh ./ nVisits;

        expVal = 10*pRew + (50-10)*pHigh;


        pRew(isnan(pRew)) = -1;
        imagesc( permute(pRew, [2 1]) );
        caxis([-0.1 1]);
        cmap = colormap;
        colorbar;
        cmap(1,:) = [1 1 1]*.8;
        colormap(cmap);
        xlabel(sprintf('Run %d', i));
    end

    subplot(2,4,8)
    imagesc( permute(map.pMap/100, [2 1]) );
    caxis([-0.001 1]);
    colorbar;
    xlabel('Actual');
end

%% show expected value
if 0
    h_expval = figure;
    set(h_expval, 'Position', [680         416        1167         562]);
    for i = 1:6
        subplot(2,3,i)
        map = res(i).map;

        nVisits = sum(~isnan(map.visitOutcomes),3);
        nRew = sum(map.visitOutcomes>=1,3);
        nHigh = sum(map.visitOutcomes>=2,3);

        pRew = nRew ./ nVisits;
        pHigh = nHigh ./ nVisits;

        expVal = 10*pRew + (50-10)*pHigh;


        pRew(isnan(expVal)) = -1;
        imagesc(expVal);
        caxis([-0.001 30]);
        cmap = colormap;
        colorbar;
        cmap(1,:) = [1 1 1]*.8;
        colormap(cmap);
    end
end

% %% prepare cog task data
% 
% cogData = [];
% % structure:
% %   [block# event# rewardLevel congruent eval RT]
% for i = 1:6
%     for ei = 1:length(res(i).e)
%         if isfield(res(i).e(ei), 'cogRes') && ~isempty(res(i).e(ei).cogRes)
%             cogData = [cogData; i ei res(i).e(ei).rewType res(i).e(ei).cogRes.congruent res(i).e(ei).cogRes.respEval res(i).e(ei).cogRes.rt];
%         end
%     end
% end
% 
% %% cog performance by block
% congNames = {'Incongruent','Congruent'};
% 
% blocks = unique(cogData(:,1));
% rewTypes = [1 2];
% congruents = [0 1];
% for blocki = 1:length(blocks)
%     block = blocks(blocki);
%     
%     for rewTypei = 1:length(rewTypes)
%         rewType = rewTypes(rewTypei);
%         
%         for congi = 1:length(congruents)
%             congruent = congruents(congi);
%             
%             inds = find( cogData(:,1)==block & cogData(:,3)==rewType & cogData(:,4)==congruent );
%             pcorr(blocki, rewTypei, congi) = nanmean(cogData(inds, 5));
%             meanRT(blocki, rewTypei, congi) = nanmean(cogData(inds, 6));
%             
%             fprintf(1, '%d %d %d: %.2f%%, %.0f msec\n', block, rewType, congruent, 100*pcorr(blocki, rewTypei, congi), 1000*meanRT(blocki, rewTypei, congi));
%         end
%     end
% end
% 
% h_pc = figure;
% h_rt = figure;
% colors = 'kr';
% 
% for rewTypei = 1:length(rewTypes)
%     rewType = rewTypes(rewTypei);
% 
%     for congi = 1:length(congruents)
%         congruent = congruents(congi);
% 
%             figure(h_pc);
%             subplot(1,2,congi);
%             hold on
%             plot(blocks, 100*squeeze(pcorr(:, rewTypei, congi)), ['o-' colors(rewTypei)]);
%             axis([0 max(blocks)+1 0 100]);
%             legend('Low Reward', 'High Reward', 'Location', 'Best');
%             ylabel('% Correct');
%             xlabel(congNames{congi});
%             
%             figure(h_rt);
%             subplot(1,2,congi);
%             hold on
%             plot(blocks, squeeze(meanRT(:, rewTypei, congi)), ['o-' colors(rewTypei)]);
%             axis([0 max(blocks)+1 0 1]);
%             legend('Low Reward', 'High Reward', 'Location', 'Best');
%             ylabel('Reaction Time (sec)');
%             xlabel(congNames{congi});
% 
%     end
% end
% 
% %% cog performance across all blocks
% h_cogall= figure;
% allRT = [];
% pcorr = [];
% meanRT = [];
% for rewTypei = 1:length(rewTypes)
%     rewType = rewTypes(rewTypei);
% 
%     for congi = 1:length(congruents)
%         congruent = congruents(congi);
% 
%         inds = find( cogData(:,3)==rewType & cogData(:,4)==congruent );
%         for indi = 1:length(inds)
%             allRT = [allRT; rewTypei congi cogData(inds(indi), 6)];
%         end
%         pcorr(rewTypei, congi) = nanmean(cogData(inds, 5));
%         meanRT(rewTypei, congi) = nanmean(cogData(inds, 6));
%         rt_se(rewTypei, congi) = nanstd(cogData(inds, 6))/sqrt(length(inds));
%     end
% end
% 
% congNames = {'Incongruent','Congruent'};
% 
% subplot(1,2,1)
% bar(100*pcorr');
% legend({'Low Reward', 'High Reward'}, 'Location', 'Best');
% set(gca, 'XTickLabel', congNames);
% ylabel('% correct');
% 
% 
% 
% subplot(1,2,2)
% barwitherr(rt_se', meanRT');
% set(gca, 'XTickLabel', congNames);
% ylabel('RT (sec)');
% alldata.(subj).meanRT = meanRT;
% 
% % anova
% [p_anova,t,stats,terms] = anovan(allRT(:,3), allRT(:,1:2), 'model','full','varnames', {'reward','congruency'}, 'display', 'off'); p_anova
% 
% % t-test for congruent data
% [h,p_congruent,ci,stats] = ttest2( allRT( find(allRT(:,1)==1 & allRT(:,2)==1), 3), allRT( find(allRT(:,1)==2 & allRT(:,2)==1), 3)); p_congruent
% 
% % t-test for incongruent data
% [h,p_incongruent,ci,stats] = ttest2( allRT( find(allRT(:,1)==1 & allRT(:,2)==2), 3), allRT( find(allRT(:,1)==2 & allRT(:,2)==2), 3)); p_incongruent


%% final map test
if 1
    nVisits = sum(~isnan(map.visitOutcomes),3);
    nRew = sum(map.visitOutcomes>=1,3);
    nHigh = sum(map.visitOutcomes>=2,3);

    pRew = nRew ./ nVisits;
    pHigh = nHigh ./ nVisits;

    expVal = 10*pRew + (50-10)*pHigh;

    pDiff = [];
    phighDiff = [];
    expvalDiff = [];
    pickedHigherProb = [];
    pickedHigherExpected = [];
    rt = [];
    mapRes = res(6).finalMaptestResults;
    for i = 1:length(mapRes)
        p1 = pRew(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y);
        p2 = pRew(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y);

        higherProb = (p2>p1) +1;
        pDiff(i) = abs(p1-p2);

        phigh1 = pHigh(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y);
        phigh2 = pHigh(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y);

        phigh_higherProb = (phigh2>phigh1) +1;
        phighDiff(i) = abs(phigh1-phigh2);

        exp1 = expVal(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y);
        exp2 = expVal(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y);

        higherExp = (exp2>exp1) + 1;
        expvalDiff(i) = abs(exp2-exp1);

        totalRew1 = nRew(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y);
        totalRew2 = nRew(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y);

        higherTotalRew = (totalRew2>totalRew1) + 1;
        totalRewDiff(i) = abs(totalRew2-totalRew1);

        totalPoints1 = 10*nRew(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y) + 40*nHigh(mapRes(i).moveOpts(1).x, mapRes(i).moveOpts(1).y);
        totalPoints2 = 10*nRew(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y) + 40*nHigh(mapRes(i).moveOpts(2).x, mapRes(i).moveOpts(2).y);

        higherTotalPoints = (totalPoints2>totalPoints1) + 1;
        totalPointsDiff(i) = abs(totalPoints2-totalPoints1);

        if isempty(mapRes(i).resp)
            pickedHigherProb(i).eval = NaN;
            pickedHigherExpected(i).eval = NaN;
            pickedHigherHighprob(i).eval = NaN;
            pickedHigherNumRew(i).eval = NaN;
            pickedHigherTotalPoints(i).eval = NaN;

            pickedHigherProb(i).rt = NaN;
            pickedHigherExpected(i).rt = NaN;
            pickedHigherHighprob(i).rt = NaN;
            pickedHigherNumRew(i).rt = NaN;
            pickedHigherTotalPoints(i).rt = NaN;        
        else
            pickedHigherProb(i).eval = mapRes(i).resp == higherProb;
            pickedHigherExpected(i).eval = mapRes(i).resp == higherExp;
            pickedHigherHighprob(i).eval = mapRes(i).resp == phigh_higherProb;
            pickedHigherNumRew(i).eval = mapRes(i).resp == higherTotalRew;
            pickedHigherTotalPoints(i).eval = mapRes(i).resp == higherTotalPoints;

            pickedHigherProb(i).rt = mapRes(i).rt;
            pickedHigherExpected(i).rt = mapRes(i).rt;
            pickedHigherHighprob(i).rt = mapRes(i).rt;
            pickedHigherNumRew(i).rt = mapRes(i).rt;
            pickedHigherTotalPoints(i).rt = mapRes(i).rt;
        end    

    end

    xvars = {pDiff, phighDiff, expvalDiff, totalRewDiff, totalPointsDiff};
    yvars = {pickedHigherProb, pickedHigherHighprob, pickedHigherExpected, pickedHigherNumRew, pickedHigherTotalPoints};
    varNames = {'Reward Probability Difference', 'High Reward Probability Difference', 'Expected Value Difference', 'Number of Rewards Difference', 'Total Points Difference'};

    h_spatial = figure;
    for vari = 1:length(xvars)
        inds = []; meanP = [];
        thisx = xvars{vari};
        thisy = [yvars{vari}.eval];

        sorted = sort(thisx(~isnan(thisx)));
    %    x = sorted(round(length(sorted).*([.1 .3 .5 .7 .9]))); %[0.05 0.15 0.25 0.35 0.45];
        x = sorted(round(length(sorted).*([.125 .375 .625 .875]))); %[0.05 0.15 0.25 0.35 0.45];
        x = x(x<max(thisx));
        x_low = [0 x(2:end)-diff(x)/2];
        x_high = [x(1:end-1)+diff(x)/2 max(thisx)];
        for xi = 1:length(x)
            inds = find(~isnan(thisx) & thisx > x_low(xi) & thisx < x_high(xi));
            if isempty(inds)
                meanP(xi) = NaN;
            else
                meanP(xi) = nanmean(thisy(inds));
            end
        end
        subplot(2,3,vari)
        plot(x, meanP, 'o-');
        hold on;plot([0 max(x)], [.5 .5], 'k--');
        axis([0 max(x) 0 1]);
        xlabel(varNames{vari});

        alldata.(subj).spatial{vari}.x = x;
        alldata.(subj).spatial{vari}.y = meanP;
    end


    set(gcf, 'position', [680         394        1147         584]);
end

% %% incremental map test
% colors = 'rgbymk';
% h_spatial = figure;
% leg = {};
% 
% for runi = 1:length(res)
%     pDiff = [];         
%     phighDiff = [];    
%     expvalDiff = [];    
%     totalRewDiff = [];    
%     totalPointsDiff = [];
%     
%     pickedHigherProb = [];    
%     pickedHigherExpected = [];    
%     pickedHigherHighprob = [];
%     pickedHigherNumRew = [];
%     pickedHigherTotalPoints = [];    
%     
%     rt = [];
%     mapRes = res(runi).maptestResults;
%     if ~isempty(mapRes)
%         for i = 1:length(mapRes)
%             p1 = mapRes(i).moveOpts(1).pRew;
%             p2 = mapRes(i).moveOpts(2).pRew;
% 
%             higherProb = (p2>p1) +1;
%             pDiff(i) = abs(p1-p2);
% 
%             phigh1 = mapRes(i).moveOpts(1).pHigh;
%             phigh2 = mapRes(i).moveOpts(2).pHigh;
% 
%             phigh_higherProb = (phigh2>phigh1) +1;
%             phighDiff(i) = abs(phigh1-phigh2);
% 
%             exp1 = mapRes(i).moveOpts(1).expVal;
%             exp2 = mapRes(i).moveOpts(2).expVal;
% 
%             higherExp = (exp2>exp1) + 1;
%             expvalDiff(i) = abs(exp2-exp1);
% 
%             totalRew1 = mapRes(i).moveOpts(1).nVisits*mapRes(i).moveOpts(1).pRew;
%             totalRew2 = mapRes(i).moveOpts(2).nVisits*mapRes(i).moveOpts(2).pRew;
% 
%             higherTotalRew = (totalRew2>totalRew1) + 1;
%             totalRewDiff(i) = abs(totalRew2-totalRew1);
% 
%             totalPoints1 = mapRes(i).moveOpts(1).nVisits*(10*mapRes(i).moveOpts(1).pRew + 40*mapRes(i).moveOpts(1).pHigh);
%             totalPoints2 = mapRes(i).moveOpts(2).nVisits*(10*mapRes(i).moveOpts(2).pRew + 40*mapRes(i).moveOpts(2).pHigh);
% 
%             higherTotalPoints = (totalPoints2>totalPoints1) + 1;
%             totalPointsDiff(i) = abs(totalPoints2-totalPoints1);
% 
%             if isempty(mapRes(i).resp)
%                 pickedHigherProb(i).eval = NaN;
%                 pickedHigherExpected(i).eval = NaN;
%                 pickedHigherHighprob(i).eval = NaN;
%                 pickedHigherNumRew(i).eval = NaN;
%                 pickedHigherTotalPoints(i).eval = NaN;
% 
%                 pickedHigherProb(i).rt = NaN;
%                 pickedHigherExpected(i).rt = NaN;
%                 pickedHigherHighprob(i).rt = NaN;
%                 pickedHigherNumRew(i).rt = NaN;
%                 pickedHigherTotalPoints(i).rt = NaN;        
%             else
%                 pickedHigherProb(i).eval = mapRes(i).resp == higherProb;
%                 pickedHigherExpected(i).eval = mapRes(i).resp == higherExp;
%                 pickedHigherHighprob(i).eval = mapRes(i).resp == phigh_higherProb;
%                 pickedHigherNumRew(i).eval = mapRes(i).resp == higherTotalRew;
%                 pickedHigherTotalPoints(i).eval = mapRes(i).resp == higherTotalPoints;
% 
%                 pickedHigherProb(i).rt = mapRes(i).rt;
%                 pickedHigherExpected(i).rt = mapRes(i).rt;
%                 pickedHigherHighprob(i).rt = mapRes(i).rt;
%                 pickedHigherNumRew(i).rt = mapRes(i).rt;
%                 pickedHigherTotalPoints(i).rt = mapRes(i).rt;
%             end    
% 
%         end
% 
%         xvars = {pDiff, phighDiff, expvalDiff, totalRewDiff, totalPointsDiff};
%         yvars = {pickedHigherProb, pickedHigherHighprob, pickedHigherExpected, pickedHigherNumRew, pickedHigherTotalPoints};
%         varNames = {'Reward Probability Difference', 'High Reward Probability Difference', 'Expected Value Difference', 'Number of Rewards Difference', 'Total Points Difference'};
% 
%         
%         for vari = 1:length(xvars)
%             inds = []; meanP = [];
%             thisx = xvars{vari};
%             thisy = [yvars{vari}.eval];
% 
%             sorted = sort(thisx(~isnan(thisx)));
%             switch numel(unique(sorted))
%                 case 1
%                     x_low = 0;
%                     x_high = max(thisx);
%                 case 2
%                     x = sorted(round(length(sorted).*([.25 .75]))); %[0.05 0.15 0.25 0.35 0.45];
%                     x = x(x<=max(thisx));
%                     x_low = [0 x(2:end)-diff(x)/2];
%                     x_high = [x(1:end-1)+diff(x)/2 max(thisx)];
%                 otherwise
%                     x = sorted(round(length(sorted).*([1/6 3/6 5/6]))); %[0.05 0.15 0.25 0.35 0.45];
%                     x = x(x<=max(thisx));
%                     x_low = [0 x(2:end)-diff(x)/2];
%                     x_high = [x(1:end-1)+diff(x)/2 max(thisx)];
%             end
%             
%             for xi = 1:length(x)
%                 inds = find(~isnan(thisx) & thisx > x_low(xi) & thisx < x_high(xi));
%                 if isempty(inds)
%                     meanP(xi) = NaN;
%                 else
%                     meanP(xi) = nanmean(thisy(inds));
%                 end
%             end
%             subplot(2,3,vari)
%             hold on
%             plot(x, meanP, ['o-' colors(runi)]);
%             
%             if runi==length(res)
%                 plot([0 max(x)], [.5 .5], 'k--');
%             end
%             axis([0 max(x) 0 1]);
%             xlabel(varNames{vari});
%             
%             if vari == 1
%                 leg{end+1} = sprintf('Run %d', runi);
%             end
% 
%             alldata.(subj).spatial{vari}.by_run(runi) = sum(thisy)/length(thisy);
%         end
%     end
% end
% legend(leg, 'Location','best')
% set(gcf, 'position', [680         394        1147         584]);

% %% incremental map test
% colors = 'rgbymk';
% leg = {};
% easy = {};
% hard = {};
% 
% for runi = 1:length(res)
%     pDiff = [];         
%     phighDiff = [];    
%     expvalDiff = [];    
%     totalRewDiff = [];    
%     totalPointsDiff = [];
%     
%     pickedHigherProb = [];    
%     pickedHigherExpected = [];    
%     pickedHigherHighprob = [];
%     pickedHigherNumRew = [];
%     pickedHigherTotalPoints = [];    
%     
%     rt = [];
%     mapRes = res(runi).maptestResults;
%     if ~isempty(mapRes)
%         for i = 1:length(mapRes)
%             p1 = mapRes(i).moveOpts(1).pRew;
%             p2 = mapRes(i).moveOpts(2).pRew;
% 
%             higherProb = (p2>p1) +1;
%             pDiff(i) = abs(p1-p2);
% 
%             phigh1 = mapRes(i).moveOpts(1).pHigh;
%             phigh2 = mapRes(i).moveOpts(2).pHigh;
% 
%             phigh_higherProb = (phigh2>phigh1) +1;
%             phighDiff(i) = abs(phigh1-phigh2);
% 
%             exp1 = mapRes(i).moveOpts(1).expVal;
%             exp2 = mapRes(i).moveOpts(2).expVal;
% 
%             higherExp = (exp2>exp1) + 1;
%             expvalDiff(i) = abs(exp2-exp1);
% 
%             totalRew1 = mapRes(i).moveOpts(1).nVisits*mapRes(i).moveOpts(1).pRew;
%             totalRew2 = mapRes(i).moveOpts(2).nVisits*mapRes(i).moveOpts(2).pRew;
% 
%             higherTotalRew = (totalRew2>totalRew1) + 1;
%             totalRewDiff(i) = abs(totalRew2-totalRew1);
% 
%             totalPoints1 = mapRes(i).moveOpts(1).nVisits*(10*mapRes(i).moveOpts(1).pRew + 40*mapRes(i).moveOpts(1).pHigh);
%             totalPoints2 = mapRes(i).moveOpts(2).nVisits*(10*mapRes(i).moveOpts(2).pRew + 40*mapRes(i).moveOpts(2).pHigh);
% 
%             higherTotalPoints = (totalPoints2>totalPoints1) + 1;
%             totalPointsDiff(i) = abs(totalPoints2-totalPoints1);
% 
%             if isempty(mapRes(i).resp)
%                 pickedHigherProb(i).eval = NaN;
%                 pickedHigherExpected(i).eval = NaN;
%                 pickedHigherHighprob(i).eval = NaN;
%                 pickedHigherNumRew(i).eval = NaN;
%                 pickedHigherTotalPoints(i).eval = NaN;
% 
%                 pickedHigherProb(i).rt = NaN;
%                 pickedHigherExpected(i).rt = NaN;
%                 pickedHigherHighprob(i).rt = NaN;
%                 pickedHigherNumRew(i).rt = NaN;
%                 pickedHigherTotalPoints(i).rt = NaN;        
%             else
%                 pickedHigherProb(i).eval = mapRes(i).resp == higherProb;
%                 pickedHigherExpected(i).eval = mapRes(i).resp == higherExp;
%                 pickedHigherHighprob(i).eval = mapRes(i).resp == phigh_higherProb;
%                 pickedHigherNumRew(i).eval = mapRes(i).resp == higherTotalRew;
%                 pickedHigherTotalPoints(i).eval = mapRes(i).resp == higherTotalPoints;
% 
%                 pickedHigherProb(i).rt = mapRes(i).rt;
%                 pickedHigherExpected(i).rt = mapRes(i).rt;
%                 pickedHigherHighprob(i).rt = mapRes(i).rt;
%                 pickedHigherNumRew(i).rt = mapRes(i).rt;
%                 pickedHigherTotalPoints(i).rt = mapRes(i).rt;
%             end    
% 
%         end
% 
%         xvars = {pDiff, phighDiff, expvalDiff, totalRewDiff, totalPointsDiff};
%         yvars = {pickedHigherProb, pickedHigherHighprob, pickedHigherExpected, pickedHigherNumRew, pickedHigherTotalPoints};
%         varNames = {'Reward Probability Difference', 'High Reward Probability Difference', 'Expected Value Difference', 'Number of Rewards Difference', 'Total Points Difference'};
% 
%         
%         for vari = 1:length(xvars)
%             inds = []; meanP = [];
%             thisx = xvars{vari};
%             thisy = [yvars{vari}.eval];
% 
%             midx = median(thisx(~isnan(thisx)));
%             easy_inds = find(thisx>midx);
%             hard_inds = find(thisx<=midx);
%             
%             easy{vari}(runi) = nanmean(thisy(easy_inds));
%             hard{vari}(runi) = nanmean(thisy(hard_inds));
%             
%             if isnan(easy{vari}(runi))
%             %    keyboard
%             end
%             
%             alldata.(subj).spatial{vari}.by_run(runi) = sum(thisy)/length(thisy);
%         end
%     end
% end
% 
% figure
% for vari = 1:length(xvars)
%     subplot(2,3,vari);
%     plot(1:6, easy{vari}, 'g');
%     hold on
%     plot(1:6, hard{vari}, 'r');
%     ylabel(['By ' varNames{vari}]);
%     xlabel('Block #');
%     plot([0 7], [.5 .5], 'k--');
%     axis([0 7 0 1]);
% end
% 
% legend({'EZ','Hard'}, 'Location','best')
% set(gcf, 'position', [680         394        1147         584]);


%% learning from moves
if 0
    figure;
    moveData = [];
    for i = 1:6
        for ei = 1:length(res(i).e)
            mo1 = res(i).e(ei).moveOpts(1);
            mo2 = res(i).e(ei).moveOpts(2);

            if mo1.pLev ~= mo2.pLev

                map = res(i).e(ei).map;

                nVisits = sum(~isnan(map.visitOutcomes),3);
                nRew = sum(map.visitOutcomes>=1,3);
                nHigh = sum(map.visitOutcomes>=2,3);

                pRew = nRew ./ nVisits;
                pHigh = nHigh ./ nVisits;

                expVal = 10*pRew + (50-10)*pHigh;
                totalVal = expVal .* nVisits;


                moveData(end+1).i = i;
                moveData(end).ei = ei;
                moveData(end).pLev1 = mo1.pLev;
                moveData(end).pLev2 = mo2.pLev;
                moveData(end).pLevDiff = mo1.pLev - mo2.pLev;


                moveData(end).pDiff = pRew(mo1.x, mo1.y) - pRew(mo2.x, mo2.y);
                moveData(end).expValDiff = expVal(mo1.x, mo1.y) - expVal(mo2.x, mo2.y);
                moveData(end).totalValDiff = totalVal(mo1.x, mo1.y) - totalVal(mo2.x, mo2.y);

                if (res(i).e(ei).map.currentLocation.x == mo1.x) & (res(i).e(ei).map.currentLocation.y == mo1.y)
                    moveData(end).choice = 1;
                else
                    moveData(end).choice = -1;
                end

                moveData(end).pickedHigherObservedProb = sign(moveData(end).choice) == sign(moveData(end).pDiff);
                moveData(end).pickedHigherProbLevel = sign(moveData(end).choice) == sign(moveData(end).pLevDiff);
                moveData(end).pickedHigherExpVal = sign(moveData(end).choice) == sign(moveData(end).expValDiff);
                moveData(end).pickedHigherTotalVal = sign(moveData(end).choice) == sign(moveData(end).totalValDiff);

            end


        end
    end


    for i = 1:6
        inds = find([moveData.i] == i);

        pHigherObservedProb(i) = sum([moveData(inds).pickedHigherObservedProb])/length(inds);
        pHigherProbLevel(i) = sum([moveData(inds).pickedHigherProbLevel])/length(inds);
        pHigherExpVal(i) = sum([moveData(inds).pickedHigherExpVal])/length(inds);
        pHigherTotalVal(i) = sum([moveData(inds).pickedHigherTotalVal])/length(inds);

        alldata.(subj).moveLearning.pHigherObservedProb(i) = pHigherObservedProb(i);
        alldata.(subj).moveLearning.pHigherProbLevel(i) = pHigherProbLevel(i);
        alldata.(subj).moveLearning.pHigherExpVal(i) = pHigherExpVal(i);
        alldata.(subj).moveLearning.pHigherTotalVal(i) = pHigherTotalVal(i);

    end

    subplot(2,2,1);
    bar(1:6, pHigherObservedProb); hold on; plot([0 7], [.5 .5], '--k');
    ylabel('% by observed prob');
    xlabel('block #');
    axis([0 7 0 1]);

    subplot(2,2,2);
    bar(1:6, pHigherProbLevel); hold on; plot([0 7], [.5 .5], '--k');
    ylabel('% by prob level');
    xlabel('block #');
    axis([0 7 0 1]);

    subplot(2,2,3);
    bar(1:6, pHigherExpVal); hold on; plot([0 7], [.5 .5], '--k');
    ylabel('% by exp val');
    xlabel('block #');
    axis([0 7 0 1]);

    subplot(2,2,4);
    bar(1:6, pHigherTotalVal); hold on; plot([0 7], [.5 .5], '--k');
    ylabel('% by total reward');
    xlabel('block #');
    axis([0 7 0 1]);
end

%% ANTI - show incorrect saccades
moveData = [];
for i = 1:6
    e = res(i).e;
    for ei = 1:length(e)
        
        if ~isempty(e(ei).cogRes)
            if e(ei).cogRes.respEval == 0 | isempty(e(ei).cogRes.respEval)
                e(ei)
                e(ei).cogRes
                figure
                plot(e(ei).eyedata.cog.x - 130);
                
                miny = min(-150, min(e(ei).eyedata.cog.x-130));
                maxy = max(150, max(e(ei).eyedata.cog.x-130));
                minx = 0;
                maxx = length(e(ei).eyedata.cog.x);
                axis([0 maxx miny maxy]);
                
                
                
                uiwait;
            end
            
            
        end
        
    end
end

%% ANTI - performance
cogdata = [];
for i = 1:6
    e = res(i).e;
    for ei = 1:length(e)
        
        if ~isempty(e(ei).cogRes)
            if isempty(e(ei).cogRes.respEval)
                %e(ei).cogRes
            else
                cogdata = [cogdata; e(ei).cogRewType e(ei).cogRes.targetSide e(ei).cogRes.targetEcc e(ei).cogRes.respEval];
            end
        end
        
    end
end

for near = [0 1]
    for rew = [1 2]
        inds = find(cogdata(:,3)==near & cogdata(:,1)==rew);
        pc(near+1,rew) = mean(cogdata(inds,4));
        se(near+1,rew) = 1.96*sqrt( (pc(near+1,rew)*(1-pc(near+1,rew))) / length(inds) );
    end
end
barwitherr(se,pc)
set(gca, 'XTickLabel', {'Near','Far'})
legend('Low Reward','High Reward')
axis([0.5 2.5 0 1])
set(gcf, 'position', [100   955   569   390]);


%%
close all