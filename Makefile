REPO := $(HOME)/repo
LINUX := $(REPO)/linux

default: kernel.img rootfs.img

run: kernel.img rootfs.img
	qemu-system-x86_64 -kernel kernel.img -append "root=/dev/ram rdinit=/sbin/init" -initrd rootfs.img -net nic,model=e1000 -net user

debug: kernel.img rootfs.img
	qemu-system-x86_64 -kernel kernel.img -append "root=/dev/ram rdinit=/sbin/init kgdboc=ttyS0,115200 kgdbwait" -initrd rootfs.img -net nic,model=e1000 -net user -serial tcp::1234,server &
	TMPFILE=$$(mktemp) && echo "target remote localhost:1234" > $$TMPFILE && gdb -x $$TMPFILE $(LINUX)/vmlinux

clean:
	rm -f kernel.img rootfs.img

kernel.img:
	cp $(LINUX)/arch/x86/boot/bzImage $@

rootfs.img:
	mkrootfs $@

.PHONY: default run debug clean
