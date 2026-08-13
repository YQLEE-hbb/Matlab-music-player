function varargout = MusicPlayer(varargin)
% MUSICPLAYER MATLAB code for MusicPlayer.fig
%      MUSICPLAYER, by itself, creates a new MUSICPLAYER or raises the existing
%      singleton*.
%
%      H = MUSICPLAYER returns the handle to a new MUSICPLAYER or the handle to
%      the existing singleton*.
%
%      MUSICPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUSICPLAYER.M with the given input arguments.
%
%      MUSICPLAYER('Property','Value',...) creates a new MUSICPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MusicPlayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MusicPlayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MusicPlayer

% Last Modified by GUIDE v2.5 14-Jul-2025 15:49:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MusicPlayer_OpeningFcn, ...
                   'gui_OutputFcn',  @MusicPlayer_OutputFcn, ...
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


% --- Executes just before MusicPlayer is made visible.
function MusicPlayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MusicPlayer (see VARARGIN)
% 初始化倍速按钮文本
% 添加倍速按钮初始化
% Initialize reverb button if it exists
if isfield(handles, 'pushbutton11')
    set(handles.pushbutton11, 'String', 'Schroeder Reverb');
end
if isfield(handles, 'pushbutton12')
    set(handles.pushbutton12, 'String', 'Moorer Reverb');
end
if isfield(handles, 'pushbutton13')
    set(handles.pushbutton13, 'String', 'Gardner Reverb');
end

if isfield(handles, 'pushbutton8')
    set(handles.pushbutton8, 'String', '打开文件');
end

if isfield(handles, 'pushbutton5')
    set(handles.pushbutton5, 'String', '1x');
    set(handles.pushbutton6, 'String', '2x');
    set(handles.pushbutton7, 'String', '3x');
    % 设置默认1x按钮为选中状态
    set(handles.pushbutton5, 'FontWeight', 'bold');
    set(handles.pushbutton6, 'FontWeight', 'normal');
    set(handles.pushbutton7, 'FontWeight', 'normal');
end
handles.isPlaying = false;
handles.player = [];
handles.originalSampleRate = []; 
guidata(hObject, handles);

handles.output = hObject;
set_axes_background(handles.axes1, 'picture1.jpg', 0.6);
set_axes_background(handles.axes2, 'picture2.png', 1.0);
guidata(hObject, handles); 

handles.output = hObject;
% EQ 中心频率（Hz）
handles.EQ.centerFreqs = [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
% 初始化 EQ 增益（dB）
handles.EQ.gains = zeros(1, 9); % 初始值 0dB
% 初始化滑块
for i = 2:10
    sliderName = ['slider' num2str(i)];
    set(handles.(sliderName), 'Min', -12, 'Max', 12, 'Value', 0);
end
% 绘制初始 EQ 曲线
updateEQPlot(handles);
% 保存 handles
guidata(hObject, handles);


% 辅助函数：设置指定 axes 的背景图片并应用透明度
function set_axes_background(hAxes, image_path, alpha_value)
    try
        img = imread(image_path);
        set(hAxes, 'Color', 'none');         % 透明背景
        set(hAxes, 'XColor', 'none');        % 隐藏 X 轴
        set(hAxes, 'YColor', 'none');        % 隐藏 Y 轴
        set(hAxes, 'Box', 'off');            % 隐藏边框
        set(hAxes, 'YTick', []);             % 移除 Y 刻度
        set(hAxes, 'XTick', []);             % 移除 X 刻度
        alpha = ones(size(img, 1), size(img, 2)) * alpha_value;
        image(img, 'AlphaData', alpha, 'Parent', hAxes);
        set(hAxes, 'XColor', 'none', 'YColor', 'none'); 
        axis(hAxes, 'image'); 
        axis(hAxes, 'image'); % 保持图片比例
        uistack(hAxes, 'top');
    catch ME
        warning(['无法加载图片: ', image_path, '\n错误: ', ME.message]);
        set(hAxes, 'Color', [0.9 0.9 0.9]); % 设置灰色背景作为替代
    end

% --- Outputs from this function are returned to the command line.
function varargout = MusicPlayer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1
% 读取图片（确保图片文件在当前路径或MATLAB搜索路径中）
% 获取axes句柄（假设为handles.axes1）

% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes2

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton1.
f = 1000;
fs = 8000;
dt = 1/fs;
T = 10;
t = 0:dt:T;
y = sin(2*pi*f*t);
plot(t, y, 'b', 'Parent', handles.axes4, 'LineWidth', 2);
axis(handles.axes4, [0, 0.01, -1.1, 1.1]);  % 明确指定axes4的范围
grid(handles.axes4, 'on');  % 为axes4添加网格
handles.player = audioplayer(y, fs);
handles.player.UserData = y;  % 保存原始音频数据
handles.isPlaying = true;
guidata(hObject, handles); % 更新 handles
play(handles.player);

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes4

function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SCP=[...
    16.352,17.324,18.354,19.446,20.602,21.827,...
    23.125,24.500,25.957,27.501,29.136,30.868;...
    32.704,34.649,36.709,38.892,41.204,43.655,...
    46.250,49.001,51.914,55.001,58.272,61.737;...
    65.408,69.297,73.418,77.784,82.409,87.309,...
    92.501,98.001,103.829,110.003,116.544,123.474;...
    130.816,138.595,146.836,155.567,164.818,174.618,...
    185.002,196.002,207.657,220.005,233.087,246.947;...
    261.632,277.189,293.672,311.135,329.636,349.237,...
    370.003,392.005,415.315,440.010,466.175,493.895;...
    523.264,554.379,587.344,622.269,659.271,698.473,...
    740.007,784.010,830.629,880.021,932.350,987.790;...
    1046.528,1108.758,1174.688,1244.538,1318.542,1396.947,...
    1480.013,1568.019,1661.258,1760.042,1864.699,1975.580;...
    2093.056,2217.515,2349.376,2489.076,2637.084,2793.893,...
    2960.027,3136.039,3322.517,3520.084,3729.398,3951.160;...
    4186.112,4435.031,4698.751,4978.153,5274.169,5587.787,...
    5920.053,6272.077,6645.034,7040.168,7458.797,7902.319;...
    8372.224,8870.062,9397.502,9956.306,10548.337,11175.573,...
    11840.106,12544.155,13290.068,14080.335,14917.594,15804.639...
    ];
SCPT=SCP';
SCP_MAIN=SCP(:,[1,3,5,6,8,10,12]);
SCPT_MAIN=SCPT([1,3,5,6,8,10,12],:);
PIANO=SCPT(10:97);
PIANO_MAIN=SCPT_MAIN(6:57);
f=8000;
tune=[...
    3,5,4,3,4,5,3,1,3,5,4,6,5,2,0.5,3,5,4,3,4,5,...
    3,1,1,2,3,2,1,-1,-2,1,0.5,3,5,4,3,4,5,3,1,3,5,4,6,5,2,...
    0.5,3,5,4,3,4,5,1,6,5,4,3,2,1,-1,-2,1,0.5,8,7,8,8,7,6,4,5,3,...
    2,1,2,3,6,4,3,4,5,8,7,8,8,7,6,4,5,6,7,5,8,9,7,5,8,...
    0.5];
rhythm=[...
    8.5,4,4,4,4,8,4,12,8,4,4,4,4,12,12,8,4,4,4,4,8,4,...
    8,2,2,4,4,4,8,4,12,12,8,4,4,4,4,8,4,12,8,4,4,4,4,12,12,...
    8,4,4,4,4,8,4,4,4,4,4,4,4,8,4,12,8,2,2,8,2,2,8,4,10,2,8,2,...
    2,8,4,4,4,4,20,2,2,8,2,2,8,4,10,2,8,4,8,2,2,8,4,20,4];
D_L=0+7 * 4;      %此曲为D大调
ftune=tune;     %音调转化为频率
for i=1:length(ftune)
    if mod(tune(i),1)==0
        ftune(i)=SCPT_MAIN(D_L+ftune(i));
    else
        ftune(i)=0;
    end
end
l=sum(rhythm);
speed=100;      %曲速（每分钟speed拍）
t0=60/speed/4;  %16分音符占t0秒
music=zeros(1,f*l*t0+5*f-1);
position=1;
n=1:length(music);
t=n/f;
for i=1:length(ftune)
    if mod(tune(i),1)~=0                 %休止符：音量同步衰减一半
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)*0.5;
    elseif mod(rhythm(i),1)~=0           %延音符号开始：a=0.01,b=2，衰减变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+0.8*mypiano(8000,ftune(i),0.01,2);
    elseif i~=0 && mod(rhythm(i-1),1)~=0 %延音符号之中：a=0.05,b=3，开始变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+0.4*mypiano(8000,ftune(i),0.05,3);
    elseif rhythm(i)>=8                  %较长音符（此为全音符），a=0.01,b=1.5，衰减变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+mypiano(8000,ftune(i),0.01,1.5); 
    else
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+mypiano(8000,ftune(i),0.01,3); 
    end
    position=position+rhythm(i)*t0*f+1;
end
music=0.75*music/max(music);    %音量调节
handles.player = audioplayer(music, f);
handles.player.UserData = music;  % 保存原始音频数据
handles.isPlaying = true;
guidata(hObject, handles); % 更新 handles
play(handles.player);
display_length = min(4*f, length(music));  % 最多显示2秒
music_display = music(1:display_length);
t_display = t(1:display_length);  % 对应时间向量
plot(t_display, music_display, 'b', 'Parent', handles.axes4);  % 指定axes4为父对象
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);  % 设置坐标范围（适配显示的波形）
grid(handles.axes4, 'on');  % 显示网格
title(handles.axes4, '音乐波形');  % 可选：添加标题
xlabel(handles.axes4, '时间 (s)');  % 可选：x轴标签
ylabel(handles.axes4, '振幅');  % 可选：y轴标签


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 检查是否有有效的播放器对象
if ~isfield(handles, 'player') || isempty(handles.player) || ~isvalid(handles.player)
    msgbox('没有正在播放的音频');
    return;
end
if handles.isPlaying  % 当前正在播放 → 暂停
    pause(handles.player);
    handles.isPlaying = false;
    set(hObject, 'String', '继续播放');  % 更新按钮文字
else  % 当前已暂停 → 继续
    resume(handles.player);
    handles.isPlaying = true;
    set(hObject, 'String', '暂停');  % 更新按钮文字
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles) %天空之城
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SCP=[...
    16.352,17.324,18.354,19.446,20.602,21.827,...
    23.125,24.500,25.957,27.501,29.136,30.868;...
    32.704,34.649,36.709,38.892,41.204,43.655,...
    46.250,49.001,51.914,55.001,58.272,61.737;...
    65.408,69.297,73.418,77.784,82.409,87.309,...
    92.501,98.001,103.829,110.003,116.544,123.474;...
    130.816,138.595,146.836,155.567,164.818,174.618,...
    185.002,196.002,207.657,220.005,233.087,246.947;...
    261.632,277.189,293.672,311.135,329.636,349.237,...
    370.003,392.005,415.315,440.010,466.175,493.895;...
    523.264,554.379,587.344,622.269,659.271,698.473,...
    740.007,784.010,830.629,880.021,932.350,987.790;...
    1046.528,1108.758,1174.688,1244.538,1318.542,1396.947,...
    1480.013,1568.019,1661.258,1760.042,1864.699,1975.580;...
    2093.056,2217.515,2349.376,2489.076,2637.084,2793.893,...
    2960.027,3136.039,3322.517,3520.084,3729.398,3951.160;...
    4186.112,4435.031,4698.751,4978.153,5274.169,5587.787,...
    5920.053,6272.077,6645.034,7040.168,7458.797,7902.319;...
    8372.224,8870.062,9397.502,9956.306,10548.337,11175.573,...
    11840.106,12544.155,13290.068,14080.335,14917.594,15804.639...
    ];
SCPT=SCP';
SCP_MAIN=SCP(:,[1,3,5,6,8,10,12]);
SCPT_MAIN=SCPT([1,3,5,6,8,10,12],:);
PIANO=SCPT(10:97);
PIANO_MAIN=SCPT_MAIN(6:57);
f=8000;
tune=[...
    6,7,8,7,8,10,7,3,3,6,5,6,8,5,0.5,3,3,4,3,4,8,...
    3,0.5,8,8,8,7,4,4,7,7,0.5,6,7,8,7,8,10,7,0.5,3,3,6,5,6,8,...
    5,0.5,3,4,8,7,7,8,9,9,10,8,0.5,8,7,6,6,7,5,6,0.5,8,9,10,9,10,12,...
    9,0.5,5,5,8,7,8,10,10,0.5,0.5,6,7,8,7,9,9,8,5,5,0.5,11,10,9,8,...
    10,10,0.5,10,13,12,12,10,9,8,0.5,8,9,8,9,9,12,10,0.5,10,...
    13,12,10,9,8,0.5,8,9,8,9,9,7,6,0.5,6,7,6];
rhythm=[...
    2.5,2,6.5,2,4,4,12,2,2,6.5,2,4,4,8,4,2,2,6.5,2,2.5,3,...
    8,2,2,2,2,6.5,2,4.5,4,8,4,2.5,2,6.5,2,4,4,8,4,2,2,6.5,2,4,4,...
    12,2,2,4,2.5,2.5,4,4,2,2,2,4,4,4.5,2,2,2,4,4,8,4,2,2,6.5,2,4,4,...
    8,4,2,2,2.5,2,4,4,8,4,4,2.5,2,4,4,2,2,6.5,2.5,4,4,4,4,4,4,...
    16.5,8,4,4,8,4,4,2,2,4,2,2,4,2.5,2.5,2,4,8,4,4,...
    8,8,2.5,2,8,2,2,2,2,2.5,2,4,8,4,2.5,2,16];
D_L=0+7 * 4;      %此曲为D大调
ftune=tune;     %音调转化为频率
for i=1:length(ftune)
    if mod(tune(i),1)==0
        ftune(i)=SCPT_MAIN(D_L+ftune(i));
    else
        ftune(i)=0;
    end
end
l=sum(rhythm);
speed=100;      %曲速（每分钟speed拍）
t0=60/speed/4;  %16分音符占t0秒
music=zeros(1,f*l*t0+5*f-1);
position=1;
n=1:length(music);
t=n/f;
for i=1:length(ftune)
    if mod(tune(i),1)~=0                 %休止符：音量同步衰减一半
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)*0.5;
    elseif mod(rhythm(i),1)~=0           %延音符号开始：a=0.01,b=2，衰减变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+0.8*mypiano(8000,ftune(i),0.01,2);
    elseif i~=0 && mod(rhythm(i-1),1)~=0 %延音符号之中：a=0.05,b=3，开始变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+0.4*mypiano(8000,ftune(i),0.05,3);
    elseif rhythm(i)>=8                  %较长音符（此为全音符），a=0.01,b=1.5，衰减变慢
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+mypiano(8000,ftune(i),0.01,1.5); 
    else
        music(position:position+3*f-1)=...
            music(position:position+3*f-1)+mypiano(8000,ftune(i),0.01,3); 
    end
    position=position+rhythm(i)*t0*f+1;
end
music=0.75*music/max(music);    %音量调节
handles.player = audioplayer(music, f);
handles.player.UserData = music;  % 保存原始音频数据
handles.isPlaying = true;
guidata(hObject, handles); % 更新 handles
play(handles.player);
display_length = min(4*f, length(music));  % 最多显示2秒
music_display = music(1:display_length);
t_display = t(1:display_length);  % 对应时间向量
plot(t_display, music_display, 'b', 'Parent', handles.axes4);  % 指定axes4为父对象
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);  % 设置坐标范围（适配显示的波形）
grid(handles.axes4, 'on');  % 显示网格
title(handles.axes4, '音乐波形');  % 可选：添加标题
xlabel(handles.axes4, '时间 (s)');  % 可选：x轴标签
ylabel(handles.axes4, '振幅');  % 可选：y轴标签

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% 检查是否有有效的播放器对象
if ~isfield(handles, 'player') || isempty(handles.player) || ~isvalid(handles.player)
    msgbox('没有正在播放的音频');
    return;
end
if isempty(handles.originalSampleRate)
    handles.originalSampleRate = handles.player.SampleRate;
end
if handles.player.SampleRate == handles.originalSampleRate
    return;
end
if handles.isPlaying
    currentPosition = handles.player.CurrentSample;
else
    currentPosition = 1;
end

% 设置为1x速度
stop(handles.player);
handles.player = audioplayer(handles.player.UserData, handles.originalSampleRate);

% 恢复播放状态
if handles.isPlaying
    play(handles.player, currentPosition);
end

% 更新按钮状态
set(handles.pushbutton5, 'FontWeight', 'bold');
set(handles.pushbutton6, 'FontWeight', 'normal');
set(handles.pushbutton7, 'FontWeight', 'normal');

guidata(hObject, handles);

% --- 2x倍速按钮回调 ---
function pushbutton6_Callback(hObject, eventdata, handles)
% 检查是否有有效的播放器对象
if ~isfield(handles, 'player') || isempty(handles.player) || ~isvalid(handles.player)
    msgbox('没有正在播放的音频');
    return;
end

% 确保有原始采样率记录
if isempty(handles.originalSampleRate)
    handles.originalSampleRate = handles.player.SampleRate;
end

% 如果已经是2x速度则不做任何操作
if handles.player.SampleRate == 2 * handles.originalSampleRate
    return;
end

% 保存当前播放位置
if handles.isPlaying
    currentPosition = handles.player.CurrentSample;
else
    currentPosition = 1;
end

% 设置为2x速度
stop(handles.player);
handles.player = audioplayer(handles.player.UserData, 2 * handles.originalSampleRate);

% 恢复播放状态
if handles.isPlaying
    play(handles.player, currentPosition);
end

% 更新按钮状态
set(handles.pushbutton5, 'FontWeight', 'normal');
set(handles.pushbutton6, 'FontWeight', 'bold');
set(handles.pushbutton7, 'FontWeight', 'normal');

guidata(hObject, handles);

% --- 3x倍速按钮回调 ---
function pushbutton7_Callback(hObject, eventdata, handles)
% 检查是否有有效的播放器对象
if ~isfield(handles, 'player') || isempty(handles.player) || ~isvalid(handles.player)
    msgbox('没有正在播放的音频');
    return;
end

% 确保有原始采样率记录
if isempty(handles.originalSampleRate)
    handles.originalSampleRate = handles.player.SampleRate;
end

% 如果已经是3x速度则不做任何操作
if handles.player.SampleRate == 3 * handles.originalSampleRate
    return;
end

% 保存当前播放位置
if handles.isPlaying
    currentPosition = handles.player.CurrentSample;
else
    currentPosition = 1;
end
% 设置为3x速度
stop(handles.player);
handles.player = audioplayer(handles.player.UserData, 3 * handles.originalSampleRate);
% 恢复播放状态
if handles.isPlaying
    play(handles.player, currentPosition);
end

% 更新按钮状态
set(handles.pushbutton5, 'FontWeight', 'normal');
set(handles.pushbutton6, 'FontWeight', 'normal');
set(handles.pushbutton7, 'FontWeight', 'bold');
guidata(hObject, handles);


function pushbutton8_Callback(hObject, eventdata, handles)
if isfield(handles, 'player') && ~isempty(handles.player)
    try
        stop(handles.player);
    catch
        % 如果停止失败，忽略错误
    end
end
[filename, pathname] = uigetfile({'*.mp3;*.wav;*.ogg', '音频文件 (*.mp3, *.wav, *.ogg)'}, ...
                                '选择音频文件');
if isequal(filename, 0)
    msgbox('没有选择文件');
    return;
end
fullpath = fullfile(pathname, filename);
try
    [y, fs] = audioread(fullpath);
    if size(y, 2) == 2
        y = mean(y, 2);
    end
    display_samples = min(length(y), 2*fs);
    t = (0:display_samples-1)/fs;
    y_display = y(1:display_samples);
    cla(handles.axes4); % 清除原有图形
    plot(handles.axes4, t, y_display, 'b', 'LineWidth', 0.5);
    axis(handles.axes4, [0 t(end) -1.1 1.1]);
    grid(handles.axes4, 'on');
    title(handles.axes4, ['波形: ' filename], 'Interpreter', 'none');
    xlabel(handles.axes4, '时间 (s)');
    ylabel(handles.axes4, '振幅');
    handles.player = audioplayer(y, fs);
    handles.player.UserData = y;  % 保存音频数据
    handles.originalSampleRate = fs; % 保存原始采样率
    handles.isPlaying = false;
    set(handles.pushbutton5, 'FontWeight', 'bold');
    set(handles.pushbutton6, 'FontWeight', 'normal');
    set(handles.pushbutton7, 'FontWeight', 'normal');
    set(handles.pushbutton1, 'Enable', 'on');
    set(handles.pushbutton3, 'Enable', 'on');
    guidata(hObject, handles);
    
catch ME
    msgbox(['无法读取文件: ' ME.message]);
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles) %Overtrue
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
note_freqs = [293.66, 329.63, 369.99, 392.00, 440.00, 493.88, 554.37]; 
tune=[...
    3,5,4,3,4,5,3,1,3,5,4,6,5,2,0.5,3,5,4,3,4,5,...
    3,1,1,2,3,2,1,-1,-2,1,0.5,3,5,4,3,4,5,3,1,3,5,4,6,5,2,...
    0.5,3,5,4,3,4,5,1,6,5,4,3,2,1,-1,-2,1,0.5,8,7,8,8,7,6,4,5,3,...
    2,1,2,3,6,4,3,4,5,8,7,8,8,7,6,4,5,6,7,5,8,9,7,5,8,...
    0.5];
rhythm=[...
    8.5,4,4,4,4,8,4,12,8,4,4,4,4,12,12,8,4,4,4,4,8,4,...
    8,2,2,4,4,4,8,4,12,12,8,4,4,4,4,8,4,12,8,4,4,4,4,12,12,...
    8,4,4,4,4,8,4,4,4,4,4,4,4,8,4,12,8,2,2,8,2,2,8,4,10,2,8,2,...
    2,8,4,4,4,4,20,2,2,8,2,2,8,4,10,2,8,4,8,2,2,8,4,20,4];
fs = 8000; % 采样率
speed = 100; % 曲速 (拍/分钟)
t0 = 60/speed/4; % 16分音符时长(秒)
music = [];
for i = 1:length(tune)
    if tune(i) == 0.5 % 休止符
        dur = rhythm(i) * t0;
        silence = zeros(1, round(dur * fs));
        music = [music, silence];
    else
        % 计算频率和时长
        note_idx = mod(tune(i)-1, 7) + 1; % 音符循环 (1-7)
        octave = floor((tune(i)-1)/7); % 八度
        freq = note_freqs(note_idx) * (2^octave);
        dur = rhythm(i) * t0;
        
        % 生成纯正弦波
        t = 0:1/fs:dur-1/fs;
        tone = sin(2*pi*freq*t);
        
        % 简单淡出避免爆音
        fade_samples = min(round(0.05*fs), length(tone));
        tone(end-fade_samples+1:end) = tone(end-fade_samples+1:end) .* linspace(1,0,fade_samples);
        
        music = [music, tone];
    end
end
music=0.75*music/max(music);    %音量调节
handles.player = audioplayer(music, fs);
handles.player.UserData = music;  % 保存原始音频数据
handles.isPlaying = true;
guidata(hObject, handles); % 更新 handles
play(handles.player);
f=1000;
display_length = min(4*f, length(music));  % 最多显示2秒
music_display = music(1:display_length);
t_display = t(1:display_length);  % 对应时间向量
plot(t_display, music_display, 'b', 'Parent', handles.axes4);  % 指定axes4为父对象
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);  % 设置坐标范围（适配显示的波形）
grid(handles.axes4, 'on');  % 显示网格
title(handles.axes4, '音乐波形');  % 可选：添加标题
xlabel(handles.axes4, '时间 (s)');  % 可选：x轴标签
ylabel(handles.axes4, '振幅');  % 可选：y轴标签


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles) %SkyCity
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
note_freqs = [293.66, 329.63, 369.99, 392.00, 440.00, 493.88, 554.37]; 
tune = [6,7,8,7,8,10,7,3,3,6,5,6,8,5,0.5,3,3,4,3,4,8,...
        3,0.5,8,8,8,7,4,4,7,7,0.5,6,7,8,7,8,10,7,0.5,3,3,6,5,6,8,...
        5,0.5,3,4,8,7,7,8,9,9,10,8,0.5,8,7,6,6,7,5,6,0.5,8,9,10,9,10,12,...
        9,0.5,5,5,8,7,8,10,10,0.5,0.5,6,7,8,7,9,9,8,5,5,0.5,11,10,9,8,...
        10,10,0.5,10,13,12,12,10,9,8,0.5,8,9,8,9,9,12,10,0.5,10,...
        13,12,10,9,8,0.5,8,9,8,9,9,7,6,0.5,6,7,6];
rhythm = [2.5,2,6.5,2,4,4,12,2,2,6.5,2,4,4,8,4,2,2,6.5,2,2.5,3,...
          8,2,2,2,2,6.5,2,4.5,4,8,4,2.5,2,6.5,2,4,4,8,4,2,2,6.5,2,4,4,...
          12,2,2,4,2.5,2.5,4,4,2,2,2,4,4,4.5,2,2,2,4,4,8,4,2,2,6.5,2,4,4,...
          8,4,2,2,2.5,2,4,4,8,4,4,2.5,2,4,4,2,2,6.5,2.5,4,4,4,4,4,4,...
          16.5,8,4,4,8,4,4,2,2,4,2,2,4,2.5,2.5,2,4,8,4,4,...
          8,8,2.5,2,8,2,2,2,2,2.5,2,4,8,4,2.5,2,16];
fs = 8000; % 采样率
speed = 100; % 曲速 (拍/分钟)
t0 = 60/speed/4; % 16分音符时长(秒)
music = [];
for i = 1:length(tune)
    if tune(i) == 0.5 % 休止符
        dur = rhythm(i) * t0;
        silence = zeros(1, round(dur * fs));
        music = [music, silence];
    else
        note_idx = mod(tune(i)-1, 7) + 1; % 音符循环 (1-7)
        octave = floor((tune(i)-1)/7); % 八度
        freq = note_freqs(note_idx) * (2^octave);
        dur = rhythm(i) * t0;
        t = 0:1/fs:dur-1/fs;
        tone = sin(2*pi*freq*t);
        fade_samples = min(round(0.05*fs), length(tone));
        tone(end-fade_samples+1:end) = tone(end-fade_samples+1:end) .* linspace(1,0,fade_samples);
        music = [music, tone];
    end
end
music=0.75*music/max(music);    %音量调节
handles.player = audioplayer(music, fs);
handles.player.UserData = music;  % 保存原始音频数据
handles.isPlaying = true;
guidata(hObject, handles); % 更新 handles
play(handles.player);
f=4000;
display_length = min(4*f, length(music));  % 最多显示2秒
music_display = music(1:display_length);
t_display = t(1:display_length);  % 对应时间向量
plot(t_display, music_display, 'b', 'Parent', handles.axes4);  % 指定axes4为父对象
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);  % 设置坐标范围（适配显示的波形）
grid(handles.axes4, 'on');  % 显示网格
title(handles.axes4, '音乐波形');  % 可选：添加标题
xlabel(handles.axes4, '时间 (s)');  % 可选：x轴标签
ylabel(handles.axes4, '振幅');  % 可选：y轴标签


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles) %Schroeder 
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles, 'player') || isempty(handles.player) || isempty(handles.player.UserData)
    msgbox('No audio data available. Please load or play a song first.');
    return;
end
prompt = {'Reverb Time (seconds):', 'Delay (milliseconds):'};
dlgtitle = 'Schroeder Reverb Parameters';
dims = [1 35];
definput = {'1', '40'};
answer = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(answer)
    return; % User cancelled
end

% Parse parameters
Tr = str2double(answer{1}); % Reverb time in seconds
delay = str2double(answer{2}); % Delay in milliseconds

% Get current audio data
original_audio = handles.player.UserData;
fs = handles.player.SampleRate;

% Apply Schroeder reverb
audio_with_reverb = apply_schroeder_reverb(original_audio, fs, Tr, delay);

% Normalize the audio to prevent clipping
audio_with_reverb = 0.99 * audio_with_reverb / max(abs(audio_with_reverb));

% Create new player with reverb effect
handles.player = audioplayer(audio_with_reverb, fs);
handles.player.UserData = audio_with_reverb; % Save the processed audio

% Update display
display_length = min(4*fs, length(audio_with_reverb));
audio_display = audio_with_reverb(1:display_length);
t_display = (0:display_length-1)/fs;
plot(t_display, audio_display, 'b', 'Parent', handles.axes4);
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);
grid(handles.axes4, 'on');
title(handles.axes4, 'Audio with Schroeder Reverb');
% Play the processed audio if currently playing
if handles.isPlaying
    play(handles.player);
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles) %Moorer
% Check if there's audio data available
if ~isfield(handles, 'player') || isempty(handles.player) || isempty(handles.player.UserData)
    msgbox('No audio data available. Please load or play a song first.');
    return;
end
original_audio = handles.player.UserData;
fs = handles.player.SampleRate;
audio_with_reverb = apply_moorer_reverb(original_audio, fs);
audio_with_reverb = 0.99 * audio_with_reverb / max(abs(audio_with_reverb));
handles.player = audioplayer(audio_with_reverb, fs);
handles.player.UserData = audio_with_reverb; % Save the processed audio
display_length = min(4*fs, length(audio_with_reverb));
audio_display = audio_with_reverb(1:display_length);
t_display = (0:display_length-1)/fs;
plot(t_display, audio_display, 'b', 'Parent', handles.axes4);
axis(handles.axes4, [0, t_display(end), -1.1, 1.1]);
grid(handles.axes4, 'on');
title(handles.axes4, 'Audio with Moorer Reverb');
if handles.isPlaying
    play(handles.player);
end
guidata(hObject, handles);

function y_moorer = apply_moorer_reverb(x, fs)
% APPLY_MOORER_REVERB Apply Moorer reverb effect to audio signal
%   x: input audio signal
%   fs: sample rate

% FIR滤波器参数(早期反射)
fir_delays = [0, 4.3, 21.5, 22.5, 26.8, 27.0, 29.8, 45.8, 48.5, 57.2, 58.7, 59.5, 61.2, 70.7, 70.8, 72.6, 74.1, 75.3, 79.7]; % ms
fir_gains = [1.000, 0.841, 0.504, 0.491, 0.379, 0.380, 0.346, 0.289, 0.272, 0.192, 0.193, 0.217, 0.181, 0.180, 0.181, 0.176, 0.142, 0.167, 0.134];

% 转换为采样点数
fir_delays_samples = round(fir_delays * fs / 1000);

% 创建FIR滤波器
max_delay = max(fir_delays_samples);
fir_output = zeros(size(x));
for i = 1:length(fir_delays_samples)
    delay = fir_delays_samples(i);
    gain = fir_gains(i);
    if delay == 0
        fir_output = fir_output + gain * x;
    else
        fir_output(delay+1:end) = fir_output(delay+1:end) + gain * x(1:end-delay);
    end
end

% 低通梳状滤波器参数(后期混响)
lpcf_params = [
    50, 0.077, 0.698;
    57, 0.090, 0.688;
    61, 0.095, 0.684;
    69, 0.100, 0.680;
    73, 0.105, 0.677;
    79, 0.110, 0.673
];

% 创建6个低通梳状滤波器
lpcf_output = zeros(size(x));
for i = 1:size(lpcf_params,1)
    D = round(lpcf_params(i,1) * fs / 1000); % 延迟点数
    g = lpcf_params(i,2); % 低通滤波器增益
    a = lpcf_params(i,3); % 衰减系数
    
    % 一阶低通滤波器
    [b_lpf, a_lpf] = butter(1, g);
    
    % 低通梳状滤波器处理
    y_lpcf = filter(1, [1 zeros(1,D-1) -a*b_lpf(1)], fir_output);
    y_lpcf = filter(b_lpf, a_lpf, y_lpcf);
    
    lpcf_output = lpcf_output + y_lpcf;
end

% 全通滤波器处理(混响密度增强)
apf_g = 0.7;
apf_m = round(6 * fs / 1000); % 6ms延迟
num_apf = [zeros(1,apf_m) 1];
den_apf = [1 zeros(1,apf_m-1) -apf_g];
y_apf = filter(num_apf, den_apf, lpcf_output);
% 最终延迟处理
final_delay = round(23.7 * fs / 1000); % 23.7ms延迟
k = 0.756; % 衰减因子
y_final = zeros(size(y_apf));
y_final(final_delay+1:end) = k * y_apf(1:end-final_delay);
% 混合干湿信号
dry = 0.6; % 干声比例
wet = 0.4; % 湿声比例
y_moorer = dry * x + wet * y_final;
% Normalize output
y_moorer = y_moorer / max(abs(y_moorer));

function pushbutton13_Callback(hObject, eventdata, handles)
    % 检查音频数据
    if ~isfield(handles, 'player') || isempty(handles.player) || isempty(handles.player.UserData)
        msgbox('请先加载或播放音频','提示','error');
        return;
    end
    
    % 创建参数对话框
    prompt = {'房间类型 (small/medium/large):', '增益系数:'};
    dlgtitle = 'Gardner混响参数';
    
    % 根据房间类型设置默认增益
    room_types = {'small', 'medium', 'large'};
    default_gains = {'0.3', '0.45', '0.6'};
    
    [indx, tf] = listdlg('ListString', room_types, ...
                        'SelectionMode', 'single', ...
                        'Name', '选择房间类型', ...
                        'PromptString', '请选择房间类型:');
    
    if ~tf
        return; % 用户取消
    end
    
    selected_type = room_types{indx};
    gain = str2double(inputdlg(['输入增益系数 (建议: ' default_gains{indx} ')'], ...
                              '增益设置', 1, {default_gains{indx}}));
    
    if isnan(gain)
        return; % 用户取消
    end
    
    % 应用混响
    try
        audio_with_reverb = apply_gardner_reverb(handles.player.UserData, ...
                                               handles.player.SampleRate, ...
                                               selected_type, gain);
        
        % 混合干湿信号(根据房间类型调整比例)
        switch selected_type
            case 'small'
                mix_ratio = 0.7; % 70%干声
            case 'medium'
                mix_ratio = 0.6;
            case 'large'
                mix_ratio = 0.5;
        end
        
        processed_audio = mix_ratio*handles.player.UserData + (1-mix_ratio)*audio_with_reverb;
        processed_audio = 0.99 * processed_audio / max(abs(processed_audio));
        
        % 更新播放器
        handles.player = audioplayer(processed_audio, handles.player.SampleRate);
        handles.player.UserData = processed_audio;
        
        % 更新显示
        update_waveform_display(handles, processed_audio, selected_type);
        
        % 保持播放状态
        if handles.isPlaying
            play(handles.player);
        end
        
    catch ME
        msgbox(sprintf('处理出错: %s', ME.message), '错误', 'error');
    end
    
    guidata(hObject, handles);

function update_waveform_display(handles, audio, room_type)
    fs = handles.player.SampleRate;
    display_length = min(4*fs, length(audio));
    t = (0:display_length-1)/fs;
    
    plot(handles.axes4, t, audio(1:display_length));
    axis(handles.axes4, [0 t(end) -1.1 1.1]);
    
    % 根据房间类型设置不同颜色
    switch lower(room_type)
        case 'small'
            color = [0 0.5 0]; % 绿色
            title_str = '小厅混响效果';
        case 'medium'
            color = [0.85 0.33 0.1]; % 橙色
            title_str = '中厅混响效果';
        case 'large'
            color = [0.5 0 0]; % 红色
            title_str = '大厅混响效果';
    end
    
    set(findobj(handles.axes4, 'Type', 'line'), 'Color', color);
    title(handles.axes4, title_str);
    grid(handles.axes4, 'on');


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    gain = get(hObject, 'Value');
    handles.EQ.gains(1) = gain; % 更新62Hz的增益
    updateEQPlot(handles);
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(2) = gain; % 更新 62Hz 的增益
   
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(3) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(4) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(5) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(6) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(7) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(8) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
  % 获取滑块值
    gain = get(hObject, 'Value');
    handles.EQ.gains(9) = gain; % 更新 62Hz 的增益
    
    % 更新 EQ 曲线
    updateEQPlot(handles);
    
    % 保存 handles
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateEQPlot(handles)
    freqs = handles.EQ.centerFreqs;
    gains = handles.EQ.gains;
    % 清除原有图形并绘制新曲线
    cla(handles.axes5);
    plot(handles.axes5, freqs, gains, 'b-o', 'LineWidth', 2);
    % 设置坐标轴
    set(handles.axes5, 'XScale', 'log', 'XGrid', 'on', 'YGrid', 'on');
    xlim(handles.axes5, [20 20000]);
    ylim(handles.axes5, [-12 12]);
    xlabel(handles.axes5, '频率 (Hz)');
    ylabel(handles.axes5, '增益 (dB)');
    title(handles.axes5, 'EQ调节');

function pushbutton14_Callback(hObject, eventdata, handles)
    % 检查是否有音频数据
    if ~isfield(handles, 'player') || isempty(handles.player) || isempty(handles.player.UserData)
        msgbox('请先加载音频文件');
        return;
    end
    
    % 保存当前播放状态和位置
    wasPlaying = handles.isPlaying;
    if wasPlaying
        currentPosition = handles.player.CurrentSample;
        stop(handles.player);
    else
        currentPosition = 1;
    end
    
    % 获取原始音频数据并确保是列向量
    originalAudio = handles.player.UserData(:); % 强制转换为列向量
    fs = handles.player.SampleRate;
    
    % 检查信号长度是否足够
    if length(originalAudio) < 128
        msgbox('音频信号太短，无法应用EQ效果', '警告', 'warn');
        return;
    end
    
    % 设计9段滤波器组（修正：仅处理有效频段）
    centerFreqs = [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
    validFreqs = centerFreqs(centerFreqs < fs/2); % 仅保留低于奈奎斯特频率的中心频率
    validGains = handles.EQ.gains(centerFreqs < fs/2);
    numBands = length(validFreqs);
    
    % 创建与原始音频相同大小的处理后信号
    processedAudio = zeros(size(originalAudio));
    
    % 为每个有效频段应用滤波
    for i = 1:numBands
        % 计算上下截止频率（修正：确保频率范围合理）
        cf = validFreqs(i);
        lowFreq = max(cf/sqrt(2), 20);  % 最低20Hz
        highFreq = min(cf*sqrt(2), fs/2*0.99);  % 最高接近奈奎斯特频率
        
        % 确保lowFreq < highFreq
        if lowFreq >= highFreq
            lowFreq = highFreq * 0.9;
        end
        
        % 归一化频率到[0,1]范围
        Wn = [lowFreq highFreq]/(fs/2);
        Wn(1) = max(Wn(1), 0.001);  % 防止频率过低
        Wn(2) = min(Wn(2), 0.999);  % 防止频率过高
        
        try
            % 设计带通滤波器（降低阶数提高稳定性）
            [b, a] = butter(2, Wn, 'bandpass');
            
            % 应用滤波和增益
            gainLinear = 10^(validGains(i)/20);
            filteredBand = filter(b, a, originalAudio) * gainLinear;
            
            % 累加处理后的频段到总信号
            processedAudio = processedAudio + filteredBand;
        catch ME
            warning('无法设计第%d段滤波器: %s', i, ME.message);
        end
    end
    
    % 检查并处理NaN/Inf
    processedAudio(isnan(processedAudio)) = 0;
    processedAudio(isinf(processedAudio)) = 0;
    
    % 归一化防止削波
    maxVal = max(abs(processedAudio));
    if maxVal > 0
        processedAudio = 0.99 * processedAudio / maxVal;
    end
    
    % 混合干湿信号（修正：确保维度匹配）
    if size(processedAudio, 1) == size(originalAudio, 1)
        dryWetRatio = 0.7;
        finalAudio = dryWetRatio*originalAudio + (1-dryWetRatio)*processedAudio;
    else
        % 如果维度不匹配，使用处理后的音频（可能有问题，但避免崩溃）
        warning('EQ处理后信号维度与原始信号不匹配，使用处理后的信号');
        finalAudio = processedAudio;
    end
    
    % 再次归一化
    maxVal = max(abs(finalAudio));
    if maxVal > 0
        finalAudio = 0.99 * finalAudio / maxVal;
    end
    
    % 更新播放器数据
    handles.player = audioplayer(finalAudio, fs);
    handles.player.UserData = finalAudio;
    
    % 显示频谱对比
    if length(finalAudio) > 128
        show_spectrum_comparison(handles, originalAudio, finalAudio, fs);
    end
    
    % 恢复播放状态
    if wasPlaying
        play(handles.player, currentPosition);
        handles.isPlaying = true;
    else
        handles.isPlaying = false;
    end
    
    % 更新波形显示
    display_length = min(4*fs, length(finalAudio));
    t_display = (0:display_length-1)/fs;
    plot(handles.axes4, t_display, finalAudio(1:display_length), 'b');
    axis(handles.axes4, [0 t_display(end) -1.1 1.1]);
    
    % 保存handles
    guidata(hObject, handles);

function show_spectrum_comparison(handles, original, processed, fs)
% 计算频谱
nfft = min(8192, length(original));
[P1_orig, f_orig] = compute_spectrum(original, fs, nfft);
[P1_proc, f_proc] = compute_spectrum(processed, fs, nfft);
% 绘制频谱
plot(handles.axes5, f_orig, 20*log10(abs(P1_orig)), 'b', 'LineWidth', 1);
hold(handles.axes5, 'on');
plot(handles.axes5, f_proc, 20*log10(abs(P1_proc)), 'r', 'LineWidth', 1);
hold(handles.axes5, 'off');
set(handles.axes5, 'XScale', 'log');
xlim(handles.axes5, [20 fs/2]);
ylim(handles.axes5, [-60 0]);
grid(handles.axes5, 'on');
xlabel(handles.axes5, '频率 (Hz)');
ylabel(handles.axes5, '幅度 (dB)');
legend(handles.axes5, '原始', '处理后', 'Location', 'southwest');
title(handles.axes5, '频谱对比');

function [P1, f] = compute_spectrum(signal, fs, nfft)
    signal = signal(:);  % 确保列向量
    if all(signal == 0)  % 信号全零时返回空
        P1 = [];
        f = [];
        return;
    end
    nfft = min(nfft, length(signal));
    nfft = max(nfft, 256);  % 确保FFT点数至少256（提高稳定性）
    window = hann(nfft);
    [Pxx, f] = pwelch(signal, window, [], nfft, fs);
    P1 = sqrt(Pxx);
