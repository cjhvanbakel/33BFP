classdef SantecTSL710_new < handle
    properties
        gpib_handle
        PrimaryAddress
        BoardIndex
        vendor
    end

    methods
        function self = SantecTSL710_new(PrimaryAddress, BoardIndex, vendor)
            % PrimaryAddress_default = 19;
            % BoardIndex_default = 2;
            % vendor_default = 'NI';
            %
            % if nargin < 1
            %   PrimaryAddress = PrimaryAddress_default;
            % end
            % if nargin < 2
            %   BoardIndex = BoardIndex_default;
            % end
            % if nargin < 3
            %   vendor = vendor_default;
            % end
            %
            % self.PrimaryAddress = PrimaryAddress;
            % self.BoardIndex = BoardIndex;
            % self.vendor = vendor;
            %
            % self.gpib_handle = instrfind('Type', 'gpib', 'BoardIndex', BoardIndex, 'PrimaryAddress', PrimaryAddress, 'Tag', '');
            % if ~isempty(self.gpib_handle)
            %   fclose(self.gpib_handle);
            %   delete(self.gpib_handle);
            % end
            % self.gpib_handle = gpib(vendor, BoardIndex, PrimaryAddress);
            % self.gpib_handle.InputBufferSize = 264000;
            % self.gpib_handle.Timeout=3;
            % fopen(self.gpib_handle);
            self.gpib_handle = visadev("GPIB0::19::INSTR");

        end

        function open(self)
            % fopen(self.gpib_handle);
        end
        function close(self)
            clear self.gpib_handle;
        end

        function cmd = send(self, cmd)
            self.gpib_handle.write( cmd);
        end
        function response = ask(self, cmd)
            self.send(cmd);
            response = self.receive();
        end
        function [response, cmd] = identification_query(self)
            cmd = '*IDN?';
            response = self.ask(cmd);
        end
        function response = receive(self)
            response = fscanf(self.gpib_handle);
        end
        function logfile = read(self)
            logfile=fread(self.gpib_handle);
        end

        function [response, cmd] = shutter(self, p)
            if nargin == 2
                %           if p <= 0.03
                %               p = 0.03;
                %           end
                if p == 0
                    cmd = 'power:shutter 0';
                else
                    cmd = 'power:shutter 1';
                end
                %        cmd = sprintf(['power:shutter ',p]);
                self.send(cmd);
                response = p;
            else
                cmd = 'power:shutter?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response,cmd] = LD_status(self,p)
            if nargin == 2
                if p == 0
                    cmd = 'power:state 0';      %LD off
                else
                    cmd = 'power:state 1';      %LD on
                end
                self.send(cmd);
                response = p;
            else
                cmd = 'power:state?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = power_unit(self, u)
            % 0 dBm
            % 1 mW
            % else error
            if nargin == 2
                if u ~= 0
                    u = 1;
                end
                cmd = sprintf('power:unit %d', u);
                self.send(cmd);
            else
                cmd = 'power:unit?';
                response = self.ask(cmd);
            end
        end
        function [response, cmd] = power(self, p)
            if nargin == 2
                if p <= 0.03
                    p = 0.03;
                end
                cmd = sprintf('power %0.2f', p);
                self.send(cmd);
                response = p;
            else
                cmd = 'power?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = power_maximum(self)
            cmd = 'power:level:maximum?';
            response = str2double(self.ask(cmd));
        end
        function [response, cmd] = power_minimum(self)
            cmd = 'power:level:minimum?';
            response = str2double(self.ask(cmd));
        end
        function [response, cmd] = power_actual(self)
            cmd = 'power:actual?';
            response = str2double(self.ask(cmd));
        end
        function [response, cmd] = wavelength(self, w)
            if nargin == 2
                if w <= 1480
                    w = 1480;
                end
                if w >= 1640
                    w = 1640;
                end
                cmd = sprintf('wavelength %0.5f',w);
                self.send(cmd);
                response = w;
            else
                cmd = 'wavelength?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = frequency(self, f)
            if nargin == 2
                cmd = sprintf('frequency %0.4f', f);
                self.send(cmd);
            else
                cmd  = 'frequency?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = wavelength_unit(self, u)
            % 0 nm
            % 1 THz
            % else nothing
            if nargin == 2
                if u ~= 0
                    u = 1;
                end
                cmd = sprintf('wavelength:unit %d', u);
                self.send(cmd);
            else
                cmd ='wavelength:unit?';
                response = self.ask(cmd);
            end
        end
        function [response,cmd] = coh_control(self,p)
            if nargin == 2
                if p == 0
                    cmd = ':COHC 0';      %off
                else
                    cmd = ':COHC 1';      %on
                end
                self.send(cmd);
                response = p;
            else
                cmd = ':COHC?';
                response = str2double(self.ask(cmd));
            end
        end
        % sweep settings
        function [response, cmd] = wavelength_start(self, w)
            if nargin == 2
                cmd = sprintf('wavelength:sweep:start %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = 'wavelength:sweep:start?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = wavelength_stop(self, w)
            if nargin == 2
                cmd = sprintf('wavelength:sweep:stop %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = 'wavelength:sweep:stop?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = wavelength_sweep_speed(self, s)
            % In nm / s
            if nargin == 2
                cmd = sprintf('wavelength:sweep:speed %0.3f',s);
                self.send(cmd);
                response = s;
            else
                cmd = 'wavelength:sweep:speed?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = wavelength_sweep_step(self, s)
            % In nm / step 0.0001 nm/step to 160 nm/step
            if nargin == 2
                cmd = sprintf('wavelength:sweep:step %0.3f',s);
                self.send(cmd);
                response = s;
            else
                cmd = 'wavelength:sweep:step?';
                response = str2double(self.ask(cmd));
            end
        end
        function [cmd] = sweep_state_stop(self)
            % stop state = 0
            cmd = 'wavelength:sweep:state 0';
            self.send(cmd);
        end
        function [response, cmd] = sweep_state(self, state)
            if nargin == 2
                cmd = sprintf('wavelength:sweep:state %d',state);
                self.send(cmd);
            else
                cmd = 'wavelength:sweep:state?';
                response = str2double(self.ask(cmd));
            end
        end
        function wait_until_stopped(self)
            while (self.sweep_state() ~= 0);
            end
        end
        function [cmd] = sweep_repeat(self)
            cmd = 'wavelength:sweep:repeat';
            self.send(cmd);
        end
        function [cmd] = sweep_trigger(self)
            cmd = ':WAV:SWE:SOFT';
            self.send(cmd);
        end
        function [response,cmd] = sweep_cycles(self,p)
            if nargin==2
                cmd = sprintf(':WAV:SWE:CYCL %d',p);    %0 to 999, 0=inf
                self.send(cmd);
            else
                cmd = ':WAV:SWE:CYCL?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response,cmd] = sweep_delay(self,p)
            if nargin==2
                cmd = sprintf(':WAV:SWE:DEL %f.1',p);    %0 to 999 in s step 0.1s
                self.send(cmd);
            else
                cmd = ':WAV:SWE:DEL?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response,cmd] = sweep_dwell(self,p)
            if nargin==2
                cmd = sprintf(':WAV:SWE:DWEL %f.1',p);    %0 to 999.9 in s step 0.1s
                self.send(cmd);
            else
                cmd = ':WAV:SWE:DWEL?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response,cmd] = sweep_mode(self,p)
            if nargin==2
                cmd = sprintf(':WAV:SWE:MOD %d',p);    %0=step 1 way, 1=sweep 1 way 2=step2w 3=sweep2w
                self.send(cmd);
            else
                cmd = ':WAV:SWE:MOD?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response,cmd] = sweep_count(self)
            cmd = ':WAV:SWE:COUN?';
            self.send(cmd);
            response = str2double(self.ask(cmd));
        end
        function [response,cmd] = head_WLlog(self)
            cmd = ':READ:DAT?';
            self.send(cmd);
            response = self.ask(cmd);
        end
        function [response,cmd] = WLlog(self)
            cmd = ':READ:DAT?';
            self.send(cmd);
            response = binblockread(self.gpib_handle,'uint32')*0.0001;
        end
        function [response,cmd] = read_WLlength(self)
            cmd = ':READ:POIN?';
            self.send(cmd);
            response = str2double(self.ask(cmd));
        end
        % triggering settings
        function [response, cmd] = trigger_in(self, w)
            if nargin == 2
                % 0 off
                % 1 on
                cmd = sprintf(':TRIG:INP:EXT %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = 'TRIG:INP:EXT?';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = trigger_standby(self, w)
            if nargin == 2
                % 0 off
                % 1 on
                cmd = sprintf(':TRIG:INP:STAN %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = 'TRIG:INP:STAN?';
                response = str2double(self.ask(cmd));
            end

        end
        function [response, cmd] = trigger_out(self, w)
            if nargin == 2
                % 0 off
                % 1 stop
                % 2 start
                % 3 step
                cmd = sprintf(':TRIG:OUTP %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = ':TRIG:OUTP?';
                response = str2double(self.ask(cmd));
            end

        end
        function [response, cmd] = trigger_step(self, w)
            % from 0.0001 to 160 nm
            if nargin == 2
                cmd = sprintf(':TRIG:OUTP:STEP %0.3f',w);
                self.send(cmd);
                response = w;
            else
                cmd = ':TRIG:OUTP:STEP?';
                response = str2double(self.ask(cmd));
            end
        end

        function [response,cmd] = power_mode(self,p)
            if nargin == 2
                if p == 0
                    cmd = ':POW:ATT:AUTO 0';      %Manual
                else
                    cmd = ':POW:ATT:AUTO 1';      %Auto
                end
                self.send(cmd);
                response = p;
            else
                cmd = '::POW:ATT:AUTO?';
                response = str2double(self.ask(cmd));
            end
        end

        function [response, cmd] = attenuation(self, w)
            % from 0 to 30 dB
            if nargin == 2
                cmd = sprintf(':POW:ATT %0.2f',w);
                self.send(cmd);
                response = w;
            else
                cmd = ':POW:ATT?';
                response = str2double(self.ask(cmd));
            end
        end

    end
end
