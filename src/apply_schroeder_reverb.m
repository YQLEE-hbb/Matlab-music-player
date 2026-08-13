function y = apply_schroeder_reverb(x, fs, Tr, delay_ms)
% APPLY_SCHROEDER_REVERB Apply Schroeder reverb effect to audio signal
%   x: input audio signal
%   fs: sample rate
%   Tr: reverb time in seconds
%   delay_ms: delay in milliseconds
% Convert delay from ms to samples
D = round(fs * delay_ms / 1000);
% Calculate decay coefficient
g = 10^(-3 * D / fs / Tr);
% Create comb filter
num = 1;
den = [1, zeros(1, D-1), -g];
% Apply the filter
y = filter(num, den, x);
% Normalize the output
y = y / max(abs(y));