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
FREERTOSDIR = $(BASEDIR)/FreeRTOS
OBJDIR = $(BASEDIR)/build
BINDIR = $(OBJDIR)/bin

MACH = cortex-m4
CFLAGS = -g -mcpu=$(MACH) -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -std=gnu11 -o0 -Wall
LDFLAGS= -g -mcpu=$(MACH) -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 --specs=nano.specs -T linker.ld -Wl,-Map=$(BINDIR)/memory.map

INCLUDES =
INCLUDES += -I$(BASEDIR)/inc
INCLUDES += -I$(DRIVERDIR)/CMSIS/Core/Include
INCLUDES += -I$(DRIVERDIR)/CMSIS/Device/inc
INCLUDES += -I$(DRIVERDIR)/STM32F4xx_HAL_Driver/Inc
INCLUDES += -I$(FREERTOSDIR)/Source/include
INCLUDES += -I$(FREERTOSDIR)/Source/portable/GCC/ARM_CM4F

CFLAGS += $(INCLUDES)
CFLAGS += -DUSE_HAL_DRIVER=1
CFLAGS += -DSTM32F410Rx=1

SRC_FILES = $(wildcard $(SRCDIR)/*.c)
HAL_FILES = $(wildcard $(HALSRCDIR)/*.c)
CMSIS_FILES += $(wildcard $(CMSISDIR)/Device/src/*.*)
FREERTOS_FILES += $(wildcard $(FREERTOSDIR)/Source/*.c)
FREERTOSPORT_FILES += $(wildcard $(FREERTOSDIR)/Source/portable/GCC/ARM_CM4F/*.c)
FREERTOSMEM_FILES += $(wildcard $(FREERTOSDIR)/Source/portable/MemMang/*.c)

OBJ_FILES = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC_FILES))
HAL_OBJ_FILES = $(patsubst $(HALSRCDIR)/%.c, $(OBJDIR)/%.o, $(HAL_FILES))
CMSIS_OBJ_FILES = $(filter %.o, $(patsubst $(CMSISDIR)/Device/src/%.c, $(OBJDIR)/%.o, $(CMSIS_FILES)) $(patsubst $(CMSISDIR)/Device/src/%.s, $(OBJDIR)/%.o, $(CMSIS_FILES)))
FREERTOS_OBJ_FILES = $(patsubst $(FREERTOSDIR)/Source/%.c, $(OBJDIR)/%.o, $(FREERTOS_FILES))
FREERTOSPORT_OBJ_FILES = $(patsubst $(FREERTOSDIR)/Source/portable/GCC/ARM_CM4F/%.c, $(OBJDIR)/%.o, $(FREERTOSPORT_FILES))
FREERTOSMEM_OBJ_FILES = $(patsubst $(FREERTOSDIR)/Source/portable/MemMang/%.c, $(OBJDIR)/%.o, $(FREERTOSMEM_FILES))
ALL_OBJ_FILES = $(OBJ_FILES)
ALL_OBJ_FILES += $(HAL_OBJ_FILES)
ALL_OBJ_FILES += $(CMSIS_OBJ_FILES)
ALL_OBJ_FILES += $(FREERTOS_OBJ_FILES)
ALL_OBJ_FILES += $(FREERTOSPORT_OBJ_FILES)
ALL_OBJ_FILES += $(FREERTOSMEM_OBJ_FILES)

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

$(OBJDIR)/%.o: $(CMSISDIR)/Device/src/%.*
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(FREERTOSDIR)/Source/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(FREERTOSDIR)/Source/portable/GCC/ARM_CM4F/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

$(OBJDIR)/%.o: $(FREERTOSDIR)/Source/portable/MemMang/%.c
	@echo "\n\r[CC] $@"
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -rf $(OBJDIR)
