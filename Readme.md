# vrc_shot_folder

VRChatのスクリーンショットフォルダにある画像を日付別フォルダに入れるコマンド

`vrc_shot_folder_time.bat`をダブルクリックすると分類されます。

**[ダウンロード](https://github.com/Narazaka/vrc_shot_folder/releases)**

## フォルダ分け

`vrc_shot_folder_time.bat`をメモ帳か何かで編集してください。

|`vrc_shot_folder_time.bat`の2行目|フォルダ分け|
|--|--|
|`@vrc_shot_folder.exe --verbose --separateBy date --separateTime 12:00`|`2021-12-24`|
|`@vrc_shot_folder.exe --verbose --separateBy month --separateTime 12:00`|`2021-12`|
|`@vrc_shot_folder.exe --verbose --separateBy date_in_month --separateTime 12:00`|`2021-12/2021-12-24`|

## 日付変更線

日付変更線が指定できます。デフォルトは昼の12:00です。

|撮影日付|フォルダ|
|--|--|
|2018/12/01 13:00|2018-12-01|
|2018/12/02 01:00|2018-12-01|
|2018/12/02 13:00|2018-12-02|

みたいな感じになります。深夜勢でも日付がまとまって安心。

`vrc_shot_folder_time.bat`をメモ帳か何かで編集してください。

## 見るフォルダ

デフォルトでは`Pictures/VRChat`フォルダを見ますが、OneDriveにしたり、その他の変更によってフォルダが変わった場合はオプションに指定して下さい。

`vrc_shot_folder_time.bat`をメモ帳か何かで編集してください。

例:

```
@vrc_shot_folder.exe --verbose --separateBy date --separateTime 12:00 --directory "C:\Users\narazaka\OneDrive\Pictures\VRChat"
```

## 空のフォルダを消す

`vrc_shot_folder_time.bat`をメモ帳か何かで編集してください。

`--deleteEmptyDirectory`を付けて下さい。

## License

[Zlib License](https://narazaka.net/license/Zlib?2019)
