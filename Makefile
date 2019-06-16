all: vrc_shot_folder.zip

vrc_shot_folder.zip: vrc_shot_folder.exe
	zip -9 vrc_shot_folder.zip vrc_shot_folder.exe vrc_shot_folder_time.bat

vrc_shot_folder.exe: src/vrc_shot_folder.nim
	nimble build --cc:vcc -d:release
