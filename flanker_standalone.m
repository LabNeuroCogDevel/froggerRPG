% flanker stand alone test

function [res, results_cell] = flanker_standalone(subj, levels, n)

if nargin < 2
    levels = [0 1 2];
end

if nargin < 3
    n = 50;
end

s.screen.bg=[120 120 120];
s.session.simulate = 0;
s.fix.color = [0 0 0];
s.flanker.colors.text = [0 0 0]*255;
s.flanker.colors.correct = [0 1 0]*255;
s.flanker.colors.incorrect = [1 0 0]*255;
s.flanker.displayTime = 0.2;
s.flanker.maxRespTime = [];
s.keys.finger = KbName({'1','2','ESCAPE'}); 

[w,res]=setupScreen(s.screen.bg, []);

trials = Shuffle(repmat(levels, [1 n]))
res = [];

for i = 1:length(trials)
    
    WaitSecs(rand*0.5);
    results_cell{i} = flanker(w, s, [], trials(i));
end

res = [];
fields = fieldnames(results_cell{1});
for i = 1:length(results_cell)
    for fi = 1:length(fields)
        res(i).(fields{fi}) = results_cell{i}.(fields{fi});
    end
end

save(sprintf('flanker_%s.mat', subj), 'res');

closedown();

% plot
h = figure;
congruent = [res(:).congruent];
eval = [res(:).respEval];
rt = [res(:).rt];

cNames = {'Congruent','Incongruent','Random'};
pc = []; meanRT = []; rt_se = [];
cs = unique(congruent);
for ci = 1:length(cs)
    c = cs(ci);
    inds = find(congruent == c);
    pc(ci) = mean(eval(inds));
    meanRT(ci) = mean(rt(inds));
    rt_se(ci) = std(rt(inds))/sqrt(length(inds));
end
subplot(1,2,1)
bar(pc([2 1 3]));
set(gca, 'XTickLabel', cNames);

subplot(1,2,2);
barwitherr(rt_se([2 1 3]), meanRT([2 1 3]));
set(gca, 'XTickLabel', cNames);

p = get(gcf, 'Position');
p(3) = 800;
p(4) = 300;
set(gcf, 'Position', p);

saveas(h, sprintf('flanker_%s.jpg', subj));
