# MATLAB 音频信号发生与播放器 (MusicPlayer)

基于 MATLAB GUIDE 开发的音频播放器，支持内置乐曲播放（钢琴音色合成）、外部音频文件加载、
变速播放、两种混响算法（Schroeder / Gardner）以及九段图形均衡器（EQ）。

仓库内还附带一个独立的配套小项目 `GUIxinhaofashengqi/`（简易信号发生器）。

---

## 目录结构

```
matlab-music-player/
├── src/                          # 主程序：MusicPlayer，直接运行即可
│   ├── MusicPlayer.m             # 主程序（GUIDE 生成，入口文件）
│   ├── MusicPlayer.fig           # 界面布局文件
│   ├── mypiano.m                 # 钢琴音色合成（谐波叠加 + 包络）
│   ├── apply_schroeder_reverb.m  # Schroeder 混响
│   ├── apply_gardner_reverb.m    # Gardner 混响
│   ├── picture1.jpg              # 界面背景图
│   └── picture2.png              # 界面背景图
│
├── GUIxinhaofashengqi/            # 独立配套小项目：简易信号发生器
│   ├── GUIxinhaofashengqi.m       # 正弦/三角/方波/白噪声，滑块调频率
│   └── GUIxinhaofashengqi.fig
│
├── archive/                       # 未接入主程序的早期草稿，仅作留存参考
│   ├── dynamic_wave.m             # 实时波形显示——独立脚本原型
│   └── updateWaveformDisplay.m    # 实时波形显示——函数化尝试
│
└── README.md
```

## 运行方法

**主程序（音乐播放器）**
1. 用 MATLAB 打开 `src/` 目录（`MusicPlayer.m` 与 `MusicPlayer.fig` 需在同一目录）。
2. 命令行输入：
   ```matlab
   MusicPlayer
   ```

**配套小项目（信号发生器）**
1. 用 MATLAB 打开 `GUIxinhaofashengqi/` 目录。
2. 命令行输入：
   ```matlab
   GUIxinhaofashengqi
   ```

## 主程序功能对照

| 功能 | 操作方式 |
|---|---|
| 播放内置曲目（千与千寻 / Overtrue / SkyCity 钢琴版）| 点击对应曲目按钮 |
| 打开本地文件 | 点击"打开文件"，支持 mp3 / wav / ogg |
| 播放 / 暂停 | 点击暂停按钮切换 |
| 变速播放（1x / 2x / 3x）| 点击对应倍速按钮。**倍速切换不支持连续调整**，换曲目前请先切回 1x |
| 混响（Schroeder / Gardner）| 点击对应混响按钮，弹窗输入参数。**每次调整混响会在当前音频基础上叠加**，不是从干声重新计算，切歌前建议重新点一次曲目按钮 |
| 九段均衡器 | 打开文件后拖动 62Hz–16000Hz 各频段滑块，**必须点击 EQ 应用按钮**才会生效 |

长音频文件计算混响耗时较长，属已知限制，不是 bug。

## 代码内部依赖关系

`MusicPlayer.m` 中被实际调用的外部函数：

- `mypiano.m` — 千与千寻 / 天空之城 两首内置曲目用它合成钢琴音色
- `apply_schroeder_reverb.m` — Schroeder 混响按钮回调直接调用
- `apply_gardner_reverb.m` — Gardner 混响按钮回调直接调用

Moorer 混响的实现是 `MusicPlayer.m` 内部的本地函数（第 750 行附近），不依赖外部文件——
原来同名的独立文件 `apply_moorer_reverb.m` 是逐行重复的死代码，整理时已删除。

## archive/ 说明

`dynamic_wave.m` 和 `updateWaveformDisplay.m` 都是"播放时波形随进度实时滚动更新"这个功能的
未完成尝试：`dynamic_wave.m` 是最早的独立脚本版本（`tic/toc` + `while` 循环轮询），
`updateWaveformDisplay.m` 是后来函数化、准备配合 `timer` 回调的版本。`MusicPlayer.m` 里
检索不到任何 `timer` 或对这个函数的调用，说明该功能最终没有接入——现在主程序里的波形图
只在每次点击按钮时画一次静态快照。如果之后想做"实时滚动波形"，`updateWaveformDisplay.m`
是相对完整的起点，需要在按钮回调里补一个 `timer` 对象定时调用它。
