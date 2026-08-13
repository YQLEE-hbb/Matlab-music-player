function varargout = GUIxinhaofashengqi(varargin)
% GUIXINHAOFASHENGQI MATLAB code for GUIxinhaofashengqi.fig
%      GUIXINHAOFASHENGQI, by itself, creates a new GUIXINHAOFASHENGQI or raises the existing
%      singleton*.
%
%      H = GUIXINHAOFASHENGQI returns the handle to a new GUIXINHAOFASHENGQI or the handle to
%      the existing singleton*.
%
%      GUIXINHAOFASHENGQI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIXINHAOFASHENGQI.M with the given input arguments.
%
%      GUIXINHAOFASHENGQI('Property','Value',...) creates a new GUIXINHAOFASHENGQI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIxinhaofashengqi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIxinhaofashengqi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIxinhaofashengqi

% Last Modified by GUIDE v2.5 09-Jul-2025 10:41:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIxinhaofashengqi_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIxinhaofashengqi_OutputFcn, ...
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


% --- Executes just before GUIxinhaofashengqi is made visible.
function GUIxinhaofashengqi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIxinhaofashengqi (see VARARGIN)

% Choose default command line output for GUIxinhaofashengqi
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIxinhaofashengqi wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIxinhaofashengqi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str2double(get(handles.edit1,'String'));
f=str2double(get(handles.edit1,'String'));

fs=8000;
dt=1/fs;T=1;
t=0:dt:T;
y=sin(2*pi*f*t);
plot(t,y,'b');
axis([0,0.01,-1.1,1.1]);
sound(y,fs);
grid;

% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

f=get(handles.slider1,'Value') ;%从滑动条获取频率值
set(handles.edit1,'String',num2str(f));% 显示滑动条选择的频率值


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str2double(get(handles.edit1,'String'));
f = str2double(get(handles.edit1,'String'));
fs = 8000;
dt = 1/fs; T = 1;
t = 0:dt:T;
% 生成三角波信号（通过sawtooth函数设置width=0.5）
y = sawtooth(2*pi*f*t, 0.5);
plot(t,y,'b');
axis([0,0.01,-1.1,1.1]);
sound(y,fs);
grid;

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str2double(get(handles.edit1,'String'));
f = str2double(get(handles.edit1,'String'));
fs = 8000;
dt = 1/fs; T = 1;
t = 0:dt:T;
% 生成方波信号（默认占空比50%）
y = square(2*pi*f*t);
plot(t,y,'b');
axis([0,0.01,-1.1,1.1]);
sound(y,fs);
grid;

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fs = 8000;
dt = 1/fs; T = 1;
t = 0:dt:T;
% 生成白噪声信号（幅度缩放至[-0.5,0.5]）
y = 0.5 * randn(size(t));
plot(t,y,'b');
axis([0,0.01,-1.1,1.1]);
sound(y,fs);
grid;