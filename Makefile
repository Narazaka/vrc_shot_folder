all: vrc_shot_folder.zip

vrc_shot_folder.zip: vrc_shot_folder.exe
	zip -9 vrc_shot_folder.zip vrc_shot_folder.exe vrc_shot_folder_time.bat pcre64.dll pcre_licence.txt

vrc_shot_folder.exe: src/vrc_shot_folder.nim
	nimble build -y --cc:vcc -d:release
