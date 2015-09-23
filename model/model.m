rps = .7;%0.5:0.1:0.9;
gridSizes = 4;%[4 5 6];
numChoices = 2;
all_nMoves = 120;%[20:20:200];
nIter = 1000;

for rpi = 1:length(rps)
    rewardProb = rps(rpi);

    %% sim settings

    results = [];
    ct = 1;

    %% run

    for gi = 1:length(gridSizes)
        gridSize = gridSizes(gi);

        for nmi = 1:length(all_nMoves)
            nMoves = all_nMoves(nmi);

            for ii = 1:nIter

                results(ct).gridSize = gridSize;
                results(ct).nMoves = nMoves;
                results(ct).iter = ii;


                rewardSchedule = [rand(1,nMoves)<rewardProb]; % eventually not random

                map.rew = zeros(gridSize, gridSize);
                map.visits = map.rew;

                map.currentLocation.x = randi([1 4], 1);
                map.currentLocation.y = randi([1 4], 1);

                prevLoc.x = [];
                prevLoc.y = [];


                for ei = 1:nMoves

                    possibleMoves = [1 1 1 1]; % [left, up, down, right]
                    if map.currentLocation.x == 1
                      possibleMoves(1) = 0;
                    end
                    if map.currentLocation.x == gridSize
                      possibleMoves(4) = 0;
                    end
                    if map.currentLocation.y == 1
                      possibleMoves(2) = 0;
                    end
                    if map.currentLocation.y == gridSize
                      possibleMoves(3) = 0;
                    end

                    if ei>1 % not relevant on first trial
                      if map.currentLocation.x>prevLoc.x
                          %'moved right, don''t allow left'
                          possibleMoves(1) = 0;
                      end
                      if map.currentLocation.x<prevLoc.x
                          %'moved left, don''t allow right'
                          possibleMoves(4) = 0;
                      end
                      if map.currentLocation.y>prevLoc.y
                          %'moved down, don''t allow up'
                          possibleMoves(2) = 0;
                      end
                      if map.currentLocation.y<prevLoc.y
                          %'moved up, don''t allow down'
                          possibleMoves(3) = 0;
                      end
                    end     

                    moves = [];
                    for i = 1:min(numChoices, sum(possibleMoves))
                        moveInds = find(possibleMoves);
                        ri = randi([1 length(moveInds)], 1);
                        moves(i) = moveInds(ri);
                        possibleMoves(moves(i)) = 0;
                    end
                    moves = sort(moves);

                    moveOpts = [];
                    for i = 1:length(moves)
                      moveOpts(i).value = i;
                      moveOpts(i).x = map.currentLocation.x;
                      moveOpts(i).y = map.currentLocation.y;

                      switch moves(i)
                          case 1
                              moveOpts(i).x = moveOpts(i).x-1;
                          case 2
                              moveOpts(i).y = moveOpts(i).y-1;
                          case 3
                              moveOpts(i).y = moveOpts(i).y+1;
                          case 4
                              moveOpts(i).x = moveOpts(i).x+1;
                      end
                    end  

                    % choose a random answer
                    choice = randi([1 length(moves)],1);

                    prevLoc.x = map.currentLocation.x;
                    prevLoc.y = map.currentLocation.y;

                    map.currentLocation.x = moveOpts(choice).x;
                    map.currentLocation.y = moveOpts(choice).y;

                    map.visits(map.currentLocation.x, map.currentLocation.y) = map.visits(map.currentLocation.x, map.currentLocation.y) + 1;
                    map.rew(map.currentLocation.x, map.currentLocation.y) = map.rew(map.currentLocation.x, map.currentLocation.y)+rewardSchedule(ei);

                end

                results(ct).unvisits = sum(map.visits(:)==0);
                pmap = map.rew ./ map.visits;
                pmap(isnan(pmap)) = 0;
                results(ct).map = pmap;
                results(ct).nvisits = map.visits;
                results(ct).std = std(pmap(:));

                ct = ct+1;
            end
        end
    end
    save(sprintf('results_%.1f.mat', rewardProb),'results');

    %% plot std

    all_g = [results(:).gridSize];
    all_m = [results(:).nMoves];
    leg = {};
    colors = 'rgbky';
    for gi = 1:length(gridSizes)
        gridSize = gridSizes(gi);

        mean_std = [];
        se = [];

        for nmi = 1:length(all_nMoves)
            nMoves = all_nMoves(nmi);
            inds = find(all_g == gridSize & all_m == nMoves);
            mean_std(nmi) = mean([results(inds).std]);
            sd(nmi) = std([results(inds).std]);
            se(nmi) = std([results(inds).std])/sqrt(length(inds));
        end
        errorbar(all_nMoves, mean_std, sd, colors(gi));
        hold on
        leg{gi} = sprintf('%dx%d', gridSize, gridSize);

    end

    axis([0 max(all_nMoves)+min(all_nMoves) 0 0.5]);
    legend(leg);
    xlabel('Number of moves');
    ylabel('Standard deviation of reward prob');
    set(gcf, 'Position', [680   617   952   481]);
    set(gcf, 'Color','w');
    export_fig(sprintf('prob_variance_%.1f.jpg', rewardProb));
    close all
    
    %% plot unvisited

    all_g = [results(:).gridSize];
    all_m = [results(:).nMoves];
    leg = {};
    colors = 'rgbky';
    for gi = 1:length(gridSizes)
        gridSize = gridSizes(gi);

        mean_std = [];
        se = [];

        for nmi = 1:length(all_nMoves)
            nMoves = all_nMoves(nmi);
            inds = find(all_g == gridSize & all_m == nMoves);
            mean_std(nmi) = mean([results(inds).unvisits]);
            sd(nmi) = std([results(inds).unvisits]);
            se(nmi) = std([results(inds).unvisits])/sqrt(length(inds));
        end
        errorbar(all_nMoves, mean_std, max(mean_std-sd,0.000001), mean_std+sd, colors(gi));
        hold on
        leg{gi} = sprintf('%dx%d', gridSize, gridSize);

    end

    legend(leg);
    xlabel('Number of moves');
    ylabel('# of unvisited squares')
    set(gcf, 'Position', [680   617   952   481]);
    set(gcf, 'Color','w');
    axis([0 max(all_nMoves)+min(all_nMoves) 0 25]);
    export_fig(sprintf('unvisited_%.1f.jpg', rewardProb));

    set(gca,'YScale','log');
    axis([0.01 max(all_nMoves)+min(all_nMoves) 0 25]);
    export_fig(sprintf('unvisited_logy_%.1f.jpg', rewardProb));
    close all
    
    %% find representative
    
    all_g = [results(:).gridSize];
    all_m = [results(:).nMoves];
    all_sd = [results(:).std];
    for gi = 1:length(gridSizes)
        gridSize = gridSizes(gi);

        for nmi = 1:length(all_nMoves)
            nMoves = all_nMoves(nmi);
            
            inds = find(all_g == gridSize & all_m == nMoves);
            mean_std = mean([results(inds).std]);
            
            i = find(all_g==gridSize & all_m==nMoves & all_sd>mean_std*0.9 & all_sd<mean_std*1.1);
            imagesc(results(i(1)).map); caxis([0 1]); colorbar
            
            export_fig(fullfile('ex',sprintf('sample_%.1f_%d_%d.jpg', rewardProb, gridSize, nMoves)));
            close all
        end
    end

end