classdef AgilentMultimeter22_new_batch < handle
    properties
        gpib_handle
        PrimaryAddress
        BoardIndex
        vendor
    end
    
    methods
        function self = AgilentMultimeter22_new_batch(PrimaryAddress, BoardIndex, vendor)
            % PrimaryAddress_default = 22;
            % BoardIndex_default = 2;
            % vendor_default = 'NI';
            % 
            % if nargin < 1
            %     PrimaryAddress = PrimaryAddress_default;
            % end
            % if nargin < 2
            %     BoardIndex = BoardIndex_default;
            % end
            % if nargin < 3
            %     vendor = vendor_default;
            % end
            % 
            % self.PrimaryAddress = PrimaryAddress;
            % self.BoardIndex = BoardIndex;
            % self.vendor = vendor;
            % 
            % self.gpib_handle = instrfind('Type', 'gpib', 'BoardIndex', BoardIndex, 'PrimaryAddress', PrimaryAddress, 'Tag', '');
            % if ~isempty(self.gpib_handle)
            %     fclose(self.gpib_handle);
            %     delete(self.gpib_handle);
            % end
            self.gpib_handle = visadev("GPIB0::22::INSTR");
            self.gpib_handle.InputBufferSize = 4*10000;
            self.gpib_handle.Timeout=10;
            % fopen(self.gpib_handle);
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
            response = self.gpib_handle.readline();
        end
        
        function [response, cmd] = voltage_unit(self, u, r)
            if nargin == 3
                cmd = sprintf('CONF:VOLT:DC %d, %d \n',u,r);
                self.send(cmd);
                response = [u r];
            else
                cmd = 'CONF:VOLT:DC 10, 1e-6 \n';
                %         response = self.ask(cmd);
                response = [10 1e-6];
            end
        end
        
        
        function [response, cmd] = measure_voltage (self)
            
            cmd = 'read?';
            response = str2double(self.ask(cmd));
            
        end
        function [response,cmd] = measure_n(self,n)
            if nargin == 2
                cmd= sprintf('R? %d',n);
                
            else
                cmd = 'R?';
            end
            cmdresponse = self.ask(cmd);
            cmdresponse(1:cmdresponse(2)+2)=[];
            response =  str2double(split(cmdresponse,','));
        end
        function [response, cmd] = int_time (self, u)
            if nargin == 2
                cmd = sprintf('SENS:VOLT:DC:APER %dE-3 \n',u);
                self.send(cmd);
                response = [u];
            else
                cmd = 'SENS:VOLT:DC:APER? \n';
                response = str2double(self.ask(cmd))*1e3;
                % response = [200E-3];
            end
            
        end
        function [response, cmd] = int_nplc(self,u)
            if nargin == 2
                cmd = sprintf('SENS:VOLT:DC:NPLC %d \n',u);
                self.send(cmd);
                response = [u];
            else
                cmd = 'SENS:VOLT:DC:NPLC? \n';
                response = str2double(self.ask(cmd));
            end
        end
        function [response, cmd] = impedance (self, u)
            if nargin == 2
                cmd = sprintf('SENS:VOLT:DC:IMP:AUTO %d \n',u);        %0 10MOhm, 1 Hi-Z
                self.send(cmd);
                response = [u];
            else
                cmd = 'SENS:VOLT:DC:IMP:AUTO?';
                response = self.ask(cmd);
            end
            
        end
        function [response, cmd] = trigger_count (self, u)
            if nargin == 2
                cmd = sprintf('TRIG:COUN %d \n',u);        %1 to 50000
                self.send(cmd);
                response = [u];
            else
                cmd = 'TRIG:COUN?';
                response = self.ask(cmd);
            end
            
        end
        function [response, cmd] = trigger_delay (self, u)
            if nargin == 2
                cmd = sprintf('TRIG:DEL %d \n',u);        %0 to 3600 s
                self.send(cmd);
                response = [u];
            else
                cmd = 'TRIG:DEL?';
                response = self.ask(cmd);
            end
            
        end
        function [response, cmd] = trigger_source (self, u)
            if nargin == 2
                cmd = sprintf('TRIG:SOUR %s',u);        % IMM (continuous) EXT (external) BUS
                self.send(cmd);
                response = [u];
            else
                cmd = 'TRIG:SOUR?';
                response = self.ask(cmd);
            end
            
        end
        function [response, cmd] = initiate (self)
            cmd = sprintf('INIT \n');
            self.send(cmd);
        end
        function [response, cmd] = kill (self)
            cmd = sprintf('ABOR \n');
            self.send(cmd);
        end
        function [response, cmd] = trigger_samples (self, u)
            if nargin == 2
                cmd = sprintf('SAMP:COUN %d \n',u);        %1 to 50000
                self.send(cmd);
                response = [u];
            else
                cmd = 'SAMP:COUN?';
                response = self.ask(cmd);
            end
            
        end
        function [response, cmd] = errorlist (self)
            cmd = sprintf('SYST:ERR?');
            response=self.ask(cmd);
        end
        function response = getlog(self)
            response_data  = char(self.ask('R?'));
            response_length = str2num(string(response_data(3:(response_data(2)-'0'+2))));%extract length of response in bytes
            response_data(1:(response_data(2)-'0'+2))=[];%remove initial bytes that respecify length
            response= typecast(uint8(response_data(1:response_length)),'single');
            % nSamples=str2double(self.ask('SAMP:COUN?'));
            % response=fread(self.gpib_handle, nSamples, 'float32');
        end
        function [nullValue, cmdLog] = set_null(self, senseFunction)
            % senseFunction examples:
            %   'VOLTage:DC'
            %   'CURRent:DC'
            %   'RESistance'
            %   'FRESistance'
            %   'CAPacitance'
            %   'FREQuency'
            %   'PERiod'
            %   'TEMPerature'
        
            cmdLog = strings(0,1);
        
            % Read current null state so we can restore behavior cleanly.
            qCmd = sprintf('SENSe:%s:NULL:STATe?', senseFunction);
            nullState = str2double(strtrim(self.ask(qCmd)));
            cmdLog(end+1) = qCmd;
        
            % Temporarily disable null so the reading is raw.
            offCmd = sprintf('SENSe:%s:NULL:STATe OFF', senseFunction);
            self.send(offCmd);
            cmdLog(end+1) = offCmd;
        
            % Get the current raw reading from the meter.
            rawReading = str2double(strtrim(self.ask('READ?')));
            cmdLog(end+1) = 'READ?';
        
            % Store that reading as the null value.
            setNullCmd = sprintf('SENSe:%s:NULL:VALue %.15g', senseFunction, rawReading);
            self.send(setNullCmd);
            cmdLog(end+1) = setNullCmd;
        
            % Enable null, matching the front-panel Null key behavior.
            onCmd = sprintf('SENSe:%s:NULL:STATe ON', senseFunction);
            self.send(onCmd);
            cmdLog(end+1) = onCmd;
        
            nullValue = rawReading;
       
        end
    end
    
end
