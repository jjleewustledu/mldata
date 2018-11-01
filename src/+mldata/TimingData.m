classdef TimingData < handle 
	%% TIMINGDATA assembles data objects using taus whenever possible, otherwise it uses times.  time{0,F,Duration}
    %  may be arbitrarily assigned.  timesMid, timeMid{0,F,Duration} may be arbitrarily assigned.  Interpolants use dt,  
    %  which is assignable.  index{0,F} and datetime{0,F} may be arbitrarily assigned.  Caches used whenever possible
    %  for performance.

    %% POSSIBLE BUG    
    %  function dt_ = datetime(this)
    %      dt_ = this.datetime0 + seconds(this.times(this.index0:this.indexF) - this.time0); 
    %  end
    % function set.datetime0(this, s)
    %     assert(this.isnice(s));
    %     assert(isdatetime(s));
    %     assert(isscalar(s));
    %     if (isempty(s.TimeZone))
    %         s.TimeZone = this.PREFERRED_TIMEZONE;
    %     end
    %     assert(s >= this.datetimeOri_);
    %     this.datetimeOri_ = s;
    % end
    
	%  $Revision$
 	%  was created 30-Jan-2017 00:16:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.  Copyright 2017 John Joowon Lee. 	

    properties (Constant)
        DEFAULT_DT = 1
        PREFERRED_TIMEZONE = 'America/Chicago'
    end
    
    properties         
        timeMid0         % frame middle after time0
        timeMidF         % frame middle after timeF
        timeMidDuration  % timeMidF - timeMid0
    end
    
	properties (Dependent) 
        taus             % frame durations,    length() == length(times)
        times            % frame starts; times(1) need not be 0
        time0            % selects time window; >= this.time(1)                
        timeF            % selects time window; <= this.times(end)
        timeDuration     % timeF - time0  
        timeInterpolants        
        timesMid         % frame middle times, length() == length(times)
        timeMidInterpolants
        
        indices
        index0           % index() >= index(time0)
        indexF           % index() >= index(timeF)  
        datetime0        % datetime of this.time0
        datetimeF        % datetime of this.timeF
        dt               % for timeInterpolants; seconds        
        datetimeDuration % datetimeF - datetime0
    end
    
    methods (Static)
        function tf = isnice(obj)
            if (islogical(obj))
                tf = obj;
                return
            end
            if (isduration(obj)); obj = seconds(obj); end
            if (isdatetime(obj)); obj = seconds(obj - obj(1)); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceDur(obj)
            if (islogical(obj))
                tf = obj;
                return
            end
            if (isdatetime(obj))
                tf = false;
                return
            end
            if (isduration(obj)); obj = seconds(obj); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceDat(obj)
            if (islogical(obj))
                tf = obj;
                return
            end
            if (isduration(obj))
                tf = false; 
                return
            end
            if (isdatetime(obj)); obj = seconds(obj - obj(1)); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceScalNum(s)
            if (islogical(s))
                tf = obj;
                return
            end
            tf = isscalar(s) && ...
                isnumeric(s) && ~isempty(s) && ~isnan(s) && isfinite(s);
        end
        function s = seconds2num(s)
            %% SECONDS2NUM preserves milliseconds
            
            assert(isduration(s));
            s = milliseconds(s) / 1e3;
        end
    end
    
    methods 
        
        %% GET, SET
        
        function g    = get.taus(this)
            if (~isempty(this.taus_)) % use cache
                g = this.taus_;
                return
            end
            if (~isempty(this.times_))
                g = diff(this.times_);
                g = [g g(end)];
                this.taus_ = g;
                return
            end
            g = [];
        end  
        function        set.taus(this, s)
            assert(this.isniceDur(s));
            s = ensureRowVector(s);
            if (isduration(s)); s = this.seconds2num(s); end
            this.taus_ = s;
        end
        function g    = get.times(this)
            if (~isempty(this.times_)) % use cache
                g = this.times_;
                return
            end
            if (~isempty(this.taus_))
                g = cumsum([0 this.taus_(1:end-1)]);
                this.times_ = g;
                return
            end
            g = [];
        end
        function        set.times(this, s)
            assert(this.isniceDat(s));
            s = ensureRowVector(s);
            if (isdatetime(s)); s = this.seconds2num(s - s(1)); end
            this.times_ = s;
        end
        function g    = get.time0(this)
            if (~isempty(this.time0_))
                g = this.time0_;
                return
            end            
            g = this.times(1);
            this.time0_ = g;
        end
        function        set.time0(this, s)
            assert(this.isniceScalNum(s));
            assert(s >= this.times(1));
            this.time0_ = s;
        end
        function g    = get.timeF(this)
            if (~isempty(this.timeF_))
                g = this.timeF_;
                return
            end            
            g = this.times(end);
            this.timeF_ = g;
        end
        function        set.timeF(this, s)
            assert(this.isniceScalNum(s));
            assert(s <= this.times(end));
            this.timeF_ = s;
        end
        function g    = get.timeDuration(this)
            g = this.timeF - this.time0;
        end
        function        set.timeDuration(this, s)
            assert(this.isniceDur(s));
            assert(isscalar(s));
            if (isduration(s)); s = this.seconds2num(s); end
            this.timeF = this.time0 + s;
        end
        function g    = get.timeInterpolants(this)
            %% GET.TIMEINTERPOLANTS are uniformly separated by this.dt
            %  @returns interpolants this.times(1):this.dt:this.times(end)
            
            g = this.times(1):this.dt:this.times(end);
        end
        function g    = get.timesMid(this)
            if (~isempty(this.timesMid_))
                g = this.timesMid_;
                return
            end
            g = this.taus/2 + this.times;
            this.timesMid_ = g;
        end  
        function        set.timesMid(this, s)
            assert(this.isniceDat(s));
            s = ensureRowVector(s);
            if (isdatetime(s)); s = this.seconds2num(s - s(1)); end
            this.timesMid_ = s;
        end
        function g    = get.timeMidInterpolants(this)
            %% GET.TIMEMIDINTERPOLANTS are uniformly separated by this.dt
            %  @returns interpolants this.timesMid(1):this.dt:this.timesMid(end)
            
            g = this.times(1)+this.taus(1)/2:this.dt:this.times(end)+this.taus(end)/2;
        end
        function g    = get.index0(this)
            [~,g] = max(this.times >= this.time0);
        end
        function        set.index0(this, s)
            assert(this.isniceScalNum(s));
            this.time0 = this.times(s);
        end
        function g    = get.indexF(this)
            [~,g] = max(this.times >= this.timeF);
        end
        function        set.indexF(this, s)
            assert(this.isniceScalNum(s));
            this.timeF = this.times(s);
        end
        function g    = get.datetime0(this)
            g = this.datetimeOri_ + seconds(this.time0 - this.times(1));
        end
        function        set.datetime0(this, s)
            assert(this.isnice(s));
            assert(isdatetime(s));
            assert(isscalar(s));
            if (isempty(s.TimeZone))
                s.TimeZone = this.PREFERRED_TIMEZONE;
            end
            assert(s >= this.datetimeOri_);
            this.datetimeOri_ = s;
        end
        function g    = get.datetimeF(this)
            g = this.datetime0 + seconds(this.timeF - this.time0);
        end
        function        set.datetimeF(this, s)
            assert(this.isnice(s));
            assert(isdatetime(s));
            assert(isscalar(s));
            this.timeF = this.seconds2num(s - this.datetime0) + this.time0;
        end
        function g    = get.datetimeDuration(this)
            g = this.datetimeF - this.datetime0;
        end
        function        set.datetimeDuration(this, s)
            assert(this.isnice(s));
            assert(isduration(s));
            assert(isscalar(s));
            this.timeF = this.seconds2num(s) + this.time0;
        end
        function g    = get.dt(this)
            if (~isempty(this.dt_))
                g = this.dt_;
                return
            end
            g = min(this.taus)/2;
            this.dt_ = g;
        end
        function        set.dt(this, s)
            assert(this.isniceDur(s));
            assert(isscalar(s));
            if (isduration(s)); s = this.seconds2num(s); end
            this.dt_ = s;
        end
        
        %%        
        
        function dt_      = datetime(this)
            dt_ = this.datetime0 + seconds(this.times(this.index0:this.indexF) - this.time0); 
        end
        function dur_     = duration(this)
            dat_ = datetime(this);
            dur_ = dat_ - dat_(1);
        end
        function this     = shiftTimes(this, Dt_)
            this.times_ = this.times_ + Dt_;
        end
        
 		function this = TimingData(varargin)
 			%% TIMINGDATA
 			%  @param named taus  are frame durations.
 			%  @param named times are frame starts.
 			%  @param named timesMid are times at the middle of frames or arbitrarily assigned.
 			%  @param named time0 >= this.times(1).
 			%  @param named timeF <= this.times(end).
            %  @param named datetime0 is the measured datetime.
            %  @param named dt is numeric and must satisfy Nyquist requirements of the client.

 			ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'taus', [], @this.isniceDur);
            addParameter(ip, 'times', [], @this.isniceDat);
            addParameter(ip, 'timesMid', [], @this.isniceDat);
            addParameter(ip, 'time0', -inf, @isnumeric); % time0 > times(1) drops early times
            addParameter(ip, 'timeF', inf, @isnumeric);  % timeF < times(end) drops late times
            addParameter(ip, 'datetime0', NaT, @isdatetime);
            addParameter(ip, 'dt', [], @isnumeric);
            parse(ip, varargin{:});
            this.taus_ = ensureRowVector(ip.Results.taus); 
            this.times_ = ensureRowVector(ip.Results.times);  
            this.timesMid_ = ensureRowVector(ip.Results.timesMid);         
            if (isduration(this.taus_))
                this.taus_ = this.seconds2num(this.taus_); 
            end
            if (isdatetime(this.times_))
                this.times_ = this.seconds2num(this.times_ - this.times_(1)); 
            end
            if (isdatetime(this.timesMid_))
                this.timesMid_ = this.seconds2num(this.timesMid_ - this.timesMid_(1)); 
            end 
            assert(length(this.taus) == length(this.times));            
            assert(length(this.times) == length(this.timesMid));
            this.time0_ = max(ip.Results.time0, this.times(1));
            this.timeF_ = min(ip.Results.timeF, this.times(end));
            this.datetimeOri_ = ip.Results.datetime0;
            if (isempty(this.datetimeOri_.TimeZone))
                this.datetimeOri_.TimeZone = this.PREFERRED_TIMEZONE;
            end
            if (isempty(ip.Results.dt))
                this.dt_ = min(this.taus)/2;
            else
                assert(this.isniceScalNum(ip.Results.dt));
                assert(ip.Results.dt <= min(this.taus), 'mldata:ValueError', 'problem concerning sampling rates');
                this.dt_ = ip.Results.dt;                
            end
            %
        end 
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        taus_
        times_
        timeInterpolants_
        timesMid_
        timeMidInterpolants_
        
        time0_
        timeF_
        datetimeOri_
        dt_        
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

