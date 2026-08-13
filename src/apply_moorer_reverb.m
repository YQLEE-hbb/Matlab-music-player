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