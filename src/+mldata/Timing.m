classdef Timing < handle & matlab.mixin.Copyable & mldata.ITiming
	%% TIMING uses numeric types to represent time internally with msec resolution.  
    %  All datetime properties/methods refer to datetimeMeasured and the internal representations.

	%  $Revision$
 	%  was created 17-Oct-2018 17:03:37 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mldata/src/+mldata.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Constant)
        MIN_DT = 0.001 % 1 msec
    end
    
	properties (Dependent)
        datetime0
        datetimeF
        datetimeWindow
        datetimeInterpolants
        datetimeMeasured
        datetimes
        dt
        index0
        indexF
        indexWindow
        indices
        preferredTimeZone
        time0
        timeF
        timeWindow
        timeInterpolants
        times
    end 

    methods (Static)
        function tf = isnice(obj) 
            %% ISNICE duration, datetime or numeric
            
            if (isduration(obj)); obj = seconds(obj); end
            if (isdatetime(obj)); obj = seconds(obj - obj(1)); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceDat(obj)
            if (isduration(obj))
                tf = false; 
                return
            end
            if (isdatetime(obj)); obj = seconds(obj - obj(1)); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceDur(obj)
            if (isdatetime(obj))
                tf = false;
                return
            end
            if (isduration(obj)); obj = seconds(obj); end
            tf = all(isnumeric(obj)) && all(~isempty(obj)) && all(~isnan(obj)) && all(isfinite(obj));
        end
        function tf = isniceScalNum(s)
            tf = isscalar(s) && ...
                isnumeric(s) && ~isempty(s) && ~isnan(s) && isfinite(s);
        end
    end
    
	methods 
        
        %% GET/SET
                
        function g = get.datetime0(this)
            g = this.datetimeMeasured_ + this.num2duration(this.time0 - this.times(1));
        end
        function     set.datetime0(this, s)
            assert(isscalar(s));
            assert(this.isniceDat(s));
            if (isempty(s.TimeZone))
                s.TimeZone = this.preferredTimeZone;
            end
            if (s < this.datetimeMeasured)
                this.time0 = this.times(1);
                return
            end
            this.time0 = this.timing2num(s - this.datetimeMeasured) + this.times(1);
        end
        function g = get.datetimeF(this)
            g = this.datetimeMeasured_ + this.num2duration(this.timeF - this.times(1));
        end
        function     set.datetimeF(this, s)
            assert(isscalar(s));
            assert(this.isniceDat(s));
            if (isempty(s.TimeZone))
                s.TimeZone = this.preferredTimeZone;
            end
            if (s > this.datetimeMeasured_ + this.num2duration(this.times(end) - this.times(1)))
                this.timeF = this.times(end);
                return
            end
            this.timeF = this.timing2num(s - this.datetimeMeasured_) + this.times(1);
        end
        function g = get.datetimeInterpolants(this)
            g = this.datetimeMeasured_ + this.num2duration(this.timeInterpolants);
        end
        function g = get.datetimeMeasured(this)
            g = this.datetimeMeasured_;
        end
        function     set.datetimeMeasured(this, s)
            assert(this.isniceDat(s));
            this.datetimeMeasured_ = s;
        end
        function g = get.datetimes(this)
            g = datetime(this);
        end
        function g = get.datetimeWindow(this)
            g = this.datetimeF - this.datetime0;
        end
        function     set.datetimeWindow(this, s)
            assert(isscalar(s));
            assert(this.isniceDur(s));
            this.timeF = this.time0 + this.timing2num(s);
        end
        function g = get.dt(this)
            if (~isempty(this.dt_) && this.dt_ > this.MIN_DT)
                g = this.dt_;
                return
            end
            g = min(diff(this.times))/2;
            this.dt_ = g;
        end
        function     set.dt(this, s)
            assert(isscalar(s));
            assert(this.isniceDur(s));
            this.dt_ = this.timing2num(s);
        end
        function g = get.index0(this)
            [~,g] = max(this.times >= floor(this.time0));
        end
        function     set.index0(this, s)
            assert(this.isniceScalNum(s));
            this.time0 = this.times(s);
        end
        function g = get.indexF(this)
            [~,g] = max(this.times >= floor(this.timeF));
        end
        function     set.indexF(this, s)
            assert(this.isniceScalNum(s));
            this.timeF = this.times(s);
        end
        function g = get.indexWindow(this)
            g = this.indexF - this.index0 + 1;
        end
        function     set.indexWindow(this, s)
            assert(this.isniceScalNum(s));
            this.indexF = this.index0 + s - 1;
        end
        function g = get.indices(this)
            g = 1:length(this.times);
        end
        function g = get.preferredTimeZone(~)
            g = mlpipeline.ResourcesRegistry.instance().preferredTimeZone;
        end
        function g = get.time0(this)
            if isfinite(this.time0_)
                g = this.time0_;
                return
            end
            if ~isempty(this.times)
                this.time0_ = this.times(1);
                g = this.time0_;
                return
            end
            g = this.time0_;
        end
        function     set.time0(this, s)
            assert(isscalar(s));
            assert(s <= this.times(end), ...
                'mldata:ValueError', 'Timing.set.time0 received request for time0 > times(end)');
            if (s < this.times(1)) % trap -inf
                warning('mldata:ValueWarning', 'Timing.set.time0 received request for time0 < times(1)');
                this.time0_ = this.times(1);
                return
            end
            assert(this.isnice(s));
            this.time0_ = this.timing2num(s);
        end
        function g = get.timeF(this)
            if (isfinite(this.timeF_))
                g = this.timeF_;
                return
            end  
            if ~isempty(this.times)
                this.timeF_ = this.times(end);
                g = this.timeF_;
                return
            end
            g = this.timeF_;
        end
        function     set.timeF(this, s)
            assert(isscalar(s));
            assert(s >= this.times(1), ...
                'mldata:ValueError', 'Timing.set.timeF received request for timeF < times(1)')
            if (s > this.times(end)) % trap inf
                warning('mldata:ValueWarning', 'Timing.set.timeF received request for timeF > times(end)');
                this.timeF_ = this.times(end);
                return
            end
            assert(this.isnice(s));
            this.timeF_ = this.timing2num(s);
        end
        function g = get.timeInterpolants(this)
            %% GET.TIMEINTERPOLANTS are uniformly separated by this.dt
            
            g = this.time0:this.dt:this.timeF;
        end
        function g = get.times(this)
            g = this.times_;
        end
        function     set.times(this, s)
            assert(this.isnice(s));
            s = ensureRowVector(s);
            this.times_ = this.timing2num(s);
        end
        function g = get.timeWindow(this)
            g = this.timeF - this.time0;
        end
        function     set.timeWindow(this, s)
            assert(isscalar(s));
            assert(this.isniceDur(s));
            this.timeF = this.time0 + this.timing2num(s);
        end
        
        %%
		  
        function d    = datetime(this)
            %% DATETIME
            %  @return all time0:timeF as datetime from this.datetime0
            
            d = this.datetime0 + seconds(this.times(this.index0:this.indexF) - this.times(this.index0)); 
        end
        function d    = duration(this)
            %% DURATION all times as seconds
            
            d = this.num2duration(this.times);
        end
        function t    = num2datetime(this, n)
            %% NUM2DATETIME
            %  @param n is arg to double in sec.
            %  @returns t is datetime with respect to datetimeMeasured.
            
            t = this.datetimeMeasured_ + milliseconds(double(n)) * 1e3;
        end
        function t    = num2duration(~, n)
            %% NUM2DURATION
            %  @param n is arg to double in sec.
            %  @returns t is duration.
            
            t = milliseconds(double(n)) * 1e3;
        end
        function        resetTimeLimits(this)  
            %% RESETTIMELIMITS:  time0 := times(1); timeF := times(end)
            
            this.time0 = this.times(1);
            this.timeF = this.times(end);
        end
        function n    = timing2num(this, t)
            %% TIMING2NUM
            %  @param t is datetime | duration | arg of double.
            %  @returns n is numeric in sec.
            
            if (isdatetime(t))
                n = milliseconds(t - this.datetimeMeasured_) / 1e3;
                return
            end
            if (isduration(t))
                n = milliseconds(t) / 1e3;
                return
            end
            n = double(t);
        end
        
 		function this = Timing(varargin)
 			%% TIMING
            %  @param named datetimeMeasured is datetime that is measured (not inferred).
 			%  @param named times are numeric, duration or datetime.
 			%  @param named time0 is the adjustable time window start; >= time(1).    
 			%  @param named timeF is the adjustable time window end; <= times(end).
            %  @param named dt is numeric, satisfying Nyquist sampling.

 			ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'datetimeMeasured', NaT, @(x) isdatetime(x) && ~isnat(x));
            addParameter(ip, 'times', 0, @(x) isnumeric(x) || isdatetime(x)); 
            addParameter(ip, 'time0', -inf, @isnumeric);
            addParameter(ip, 'timeF',  inf, @isnumeric);
            addParameter(ip, 'dt', 0, @isnumeric);
            parse(ip, varargin{:});
            ipr = ip.Results;
            
            this.datetimeMeasured_ = ipr.datetimeMeasured;
            if isempty(this.datetimeMeasured_.TimeZone)
                this.datetimeMeasured_.TimeZone = this.preferredTimeZone;
            end
            warning('off', 'mldata:ValueWarning');
            this.times_ = this.timing2num(ipr.times);
            this.time0_ = ipr.time0;
            this.timeF_ = ipr.timeF;
            this.dt_    = ipr.dt;
            warning('on', 'mldata:ValueWarning');
 		end
 	end 

    
    %% PRIVATE
    
    properties (Access = private)
        times_        
        time0_
        timeF_
        timeInterpolants_        
        datetimeMeasured_
        dt_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

