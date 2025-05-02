# Генерируем PNG нужных размеров
inkscape app_icon.svg --export-width=16 --export-height=16 --export-filename=app_icon_16.png
inkscape app_icon.svg --export-width=32 --export-height=32 --export-filename=app_icon_32.png
inkscape app_icon.svg --export-width=48 --export-height=48 --export-filename=app_icon_48.png
inkscape app_icon.svg --export-width=64 --export-height=64 --export-filename=app_icon_64.png
inkscape app_icon.svg --export-width=128 --export-height=128 --export-filename=app_icon_128.png
inkscape app_icon.svg --export-width=256 --export-height=256 --export-filename=app_icon_256.png
inkscape app_icon.svg --export-width=512 --export-height=512 --export-filename=app_icon_512.png
inkscape app_icon.svg --export-width=1024 --export-height=1024 --export-filename=app_icon_1024.png

inkscape app_icon_background.svg --export-width=16 --export-height=16 --export-filename=app_icon_background_16.png
inkscape app_icon_background.svg --export-width=32 --export-height=32 --export-filename=app_icon_background_32.png
inkscape app_icon_background.svg --export-width=48 --export-height=48 --export-filename=app_icon_background_48.png
inkscape app_icon_background.svg --export-width=64 --export-height=64 --export-filename=app_icon_background_64.png
inkscape app_icon_background.svg --export-width=128 --export-height=128 --export-filename=app_icon_background_128.png
inkscape app_icon_background.svg --export-width=256 --export-height=256 --export-filename=app_icon_background_256.png
inkscape app_icon_background.svg --export-width=512 --export-height=512 --export-filename=app_icon_background_512.png
inkscape app_icon_background.svg --export-width=1024 --export-height=1024 --export-filename=app_icon_background_1024.png

inkscape app_icon_white.svg --export-width=16 --export-height=16 --export-filename=app_icon_white_16.png
inkscape app_icon_white.svg --export-width=32 --export-height=32 --export-filename=app_icon_white_32.png
inkscape app_icon_white.svg --export-width=48 --export-height=48 --export-filename=app_icon_white_48.png
inkscape app_icon_white.svg --export-width=64 --export-height=64 --export-filename=app_icon_white_64.png
inkscape app_icon_white.svg --export-width=128 --export-height=128 --export-filename=app_icon_white_128.png
inkscape app_icon_white.svg --export-width=256 --export-height=256 --export-filename=app_icon_whiten_256.png
inkscape app_icon_white.svg --export-width=512 --export-height=512 --export-filename=app_icon_white_512.png
inkscape app_icon_white.svg --export-width=1024 --export-height=1024 --export-filename=app_icon_white_1024.png


# Делаем .ico
convert app_icon_16.png app_icon_32.png app_icon_48.png app_icon_256.png app_icon_512.png app_icon.ico

convert app_icon_white_16.png app_icon_white_32.png app_icon_white_48.png app_icon_white_256.png app_icon_white_512.png app_icon_white.ico

# Делаем BMP для трея
convert app_icon_128.png BMP3:app_icon_128.bmp
convert app_icon_16.png BMP3:app_icon_16.bmp
