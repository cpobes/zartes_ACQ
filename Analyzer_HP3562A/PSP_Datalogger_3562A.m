function varargout = PSP_Datalogger_3562A(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PSP_Datalogger_3562A_OpeningFcn, ...
                   'gui_OutputFcn',  @PSP_Datalogger_3562A_OutputFcn, ...
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


function PSP_Datalogger_3562A_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

set(handles.Clear_TAG,'Enable','off');
set(handles.Save_TAG,'Enable','off');
set(handles.SMS_TAG,'Visible','off');

set(gcf,'CurrentAxes',handles.Plot_TAG);

xlabel('Frequency, f (Hz)','fontsize',12);
ylabel('Output','fontsize',12);

hold on;

set(handles.Plot_TAG,'XGrid','on');
set(handles.Plot_TAG,'YGrid','on');

set(gca,'Box','on');

set(handles.XScale_TAG,'Enable','off');
set(handles.YScale_TAG,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PSP_Datalogger_3562A wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PSP_Datalogger_3562A_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in GetData_TAG.
function GetData_TAG_Callback(hObject, eventdata, handles)

global GPIB_Dev;

set(handles.Clear_TAG,'Enable','off');
set(handles.Save_TAG,'Enable','off');
set(handles.SMS_TAG,'Visible','on');

set(handles.XScale_TAG,'Enable','off');
set(handles.YScale_TAG,'Enable','off');

%set(handles.Dev_TAG,'Enable','off');

try
%[PSP] = PWR_SPECTRUM (GPIB_Dev);
[PSP(:,2),PSP(:,1)]=hp3562a(GPIB_Dev);
catch
    warning('Has seleccionado la direccion correcta?');
    PSP=[0 0];
end
lambda = size(PSP);
if(lambda(1,1) == 1)
    
    set(handles.Dev_TAG,'Enable','on');
    
else
    
    Results = fopen('C:\SICE_Programs\Analyzer_3562A\Results.txt','w');

    for h=1:lambda(1,1)
    
        fprintf(Results,'%e %e\n',PSP(h,1),PSP(h,2));
    
    end

    fclose(Results);

    set(gcf,'CurrentAxes',handles.Plot_TAG);

    plot(PSP(:,1),PSP(:,2));

    xlabel('Frequency, f (Hz)','fontsize',12);
    ylabel('Output','fontsize',12);

    hold on;

    set(handles.Plot_TAG,'XGrid','on');
    set(handles.Plot_TAG,'YGrid','on');

    set(gca,'Box','on');
    
    set(handles.XScale_TAG,'Enable','on');
    set(handles.YScale_TAG,'Enable','on');

    set(handles.Clear_TAG,'Enable','on');
    set(handles.Save_TAG,'Enable','on');

    set(handles.Dev_TAG,'Enable','off');
    
end

set(handles.SMS_TAG,'Visible','off');




% --- Executes on button press in Clear_TAG.
function Clear_TAG_Callback(hObject, eventdata, handles)

set(handles.XScale_TAG,'Value',1);
set(handles.YScale_TAG,'Value',1);

set(gcf,'CurrentAxes',handles.Plot_TAG);

hold off;
cla reset;

set(gca,'Box','on');
    
set(handles.Plot_TAG,'XGrid','on');
set(handles.Plot_TAG,'YGrid','on');
    
hold on;
    
xlabel('Frequency, f (Hz)','fontsize',12);
ylabel('Output','fontsize',12);


% --- Executes on button press in Save_TAG.
function Save_TAG_Callback(hObject, eventdata, handles)

[FileName,PathName] = uiputfile({'*.txt'},'Save Data As','C:\SICE_Programs\Analyzer_3562A\');%default file name: Results.txt

Destination = strcat(PathName,FileName);

copyfile('C:\SICE_Programs\Analyzer_3562A\Results.txt',Destination,'f');


% --- Executes on selection change in XScale_TAG.
function XScale_TAG_Callback(hObject, eventdata, handles)

set(gcf,'CurrentAxes',handles.Plot_TAG);

if(get(handles.XScale_TAG,'Value') == 1)
    
    set(handles.Plot_TAG,'XScale','linear');

else
    
    set(handles.Plot_TAG,'XScale','log');
    
end


% --- Executes during object creation, after setting all properties.
function XScale_TAG_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YScale_TAG.
function YScale_TAG_Callback(hObject, eventdata, handles)

set(gcf,'CurrentAxes',handles.Plot_TAG);

if(get(handles.YScale_TAG,'Value') == 1)
    
    set(handles.Plot_TAG,'YScale','linear');

else
    
    set(handles.Plot_TAG,'YScale','log');
    
end


% --- Executes during object creation, after setting all properties.
function YScale_TAG_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Dev_TAG.
function Dev_TAG_Callback(hObject, eventdata, handles)

global GPIB_Dev;

GPIB_Dev = get(handles.Dev_TAG,'Value');
GPIB_Dev = GPIB_Dev - 1;


% --- Executes during object creation, after setting all properties.
function Dev_TAG_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
