classdef BlamKeyboard < PsychHandle
    properties
        timing_tolerance;
        valid_indices;
        valid_keys;
        force_min;
        force_max;
        p;
    end

    methods
        function self = BlamKeyboard(valid_indices, varargin)
            self.p = inputParser;
            self.p.FunctionName = 'BlamKeyboard';
            self.p.addRequired('valid_indices');
            self.p.addParamValue('possible_keys', {{'a','w','e','f','v','b','h','u','i','l'}}, @(x) iscell(x));
            self.p.addParamValue('timing_tolerance', 0.075, @(x) isnumeric(x));
            self.p.addParamValue('force_min', 1);
            self.p.addParamValue('force_max', 100);
            self.p.parse(valid_indices, varargin{:});

            opts = self.p.Results;
            self.timing_tolerance = opts.timing_tolerance;
            self.force_min = opts.force_min;
            self.force_max = opts.force_max;
            self.valid_keys = opts.possible_keys{1}(valid_indices);
            self.valid_indices = valid_indices;

            keys = zeros(1, 256);
            keys(KbName(self.valid_keys)) = 1;
            KbQueueCreate(-1, keys);
        end

        function Start(self)
            KbQueueStart;
        end

        function Stop(self)
            KbQueueStop;
        end

        function Flush(self)
            KbQueueFlush;
        end

        function Close(self)
            KbQueueRelease;
            delete(self);
        end

        function new_press = Check(self)

            [~, pressed, released] = KbQueueCheck;
            if any(pressed > 0)
                press_key = KbName(find(pressed > 0));
                if iscell(press_key)
                    %press_key = cell2mat(press_key);
                    press_key = press_key{1}; % incorrect, but how to fix?
                end
                press_index = find(not(cellfun('isempty', (strfind(self.valid_keys, press_key)))));
                time_press = min(pressed(pressed > 0));
                new_press = [press_index, time_press];
            else % no new presses
                new_press = [-1, -1];
            end
        end % end CheckKeyResponse

    end % end methods
end % end classdef
