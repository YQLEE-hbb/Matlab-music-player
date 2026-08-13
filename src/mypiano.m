function wave=mypiano(f,ftune,a,b)  %f:采样频率；ftune:基音频率；a:包络参数1；b:包络参数2.
    t=(1:3*f)/f;
    wave=sin(2*pi*ftune*t);
    k=[1,0.20,0.15,0.15,0.10,0.10,0.01,0.05,0.01,0.01,0.003,0.003,0.002,0.002];
    for i=2:14
        wave=wave+k(i)*sin(2*pi*ftune*i*t);
    end
    wave=wave/max(wave);
    wave=wave.*(t.^a.*exp(-b*t));