[filename, filepath] = uigetfile('*.wav'); % 让用户选择.wav文件
absolutePath = fullfile(filepath, filename); % 将相对路径转换为绝对路径

[audio, Fs] = audioread(absolutePath);
duration = length(audio) / Fs;

tic;
sound(audio,Fs);
while toc <= duration
    
    current_time = toc;
    start_index = round(current_time * Fs) + 1;
    end_index = min(start_index + Fs - 1, length(audio));
    waveform = audio(start_index:end_index);
    plot(waveform);
    title(sprintf('时间: %.2f seconds', current_time));
    xlabel('采样点数');
    

 ylabel('时域幅值');
    
    % 更新图形显示
    drawnow;
end


