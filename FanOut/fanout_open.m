function fanout_open(varargin)
%write Z to open both channels.
if nargin==0
    fan=fanout_init();
elseif nargin==1
    fan=varargin{1};
end
fwrite(fan,'Z\n');