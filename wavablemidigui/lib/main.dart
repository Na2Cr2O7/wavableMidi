import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:shell/shell.dart';

import 'dart:io';
// usage: wavableMidi [-h] -i INPUT [-w WAVFILE] -o OUTPUT [-t MIDITRACK] [-s SAMPLERATE] [-B BASENOTE] [-N] [-C]
//                    [-wv WITHVIDEO]

// options:
//   -h, --help            show this help message and exit
//   -i, --input INPUT     input midi file | 输入的 MIDI 文件路径
//   -w, --wavfile WAVFILE
//                         wav file to be used as reference | 作为参考使用的 WAV 文件（用于音色或采样）
//   -o, --output OUTPUT   output directory | 输出文件的保存目录
//   -t, --midiTrack MIDITRACK
//                         the track number of the midi file to be used (-1 means the last track) | 要使用的 MIDI 文件中的轨道编号（-1
//                         表示最后一轨）
//   -s, --sampleRate SAMPLERATE
//                         sample rate to be used for output | 输出音频所使用的采样率
//   -B, --baseNote BASENOTE
//                         the base note to be used for the output (60 -> C4) | 输出音频所使用的基准音符（60 对应中央 C，即 C4）
//   -N, --NoCache         disable cache | 禁用缓存到ROM ，即缓存到RAM
//   -C, --anotherway      another way(wavCompositor) to process the audio (-N will be enabled while -s will be 44100
//                         forever) | 使用另一种音频处理方式(wavCompositor)（启用此选项会自动禁用缓存，并固定采样率为 44100）
//   -wv, --withVideo WITHVIDEO
//                         create video file (if enabled ,wavfile will be from video file(ffmepg -i <--withVideo>
//
//            input0.wav)) | 附加视频文件

ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.lightGreen,
  brightness: Brightness.light,
);
ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.lightGreen,
  brightness: Brightness.dark,
);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: lightColorScheme),
      home: HomePage(),
    );
  }
}

bool isnumeric(String s) {
  return s.trim().isNotEmpty && int.tryParse(s.trim()) != null;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String inputFileDirectory = "";
  String outputDirectory = "";
  String wavormp4FileDirectory = "";
  int selectedTrack = -1;
  int sampleRate = 44100;
  int baseNote = 60;
  TextEditingController selectedTrackController = TextEditingController();
  TextEditingController sampleRateController = TextEditingController();
  TextEditingController baseNoteController = TextEditingController();
  bool noCache = true;
  bool anotherway = false;
  bool withVideo = false;
  String arguments = "";
  String ShellResult = "输出";
  void setArguments() {
    if (inputFileDirectory == "") {
      arguments = "输入的 MIDI 文件路径不能为空";
      return;
    }
    if (outputDirectory == "") {
      arguments = "输出文件的保存目录不能为空";
      return;
    }
    if (wavormp4FileDirectory == "") {
      arguments = "作为参考使用的文件不能为空";
      return;
    }
    arguments = "python SeparateVoice.py -i \"$inputFileDirectory\"";
    arguments += withVideo
        ? " -wv \"$wavormp4FileDirectory\""
        : " -w \"$wavormp4FileDirectory\"";
    arguments += " -o \"$outputDirectory";
    arguments += withVideo ? ".mp4\"" : ".wav\"";

    arguments += " -t $selectedTrack";
    arguments += " -s $sampleRate";
    arguments += " -B $baseNote";

    if (noCache) {
      arguments += " -N";
    }
    if (anotherway) {
      arguments += " -C";
    }

    // if (withVideo) {
    //   arguments += " -wv $wavormp4FileDirectory";
    // } else {
    //   arguments += "-w $wavormp4FileDirectory";
    // }
  }

  @override
  void initState() {
    super.initState();
    selectedTrackController.addListener(() {
      if (isnumeric(selectedTrackController.text)) {
        selectedTrack = int.parse(selectedTrackController.text);
      } else {
        selectedTrackController.text = "-1";
        selectedTrack = -1;
      }
      setState(() {
        setArguments();
      });
      // try {
      //   selectedTrack = int.parse(selectedTrackController.text);
      // } catch (e) {
      //   selectedTrackController.text = "-1";
      // }
    });
    sampleRateController.addListener(() {
      if (isnumeric(sampleRateController.text)) {
        sampleRate = int.parse(sampleRateController.text);
      } else {
        sampleRateController.text = "44100";
        sampleRate = 44100;
      }
      setState(() {
        setArguments();
      });
    });
    baseNoteController.addListener(() {
      if (isnumeric(baseNoteController.text)) {
        baseNote = int.parse(baseNoteController.text);
      } else {
        baseNoteController.text = "60";
        baseNote = 60;
      }
      setState(() {
        setArguments();
      });
    });
  }

  void inputFileButton_Pressed() async {
    final xtype = XTypeGroup(label: "midi", extensions: ["mid", "midi"]);
    final result = await openFile(acceptedTypeGroups: [xtype]);
    if (result != null) {
      setState(() {
        inputFileDirectory = result.path;
      });
    }
    setArguments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(child: Text("wavableMidi GUI")),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("输入的 MIDI 文件路径", style: TextStyle(fontSize: 16)),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          side: BorderSide(
                            width: 2,
                            color: lightColorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          inputFileButton_Pressed();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder),
                            Text(
                              inputFileDirectory == ""
                                  ? "选择文件"
                                  : inputFileDirectory.split(
                                      "/",
                                    )[inputFileDirectory.split("/").length - 1],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: lightColorScheme.inversePrimary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("输出文件的保存目录", style: TextStyle(fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  side: BorderSide(
                                    width: 2,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await getSaveLocation();
                                  if (result != null) {
                                    setState(() {
                                      outputDirectory = result.path;
                                      setArguments();
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.folder),
                                    Text(
                                      outputDirectory == ""
                                          ? "选择目录"
                                          : outputDirectory.split(
                                              "/",
                                            )[outputDirectory
                                                    .split("/")
                                                    .length -
                                                1],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("作为参考使用的文件（用于音色或采样）", style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      onPressed: () async {
                        final result = await openFile(
                          acceptedTypeGroups: [
                            XTypeGroup(label: "wav", extensions: ["wav"]),
                            XTypeGroup(label: "mp4", extensions: ["mp4"]),
                          ],
                        );
                        if (result != null) {
                          if (result.path.endsWith(".mp4")) {
                            withVideo = true;
                          } else {
                            withVideo = false;
                          }
                          setState(() {
                            wavormp4FileDirectory = result.path;
                            setArguments();
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.folder),
                          Text(
                            wavormp4FileDirectory == ""
                                ? "选择文件"
                                : wavormp4FileDirectory.split(
                                    "/",
                                  )[wavormp4FileDirectory.split("/").length -
                                      1],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // decoration: BoxDecoration(color: lightColorScheme.inversePrimary),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Text(
                      "要使用的 MIDI 文件中的轨道编号(-1表示最后一轨)",
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(padding: const EdgeInsets.all(6)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      width: 100,
                      child: TextField(
                        controller: selectedTrackController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              // decoration: BoxDecoration(color: lightColorScheme.inversePrimary),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Text("输出音频所使用的采样率", style: TextStyle(fontSize: 16)),
                    Padding(padding: const EdgeInsets.all(6)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      width: 100,
                      child: TextField(
                        controller: sampleRateController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: lightColorScheme.inversePrimary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            Text(
                              "输出音频所使用的基准音符(60对应中央C，即C4)",
                              style: TextStyle(fontSize: 16),
                            ),
                            Padding(padding: const EdgeInsets.all(6)),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              width: 100,
                              child: TextField(
                                controller: baseNoteController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Text("禁用缓存到ROM，即缓存到RAM", style: TextStyle(fontSize: 16)),
                  Checkbox(
                    value: noCache,
                    onChanged: (bool? value) {
                      setState(() {
                        noCache = value!;
                        setArguments();
                      });
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: lightColorScheme.inversePrimary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Text(
                            "使用wavCompositor",
                            style: TextStyle(fontSize: 16),
                          ),
                          Checkbox(
                            value: anotherway,
                            onChanged: (bool? value) {
                              setState(() {
                                anotherway = value!;
                                setArguments();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Text("视频输出(根据输入文件自动选择)", style: TextStyle(fontSize: 16)),
                  Checkbox(value: withVideo, onChanged: (bool? value) {}),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: lightColorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(78, 0, 0, 0),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  arguments,
                  style: TextStyle(fontSize: 16),
                  softWrap: true, // 启用自动换行
                  overflow: TextOverflow.clip,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: lightColorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(78, 0, 0, 0),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    ShellResult,
                    style: TextStyle(fontSize: 16),
                    softWrap: true, // 启用自动换行
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () async {
                var result;
                try {
                  result = await Process.run(arguments, []);
                  setState(() {
                    ShellResult =
                        result.stdout.toString() + result.stderr.toString();
                  });
                } on Exception catch (e) {
                  result = e;
                }
              },
              child: Column(children: [Icon(Icons.play_arrow), Text("开始转换")]),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: arguments));
              },
              child: Column(children: [Icon(Icons.copy), Text("复制命令")]),
            ),
            TextButton(
              onPressed: () async {
                await OpenFile.open(outputDirectory);
              },
              child: Column(children: [Icon(Icons.open_in_new), Text("打开文件夹")]),
            ),
          ],
        ),
      ),
    );
  }
}
