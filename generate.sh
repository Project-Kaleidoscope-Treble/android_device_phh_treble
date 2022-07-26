#!/bin/bash

echo 'PRODUCT_MAKEFILES := \' > AndroidProducts.mk

for part in a ab;do
    for product in common_no_telephony mobile tablet tablet_no_telephony;do
		for arch in arm64 arm a64;do
			extra_packages=""

			rom_script='$(call inherit-product, 'vendor/kscope/target/product/${product}.mk')'
	                product_suffix=""
			if [ "$product" == "common_no_telephony" ];then
				product_suffix="C"
				model_description="Device with no telephony feature"
			elif [ "$product" == "mobile" ];then
				product_suffix="M"
				model_description="Mobile phone"
			elif [ "$product" == "tablet" ];then
				product_suffix="T"
				model_description="Tablet"
			elif [ "$product" == "tablet_no_telephony" ];then
				product_suffix="t"
				model_description="Tablet with no telephony feature"
			fi
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
				target="kscope_treble_${arch}_${part_suffix}${product_suffix}"

			baseArch="$arch"
			if [ "$arch" = "a64" ];then
				baseArch="arm"
			fi

			zygote=32
			if [ "$arch" = "arm64" ];then
				zygote=64_32
			fi

			cat > ${target}.mk << EOF
include build/make/target/product/aosp_${baseArch}.mk
\$(call inherit-product, device/phh/treble/base.mk)
$optional_base
$rom_script

PRODUCT_NAME := $target
PRODUCT_DEVICE := phhgsi_${arch}_$part
PRODUCT_BRAND := google
PRODUCT_SYSTEM_BRAND := google
PRODUCT_MODEL := Phh-Treble for ${model_description}

# Overwrite the inherited "emulator" characteristics
PRODUCT_CHARACTERISTICS := device

PRODUCT_PACKAGES += $extra_packages

EOF
echo -e '\t$(LOCAL_DIR)/'$target.mk '\' >> AndroidProducts.mk
		done
	done
done
echo >> AndroidProducts.mk
