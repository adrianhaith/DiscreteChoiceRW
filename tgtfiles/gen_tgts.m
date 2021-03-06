
num_choices = 4;
scale = 0.075;
num_trials = 10;
lower = 0.1;
upper = 0.9;

for ii = 1:10
    rand('seed', ii);
    output = DiscreteRandomWalk(num_choices, scale, num_trials, lower, upper);
    csvwrite(['tgtfiles/', 'block', num2str(ii), '_nchoice', num2str(num_choices), '.csv'], output);
end
