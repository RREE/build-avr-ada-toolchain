#--------------------------------------------------------------------------
#- The AVR-Ada Library is free software;  you can redistribute it and/or --
#- modify it under terms of the  GNU General Public License as published --
#- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
#- option) any later version.  The AVR-Ada Library is distributed in the --
#- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
#- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
#- PURPOSE. See the GNU General Public License for more details.         --
#-                                                                       --
#- As a special exception, if other files instantiate generics from this --
#- unit,  or  you  link  this  unit  with  other  files  to  produce  an --
#- executable   this  unit  does  not  by  itself  cause  the  resulting --
#- executable to  be  covered by the  GNU General  Public License.  This --
#- exception does  not  however  invalidate  any  other reasons why  the --
#- executable file might be covered by the GNU Public License.           --
#--------------------------------------------------------------------------

# rts/gcc-*/Makefile builds the AVR-Ada run time system (RTS)

###############################################################
#
#  Top
#
all: build_rts
clean: clean_rts
install: install_rts
uninstall: uninstall_rts

.PHONY: all clean install uninstall


###############################################################
#
#  Config
#
LIBGCC := $(shell avr-gcc -print-libgcc-file-name)
RTS_BASE := $(dir $(LIBGCC))

###############################################################
#
#  Settings
#
# Ada source files
ADASRC = system.ads \
   s-maccod.ads \
   s-stoele.ads s-stoele.adb \
   s-unstyp.ads \
   s-bitops.ads s-bitops.adb \
   s-stalib.ads \
   s-parame.ads \
   s-secsta.ads s-secsta.adb \
   s-memory.ads s-memory.adb \
   s-gccbui.ads \
   interfac.ads i-c.ads \
   i-cstrin.ads i-cstrin.adb \
   s-intimg.ads \
   ada.ads \
   unchconv.ads a-unccon.ads \
   a-charac.ads a-chlat1.ads a-chlat9.ads \
   a-calend.ads a-caldel.ads \
   a-except.ads a-except.adb \
   a-tags.ads a-tags.adb \
   gnat.ads g-souinf.ads

#   s-htable.ads s-htable.adb
#   a-stream.ads
#   s-finroo.ads s-finroo.adb a-finali.ads a-finali.adb
#   a-reatim.adb a-reatim.ads
#   a-interr.ads a-intnam.ads a-intsig.ads s-interr.adb s-interr.ads

ASMSRC = ada_u32_img.S

# List of AVR architectures
ARCH_LIST := avr25 avr3 avr31 avr35 avr4 avr5 avr51 avr6

# Library to build for each architecture
LIB := libgnat.a

# Objects needed in library
OBJS = s-bitops.o \
       a-except.o \
       s-memory.o \
       a-tags.o \
       s-secsta.o \
       ada_u32_img.o

# .ali for all specs
ALIS = $(ADASRC:.ads=.ali)

# All libraries
RTS_LIB_LIST := $(patsubst %, %/adalib/$(LIB), $(ARCH_LIST))

# Sources do not exist in $(MCU)/adalib but in $(MCU)/adainclude
vpath %.ads ../adainclude
vpath %.adb ../adainclude
vpath %.S   ../../asm

# Includes relative to $(MCU)/adalib
INC = -I- -I../adainclude

# Compile flags
ADAFLAGS = -g -Os -gnatn -gnatpg -mmcu=$(MCU) -fdata-sections -ffunction-sections
ASMFLAGS = -c -I. -x assembler-with-cpp -mmcu=$(MCU)

# Modes for installed items
INSTALL_FILE_MODE = u=rw,go=r
INSTALL_SRC_MODE = ugo=r
INSTALL_DIR_MODE = u=rwx,go=rx


###############################################################
#
#  Tools
#
CC      = avr-gcc
RM      = rm -f
CP      = cp
INSTALL = install
AR      = avr-ar
RANLIB  = avr-ranlib
MKDIR   = mkdir
TAR     = tar
ECHO    = echo
CHMOD   = chmod
RMDIR   = rmdir


###############################################################
#
#  Build
#
build_rts: $(RTS_LIB_LIST)

%/adalib/$(LIB): MCU = $(patsubst %/adalib/$(LIB),%, $@)
%/adalib/$(LIB): %/adalib %/adainclude
	$(MAKE) -C $(MCU)/adainclude -f ../../Makefile $(ADASRC)
	$(MAKE) -C $(MCU)/adalib     -f ../../Makefile $(ALIS) MCU=$(MCU)
	$(MAKE) -C $(MCU)/adalib     -f ../../Makefile $(LIB) MCU=$(MCU)

%/adalib:
	$(MKDIR) -p $@

%/adainclude:
	$(MKDIR) -p $@

$(LIB): $(OBJS)
	$(AR) cr $@ $^
	$(RANLIB) $@

.PRECIOUS: %/adalib %/adainclude


###############################################################
#
#  Clean
#
clean_rts:
	$(RM) -r $(ARCH_LIST)

.PHONY: clean_rts


###############################################################
#
#  Install
#
install_rts: build_rts uninstall_rts
	$(CP) -a $(ARCH_LIST) $(RTS_BASE)
	-$(INSTALL) -d $(RTS_BASE)/adainclude
	-$(INSTALL) -d $(RTS_BASE)/adalib
	-$(INSTALL) adainclude/system.ads $(RTS_BASE)/adainclude
	-$(INSTALL) README.gnatlink_inst  $(RTS_BASE)/adainclude
	-$(INSTALL) README.gprconfig      $(RTS_BASE)/adalib

.PHONY: install_rts


###############################################################
#
#  Uninstall
#
uninstall_rts:
	$(RM) $(RTS_BASE)/ada_source_path
	$(RM) $(RTS_BASE)/ada_object_path
	$(RM) -r $(RTS_BASE)/adainclude
	for arch in $(ARCH_LIST); do \
	   rm -rf $(RTS_BASE)/$$arch/adainclude; \
	   rm -rf $(RTS_BASE)/$$arch/adalib; \
	done

.PHONY: uninstall_rts


###############################################################
#
#  Implicit rules
#

# Copy source files into $(MCU)/adainclude directory if they
# have changed.  Write access is removed because we need to discourage
# modification of these copies (mods that won't be retained).
%: ../../adainclude/%
	-$(INSTALL) --preserve-timestamps --mode=$(INSTALL_SRC_MODE) ../../adainclude/$@ .

# keep the order of the following two implicit rules.  This way it
# tries to build a .ali first from .adb if available.  Only if there
# is no .adb, it tries to build from .ads.
%.ali %.o : %.adb
	$(CC) -c $(ADAFLAGS) $(INC) $<

%.ali %.o : %.ads
	$(CC) -c $(ADAFLAGS) $(INC) $<

%.o : %.S
	$(CC) -c $(ASMFLAGS) $<

-include $(Makefile_post)
