function y = apply_gardner_reverb(x, fs, room_type, gain)
    % 安全截止频率
    max_cutoff = fs/2 * 0.95;
    
    switch lower(room_type)
        case 'small'
            % 小厅参数(保持不变)
            D1 = round(fs * 24 / 1000);
            D2 = round(fs * 22 / 1000);
            D3 = round(fs * 8.3 / 1000);
            D4 = round(fs * 4.7 / 1000);
            D5 = round(fs * 30 / 1000);
            D6 = round(fs * 36 / 1000);
            a1 = 0.3; a2 = 0.4; a3 = 0.6; % 反射系数
            
        case 'medium'
            % 中厅参数
            D1 = round(fs * 36 / 1000);   % 更长延迟
            D2 = round(fs * 30 / 1000);
            D3 = round(fs * 12 / 1000);
            D4 = round(fs * 6 / 1000);
            D5 = round(fs * 45 / 1000);
            D6 = round(fs * 50 / 1000);
            a1 = 0.5; a2 = 0.5; a3 = 0.7; % 更强反射
            
        case 'large'
            % 大厅参数
            D1 = round(fs * 50 / 1000);   % 最长延迟
            D2 = round(fs * 40 / 1000);
            D3 = round(fs * 15 / 1000);
            D4 = round(fs * 8 / 1000);
            D5 = round(fs * 60 / 1000);
            D6 = round(fs * 70 / 1000);
            a1 = 0.7; a2 = 0.6; a3 = 0.8; % 最强反射
            
        otherwise
            error('不支持的房间类型');
    end
    
    % 公共处理部分
    % 子系统H1
    G_num1 = conv([-a2 1 zeros(1,D2-1)], [-a3 1 zeros(1,D3-1)]);
    G_den1 = conv([1 -a2 zeros(1,D2-1)], [1 -a3 zeros(1,D3-1)]);
    G_num1 = [G_num1 zeros(1,D4)];
    G_den1 = [G_den1 zeros(1,D4)];
    
    H1_num = conv([-a1 1 zeros(1,D1)], [G_num1, -a1]);
    H1_den = conv([1 -a1 zeros(1,D1)], [G_den1, -a1]);
    
    % 子系统H2
    G2_num = conv([-a2 1 zeros(1,D5-1)], [1 zeros(1,D6)]);
    G2_den = [1 -a2 zeros(1,D5+D6-1)];
    
    H2_num = conv([-0.1 1], [G2_num, -0.1]);
    H2_den = conv([1 -0.1], [G2_den, -0.1]);
    
    % 子系统H3 (低通滤波器)
    [b_lp, a_lp] = butter(1, max_cutoff/(fs/2));
    H3_num = b_lp * gain;
    H3_den = a_lp;
    
    % 系统函数
    num = 0.5 * conv(H1_num, [1, H2_num]);
    
    term1 = conv(H1_den, H2_den);
    term2 = conv(H1_num, conv(H2_num, H3_num));
    
    max_len = max(length(term1), length(term2));
    term1 = [term1, zeros(1, max_len-length(term1))];
    term2 = [term2, zeros(1, max_len-length(term2))];
    
    den = term1 - term2;
    
    y = filter(num, den, x);
    y = y / max(abs(y));
end