function m = initMap(settings, m, numEv)

if nargin<2 || isempty(m)
    m = [];

    % track outcomes
    m.visitOutcomes = NaN*ones(settings.map.gridSize, settings.map.gridSize, 1000); % 1000 is maximum visits per square; make it large
    
    % set up probability map
    switch settings.map.gridSize
        case 3
            m.pLevels = [20 50 80];
            
        case 4
            m.pLevels = [20 40 60 80];
            
        case 5
            m.pLevels = [10 30 50 70 90];
            
    end
    
    m.squaresPerLevel = settings.map.gridSize*settings.map.gridSize/length(m.pLevels);

    validMap = 0;
    ct = 0;
    while ~validMap
        ct = ct + 1;
        probs = repmat(m.pLevels, [1 m.squaresPerLevel]);
        %probs = probs(randperm(length(probs)));
        probs = Shuffle(probs);
        pMap = reshape(probs, settings.map.gridSize, settings.map.gridSize);
        
        % check for neighbors of same p
        validMap = 1;
        
        for xi = 1:settings.map.gridSize
            for yi = 1:settings.map.gridSize
                if xi<settings.map.gridSize & pMap(xi,yi)==pMap(xi+1,yi)
                    validMap = 0;
                end
                if yi<settings.map.gridSize & pMap(xi,yi)==pMap(xi,yi+1)
                    validMap = 0;
                end
            end
        end
    end
    fprintf(1, 'Found good map after %d iterations\n',ct);
    m.pMap = pMap;
    
    % find # of repetitions
    totalTrials = numEv * settings.session.maxRuns;
    trialsPerProb = ceil(totalTrials / length(m.pLevels));
    for i = 1:length(m.pLevels)
        m.trials.maxTrials(i) = trialsPerProb;
        m.trials.maxRewarded(i) = round(m.trials.maxTrials(i)*m.pLevels(i)/100) + 1;
        m.trials.maxUnrewarded(i) = m.trials.maxTrials(i) - m.trials.maxRewarded(i) + 2;
        
        m.trials.numRewarded(i) = 0;
        m.trials.numUnrewarded(i) = 0;
    end
    
end

m.trials
% set start location (currently randomized)
m.currentLocation.x = randi(settings.map.gridSize, 1);
m.currentLocation.y = randi(settings.map.gridSize, 1);

