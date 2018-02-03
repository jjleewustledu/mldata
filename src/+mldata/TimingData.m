classdef TimingData < mldata.ITimingData
	%% TIMINGDATA  

	%  $Revision$
 	%  was created 30-Jan-2017 00:16:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.  Copyright 2017 John Joowon Lee.
 	

    properties (Constant)
        PREFERRED_TIMEZONE = 'America/Chicago'
        SERIAL_DAYS_1900_TO_1904 = 1462
        EXCEL_INITIAL_DATETIME = datetime(1899,12,31)
        
        % https://support.microsoft.com/en-us/help/214330/differences-between-the-1900-and-the-1904-date-system-in-excel
    end
    
	properties (Dependent) 
        times         % frame starts
        taus          % frame durations,    length() == length(times)
        timeMidpoints % frame middle times, length() == length(times)
        time0         % selects time window; >= this.time(1)                
        timeF         % selects time window; <= this.times(end)
        index0        % index() >= index(time0)
        indexF        % index() >= index(timeF)
        timeDuration  % timeF - time0     
        datetime0     % measured datetime of this.time(1)
        dt            % for timeInterpolants; <= min(taus)/2     
    end
    
    methods (Static)
        function dati = datetimeConvertFromExcel(days)
            assert(isnumeric(days));
            dati = datetime(days + mldata.TimingData.SERIAL_DAYS_1900_TO_1904, 'ConvertFrom', 'excel');
        end
        function dati = datetimeConvertFromExcel2(days)
            % addresses what may be an artefact of linking cells across sheets in Numbers/Excel on MacOS
            assert(isnumeric(days));
            dati = datetime(days + 2*mldata.TimingData.SERIAL_DAYS_1900_TO_1904, 'ConvertFrom', 'excel');
        end
    end
    
    methods 
        
        %% GET, SET
        
        function g    = get.times(this)
            g = this.times_;
        end
        function this = set.times(this, s)
            if (isdatetime(s))
                s = this.datetime2sec(s);
            end
            if (isduration(s))
                s = seconds(s);
            end
            assert(isnumeric(s));
            this.times_ = s;
            this.time0_ = this.times_(1);
            this.timeF_ = this.times_(end);
        end
        function g    = get.taus(this)
            if (~isempty(this.taus_))
                g = this.taus_;
                assert(length(g) == length(this.times))
                return
            end
            if (length(this.times_) < 2)
                g = nan;
                return
            end
            g = this.times_(2:end) - this.times_(1:end-1);
            g = [g g(end)];
        end  
        function g    = get.timeMidpoints(this)
            if (~isempty(this.timeMidpoints_))
                g = this.timeMidpoints_;
                assert(length(g) == length(this.times))
                return
            end
            g = this.times_ + this.taus/2;
        end   
        function g    = get.time0(this)
            if (~isempty(this.time0_))
                g = this.time0_;
                return
            end            
            g = this.times(1);
        end
        function this = set.time0(this, s)
            if (isdatetime(s))
                s = this.datetime2sec(s);
            end
            if (isduration(s))
                s = seconds(s);
            end
            assert(isnumeric(s));
            this.time0_ = s;
        end
        function g    = get.timeF(this)
            if (~isempty(this.timeF_))
                g = this.timeF_;
                return
            end            
            g = this.times(end);
        end
        function this = set.timeF(this, s)
            if (isdatetime(s))
                s = this.datetime2sec(s);
            end
            if (isduration(s))
                s = seconds(s);
            end
            assert(isnumeric(s));
            this.timeF_ = s;
        end        
        function g    = get.index0(this)
            [~,g] = max(this.times >= this.time0);
        end
        function this = set.index0(this, s)
            this.time0 = this.times(s);
        end
        function g    = get.indexF(this)
            [~,g] = max(this.times >= this.timeF);
        end
        function this = set.indexF(this, s)
            this.timeF = this.times(s);
        end
        function g    = get.timeDuration(this)
            g = this.timeF - this.time0;
        end
        function this = set.timeDuration(this, s)
            this.timeF = this.time0 + s;
        end
        function g    = get.datetime0(this)
            g = this.datetime0_;
        end
        function this = set.datetime0(this, s)
            assert(isdatetime(s));
            this.datetime0_ = s;
        end
        function g    = get.dt(this)
            g = this.dt_;
        end
        function this = set.dt(this, s)
            assert(isnumeric(s));
            %assert(s <= min(this.taus)/2);
            this.dt_ = s;
        end
        
        %%        
        
        function s    = datetime2sec(this, dt_)
            assert(isdatetime(dt_));
            dt_.TimeZone = this.PREFERRED_TIMEZONE;
            s = seconds(dt_ - this.datetime0);
            if (isduration(s))
                s = seconds(s);
            end
            assert(isnumeric(s));
        end
        function dt   = sec2datetime(this, s)
            dt = this.datetime0 + duration(0,0,s);
        end
        function this = shiftTimes(this, Dt_)
            this.times_ = this.times_ + Dt_;
        end

        function len      = length(this)
            len = length(this.times);
        end
        function [t,this] = timeInterpolants(this, varargin)
            %% TIMEINTERPOLANTS are uniformly separated by this.dt
            %  @param varargin are optional array indices.
            %  @returns interpolants this.times(1):this.dt:this.times(end)
            
            if (~isempty(this.timeInterpolants_))
                t = this.timeInterpolants_;
                return
            end
            
            t = this.times(1):this.dt:this.times(end);
            this.timeInterpolants_ = t;
            if (~isempty(varargin))
                t = t(varargin{:}); 
            end
        end
        function [t,this] = timeMidpointInterpolants(this, varargin)
            %% TIMEMIDPOINTINTERPOLANTS are uniformly separated by this.dt
            %  @param varargin are optional array indices.
            %  @returns interpolants this.timeMidpoints(1):this.dt:this.timeMidpoints(end)
            
            if (~isempty(this.timeMidpointInterpolants_))
                t = this.timeMidpointInterpolants_;
                return
            end
            
            t = this.times(1)+this.taus(1)/2:this.dt:this.times(end)+this.taus(end)/2;
            this.timeMidpointInterpolants_ = t;
            if (~isempty(varargin))
                t = t(varargin{:}); 
            end
        end
        
 		function this = TimingData(varargin)
 			%% TIMINGDATA
 			%  @param named times are frame starts.
 			%  @param named taus  are frame durations.
 			%  @param named timeMidpoints are times at the middle of frames.
 			%  @param named time0 >= this.times(1).
 			%  @param named timeF <= this.times(end).
            %  @param named datetime0 is the measured datetime.
            %  @param named dt is numeric and must satisfy Nyquist requirements of the client.

 			ip = inputParser;
            addParameter(ip, 'times', 0, @isnumeric);
            addParameter(ip, 'taus', [], @isnumeric);
            addParameter(ip, 'timeMidpoints', [], @isnumeric);
            addParameter(ip, 'time0', -inf, @isnumeric); % time0 > times(1) drops early times
            addParameter(ip, 'timeF', inf, @isnumeric);  % timeF < times(end) drops late times
            addParameter(ip, 'datetime0', NaT, @(x) isdatetime(x) && strcmp(x.TimeZone,this.PREFERRED_TIMEZONE));
            addParameter(ip, 'dt', 1, @isnumeric);
            parse(ip, varargin{:});
            
            this.times_             = ensureRowVector(ip.Results.times);
            this.taus_              = ensureRowVector(ip.Results.taus);
            this.timeMidpoints_     = ensureRowVector(ip.Results.timeMidpoints);
            this.time0_             = max(ip.Results.time0, this.times_(1));
            this.timeF_             = min(ip.Results.timeF, this.times_(end));
            this.datetime0_         = ip.Results.datetime0;
            this.dt_                = ip.Results.dt;            
            %assert(this.dt_ <= min(this.taus)); % alert to external problems with Nyquist sampling
        end     
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        times_
        taus_
        timeMidpoints_
        time0_
        timeF_
        datetime0_
        dt_
        
        timeInterpolants_
        timeMidpointInterpolants_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

