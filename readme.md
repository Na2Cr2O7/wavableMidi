
# 🎵 wavableMidi

将 MIDI 文件转换为 WAV 音频文件。

## 📦 安装说明

建议使用 Python 3.13.2 环境运行本项目。

```bash
pip install -r requirements.txt
```

## 💻 运行环境支持

### Windows

无需额外编译步骤，直接运行即可。希望一切顺利！

### Linux & macOS

需要手动编译两个 C++ 工具程序：

```bash
g++ Pitch.cpp -o Pitch
g++ wavCompositor.cpp -o wavCompositor
```

请确保编译后的二进制文件位于系统路径中或脚本可访问的位置。

---

## 🚀 使用方法

### 命令帮助信息

```bash
python SeparateVoice.py --help
```

输出如下：

```
usage: quickwindsonglyre [-h] -i INPUT -w WAVFILE -o OUTPUT [-t MIDITRACK] [-s SAMPLERATE] [-B BASENOTE] [-N] [-C]

options:
  -h, --help            show this help message and exit
  -i, --input INPUT     input midi file | 输入的 MIDI 文件路径
  -w, --wavfile WAVFILE
                        wav file to be used as reference | 作为参考使用的 WAV 文件（用于音色或采样）
  -o, --output OUTPUT   output directory | 输出文件的保存目录
  -t, --midiTrack MIDITRACK
                        the track number of the midi file to be used (-1 means the last track) | 要使用的 MIDI 文件中的轨道编号（-1
                        表示最后一轨）
  -s, --sampleRate SAMPLERATE
                        sample rate to be used for output | 输出音频所使用的采样率
  -B, --baseNote BASENOTE
                        the base note to be used for the output (60 -> C4) | 输出音频所使用的基准音符（60 对应中央 C，即 C4）
  -N, --NoCache         disable cache | 禁用缓存到RAM功能
  -C, --anotherway      another way(wavCompositor) to process the audio (-N will be enabled while -s will be 44100
                        forever) | 使用另一种音频处理方式(wavCompositor)（启用此选项会自动禁用缓存，并固定采样率为 44100）

---

## 🧪 示例命令

```bash
# 使用 wavCompositor 方式处理音频，固定采样率为 44100
python SeparateVoice.py -i thomas.mid -w piano01.wav -o thomas.wav -C

# 使用 MIDI 第 1 轨，设置采样率为 44100，基准音高为 C4（60）
python SeparateVoice.py -i thomas.mid -w piano01.wav -o thomas.wav -t 1 -s 44100 -B 60
```

---

## ⚙️ 高级设置

在 `VoiceSwift.py` 中提供了三种变调算法可供选择。你可以在第 72~74 行修改所使用的变调函数：

```python
# 可选变调函数：changePitch1 / changePitch2 / changePitch3
changePitch = changePitch3  # 默认使用 changePitch3
```

你可以根据需求切换不同的变调逻辑以获得更佳的音质效果。

---

## 📝 注意事项

- 所需的 WAV 音源文件应尽量包含完整音域，以便匹配 MIDI 中的所有音符。
- 若使用 `-C` 参数（wavCompositor），则无法自定义采样率，且禁用缓存机制。
- 编译时若出现错误，请检查是否安装了 `g++` 编译器及相关依赖库。

---

## 🤝 贡献与反馈

欢迎提交 Issue 和 Pull Request 来帮助改进此项目！
### midi文件出处
thomas.mid来自网络
[Memory Lane-Tobu.mid](<Memory Lane-Tobu.mid>) 是Tobu的歌曲Memory Lane加速1.1倍后用Melodyne 5生成。

AudioFile.h 来自 [https://github.com/adamstark/AudioFile](https://github.com/adamstark/AudioFile) 在MIT许可证下授权。
(虽然没有用到)CwriteWav.c 来自 [https://github.com/lyc18/C-CPP-read-write-WAV](https://github.com/lyc18/C-CPP-read-write-WAV) 在MIT许可证下授权。

