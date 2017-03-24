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
    end
    
	properties (Dependent) 
        datetime0 % established datetime of this.time(1)
        dt     % for timeInterpolants
        index0 % for timeInterpolants
        indexF % for timeInterpolants
        interpolatedTimeShift % shifts time0, timeF such that for shifts < 0 the data shifts left; for shifts > 0, the data shifts to the right.  See also:  shiftVector
        time0  % for timeInterpolants
        timeF  % for timeInterpolants
        timeDuration 
        times
        timeMidpoints % length() <= length(times)
        taus          % length() <= length(times)
    end
    
    methods %% GET, SET
        function g    = get.datetime0(this)
            g = this.datetime0_;
        end
        function this = set.datetime0(this, s)
            assert(isa(s, 'datetime'));
            s.TimeZone = this.PREFERRED_TIMEZONE;
            this.datetime0_ = s;
        end
        function g    = get.dt(this)
            if (~isempty(this.dt_))
                g = this.dt_;
                return
            end            
            g = min(this.taus);
        end
        function this = set.dt(this, s)
            assert(isnumeric(s));
            this.dt_ = s;
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
        function g    = get.interpolatedTimeShift(this)
            g = this.interpolatedTimeShift_;
        end
        function this = set.interpolatedTimeShift(this, s)
            assert(isnumeric(s) && isscalar(s));
            this.interpolatedTimeShift_ = s;
        end
        function g    = get.time0(this)
            if (~isempty(this.time0_))
                g = this.time0_ - this.interpolatedTimeShift;
                return
            end            
            g = this.times(1) - this.interpolatedTimeShift;
        end
        function this = set.time0(this, s)
            assert(isnumeric(s));
            this.time0_ = s;
        end
        function g    = get.timeF(this)
            if (~isempty(this.timeF_))
                g = this.timeF_ - this.interpolatedTimeShift;
                return
            end            
            g = this.times(end) - this.interpolatedTimeShift;
        end
        function this = set.timeF(this, s)
            assert(isnumeric(s));
            this.timeF_ = s;
        end
        function g    = get.timeDuration(this)
            g = this.timeF - this.time0;
        end
        function this = set.timeDuration(this, s)
            if (isnumeric(s) && s < this.times(end) - this.time0_)
                this.timeF_ = this.time0_ + s;
                return
            end            
            warning('mldata:setPropertyIgnored', 'TimingData.set.timeDuration');
        end
        function g    = get.times(this)
            g = this.times_;
        end
        function this = set.times(this, s)
            assert(isnumeric(s));
            this.times_ = s;
            if (length(s) > 2)
                assert(all(this.taus > 0));
            end
        end
        function g    = get.timeMidpoints(this)
            g = (this.times_(1:end-1) + this.times_(2:end))/2;
            g = [g g(end)];
            if (~isempty(this.timeMidpoints_))
                g(end) = this.timeMidpoints_(end);
            end
        end
        function g    = get.taus(this)
            g = this.times_(2:end) - this.times_(1:end-1);
            g = [g g(end)];
            if (~isempty(this.taus_))
                g(end) = this.taus_(end);
            end
        end
    end

	methods		  
 		function this = TimingData(varargin)
 			%% TIMINGDATA
 			%  @param named time0 is numeric; stored as row-vector.
 			%  @param named timeF ".
 			%  @param named times ".
 			%  @param named timeMidpoints ".
 			%  @param named taus ".

 			ip = inputParser;
            addParameter(ip, 'times', 0, @isnumeric);
            addParameter(ip, 'time0', -inf, @isnumeric);
            addParameter(ip, 'timeF', inf, @isnumeric);
            addParameter(ip, 'timeMidpoints', [], @isnumeric);
            addParameter(ip, 'taus', [], @isnumeric);
            addParameter(ip, 'datetime0', datetime('now'), @(x) isa(x, 'datetime'));
            parse(ip, varargin{:});
            
            this.times_         = ensureRowVector(ip.Results.times);
            this.timeMidpoints_ = ensureRowVector(ip.Results.timeMidpoints);
            this.taus_          = ensureRowVector(ip.Results.taus);
            this.time0          = max(ip.Results.time0, this.times_(1));
            this.timeF          = min(ip.Results.timeF, this.times_(end));
            this.datetime0      = ip.Results.datetime0;
        end        
        
        function s        = datetime2sec(this, dt)
            dt.TimeZone = this.PREFERRED_TIMEZONE;
            s = seconds(dt - this.datetime0);
        end
        function len      = length(this)
            len = length(this.times);
        end
        function dt       = sec2datetime(this, s)
            dt = this.datetime0 + duration(0,0,s);
        end
        function [t,this] = timeInterpolants(this, varargin)
            %% TIMEINTERPOLANTS are uniformly separated by this.dt
            %  @param varargin are optional array indices.
            
            if (~isempty(this.timeInterpolants_))
                t = this.timeInterpolants_;
                return
            end
            
            t = 0:this.dt:this.timeF-this.time0;
            this.timeInterpolants_ = t;
            if (~isempty(varargin))
                t = t(varargin{:}); end
        end
        function [t,this] = timeMidpointInterpolants(this, varargin)
            %% TIMEMIDPOINTINTERPOLANTS are uniformly separated by this.dt
            %  @param varargin are optional array indices.
            
            if (~isempty(this.timeMidpointInterpolants_))
                t = this.timeMidpointInterpolants_;
                return
            end
            
            t = this.time0+this.dt/2:this.dt:this.timeF+this.dt/2;
            t = t - this.time0;
            this.timeMidpointInterpolants_ = t;
            if (~isempty(varargin))
                t = t(varargin{:}); end
        end
        function [t,this] = tauInterpolants(this, varargin)
            %% TAUINTERPOLANTS are uniformly separated by this.dt
            %  @param varargin are optional array indices.
            
            if (~isempty(this.tauInterpolants_))
                t = this.tauInterpolants_;
                return
            end
            
            t = this.dt*ones(1, length(this.timeInterpolants));
            this.tauInterpolants_ = t;
            if (~isempty(varargin))
                t = t(varargin{:}); end
        end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        datetime0_
        dt_
        interpolatedTimeShift_ = 0
        time0_
        timeF_
        times_
        timeMidpoints_ % length >= length(times_) - 1
        taus_          % length >= length(times_) - 1
        
        timeInterpolants_
        timeMidpointInterpolants_
        tauInterpolants_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

