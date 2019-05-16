TARGET 		= build/rockbot.elf

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC  := $(CROSS_COMPILE)gcc
LD  := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
STRIP := $(CROSS_COMPILE)strip
RC  := $(CROSS_COMPILE)windres

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS   	= -G0 -Wall -O3 -DDINGUX -DHANDHELD -g -I. $(SDL_CFLAGS)
CXXFLAGS 	= $(CFLAGS) -fexceptions -fno-rtti
LDFLAGS 	= -lm -lc -lstdc++ -lc -lSDL -lSDL_mixer -lvorbisidec -logg -lSDL_ttf -lfreetype -lSDL_image -ljpeg -lpng -lz $(SDL_LIBS)

OBJS   		= main.o options/key_map.o inputlib.o timerlib.o soundlib.o file/file_io.o collision_detection.o graphicslib.o \
sceneslib.o stage_select.o graphic/option_picker.o classmap.o objects/object.o character/character.o projectilelib.o \
graphic/animation.o stage.o class_config.o scenes/dialogs.o game.o character/classplayer.o \
character/classnpc.o character/artificial_inteligence.o aux_tools/trajectory_parabola.o file/convert.o \
graphic/draw.o graphic/gfx_sin_wave.o character/movement/jump.o character/movement/inertia.o scenes/sceneshow.o \
game_mediator.o ports/psp/psp_ram.o strings_map.o file/fio_strings.o file/fio_common.o \
file/fio_scenes.o aux_tools/stringutils.o aux_tools/fps_control.o docs/game_manual.o

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CC) $(CXXFLAGS) -c $< -o $@

ipk: $(TARGET)
	@rm -rf /tmp/.rockbot-ipk/ && mkdir -p /tmp/.rockbot-ipk/root/home/retrofw/games/rockbot /tmp/.rockbot-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r build/rockbot.elf build/rockbot.png build/fonts build/games build/packages build/shared build/template /tmp/.rockbot-ipk/root/home/retrofw/games/rockbot
	@cp build/rockbot.lnk /tmp/.rockbot-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" build/control > /tmp/.rockbot-ipk/control
	@cp build/conffiles /tmp/.rockbot-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.rockbot-ipk/control.tar.gz -C /tmp/.rockbot-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.rockbot-ipk/data.tar.gz -C /tmp/.rockbot-ipk/root/ .
	@echo 2.0 > /tmp/.rockbot-ipk/debian-binary
	@ar r build/rockbot.ipk /tmp/.rockbot-ipk/control.tar.gz /tmp/.rockbot-ipk/data.tar.gz /tmp/.rockbot-ipk/debian-binary

clean:
	rm -f $(TARGET) $(OBJS)
