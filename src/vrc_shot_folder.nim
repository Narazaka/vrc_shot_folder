import os, times, nre, strutils, system

let vrchatPictureDir = getHomeDir() / "Pictures" / "VRChat"

let timeRe = re"(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})\.(\d+)\.png$"

let params = commandLineParams()
if params.len > 1:
  echo "Usage: vrc_shot_folder 12:00"
  quit(1)
let sepTime =
  parse(
    if params.len == 1:
      params[0]
    else:
      "12:00",
    "HH:mm",
    local()
  )

proc timeTick(datetime: DateTime): int64 =
  datetime.hour * 3600 + datetime.minute * 60 + datetime.second

var dirs: seq[string] = @[]
type SrcDst = tuple
      src: string
      dst: string
var files: seq[SrcDst] = @[]

for file in walkDir(vrchatPictureDir):
  if file.kind == pcFile:
    let matched = file.path.find(timeRe)
    if matched.isSome:
      var datetime = parse(matched.get.match, "yyyy-MM-dd'_'HH-mm-ss'.'fff'.png'", local())
      if datetime.timeTick < sepTime.timeTick:
        datetime -= 1.days
      let useDate = datetime.format("yyyy-MM-dd")
      let dirPath = vrchatPictureDir / useDate
      if not dirs.contains(dirPath):
        dirs.add(dirPath)
      files.add((src: file.path, dst: dirPath / extractFilename(file.path)))

for dir in dirs:
  discard existsOrCreateDir(dir)

for file in files:
  moveFile(file.src, file.dst)

echo files.len, " files moved"
