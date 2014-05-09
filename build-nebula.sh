# nebula kernel compilation script

# Get intial time of script startup
res1=$(date +%s.%N)



# No scrollback buffer
echo -e '\0033\0143'


tput bold
tput setaf 1

echo ""
echo ""
echo ""
echo "         )                   (                   )       (        )       (     ";
echo "      ( /(        (          )\ )    (        ( /(       )\ )  ( /(       )\ )  ";
echo "      )\()) (   ( )\     (  (()/(    )\       )\()) (   (()/(  )\()) (   (()/(  ";
echo "     ((_)\  )\  )((_)    )\  /(_))((((_)(   |((_)\  )\   /(_))((_)\  )\   /(_)) ";
echo "      _((_)((_)((_)_  _ ((_)(_))   )\ _ )\  |_ ((_)((_) (_))   _((_)((_) (_))   ";
echo "     | \| || __|| _ )| | | || |    (_)_\(_) | |/ / | __|| _ \ | \| || __|| |    ";
echo "     | .  || _| | _ \| |_| || |__   / _ \   |   <  | _| |   / | .  || _| | |__  ";
echo "     |_|\_||___||___/ \___/ |____| /_/ \_\  |_|\_\ |___||_|_\ |_|\_||___||____| ";
echo "                                                                                ";
echo ""
echo ""
echo ""


# Confirm device
tput sgr0
echo -e "\n\nCompile nebula kernel for? \n"
echo -e "1. i9082 - Galaxy Grand"
echo -e "2. s2vep - Galaxy S2 Plus"
echo ""
read askDevice



# Export paths and variables in shell
export PATH=$PATH:~/kernel/toolchains/linaro-4.7.4-14.04/bin
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=arm-cortex_a9-linux-gnueabihf-


# Specify colors for shell
red='tput setaf 1'
green='tput setaf 2'
yellow='tput setaf 3'
blue='tput setaf 4'
violet='tput setaf 5'
cyan='tput setaf 6'
white='tput setaf 7'
normal='tput sgr0'
bold='setterm -bold'
date="date"


# Kernel compilation specific details
export KBUILD_BUILD_USER="shubhang"
TOOLCHAIN=~/kernel/toolchains/linaro-4.7.4-14.04/bin/arm-cortex_a9-linux-gnueabihf-

if [ "$askDevice" == "2" ]
	then
		KERNEL_BUILD="nebula-v3.00-s2vep-xenon92-`date '+%Y%m%d-%H%M'`"
	else
		KERNEL_BUILD="nebula-v3.00-i9082-xenon92-`date '+%Y%m%d-%H%M'`"
fi





# Variables
MODULES=./output/flashablezip/system/lib/modules


rm -rf arch/arm/boot/boot.img-zImage
rm -rf output/bootimg_processing
rm -rf output/flashablezip/system
rm -rf output/boot.img
rm -rf output/flashablezip/kernel/zImage
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Copy prebuilt drivers
cp ../drivers/voicesolution/VoiceSolution.ko drivers/voicesolution/

# Making config for nebula kernel
$violet
echo ""
echo ""

$cyan
if [ "$askDevice" == "2" ]

	then
		echo ""
		echo ""
	    echo -e "\n\n     Compiling for s2vep... \n\n"
		echo ""
		echo ""
	        make nebula_s2vep_defconfig
	else
		echo ""
		echo ""
	    echo -e "\n\n     Compiling for i9082... \n\n"
		echo ""
		echo ""
	        make nebula_i9082_defconfig
fi

echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Compiling kernel
$red
echo ""
echo ""
echo "Compiling kernel..."
echo ""
echo ""
make -j8
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Processing boot.img
# $yellow
# echo ""
# echo ""
# echo "Processing boot.img..."
# echo ""
# echo ""
# mkdir output/bootimg_processing
# cp bootimg/stockbootimg/boot.img output/bootimg_processing/boot.img
# cd output/bootimg_processing
# rm -rf unpack
# rm -rf output
# rm -rf boot
# mkdir unpack
# mkdir outputbootimg
# mkdir boot
# cd unpack

# echo ""
# echo ""
# echo "Extracting boot.img..."
# echo ""
# echo ""
# ../../../processing_tools/bootimg_tools/unmkbootimg -i ../boot.img
# cd ../boot
# gzip -dc ../unpack/ramdisk.cpio.gz | cpio -i
# cd ../../../
# echo ""
# echo ""
# echo "==========================================================="
# echo ""
# echo ""


# Copying the required files to make final boot.img
$green
echo ""
echo ""
echo "Copying output files to make the final zip..."
echo ""
echo ""
cp arch/arm/boot/zImage output/flashablezip/kernel/zImage
# rm output/bootimg_processing/bootimage/unpack/boot.img-zImage
# cp arch/arm/boot/boot.img-zImage output/bootimg_processing/unpack/boot.img-zImage	
# rm boot.img-zImage
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Processing modules to be packed along with final boot.img
cd output/flashablezip
mkdir system
mkdir system/app
mkdir system/lib
mkdir system/lib/modules
cd ../../

find -name '*.ko' -exec cp -av {} $MODULES/ \;

$red
echo ""
echo ""
echo "Stripping Modules..."
echo ""
echo ""
cd $MODULES
for m in $(find . | grep .ko | grep './')
do echo $m
$TOOLCHAIN-strip --strip-unneeded $m
done
cd ../../../../../
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Making final boot.img
# $blue
# echo ""
# echo ""
# echo "Making output boot.img..."
# echo ""
# echo ""
# cd output/bootimg_processing/outputbootimg

# ../../../processing_tools/bootimg_tools/mkbootfs ../boot | gzip > ../unpack/boot.img-ramdisk-new.gz

# rm -rf ../../output/bootimg_processing/boot.img
# cd ../../../

# processing_tools/bootimg_tools/mkbootimg --kernel output/bootimg_processing/unpack/boot.img-zImage --ramdisk output/bootimg_processing/unpack/boot.img-ramdisk-new.gz -o output/bootimg_processing/outputbootimg/boot.img --base 0 --pagesize 4096 --kernel_offset 0xa2008000 --ramdisk_offset 0xa3000000 --second_offset 0xa2f00000 --tags_offset 0xa2000100 --cmdline 'console=ttyS0,115200n8 mem=832M@0xA2000000 androidboot.console=ttyS0 vc-cma-mem=0/176M@0xCB000000'

# rm -rf unpack
# rm -rf boot
# echo ""
# echo ""
# echo "==========================================================="
# echo ""
# echo ""


# Making output flashable zip
$green
echo ""
echo ""
echo "Making output flashable zip and packing everything..."
echo ""
echo ""
cd output/flashablezip/
mkdir outputzip
mkdir outputzip/system
mkdir outputzip/system/app
mkdir outputzip/system/lib
mkdir system
mkdir system/lib
mkdir kernel

cp -avr META-INF/ outputzip/
cp -avr system/lib/modules/ outputzip/system/lib/
cp -avr kernel/ outputzip/
# cp ../bootimg_processing/outputbootimg/boot.img outputzip/boot.img
# cp ../performance_control_app/PerformanceControl-2.1.11.apk outputzip/system/app/PerformanceControl-2.1.11.apk

echo ""
echo ""
echo "Moving old zip file..."
echo ""
echo ""
mkdir old_builds_zip
mv outputzip/*.zip old_builds_zip/

echo ""
echo ""
echo "Packing files into zip..."
echo ""
echo ""
cd outputzip
zip -r $KERNEL_BUILD.zip *
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Cleaning
$blue
echo ""
echo ""
echo "Cleaning..."
echo ""
echo ""

rm -rf META-INF
rm -rf system
rm -rf kernel
rm boot.img
rm ../kernel/zImage
cd ../../
rm -rf ../arch/arm/boot/boot.img-zImage
rm -rf bootimg_processing
rm -rf flashablezip/system
cd ..
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Cleaning 
echo ""
echo -e "\n\nCleaning... \n\n"
echo ""
echo ""
make clean mrproper
git checkout drivers/misc/vc04_services/interface/vchiq_arm/vchiq_version.c
echo ""
echo ""
echo "==========================================================="
echo ""
echo ""


# Get elapsed time
$blue
res2=$(date +%s.%N)
echo -e ""
echo -e ""
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
echo -e ""
echo -e ""


# End of script
$red
echo ""
echo "*************END OF KERNEL COMPILATION SCRIPT**************"
echo ""
echo ""
$normal