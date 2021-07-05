#!/bin/bash
# Run from root directory of linux-offline-packaging-ks

# Script variables
generate_essentials_tar_xz=false

# Check if user needs to generate Essentials.tar.xz
if [ "$1" == "--generate-essentials-archive" ]; then
	generate_essentials_tar_xz=true
	echo "--generate-essentials-archive invoked"
fi

# Restore packages
echo "- Restoring packages..."
echo "  - cd Kernel-Simulator"
cd Kernel-Simulator
echo "  - HOME=`pwd`/nuget msbuild -t:restore"
HOME=`pwd`/nuget msbuild -t:restore
if [ "$?" -ne 0 ]; then
	exit $?
fi

# Copy dependencies to Kernel-Simulator/deps
echo "- Copying dependencies to Kernel-Simulator/deps..."
echo "  - mkdir deps"
mkdir deps
echo "  - cp -R ./nuget/.nuget/packages/* ./deps/"
cp -R ./nuget/.nuget/packages/* ./deps/

# Compressing essential packages
if [ ${generate_essentials_tar_xz} == true ]; then
	echo "- Compressing essential packages to Essentials.tar..."
	echo "  - tar cfv ../Essentials.tar deps"
	tar cfv ../Essentials.tar deps
	echo "  - xz -9 ../Essentials.tar"
	xz -9 ../Essentials.tar
fi

# Copy NuGet.config for offline use
echo "- Copying NuGet.config..."
echo "  - cp ../offline/NuGet.config ."
cp ../offline/NuGet.config .

echo "- Build using \"msbuild\" from the \"Kernel-Simulator\" directory."
echo "- For Launchpad PPAs and general Ubuntu package builds, change \"preview\" in \"debian/changelog\" to \"focal\" or any Ubuntu codename."
echo "- You may want to run \"dch -U\" to sign your custom KS package changelog."
echo "- Use \"debuild -S -sa\" to build source package for \"sbuild\"."
echo "- Undo patches once done."

