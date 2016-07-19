function output = main(subject_id, tgtfile, fullscreen)

    addpath(genpath('Psychoobox'));
    addpath('tgtfiles');
    tgt = csvread(['tgtfiles/', tgtfile]);
    block = str2num(regexprep(tgtfile(5:8), '\D', ''));

    rand('seed', block);
    num_choices = size(tgt, 2);
    num_trials = size(tgt, 1);
    points = 0;

    output = zeros(num_trials, 6 + num_choices);
    output(:, 7:end) = tgt;
    output(:, 1) = subject_id;
    output(:, 2) = block;

    % Set up keyboard
    potential_keys = {{'a', 's', 'd', 'f', 'h', 'j', 'k', 'l'}};
    mykeys = BlamKeyboard(1:num_choices, 'possible_keys', potential_keys);
    potential_keys = potential_keys{1};
    if fullscreen
        rect_size = [];
    else
        rect_size = [30 30 400 400];
    end

    % set up aud cue
    snd = wavread('beep.wav');
    snd2 = wavread('smw_coin.wav');
    aud = PsychAudio('mode', 9);
    aud.AddSlave(1, 'channels', 2);
    aud.AddSlave(2, 'channels', 2);
    aud.FillBuffer([snd snd]', 1);
    aud.FillBuffer([snd2 snd2]', 2);


    Screen('Preference', 'Verbosity', 1);
    win = PsychWindow(0, true, 'color', [0 0 0], 'rect', rect_size);
    pks = cellfun(@(str) sprintf('%s, ', str), mykeys.valid_keys, 'UniformOutput', false);
    pks = strcat(pks{:});
    pks = pks(1:end-1);
    intro_txt = ['Keys are: ', pks];
    txt = PsychText('val', intro_txt,...
                    'color', [255 255 255],...
                    'x', win.center(1), 'y', win.center(2), ...
                    'size', 30);
    txt.Draw(win.pointer);


    % set up cat
%     kitty = imread('cat.jpg');
%     textures = PsychTexture;
%     textures.AddImage(kitty, win.pointer, 1, 'draw_rect', [10 10 300 200]);
%     textures.Draw(win.pointer, 1);

    win.Flip;
    WaitSecs(2);

    txt_str = ['Points: +', num2str(points), '\n', 'Trial #: ', num2str(0)];
    txt.Set('val', txt_str, 'color', [78 230 50]);
    txt.Draw(win.pointer);
%     textures.Draw(win.pointer, 1);
    time_ref = win.Flip;

    for nn = 1:num_trials

        aud.Play(0, 1);
        mykeys.Start;
        new_press = [-1 -1];
        while new_press(1) == -1
            new_press = mykeys.Check;
            WaitSecs(0.1);
        end

        mykeys.Stop;
        mykeys.Flush;
        output(nn, 3) = new_press(1);
        output(nn, 4) = new_press(2) - time_ref;

        reward = binornd(1, tgt(nn, new_press(1)));
        output(nn, 5) = reward;
        if reward
            points = points + 10;
            aud.Play(0, 2);
        end
        txt_str = ['Points: +', num2str(points), '\n', 'Trial #: ', num2str(nn)];
        txt.Set('val', txt_str);
        txt.Draw(win.pointer);
%         textures.Draw(win.pointer, 1);
        win.Flip;
        WaitSecs(0.5);
        output(nn, 6) = points;
    end

    mykeys.Close;

    txt.Set('val', ['Final Score: ', num2str(points)], 'size', 40);
    txt.Draw(win.pointer);
    win.Flip;

    WaitSecs(2);

    % write header and data to file
    header = {'id', 'block', 'response', 'time_response', 'reward', 'points'};
    for nn = 1:num_choices
        header = [header, ['key_', potential_keys{nn}]];
    end

    filename = ['data/id', num2str(subject_id), '_block', num2str(block), '_nchoice', num2str(num_choices), '.csv'];

    fid = fopen(filename, 'wt');
    csvFun = @(str)sprintf('%s, ', str);
    xchar = cellfun(csvFun, header, 'UniformOutput', false);
    xchar2 = strcat(xchar{:});
    xchar2 = strcat(xchar2(1:end-1), '\n');
    fprintf(fid, xchar2);
    fclose(fid);

    dlmwrite(filename, output, '-append', 'delimiter', ',', 'precision', '%.3f');

    win.Close;
    aud.Close;
    txt.Close;
end
