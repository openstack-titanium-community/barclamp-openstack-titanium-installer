#!/bin/bash
infile='barclamp.lst'
clonelocation="/home/crowbar/barclamps"

# BarClamp clone download location
echo -e "\n\e[1;34m*********************************************************************************\e[0m"
echo -e "\e[1;34m*********************** Starting Crowbar Barclamp Install ***********************\e[0m"

mkdir -p ${clonelocation}
while IFS='|' read  -a fld ; do
	if ! grep -q "#" <<< "${fld[0]}" ; then 
		barclamp=${fld[0]}
		titanium=${fld[1]}
		gitparam=${fld[2]}

		echo -e "\e[8;33m*************************** Processing ${barclamp} *************************\e[0m"
		# Check if latest barclamp is to be pulled from github
		if ! grep -q "installonly" <<< "$1" ; then
			echo "** Removing existing clone from ${clonelocation}/${titanium}"
			rm -rf ${clonelocation}/${titanium}
			echo "** Cloning from ${gitparam}"
			git clone ${gitparam} ${clonelocation}/${titanium}
			echo "** Barclamp Uninstall"
		else
			echo "** INSTALLING EXISTING ${clonelocation}/${titanium}/${barclamp} as  'installonly'  switch detected **"
		fi
		/opt/dell/bin/barclamp_uninstall.rb /opt/dell/barclamps/${barclamp}
		echo "** Deleting barclamp from knife"
		knife cookbook delete --yes --all --no-color ${barclamp}
		echo "** Removing old barclamp directory"
		
		rm -rf /opt/dell/barclamps/${barclamp}
		echo "** Copying new barclamp from ${clonelocation}/${titanium}/${barclamp} to /opt/dell/barclamps"
		cp -a ${clonelocation}/${titanium}/${barclamp} /opt/dell/barclamps/
		
		echo "** Installing new barclamp"
		/opt/dell/bin/barclamp_install.rb /opt/dell/barclamps/${barclamp}
	else
		echo -e "\e[8;33m** INFO: Not Processing ${fld[0]}\e[0m"
	fi
done < "$infile"
echo "Restarting crowbar webserver"
bluepill crowbar-webserver restart
echo -e "\n\e[1;32m*********************** Install Complete Ready for Deploy ***********************\e[0m"
echo -e "\e[1;32m*********************************************************************************\e[0m"