function updateWaveformDisplay(~, ~, hFigure)
handles = guidata(hFigure);
if ~isfield(handles, 'player') || isempty(handles.player) || ~handles.isPlaying
    return;
end

currentSample = handles.player.CurrentSample;
fs = handles.player.SampleRate;
audioData = handles.player.UserData;

% 计算显示窗口
windowSize = 0.5; % 显示0.5秒的波形
samplesToShow = round(windowSize * fs);
startSample = max(1, currentSample - samplesToShow);
endSample = min(length(audioData), currentSample + samplesToShow);

% 更新显示
t = (startSample:endSample)/fs - currentSample/fs;
plot(handles.axes4, t, audioData(startSample:endSample), 'b');
axis(handles.axes4, [-windowSize windowSize -1.1 1.1]);
grid(handles.axes4, 'on');
title(handles.axes4, '实时波形');
xlabel(handles.axes4, '时间 (s)');
ylabel(handles.axes4, '振幅');