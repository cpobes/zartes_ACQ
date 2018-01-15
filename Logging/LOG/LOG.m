function varargout = LOG(varargin)
% LOG MATLAB code for LOG.fig
%      LOG, by itself, creates a new LOG or raises the existing
%      singleton*.
%
%      H = LOG returns the handle to a new LOG or the handle to
%      the existing singleton*.
%
%      LOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOG.M with the given input arguments.
%
%      LOG('Property','Value',...) creates a new LOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LOG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LOG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LOG

% Last Modified by GUIDE v2.5 25-Nov-2015 13:58:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LOG_OpeningFcn, ...
    'gui_OutputFcn',  @LOG_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LOG is made visible.
function LOG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LOG (see VARARGIN)

% Choose default command line output for LOG

handles.output = hObject;

% START USER CODE
% Create a timer object to fire at 1/10 sec intervals
% Specify function handles for its start and run callbacks
Period = 30;
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_display,hObject}); % Specify callback function
% Initialize slider and its readout text field

set(handles.version,'String','Version 1.5');

zoom off;
pan off;

dataPlot = 0;
timeAxis = 0;
handles.plot = plot(handles.graph1,timeAxis,dataPlot,'r','LineWidth',1);
handles.plot2 = plot(handles.graph2,timeAxis,dataPlot,'k','LineWidth',1);
handles.plot3 = plot(handles.graph3,timeAxis,dataPlot,'b','LineWidth',1);

close_visible(hObject, eventdata, handles);
objLOG = LOGClass;
objLOG.closeVisibleNew(hObject, eventdata, handles);
% END USER CODE

set(handles.filenamestatic,'backg',[0.941 0.941 0.941]);
set(handles.filedirectorystatic,'backg',[0.941 0.941 0.941]);
set(handles.filename,'backg',[0.941 0.941 0.941]);
set(handles.filedirectory,'backg',[0.941 0.941 0.941]);
set(handles.autoupdate,'backg',[0.941 0.941 0.941]);
set(handles.dateHeader,'backg',[0.941 0.941 0.941]);
set(handles.updatetext,'backg',[0.941 0.941 0.941]);
set(handles.version,'backg',[0.941 0.941 0.941]);

% Update handles structure
guidata(hObject,handles);

% UIWAIT makes LOG wait for user response (see UIRESUME)
% uiwait(handles.LOG);


% --- Outputs from this function are returned to the command line.
function varargout = LOG_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%-----------------------------------------------------------------------------------------% Push & Toggle Buttons

% --- Executes on button press in infobutton.
function infobutton_Callback(hObject, eventdata, handles)
% hObject    handle to infobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ver10 = {'Version 1.0' '-New: Interface works with specific data format.' ...
    '-New: Browsing a file supported with file name and directory information.' ...
    '-New: Auto data update is available.' ...
    '-New: Last data update information is available.' ...
    '-New: Magnify and Zoom features are available.' ...
    '-New: Only one parameter selection is supported.' ...
    '-New: User interface resize behaviour is proportional.' ...
    '-New: Precautions are taken into account for possible errors.' ...
    '-Unresolved: More than one parameter selection does not work.' ...
    '-Unresolved: Errors occur while using Pan. Pan is disabled.' ...
    '-Unresolved: Cursor clean function is required, Data Cursor is disabled. ' ...
    };

ver11 = {'' 'Version 1.1' '-Changed: Security fixes for browsing a file.'...
    '-Changed: Parameter selection performance improved.' ...
    '-Changed: User Interface style is upgraded.' ...
    '-Fixed: Initial data plot works properly.' ...
    };

ver12 = {'' 'Version 1.2' '-Changed: Browsing a file from any direction is available.'...
    '-Fixed: Bug - Selecting a file with different format type.'...
    '-Fixed: Data Auto Update works properly.' ...
    };

ver13 = {'' 'Version 1.3' '-New: Pan feature is available. (Solved)'...
    '-Changed: Data importing and updating performance improved.'...
    '-Changed: Toolbar is disabled.'...
    '-Changed: Cursor feature is permanently deleted.(Solved)'...
    };

ver132 = {'' 'Version 1.3.2' '-Fixed: Data auto update bug is fixed.'...
    '-Fixed: Zoom out feature is fixed.'...
    };

ver14 = {'' 'Version 1.4' '-New: Point tracking is added.'...
    '-New: Auto zoom out is added.'...
    '-New: y-Axis label is added.'...
    '-Unresolved: Multiple selection will be added in the near future.' ...
    };

ver15 = {'' 'Version 1.5' '-Solved: Multiple plot is added.'...
    };
verTotal = [ver10 ver11 ver12 ver13 ver132 ver14 ver15];

msgbox(verTotal,'Version Release History');

% --- Executes on button press in browsefile.
function browsefile_Callback(hObject, eventdata, handles)
% hObject    handle to browsefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% Choose default command line output for LOG
% clc;
global fid
fid = -1;

handles.output = hObject;

zoom off;
pan off;
set(handles.pan,'Value',0);
set(handles.magnify,'Value',0);
set(handles.zoomXY,'Value',0);

f1 = handles.LOG;

set(f1, ...
    'WindowButtonDownFcn',@emptyF, ...
    'WindowButtonUpFcn', @emptyF, ...
    'WindowButtonMotionFcn', @emptyF, ...
    'KeyPressFcn', @emptyF);

set(handles.pan,'backg',[0.941 0.941 0.941])  % Now reset the button features.
set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.

if get(handles.autoupdate, 'Value') == 1
    stop(handles.timer);
    set(handles.autoupdate,'Value',0);
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
end

try
    [FileName,PathName] = uigetfile('*.*','Select the LOG data file');
    if FileName == 0
        close_visible(hObject, eventdata, handles);
        objLOG = LOGClass;
        objLOG.closeVisibleNew(hObject, eventdata, handles);
        FileName = 'File is not selected.';
        PathName = 'File is not selected.';
        set(handles.updatetext,'String','');
        set(handles.filename,'String',FileName);
        set(handles.filedirectory,'String',PathName);
        errordlg('File not found','File Error');
        
        if fid ~= -1
            fclose(fid);
        end
    else
        close_visible(hObject, eventdata, handles);
        objLOG = LOGClass;
        objLOG.closeVisibleNew(hObject, eventdata, handles);
        set(handles.parameterlist,'Value',1);
        
        set(handles.filename,'String',FileName);
        set(handles.filedirectory,'String',PathName);
        set(handles.updatetext,'String','');
        
        assignin('base','FileName',FileName);
        assignin('base','PathName',PathName);
        getLOG(FileName,PathName);
        
        parameterNames = evalin('base','parameterNames');
        set(handles.parameterlist,'String',transpose(parameterNames(3:length(parameterNames))));
        
        
        parameterSelect = get(handles.parameterlist,'Value');
        
        data = evalin('base','dataTemp');
        timeAxis = evalin('base','timeAxis');
        dataPlot = cell2mat(data(:,parameterSelect+2));
        
        axes(handles.graph1);
        open_visible(hObject, eventdata, handles);
        
        objLOG = LOGClass;
        objLOG.openVisibleNew(hObject, eventdata, handles);
        
        set(handles.plot,'XData',timeAxis,'YData',dataPlot);
        
        if get(handles.compareSelection,'Value') == 1
            ylabel(parameterNames(parameterSelect+2),'FontSize',12,'FontWeight','bold','Color','r');
        end
        
        set(handles.parameterlist2,'String',transpose(parameterNames(3:length(parameterNames))));
        set(handles.parameterlist3,'String',transpose(parameterNames(3:length(parameterNames))));
        
        setGraphTicks();
        
        graph1oldPOS = [0.06654170571696343, 0.055652173913043515, 0.7769447047797562, 0.8382608695652175];
        set(handles.graph1,'Position',graph1oldPOS);
        
        dataPlot = 0;
        timeAxis = 0;
        handles.plot2 = plot(handles.graph2,timeAxis,dataPlot,'k','LineWidth',1);
        handles.plot3 = plot(handles.graph3,timeAxis,dataPlot,'b','LineWidth',1);
        
        set(handles.graph2,'Visible','off');
        set(handles.graph3,'Visible','off');
        set(handles.parameterlist2,'Enable','off');
        set(handles.parameterlist3,'Enable','off');
        
        set(handles.graph1,'Color',[1,1,1]);
        
    end
catch err
    FileName = 'File is not selected.';
    PathName = 'File is not selected.';
    set(handles.updatetext,'String','');
    set(handles.filename,'String',FileName);
    set(handles.filedirectory,'String',PathName);
    errordlg('File not found','File Error');
    
    close_visible(hObject, eventdata, handles);
    
    objLOG = LOGClass;
    objLOG.closeVisibleNew(hObject, eventdata, handles);
    stop(handles.timer);
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
    
    if fid ~= -1
        fclose(fid);
    end
end

% Update handles structure
guidata(hObject, handles);
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of browsefile

% --- Executes on button press in zoomreset.
function zoomreset_Callback(hObject, eventdata, handles)
% hObject    handle to zoomreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;

set(handles.pointTracking,'Value',0);
set(handles.autoZoomOut,'Value',0);
setGraphTicks();

% Update handles structure
if get(handles.autoupdate,'Value') == 1
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','on');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','on');
end
% zoom reset;

% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of zoomreset

% --- Executes on button press in pan.
function pan_Callback(hObject, eventdata, handles)
% hObject    handle to pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pan
if get(handles.pan,'Value') == 1
    zoom off;
    
    set(handles.LOG, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    set(handles.pan,'backg',[1 .6 .6]) % Change color of button.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    
    pan on;
    
    set(handles.magnify,'Value',0);
    set(handles.zoomXY,'Value',0);
    
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
else
    pan off;
    
    % Update handles structure
    if get(handles.autoupdate,'Value') == 1
        set(handles.pointTracking,'Value',0);
        set(handles.pointTracking,'Enable','on');
        set(handles.autoZoomOut,'Value',0);
        set(handles.autoZoomOut,'Enable','on');
    end
    
    set(handles.pan,'Value',0);
    set(handles.pan,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end

% --- Executes on button press in zoomXY.
function zoomXY_Callback(hObject, eventdata, handles)
% hObject    handle to zoomXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom off;
if get(handles.zoomXY,'Value') == 1
    
    pan off;
    
    set(handles.LOG, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    set(handles.pan,'Value',0);
    set(handles.magnify,'Value',0);
    zoom xon;
    % Update handles structure
    
    set(handles.zoomXY,'backg',[1 .6 .6]) % Change color of button.
    set(handles.pan,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
else
    zoom off;
    
    % Update handles structure
    if get(handles.autoupdate,'Value') == 1
        set(handles.pointTracking,'Value',0);
        set(handles.pointTracking,'Enable','on');
        set(handles.autoZoomOut,'Value',0);
        set(handles.autoZoomOut,'Enable','on');
    end
    
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end

% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of zoomXY


% --- Executes on button press in magnify.
function magnify_Callback(hObject, eventdata, handles)
% hObject    handle to magnify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom off;
f1 = handles.LOG;
if (nargin == 0)
    f1 = handles.LOG;
end;

if get(handles.magnify,'Value') == 1
    set(handles.pan,'Value',0);
    set(handles.zoomXY,'Value',0);
    zoom off;
    pan off;
    set(f1, ...
        'WindowButtonDownFcn', @ButtonDownCallback, ...
        'WindowButtonUpFcn', @ButtonUpCallback, ...
        'WindowButtonMotionFcn', @ButtonMotionCallback, ...
        'KeyPressFcn', @KeyPressCallback);
    
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
    
    set(handles.magnify,'backg',[1 .6 .6]) % Change color of button.
    set(handles.pan,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
else
    set(f1, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    % Update handles structure
    if get(handles.autoupdate,'Value') == 1
        set(handles.pointTracking,'Value',0);
        set(handles.pointTracking,'Enable','on');
        set(handles.autoZoomOut,'Value',0);
        set(handles.autoZoomOut,'Enable','on');
    end
    
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end

% Update handles structure
guidata(hObject, handles);
return;

%-----------------------------------------------------------------------------------------% Sliders

%----------------------------------------% List & Check Boxes

% --- Executes on button press in autoupdate.
function autoupdate_Callback(hObject, eventdata, handles)
% hObject    handle to autoupdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;

if get(handles.autoupdate, 'Value') == 1
    start(handles.timer);
    if get(handles.compareSelection,'Value') == 1
        set(handles.pointTracking,'Value',0);
        set(handles.pointTracking,'Enable','on');
        set(handles.autoZoomOut,'Value',0);
        set(handles.autoZoomOut,'Enable','on');
    end
else
    stop(handles.timer);
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
end

% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of autoupdate

% --- Executes on selection change in parameterlist.
function parameterlist_Callback(hObject, eventdata, handles)
% hObject    handle to parameterlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parameterSelect = get(handles.parameterlist,'Value');
parameterNames = evalin('base','parameterNames');
data = evalin('base','dataTemp');
timeAxis = evalin('base','timeAxis');
dataPlot = cell2mat(data(:,parameterSelect+2));
set(handles.plot,'XData',timeAxis,'YData',dataPlot);
axes(handles.graph1);
axis(handles.graph1,'auto y');

if get(handles.compareSelection,'Value') == 1
    ylabel(parameterNames(parameterSelect+2),'FontSize',12,'FontWeight','bold','Color','r');
else
    set(handles.graph1,'Color','none');
end

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns parameterlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterlist

% --- Executes during object creation, after setting all properties.
function parameterlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%-----------------------------------------------------------------------------------------% Static Texts

%-----------------------------------------------------------------------------------------% Edit Texts

%-----------------------------------------------------------------------------------------% Axes

%-----------------------------------------------------------------------------------------% Others

function emptyF(~,~,~,~)
return;

function open_visible(hObject, eventdata, handles)

handles.output = hObject;

set(handles.pan,'Visible','on');
set(handles.dateHeader,'Visible','on');
set(handles.updatetext,'Visible','on');
set(handles.zoomXY,'Visible','on');
set(handles.zoomreset,'Visible','on');
set(handles.parameterlist,'Visible','on');
set(handles.magnify,'Visible','on');
set(handles.autoupdate,'Visible','on');
set(handles.graph1,'Visible','on');

set(handles.pointTracking,'Visible','on');
set(handles.pointTracking,'Enable','off');
set(handles.autoZoomOut,'Visible','on');
set(handles.autoZoomOut,'Enable','off');
% Update handles structure
guidata(hObject, handles);

function close_visible(hObject, eventdata, handles)

handles.output = hObject;

FileName = 'File is not selected.';
PathName = 'File is not selected.';
set(handles.filename,'String',FileName);
set(handles.filedirectory,'String',PathName);

set(handles.pan,'Visible','off');
set(handles.dateHeader,'Visible','off');
set(handles.updatetext,'Visible','off');
set(handles.plot,'XData',0,'YData',0);
set(handles.zoomXY,'Visible','off');
set(handles.zoomreset,'Visible','off');
set(handles.parameterlist,'Visible','off');
set(handles.magnify,'Visible','off');
set(handles.autoupdate,'Visible','off');
set(handles.graph1,'Visible','off');

set(handles.pointTracking,'Visible','off');
set(handles.autoZoomOut,'Visible','off');

stop(handles.timer);
set(handles.autoupdate,'Value',0);
set(handles.pointTracking,'Value',0);
set(handles.autoZoomOut,'Value',0);
% Update handles structure
guidata(hObject, handles);

function getLOG(FileName,PathName)
% To let it work properly, we should define these 3 parameters' name same
% assignin('base','timeAxis',timeAxis);
% assignin('base','dataTemp',dataTemp);
% assignin('base','parameterNames',parameterNames);

global fid
global dataTemp
global dataTemp2
global timeAxis
global timeAxis2
global parameterNames

if fid == -1
    
    directory = strcat(PathName,FileName);
    fid = fopen(directory,'r');
    
    header = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s',1);
    headerFirst = header(1:33);
    headerMid = strcat(header(34),header(35),header(36));
    headerMid = headerMid{1};
    headerMid = strcat(headerMid(1),headerMid(2),headerMid(3));
    headerLast = header(37:end);
    header = [headerFirst headerMid headerLast];
    values = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
    
    parameterNames = [header{1},header{2},header{3},header{4},header{5},header{6}, ...
        header{7},header{8},header{9},header{10},header{11},header{12}, ...
        header{13},header{14},header{15},header{16},header{5},header{6}, ...
        header{19},header{20},header{21},header{22},header{23},header{24}, ...
        header{25},header{26},header{27},header{28},header{29},header{30}, ...
        header{31},header{32},header{33},header{34},header{35},header{36}, ...
        header{37},header{38},header{39},header{40},header{41},header{42},header{43}];
    
    temp1 = [values{:,1} values{:,2}];
    temp2 = [values{3:end}];
    cellSize = length(values{1,1});
    dataTemp = cell(cellSize,43);
    
    for i =1:cellSize
        for j = 1:2
            dataTemp(i,j) = temp1(i,j);
        end
    end
    
    for i =1:cellSize
        for j = 3:43
            dataTemp{i,j} = temp2(i,j-2);
        end
    end
    
    formatDate = 'dd/mm/yyyy_HH:MM:SS';
    convertDate = strcat(values{1,1}(:),'_',values{1,2}(:));
    dataDate = datevec(convertDate, formatDate);
    timeAxis = datenum(dataDate);
    
else
    
    update = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
    if ~isempty(update{1})
        temp1 = [update{:,1} update{:,2}];
        temp2 = [update{3:end}];
        cellSize = length(update{1,1});
        dataTemp2 = cell(cellSize,43);
        
        for i =1:cellSize
            for j = 1:2
                dataTemp2(i,j) = temp1(i,j);
            end
        end
        
        for i =1:cellSize
            for j = 3:43
                dataTemp2{i,j} = temp2(i,j-2);
            end
        end
        
        formatDate = 'dd/mm/yyyy_HH:MM:SS';
        convertDate = strcat(update{1,1}(:),'_',update{1,2}(:));
        dataDate = datevec(convertDate, formatDate);
        timeAxis2 = datenum(dataDate);
        
        dataTemp = [dataTemp;dataTemp2];
        timeAxis = [timeAxis;timeAxis2];
    end
end

assignin('base','timeAxis',timeAxis);
assignin('base','dataTemp',dataTemp);
assignin('base','parameterNames',parameterNames);

function setGraphTicks()
datetick('x', 'ddd HHPM MM','keeplimits');
dynamicDateTicks(gca, [], 'ddd/mm');
grid on

% START USER CODE
function update_display(hObject,eventdata,hfigure)
% Timer timer1 callback, called each time timer iterates.
% Gets surface Z data, adds noise, and writes it back to surface object.

handles = guidata(hfigure);

FileName = evalin('base','FileName');
PathName = evalin('base','PathName');
getLOG(FileName,PathName);

parameterNames = evalin('base','parameterNames');
set(handles.parameterlist,'String',transpose(parameterNames(3:length(parameterNames))));

parameterSelect = get(handles.parameterlist,'Value');
data = evalin('base','dataTemp');
timeAxis = evalin('base','timeAxis');
dataPlot = cell2mat(data(:,parameterSelect+2));
set(handles.plot,'XData',timeAxis,'YData',dataPlot);
set(handles.updatetext,'String',datestr(now));

trackState = get(handles.pointTracking,'Value');
autoZoomOut = get(handles.autoZoomOut,'Value');
if trackState == 1
    [XLimOld] = get(handles.graph1,'XLim');
    set(handles.graph1,'XLim', [XLimOld(1), timeAxis(end)+(timeAxis(end)-timeAxis(end-1))*50]);
    
    set(handles.graph1,'XTickLabelMode','auto');
    set(handles.graph1,'XTickMode','auto');
    
    datetick(handles.graph1,'x', 'HH:MM','keeplimits','keepticks');
elseif autoZoomOut == 1
    datetick(handles.graph1,'x', 'ddd HHPM MM','keeplimits');
    %     dynamicDateTicks(handles.graph1, [], 'ddd/mm');
    for i = 1:length(handles.graph1)
        
        datetick(handles.graph1, 'x');
        mdformat = 'ddd/mm';
        % Get the current axes ticks & labels
        ticks  = get(handles.graph1, 'XTick');
        labels = get(handles.graph1, 'XTickLabel');
        
        % Sometimes the first tick can be outside axes limits. If so, remove it & its label
        if all(ticks(1) < get(handles.graph1,'xlim'))
            ticks(1) = [];
            labels(1,:) = [];
        end
        
        [yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
        newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information
        
        if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
            
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
            labels = strcat(labels, newlabels);
            
        elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
            
            % Change mm/dd to dd/mm if necessary
            labels = datestr(ticks, mdformat);
            % Add year information to first tick & ticks where the year changes
            ind = [1 find(diff(yr))+1];
            newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
            labels = strcat(labels, newlabels);
            
        elseif any(labels(1,:) == ':') % Tick format is HH:MM
            
            % Add month/day/year information to the first tick and month/day to other ticks where the day changes
            ind = find(diff(da))+1;
            newlabels{1}   = datestr(ticks(1), [mdformat '/yy-']); % Add month/day/year to first tick
            newlabels(ind) = cellstr(datestr(ticks(ind), [mdformat '-'])); % Add month/day to ticks where day changes
            labels = strcat(newlabels, labels);
            
        end
    end
    set(handles.graph1, 'XTick', ticks, 'XTickLabel', labels);
else
    compareSelection = get(handles.compareSelection,'Value');
    if compareSelection == 2
        
        objLOG = LOGClass;
        objLOG.draw2nd(hObject, eventdata, handles);
        
        graph1newPOS = get(handles.graph1,'Position');
        graph3POS = get(handles.graph3,'Position');
        scale13 = graph3POS(3)/graph1newPOS(3);
        graph1XLim = get(handles.graph1,'XLim');
        graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
        
        set(handles.graph3,'XLim',graph3XLim);
        
        blueline = findobj(handles.graph3,'Type','Line','color','b');
        xdataBlueline = get(blueline,'XData');
        ydataBlueline = get(blueline,'YData');
        
        erasePart = find(xdataBlueline>graph3XLim(1) & xdataBlueline<graph1XLim(1));
        xdataBlueline(erasePart) = [];
        ydataBlueline(erasePart) = [];
        
        set(blueline, 'xdata', xdataBlueline, 'ydata', ydataBlueline);
        axis(handles.graph3,'auto y');
        
    elseif compareSelection == 3
        
        objLOG = LOGClass;
        objLOG.draw3rd(hObject, eventdata, handles);
        
        graph1newPOS = get(handles.graph1,'Position');
        graph2POS = get(handles.graph2,'Position');
        scale12 = graph2POS(3)/graph1newPOS(3);
        graph1XLim = get(handles.graph1,'XLim');
        graph2XLim = [graph1XLim(2)-scale12*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
        
        set(handles.graph2,'XLim',graph2XLim);
        
        blackline = findobj(handles.graph2,'Type','Line','color','k');
        xdataBlackline = get(blackline,'XData');
        ydataBlackline = get(blackline,'YData');
        
        erasePart = find(xdataBlackline>graph2XLim(1) & xdataBlackline<graph1XLim(1));
        xdataBlackline(erasePart) = [];
        ydataBlackline(erasePart) = [];
        
        set(blackline, 'xdata', xdataBlackline, 'ydata', ydataBlackline);
        axis(handles.graph2,'auto y');
        
        objLOG.draw2nd(hObject, eventdata, handles);
        
        graph1newPOS = get(handles.graph1,'Position');
        graph3POS = get(handles.graph3,'Position');
        scale13 = graph3POS(3)/graph1newPOS(3);
        graph1XLim = get(handles.graph1,'XLim');
        graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
        
        set(handles.graph3,'XLim',graph3XLim);
        
        blueline = findobj(handles.graph3,'Type','Line','color','b');
        xdataBlueline = get(blueline,'XData');
        ydataBlueline = get(blueline,'YData');
        
        erasePart = find(xdataBlueline>graph3XLim(1) & xdataBlueline<graph1XLim(1));
        xdataBlueline(erasePart) = [];
        ydataBlueline(erasePart) = [];
        
        set(blueline, 'xdata', xdataBlueline, 'ydata', ydataBlueline);
        axis(handles.graph3,'auto y');
        
    else
    end
end
% END USER CODE

% --- Executes on button press in pointTracking.
function pointTracking_Callback(hObject, eventdata, handles)
% hObject    handle to pointTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.autoZoomOut,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of pointTracking


% --- Executes on button press in autoZoomOut.
function autoZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to autoZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pointTracking,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of autoZoomOut


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dynamicDateTicks(axH, link, mdformat)
% DYNAMICDATETICKS is a wrapper function around DATETICK which creates
% dynamic date tick labels for plots with dates on the X-axis. The date
% ticks intelligently include year/month/day information on specific ticks
% as appropriate. The ticks are dynamic with respect to zooming and
% panning. They update as the timescale changes (from years to seconds).
% Data tips on the plot also show intelligently as dates.
%
% The function may be used with linked axes as well as with multiple
% independent date and non-date axes within a plot.
%
% USAGE:
% dynamicDateTicks()
%       makes the current axes a date axes with dynamic properties
%
% dynamicDateTicks(axH)
%       makes all the axes handles in vector axH dynamic date axes
%
% dynamicDateTicks(axH, 'link')
%       additionally specifies that all the axes in axH are linked. This
%       option should be used in conjunction with LINKAXES.
%
% dynamicDateTicks(axH, 'link', 'dd/mm')
%       additionally specifies the format of all ticks that include both
%       date and month information. The default value is 'mm/dd' but any
%       valid date string format can be specified. The first two options
%       may be empty [] if only specifying format.
%
% EXAMPLES:
% load integersignal
% dates = datenum('July 1, 2008'):1/24:datenum('May 11, 2009 1:00 PM');
% subplot(2,1,1), plot(dates, Signal1);
% dynamicDateTicks
% subplot(2,1,2), plot(dates, Signal4);
% dynamicDateTicks([], [], 'dd/mm');
%
% figure
% ax1 = subplot(2,1,1); plot(dates, Signal1);
% ax2 = subplot(2,1,2); plot(dates, Signal4);
% linkaxes([ax1 ax2], 'x');
% dynamicDateTicks([ax1 ax2], 'linked')

if nargin < 1 || isempty(axH) % If no axes is specified, use the current axes
    axH = gca;
end

if nargin < 3 % Default mm/dd format
    mdformat = 'mm/dd';
end

% Apply datetick to all axes in axH, and store any linking information
axesInfo.Type = 'dateaxes'; % Information stored in axes userdata indicating that these are date axes
for i = 1:length(axH)
    datetick(axH(i), 'x');
    if nargin > 1 && ~isempty(link) % If axes are linked,
        axesInfo.Linked = axH; % Need to modify all axes at once
    else
        axesInfo.Linked = axH(i); % Need to modify only 1 axes
    end
    axesInfo.mdformat = mdformat; % Remember mm/dd format for each axes
    set(axH(i), 'UserData', axesInfo); % Store the fact that this is a date axes and its link & mm/dd information in userdata
    updateDateLabel('', struct('Axes', axH(i)), 0); % Call once to ensure proper formatting
end

% Set the zoom, pan and datacursor callbacks
figH = get(axH, 'Parent');
if iscell(figH)
    figH = unique([figH{:}]);
end
if length(figH) > 1
    error('Axes should be part of the same plot (have the same figure parent)');
end

z = zoom(figH);
p = pan(figH);
d = datacursormode(figH);

set(z,'ActionPostCallback',@updateDateLabel);
set(p,'ActionPostCallback',@updateDateLabel);
set(d,'UpdateFcn',@dateTip);

% ------------ End of dynamicDateTicks-----------------------

function output_txt = dateTip(gar, ev)
pos = ev.Position;
axHandle = get(ev.Target, 'Parent'); % Which axes is the data cursor on
axesInfo = get(axHandle, 'UserData'); % Get the axes info for that axes
try % If it is a date axes, create a date-friendly data tip
    if strcmp(axesInfo.Type, 'dateaxes')
        output_txt = sprintf('X: %s\nY: %0.4g', datestr(pos(1)), pos(2));
    else
        output_txt = sprintf('X: %0.4g\nY: %0.4g', pos(1), pos(2));
    end
catch % It's not a date axes, create a generic data tip
    output_txt = sprintf('X: %0.4g\nY: %0.4g', pos(1), pos(2));
end

function updateDateLabel(obj, ev, varargin)
ax1 = ev.Axes; % On which axes has the zoom/pan occurred
axesInfo = get(ev.Axes, 'UserData');
% Check if this axes is a date axes. If not, do nothing more (return)
try
    if ~strcmp(axesInfo.Type, 'dateaxes')
        return;
    end
catch
    return;
end

% Re-apply date ticks, but keep limits (unless called the first time)
if nargin < 3
    datetick(ax1, 'x', 'keeplimits');
end


% Get the current axes ticks & labels
ticks  = get(ax1, 'XTick');
labels = get(ax1, 'XTickLabel');

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
if all(ticks(1) < get(ax1,'xlim'))
    ticks(1) = [];
    labels(1,:) = [];
end

[yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information

if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
    
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
    
    % Change mm/dd to dd/mm if necessary
    labels = datestr(ticks, axesInfo.mdformat);
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif any(labels(1,:) == ':') % Tick format is HH:MM
    
    % Add month/day/year information to the first tick and month/day to other ticks where the day changes
    ind = find(diff(da))+1;
    newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '/yy-']); % Add month/day/year to first tick
    newlabels(ind) = cellstr(datestr(ticks(ind), [axesInfo.mdformat '-'])); % Add month/day to ticks where day changes
    labels = strcat(newlabels, labels);
    
end

set(axesInfo.Linked, 'XTick', ticks, 'XTickLabel', labels);

% ylim('auto');
axis 'auto y';
%#ok<*CTCH>
%#ok<*ASGLU>
%#ok<*INUSL>
%#ok<*INUSD>

function ButtonDownCallback(src,eventdata)
f1 = src;
a1 = get(f1,'CurrentAxes');
a2 = copyobj(a1,f1);

set(f1, ...
    'UserData',[f1,a1,a2], ...
    'Pointer','fullcrosshair', ...
    'CurrentAxes',a2);
set(a2, ...
    'UserData',[2,0.2], ... %magnification, frame size
    'Color',get(a1,'Color'), ...
    'Box','on');
xlabel(''); ylabel(''); zlabel(''); title('');

set(a1, ...
    'Color',get(a1,'Color')*0.95);
set(f1, ...
    'CurrentAxes',a1);
ButtonMotionCallback(src);
return;

function ButtonUpCallback(src,eventdata)
H = get(src,'UserData');
f1 = H(1); a1 = H(2); a2 = H(3);
set(a1, ...
    'Color',get(a2,'Color'));
set(f1, ...
    'UserData',[], ...
    'Pointer','arrow', ...
    'CurrentAxes',a1);
if ~strcmp(get(f1,'SelectionType'),'alt'),
    delete(a2);
end;
return;

function ButtonMotionCallback(src,eventdata)
H = get(src,'UserData');
if ~isempty(H)
    f1 = H(1); a1 = H(2); a2 = H(3);
    a2_param = get(a2,'UserData');
    f_pos = get(f1,'Position');
    a1_pos = get(a1,'Position');
    
    [f_cp, a1_cp] = pointer2d(f1,a1);
    
    set(a2,'Position',[(f_cp./f_pos(3:4)) 0 0]+a2_param(2)*a1_pos(3)*[-1 -1 2 2]);
    a2_pos = get(a2,'Position');
    
    set(a2,'XLim',a1_cp(1)+(1/a2_param(1))*(a2_pos(3)/a1_pos(3))*diff(get(a1,'XLim'))*[-0.5 0.5]);
    set(a2,'YLim',a1_cp(2)+(1/a2_param(1))*(a2_pos(4)/a1_pos(4))*diff(get(a1,'YLim'))*[-0.5 0.5]);
end;
return;

function KeyPressCallback(src,eventdata)
H = get(gcf,'UserData');
if ~isempty(H)
    f1 = H(1); a1 = H(2); a2 = H(3);
    a2_param = get(a2,'UserData');
    if (strcmp(get(f1,'CurrentCharacter'),'+') | strcmp(get(f1,'CurrentCharacter'),'='))
        a2_param(1) = a2_param(1)*1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'-') | strcmp(get(f1,'CurrentCharacter'),'_'))
        a2_param(1) = a2_param(1)/1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'<') | strcmp(get(f1,'CurrentCharacter'),','))
        a2_param(2) = a2_param(2)/1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'>') | strcmp(get(f1,'CurrentCharacter'),'.'))
        a2_param(2) = a2_param(2)*1.2;
    end;
    set(a2,'UserData',a2_param);
    ButtonMotionCallback(src);
end;
return;

function [fig_pointer_pos, axes_pointer_val] = pointer2d(fig_hndl,axes_hndl)

if (nargin == 0), fig_hndl = gcf; axes_hndl = gca; end;
if (nargin == 1), axes_hndl = get(fig_hndl,'CurrentAxes'); end;

set(fig_hndl,'Units','pixels');

pointer_pos = get(0,'PointerLocation');	%pixels {0,0} lower left
fig_pos = get(fig_hndl,'Position');	%pixels {l,b,w,h}

fig_pointer_pos = pointer_pos - fig_pos([1,2]);
set(fig_hndl,'CurrentPoint',fig_pointer_pos);

if (isempty(axes_hndl)),
    axes_pointer_val = [];
elseif (nargout == 2),
    axes_pointer_line = get(axes_hndl,'CurrentPoint');
    axes_pointer_val = sum(axes_pointer_line)/2;
end;

% --- Executes when user attempts to close LOG.
function LOG_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to LOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fid
% Close request function
% to display a question dialog box
% selection = questdlg('Close This Figure?',...
%     'Close Request',...
%     'Yes','No','Yes');
% switch selection,
%     case 'Yes'

stop(handles.timer);
set(handles.pointTracking,'Value',0);
set(handles.pointTracking,'Enable','off');
set(handles.autoZoomOut,'Value',0);
set(handles.autoZoomOut,'Enable','off');

assignin('base','timeAxis',[]);
assignin('base','parameterNames',[]);
assignin('base','dataTemp',[]);
assignin('base','PathName',[]);
assignin('base','FileName',[]);

delete(handles.LOG);
if fid ~= -1
    fclose(fid);
end

clear LOG
clear all;
clc;
%     case 'No'
%         return
% end


% --- Executes on selection change in compareSelection.
function compareSelection_Callback(hObject, eventdata, handles)
% hObject    handle to compareSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for modelIV
handles.output = hObject;

selectionValue = get(handles.compareSelection,'Value');
if selectionValue == 1
    dataPlot = 0;
    timeAxis = 0;
    handles.plot2 = plot(handles.graph2,timeAxis,dataPlot,'k','LineWidth',1);
    handles.plot3 = plot(handles.graph3,timeAxis,dataPlot,'b','LineWidth',1);
    
    set(handles.graph1,'Color',[1,1,1]);
    
    objLOG = LOGClass;
    objLOG.disableAxes3(hObject, eventdata, handles);
    
    zoom off;
    pan off;
    
    set(handles.LOG, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    set(handles.pan,'backg',[0.941 0.941 0.941]) % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    
    set(handles.pan,'Value',0);
    set(handles.magnify,'Value',0);
    set(handles.zoomXY,'Value',0);
    
    set(handles.pan,'Enable','on');
    set(handles.magnify,'Enable','on');
    set(handles.zoomXY,'Enable','on');
    set(handles.zoomreset,'Enable','on');
    
    if get(handles.autoupdate,'Value') == 1
        set(handles.pointTracking,'Value',0);
        set(handles.pointTracking,'Enable','on');
        set(handles.autoZoomOut,'Value',0);
        set(handles.autoZoomOut,'Enable','on');
    end
    
    parameterNames = evalin('base','parameterNames');
    parameterSelect = get(handles.parameterlist,'Value');
    ylabel(parameterNames(parameterSelect+2),'FontSize',12,'FontWeight','bold','Color','r');
    
elseif selectionValue == 2
    dataPlot = 0;
    timeAxis = 0;
    handles.plot2 = plot(handles.graph2,timeAxis,dataPlot,'k','LineWidth',1);
    handles.plot3 = plot(handles.graph3,timeAxis,dataPlot,'b','LineWidth',1);
    
    objLOG = LOGClass;
    objLOG.enableAxes2(hObject, eventdata, handles);
    
    zoom off;
    pan off;
    
    set(handles.LOG, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    set(handles.pan,'backg',[0.941 0.941 0.941]) % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    
    set(handles.pan,'Value',0);
    set(handles.magnify,'Value',0);
    set(handles.zoomXY,'Value',0);
    
    set(handles.pan,'Enable','off');
    set(handles.magnify,'Enable','off');
    set(handles.zoomXY,'Enable','off');
    set(handles.zoomreset,'Enable','off');
    
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
    
    set(handles.parameterlist2,'Value',1);
    set(handles.parameterlist3,'Value',1);
    
    objLOG = LOGClass;
    objLOG.draw2nd(hObject, eventdata, handles);
    
    graph1newPOS = get(handles.graph1,'Position');
    graph3POS = get(handles.graph3,'Position');
    scale13 = graph3POS(3)/graph1newPOS(3);
    graph1XLim = get(handles.graph1,'XLim');
    graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
    
    set(handles.graph3,'XLim',graph3XLim);
    
elseif selectionValue == 3
    dataPlot = 0;
    timeAxis = 0;
    handles.plot2 = plot(handles.graph2,timeAxis,dataPlot,'k','LineWidth',1);
    handles.plot3 = plot(handles.graph3,timeAxis,dataPlot,'b','LineWidth',1);
    
    objLOG = LOGClass;
    objLOG.enableAxes3(hObject, eventdata, handles);
    
    zoom off;
    pan off;
    
    set(handles.LOG, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    
    set(handles.pan,'backg',[0.941 0.941 0.941]) % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomXY,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    
    set(handles.pan,'Value',0);
    set(handles.magnify,'Value',0);
    set(handles.zoomXY,'Value',0);
    
    set(handles.pan,'Enable','off');
    set(handles.magnify,'Enable','off');
    set(handles.zoomXY,'Enable','off');
    set(handles.zoomreset,'Enable','off');
    
    set(handles.pointTracking,'Value',0);
    set(handles.pointTracking,'Enable','off');
    set(handles.autoZoomOut,'Value',0);
    set(handles.autoZoomOut,'Enable','off');
    
    set(handles.parameterlist2,'Value',1);
    set(handles.parameterlist3,'Value',1);
    
    objLOG = LOGClass;
    objLOG.draw3rd(hObject, eventdata, handles);
    
    graph1newPOS = get(handles.graph1,'Position');
    graph2POS = get(handles.graph2,'Position');
    scale12 = graph2POS(3)/graph1newPOS(3);
    graph1XLim = get(handles.graph1,'XLim');
    graph2XLim = [graph1XLim(2)-scale12*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
    
    set(handles.graph2,'XLim',graph2XLim);
    
    objLOG.draw2nd(hObject, eventdata, handles);
    
    graph1newPOS = get(handles.graph1,'Position');
    graph3POS = get(handles.graph3,'Position');
    scale13 = graph3POS(3)/graph1newPOS(3);
    graph1XLim = get(handles.graph1,'XLim');
    graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
    
    set(handles.graph3,'XLim',graph3XLim);
    
else
end

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns compareSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compareSelection


% --- Executes during object creation, after setting all properties.
function compareSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compareSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in parameterlist2.
function parameterlist2_Callback(hObject, eventdata, handles)
% hObject    handle to parameterlist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for modelIV
handles.output = hObject;

objLOG = LOGClass;
objLOG.draw3rd(hObject, eventdata, handles);

graph1newPOS = get(handles.graph1,'Position');
graph2POS = get(handles.graph2,'Position');
scale12 = graph2POS(3)/graph1newPOS(3);
graph1XLim = get(handles.graph1,'XLim');
graph2XLim = [graph1XLim(2)-scale12*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];

set(handles.graph2,'XLim',graph2XLim);

blackline = findobj(handles.graph2,'Type','Line','color','k');
xdataBlackline = get(blackline,'XData');
ydataBlackline = get(blackline,'YData');

erasePart = find(xdataBlackline>graph2XLim(1) & xdataBlackline<graph1XLim(1));
xdataBlackline(erasePart) = [];
ydataBlackline(erasePart) = [];

set(blackline, 'xdata', xdataBlackline, 'ydata', ydataBlackline);
axis(handles.graph2,'auto y');

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns parameterlist2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterlist2


% --- Executes during object creation, after setting all properties.
function parameterlist2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterlist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in parameterlist3.
function parameterlist3_Callback(hObject, eventdata, handles)
% hObject    handle to parameterlist3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for modelIV
handles.output = hObject;

objLOG = LOGClass;
objLOG.draw2nd(hObject, eventdata, handles);

graph1newPOS = get(handles.graph1,'Position');
graph3POS = get(handles.graph3,'Position');
scale13 = graph3POS(3)/graph1newPOS(3);
graph1XLim = get(handles.graph1,'XLim');
graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];

set(handles.graph3,'XLim',graph3XLim);

blueline = findobj(handles.graph3,'Type','Line','color','b');
xdataBlueline = get(blueline,'XData');
ydataBlueline = get(blueline,'YData');

erasePart = find(xdataBlueline>graph3XLim(1) & xdataBlueline<graph1XLim(1));
xdataBlueline(erasePart) = [];
ydataBlueline(erasePart) = [];

set(blueline, 'xdata', xdataBlueline, 'ydata', ydataBlueline);
axis(handles.graph3,'auto y');

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns parameterlist3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterlist3


% --- Executes during object creation, after setting all properties.
function parameterlist3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterlist3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
