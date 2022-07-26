#!/bin/bash

rom_script=''
if [ -n "$1" ];then
	if echo "$1" | grep -qF /;then
        rom_script=''
        for i in "$@";do
            rom_script="$rom_script"$'\n''$(call inherit-product, '$i')'
        done
    else
		rom_script='$(call inherit-product, device/phh/treble/'$1'.mk)'
	fi
fi

echo 'PRODUCT_MAKEFILES := \' > AndroidProducts.mk

for part in a ab;do
	for arch in arm64 arm a64;do
		extra_packages=""
                vndk="vndk.mk"
		optional_base=""
		if [ "$arch" == "arm" ];then
			vndk="vndk-binder32.mk"
		fi
		if [ "$arch" == "a64" ];then
			vndk="vndk32.mk"
		fi

		part_suffix='a'
		if [ "$part" == 'ab' ];then
			part_suffix='b'
		else
			optional_base='$(call inherit-product, device/phh/treble/base-sas.mk)'
		fi
			target="kscope_treble_${arch}_${part_suffix}"

		baseArch="$arch"
		if [ "$arch" = "a64" ];then
			baseArch="arm"
		fi

		zygote=32
		if [ "$arch" = "arm64" ];then
			zygote=64_32
		fi

		cat > ${target}.mk << EOF
\$(call inherit-product, device/phh/treble/base-pre.mk)
include build/make/target/product/aosp_${baseArch}.mk
\$(call inherit-product, device/phh/treble/base.mk)
$optional_base
$rom_script

PRODUCT_NAME := $target
PRODUCT_DEVICE := phhgsi_${arch}_$part
PRODUCT_BRAND := google
PRODUCT_SYSTEM_BRAND := google
PRODUCT_MODEL := Phh-Treble

# Overwrite the inherited "emulator" characteristics
PRODUCT_CHARACTERISTICS := device

PRODUCT_PACKAGES += $extra_packages

EOF
echo -e '\t$(LOCAL_DIR)/'$target.mk '\' >> AndroidProducts.mk
	done
done
echo >> AndroidProducts.mk
