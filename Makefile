MACH = cortex-m4
CFLAGS = -g -mcpu=$(MACH) -mthumb -mfloat-abi=soft -std=gnu11 -o0 -Wall
LDFLAGS= -g -mcpu=$(MACH) -mthumb -mfloat-abi=soft --specs=nano.specs -T linker.ld -Wl,-Map=memory.map

CROSS_COMPILE = arm-none-eabi-
AR = $(CROSS_COMPILE)ar
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
NM = $(CROSS_COMPILE)nm
LD = $(CROSS_COMPILE)gcc
GDB = $(CROSS_COMPILE)gdb
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

BASEDIR = $(shell pwd)
SRCDIR = $(BASEDIR)/src
DRIVERDIR = $(BASEDIR)/Drivers
HALDIR = $(DRIVERDIR)/STM32F4xx_HAL_Driver
HALSRCDIR = $(HALDIR)/Src
CMSISDIR = $(DRIVERDIR)/CMSIS
OBJDIR = $(BASEDIR)/obj
BINDIR = $(OBJDIR)/bin

INCLUDES =
INCLUDES += -I$(BASEDIR)/inc
INCLUDES += -I$(DRIVERDIR)/CMSIS/Core/Include
INCLUDES += -I$(DRIVERDIR)/CMSIS/Device/inc
INCLUDES += -I$(DRIVERDIR)/STM32F4xx_HAL_Driver/Inc

CFLAGS += $(INCLUDES)
CFLAGS += -DUSE_HAL_DRIVER=1
CFLAGS += -DSTM32F410Rx=1

SRC_FILES = $(wildcard $(SRCDIR)/*.c)
HAL_FILES = $(wildcard $(HALSRCDIR)/*.c)
CMSIS_FILES += $(wildcard $(CMSISDIR)/Device/src/*.c $(CMSISDIR)/Device/src/*.s)

OBJ_FILES = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC_FILES))
HAL_OBJ_FILES = $(patsubst $(HALSRCDIR)/%.c, $(OBJDIR)/%.o, $(HAL_FILES))
CMSIS_OBJ_FILES = $(patsubst $(CMSISDIR)/Device/src/%.c, $(OBJDIR)/%.o, $(CMSIS_FILES))
CMSIS_OBJ_FILES += $(patsubst $(CMSISDIR)/Device/src/%.s, $(OBJDIR)/%.o, $(CMSIS_FILES))
ALL_OBJ_FILES = $(OBJ_FILES)
ALL_OBJ_FILES += $(HAL_OBJ_FILES)
ALL_OBJ_FILES += $(CMSIS_OBJ_FILES)

.PHONY: all
all: mkdir $(BINDIR)/final.elf

.PHONY: mkdir
mkdir:
	mkdir -p $(BINDIR)
	@echo "\n\r[ALL_OBJ_FILES] $(ALL_OBJ_FILES)"
	@echo "\n\r[INCLUDES] $(INCLUDES)"

$(BINDIR)/final.elf: $(ALL_OBJ_FILES)
	@echo "\n\r[LD] $@"
	$(LD) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(HALSRCDIR)/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(CMSISDIR)/Device/src/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(CMSISDIR)/Device/src/%.s
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -rf $(OBJDIR)
	rm -rf *.map
