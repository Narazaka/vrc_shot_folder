import os, times, nre, cligen, system

let moduleVersion = "0.5.0"

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
      extraFiles: seq[string]

proc detectDestinations(directory: string, separateBy: SeparateBy, sepTime: DateTime): Destinations =
  var dirs: seq[string] = @[]
  var files: seq[SrcDst] = @[]
  var extraFiles: seq[string] = @[]

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
    else:
      extraFiles.add(file)

  (dirs, files, extraFiles)

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

proc detectEmptyDirectories(files: seq[SrcDst], extraFiles: seq[string]): seq[string] =
  var dirs: seq[string] = @[]
  var stayDirs: seq[string] = @[]
  var emptyDirs: seq[string] = @[]
  for file in files:
    for dir in parentDirs(file.src, inclusive=false):
      if not dirs.contains(dir):
        dirs.add(dir)
  for file in files:
    for dir in parentDirs(file.dst, inclusive=false):
      if not stayDirs.contains(dir):
        stayDirs.add(dir)
  for file in extraFiles:
    for dir in parentDirs(file, inclusive=false):
      if not stayDirs.contains(dir):
        stayDirs.add(dir)
  for dir in dirs:
    if not stayDirs.contains(dir):
      emptyDirs.add(dir)
  emptyDirs

proc removeEmptyDirectories(emptyDirs: seq[string], log=false) =
  for dir in emptyDirs:
    if dirExists(dir):
      removeDir(dir)
      if log:
        echo "remove ", dir

proc main(directory=vrchatPictureDir, separateBy=date, version=false, verbose=false, deleteEmptyDirectory=false, dryRun=false, separateTime="12:00") =
  if version:
    echo moduleVersion
    return
  let sepTime = parseSepTime(separateTime)
  let (dirs, files, extraFiles) = detectDestinations(directory, separateBy, sepTime)
  if dryRun:
    if verbose:
      for file in files:
        logMoveFile(file)
      if deleteEmptyDirectory:
        let emptyDirs = detectEmptyDirectories(files, extraFiles)
        for dir in emptyDirs:
          echo "remove ", dir
  else:
    makeDirs(dirs)
    moveFiles(files, verbose)
    if deleteEmptyDirectory:
      let emptyDirs = detectEmptyDirectories(files, extraFiles)
      removeEmptyDirectories(emptyDirs, verbose)
  echo files.len, " files moved"

if isMainModule:
  dispatch(main, help={
    "separateTime": "\"beginning of day\", in HH:mm format",
    "separateBy": "date / month / date_in_month",
    "dryRun": "do not move files, just print what would be done",
    "deleteEmptyDirectory": "delete empty directories",
  }, short={
    "separateTime": 't',
  })
