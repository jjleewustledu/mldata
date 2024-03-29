classdef TimingData < handle & matlab.mixin.Copyable & mldata.ITiming
	%% TIMINGDATA supports nonuniformly sampled dynamic data.  
    %  It assembles data objects using taus whenever possible, otherwise using times.  
    %  It delegates to mldata.Timing
    %  It uses caches whenever possible for performance.
    %  Its properties and datetime{0,F}, index{0,F} and time{0,F,s} may be arbitrarily assigned.  
    %  Its interpolants use dt,  which is assignable.    
    
	%  $Revision$
 	%  was created 30-Jan-2017 00:16:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mldata/src/+mldata.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.  Copyright 2017 John Joowon Lee. 	

    properties (Constant)
        DEFAULT_DT = 1
    end
    
	properties (Dependent)
        datetime0            % datetime of time0
        datetimeF            % datetime of timeF   
        datetimeInterpolants % uniform sampling ~ 1/dt
        datetimeMeasured     % datetime of measurement of times(1)
        datetimes            % synonym for datetime()
        datetimeWindow       % datetimeF - datetime0
        dt                   % for timeInterpolants, in seconds
        index0               % index0 >= index(time0)
        indexF               % indexF >= index(timeF)  
        indices              % indices for all times and taus
        taus                 % frame durations; frame starting at times(i) lasts taus(i); length(taus) == length(times)
        time0                % adjustable time window start; >= time(1)             
        timeF                % adjustable time window end; <= times(end)
        timeInterpolants     % uniform sampling ~ 1/dt
        timeWindow           % timeF - time0  
        times                % starting times for frames; times(1) need not be 0
    end
    
    methods (Static)
        function tf = isnice(obj) 
            tf = mldata.Timing.isnice(obj);
        end
        function tf = isniceDur(obj)
            tf = mldata.Timing.isniceDur(obj);
        end
        function tf = isniceDat(obj)
            tf = mldata.Timing.isniceDat(obj);
        end
        function tf = isniceScalNum(s)
            tf = mldata.Timing.isniceScalNum(s);
        end
    end
    
    methods 
        
        %% GET, SET
        
        function g = get.datetime0(this)
            g = this.timing_.datetime0;
        end
        function     set.datetime0(this, s)
            this.timing_.datetime0 = s;
        end
        function g = get.datetimeF(this)
            g = this.timing_.datetimeF;
        end
        function     set.datetimeF(this, s)
            this.timing_.datetimeF = s;
        end
        function g = get.datetimeInterpolants(this)
            g = this.timing_.datetimeInterpolants;
        end
        function g = get.datetimeMeasured(this)
            g = this.timing_.datetimeMeasured;
        end
        function     set.datetimeMeasured(this, s)
            this.timing_.datetimeMeasured = s;
        end
        function g = get.datetimes(this)
            g = this.timing_.datetimes;
        end
        function g = get.datetimeWindow(this)
            g = this.timing_.datetimeWindow;
        end
        function     set.datetimeWindow(this, s)
            this.timing_.datetimeWindow = s;
        end
        function g = get.dt(this)
            g = this.timing_.dt;
        end
        function     set.dt(this, s)
            this.timing_.dt = s;
        end
        function g = get.index0(this)
            g = this.timing_.index0;
        end
        function     set.index0(this, s)
            this.timing_.index0 = s;
        end
        function g = get.indexF(this)
            g = this.timing_.indexF;
        end
        function     set.indexF(this, s)
            this.timing_.indexF = s;
        end
        function g = get.indices(this)
            g = this.timing_.indices;
        end
        function g = get.taus(this)
            if (~isempty(this.taus_)) % use cache
                g = this.taus_;
                return
            end
            if (~isempty(this.times))
                g = diff(this.times);
                g = [g g(end)];
                this.taus_ = g;
                return
            end
            g = [];
        end  
        function     set.taus(this, s)
            assert(this.isniceDur(s));
            s = ensureRowVector(s);
            if (isduration(s)); s = this.timing2num(s); end
            this.taus_ = s;
        end
        function g = get.time0(this)
            g = this.timing_.time0;
        end
        function     set.time0(this, s)
            this.timing_.time0 = s;
        end
        function g = get.timeF(this)
            g = this.timing_.timeF;
        end
        function     set.timeF(this, s)
            this.timing_.timeF = s;
        end
        function g = get.timeInterpolants(this)
            %% GET.TIMEINTERPOLANTS are uniformly separated by this.dt
            %  @returns interpolants this.times(1):this.dt:this.times(end)
            
            g = this.timing_.timeInterpolants;
        end
        function g = get.times(this)
            g = this.timing_.times;
        end
        function     set.times(this, s)
            this.timing_.times = s;
        end
        function g = get.timeWindow(this)
            g = this.timing_.timeWindow;
        end
        function     set.timeWindow(this, s)
            this.timing_.timeWindow = s;
        end
        
        %%        
        
        function dt_      = datetime(this)
            dt_ = this.timing_.datetime();
        end
        function dur_     = duration(this)
            %% timeF  - time0, in sec
            
            dur_ = duration(this.timing_);
        end
        function            resetTimeLimits(this)
            this.timing_.resetTimeLimits;
        end
        function n        = timing2num(this, t)
            %% TIMING2NUM
            %  @param t is datetime | duration | arg of double.
            %  @returns n is numeric in sec.
            
            n = this.timing_.timing2num(t);
        end
        
 		function this = TimingData(varargin)
 			%% TIMINGDATA
 			%  @param named taus  are frame durations.
 			%  @param named times are frame starts.
 			%  @param named time0 >= this.times(1).
 			%  @param named timeF <= this.times(end).
            %  @param named datetimeMeasured is the measured datetime for times(1).
            %  @param named dt is numeric and must satisfy Nyquist requirements of the client.

 			ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'taus', [], @isnumeric);
            addParameter(ip, 'times', [], @(x) isnumeric(x) || isdatetime(x));
            addParameter(ip, 'time0', -inf, @isnumeric); % time0 > times(1) drops early times
            addParameter(ip, 'timeF', inf, @isnumeric);  % timeF < times(end) drops late times
            addParameter(ip, 'datetimeMeasured', NaT, @isdatetime);
            addParameter(ip, 'dt', 0, @isnumeric);
            parse(ip, varargin{:});
            ipr = ip.Results;
            
            this.taus_ = ensureRowVector(ipr.taus); 
            if (isduration(this.taus_))
                this.taus_ = this.seconds2num(this.taus_); 
            end
            if isempty(ipr.times) && ~isempty(ipr.taus)
                ipr.times = cumsum([0 ipr.taus(1:end-1)]);
            end
            this.timing_ = mldata.Timing( ...
                'datetimeMeasured', ipr.datetimeMeasured, ...
                'times', ipr.times, ...
                'time0', ipr.time0, ...
                'timeF', ipr.timeF, ...
                'dt', ipr.dt);
        end 
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        taus_        
        timing_
    end

    methods (Access = protected)    
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.timing_ = copy(this.timing_);
        end    
        function s = seconds2num(~, s)
            %% SECONDS2NUM preserves milliseconds
            
            assert(isduration(s));
            s = milliseconds(s) / 1e3;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

