classdef PCIe5763_Labview_2015
    % Matlab Class compatible con R2015 para comunicar con Labview VI
    
    properties
        tcp_ip
        Step
        Time
        Channels
        Trigger
        Trg_Chn
        Trg_Threshold
        Trg_Edge
        Step_Mode
        Average
    end

    methods
        function obj = PCIe5763_Labview_2015()
            % En 2015 se usa tcpip
            obj.tcp_ip = tcpip('localhost', 13000);
            obj.tcp_ip.InputBufferSize = 1024*1024*10;
            obj.tcp_ip.OutputBufferSize = 1024*10;
            fopen(obj.tcp_ip);
        end

        function Start(obj)
            fprintf(obj.tcp_ip, 'GO\n');
        end

        function st = Status(obj)
            fprintf(obj.tcp_ip, 'ST\n');
            st = fgetl(obj.tcp_ip);
        end

        function gt = ActualTime(obj)
            fprintf(obj.tcp_ip, 'GT\n');
            gt = fgetl(obj.tcp_ip);
        end

        function obj = set.Step(obj, stp)
            obj.Step = stp;
            if ~isempty(stp)
                fprintf(obj.tcp_ip, 'STP %d\n', stp);
            end
        end

        function obj = set.Time(obj, time)
            obj.Time = time;
            if ~isempty(time)
                fprintf(obj.tcp_ip, 'TIM %d\n', time);
            end
        end

        function obj = set.Channels(obj, chns)
            obj.Channels = chns;
            if ~isempty(chns)
                chn_str = strjoin(arrayfun(@num2str, chns, 'UniformOutput', false), ',');
                fprintf(obj.tcp_ip, 'CHN %s\n', chn_str);
            end
        end

        function data = Get(obj, ch)
            fprintf(obj.tcp_ip, 'GET %d\n', ch);
            n_data = fread(obj.tcp_ip, 1, 'uint32');
            if ~isempty(n_data)
                data = fread(obj.tcp_ip, n_data, 'int16');
            else
                data = [];
            end
        end

        function obj = set.Trigger(obj, trg)
            if islogical(trg)
                obj.Trigger = trg;
                if trg
                    fprintf(obj.tcp_ip, 'TRG ON\n');
                else
                    fprintf(obj.tcp_ip, 'TRG OFF\n');
                end
            elseif ischar(trg)
                if strcmpi(trg,'ON')
                    obj.Trigger = true;
                    fprintf(obj.tcp_ip, 'TRG ON\n');
                elseif strcmpi(trg , 'OFF')
                    obj.Trigger = false;
                    fprintf(obj.tcp_ip, 'TRG OFF\n');
                end
            end
        end

        function obj = set.Trg_Chn(obj, tch)
            obj.Trg_Chn = tch;
            if ~isempty(tch)
                fprintf(obj.tcp_ip, 'TCH %d\n', tch);
            end
        end

        function obj = set.Trg_Threshold(obj, th)
            obj.Trg_Threshold = th;
            if ~isempty(th)
                fprintf(obj.tcp_ip, 'TTH %.6f\n', th);
            end
        end

        function obj = set.Trg_Edge(obj, edge)
            if edge==0
                obj.Trg_Edge = 0;
                fprintf(obj.tcp_ip, 'TEG 0\n');
            elseif edge==1
                obj.Trg_Edge = 1;
                fprintf(obj.tcp_ip, 'TEG 1\n');
            end
        end

        function [x, data] = StartAndGet(obj, ch)
            obj.Start();
            reading = true;
            while (reading)
                res_status = obj.Status();
                reading = strcmp(res_status, '1');
                pause(0.01);
            end
            data = obj.Get(ch);
            at_str = obj.ActualTime();
            at = str2double(at_str);
            stp = 1E-6 * at / (numel(data) - 1);
            x = (0:numel(data)-1) * stp;
        end

        function obj = set.Average(obj, avg)
            obj.Average = avg;
            if ~isempty(avg)
                fprintf(obj.tcp_ip, 'AVG %d\n', avg);
            end
        end

        function Stop(obj)
            fprintf(obj.tcp_ip, 'NO\n');
        end

        function prg = Progress(obj)
            fprintf(obj.tcp_ip, 'GP\n');
            prg = str2double(fgetl(obj.tcp_ip));
        end

        function obj = set.Step_Mode(obj, mode)
            if mode==0
                obj.Step_Mode = 0;
                fprintf(obj.tcp_ip, 'SMD 0\n');
            elseif mode==1
                obj.Step_Mode = 1;
                fprintf(obj.tcp_ip, 'SMD 1\n');
            elseif mode==2
                obj.Step_Mode = 2;
                fprintf(obj.tcp_ip, 'SMD 2\n');
            end
        end

        function data = FFT(obj, ch)
            fprintf(obj.tcp_ip, 'FFT %d\n', ch);
            n_data = fread(obj.tcp_ip, 1, 'uint32');
            if ~isempty(n_data)
                data = fread(obj.tcp_ip, n_data, 'double');
            else
                data = [];
            end
        end
        
        function delete(obj)
            if ~isempty(obj.tcp_ip) && isvalid(obj.tcp_ip)
                fclose(obj.tcp_ip);
                delete(obj.tcp_ip);
            end
        end
    end
end
