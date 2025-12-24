# minikernel-boot/Makefile
CC := gcc
LD := ld
OBJCOPY := objcopy
OBJDUMP := objdump

ARCH := x86_64
CFLAGS := -m64 -O0 -g -Wall -Werror \
	-fno-PIE -fno-stack-protector -fno-builtin \
	-ffreestanding -nostdlib \
	-I include \
	-D__KERNEL__ -D__ASSEMBLY__ -D__x86_64__

LDFLAGS := -m elf_x86_64 --no-relax

TARGET := vmlinux
IMAGE := vmlinux.bin

OBJS := \
	arch/x86/boot/header.o \
	arch/x86/kernel/head_64.o \
	arch/x86/kernel/head64.o \
	arch/x86/kernel/setup.o \
	init/main.o \
	lib/string.o

.PHONY: all clean run debug

all: $(IMAGE)

$(TARGET): linker.ld $(OBJS)
	$(LD) $(LDFLAGS) -T linker.ld -o $@ $(OBJS)

$(IMAGE): $(TARGET)
	$(OBJCOPY) -O binary $< $@

%.o: %.S
	$(CC) $(CFLAGS) -D__ASSEMBLY__ -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(IMAGE) *.o */*.o */*/*.o

run: $(IMAGE)
	qemu-system-x86_64 -kernel $(IMAGE) -nographic -serial mon:stdio -no-reboot

debug: $(IMAGE)
	qemu-system-x86_64 -kernel $(IMAGE) -nographic -serial mon:stdio -no-reboot -s -S &
	echo "GDB: gdb vmlinux -ex 'target remote :1234'"
