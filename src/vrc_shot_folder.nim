import os, times, nre, cligen, system

let moduleVersion = "0.4.0"

let vrchatPictureDir = getHomeDir() / "Pictures" / "VRChat"

type SeparateBy = enum
  month, date, date_in_month

proc parseSepTime(separateTime: string): DateTime =
  parse(
    separateTime,
    "HH:mm",
    local()
  )

let timeRe = re"(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})\.(\d+)\.png$"

proc timeTick(datetime: DateTime): int64 =
  datetime.hour * 3600 + datetime.minute * 60 + datetime.second

type SrcDst = tuple
      src: string
      dst: string

type Destinations = tuple
      dirs: seq[string]
      files: seq[SrcDst]

proc detectDestinations(directory: string, separateBy: SeparateBy, sepTime: DateTime): Destinations =
  var dirs: seq[string] = @[]
  var files: seq[SrcDst] = @[]

  for file in walkDirRec(directory, { pcFile, pcLinkToFile }, { pcDir, pcLinkToDir }):
    let matched = file.find(timeRe)
    if matched.isSome:
      var datetime = parse(matched.get.match, "yyyy-MM-dd'_'HH-mm-ss'.'fff'.png'", local())
      if datetime.timeTick < sepTime.timeTick:
        datetime -= 1.days
      let useDate =
        case separateBy
        of date:
          datetime.format("yyyy-MM-dd")
        of date_in_month:
          datetime.format("yyyy-MM") / datetime.format("yyyy-MM-dd")
        of month:
          datetime.format("yyyy-MM")
      let dirPath = directory / useDate
      let dst = dirPath / extractFilename(file)
      if file != dst:
        if separateBy == date_in_month:
          let parentDirPath = parentDir(dirPath)
          if not dirs.contains(parentDirPath):
            dirs.add(parentDirPath)
        if not dirs.contains(dirPath):
          dirs.add(dirPath)
        files.add((src: file, dst: dst))

  (dirs, files)

proc logMoveFile(file: SrcDst) =
  echo file.src, " -> ", file.dst

proc makeDirs(dirs: seq[string]) =
  for dir in dirs:
    discard existsOrCreateDir(dir)

proc moveFiles(files: seq[SrcDst], log=false) =
  for file in files:
    moveFile(file.src, file.dst)
    if log:
      logMoveFile(file)

proc main(directory=vrchatPictureDir, separateBy=date, version=false, verbose=false, dryRun=false, separateTime="12:00") =
  if version:
    echo moduleVersion
    return
  let sepTime = parseSepTime(separateTime)
  let (dirs, files) = detectDestinations(directory, separateBy, sepTime)
  if dryRun:
    if verbose:
      for file in files:
        logMoveFile(file)
  else:
    makeDirs(dirs)
    moveFiles(files, verbose)
  echo files.len, " files moved"

if isMainModule:
  dispatch(main, help={
    "separateTime": "\"beginning of day\", in HH:mm format",
    "separateBy": "date / month / date_in_month",
    "dryRun": "do not move files, just print what would be done",
  }, short={
    "separateTime": 't',
  })
