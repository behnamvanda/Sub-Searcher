#!/bin/bash
# Subdomain Lister Coded By Behnam Abbasi Vanda

SHODAN_APIKEY="rOvZVcxLJEu5BNyy10iish25sib24oDE" # insert shodan api key here

# =====================

TARGET_LIST="$1"

# =====================
RED="\e[1;91m"
GREEN="\e[1;92m"
YELLOW="\e[1;93m"
BLUE="\e[1;94m"
MAGENTA="\e[1;95m"
CYAN="\e[1;96m"
WHITE="\e[1;97m"
DARK_RED="\e[0;31m"
DARK_GREEN="\e[0;32m"
DARK_YELLOW="\e[0;33m"
DARK_BLUE="\e[0;34m"
DARK_MAGENTA="\e[0;35m"
DARK_CYAN="\e[0;36m"
DARK_WHITE="\e[0;37m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"
BG_WHITE="\e[47m"
NOR="\e[0m"
# ====================


find_subdomain() 
{
dom=$1

if [ -e "temp_sub.txt" ]; then
    rm -rf temp_sub.txt

fi 

#------------------------------------------
echo  -ne "	[~] searching$BOLD $dom $NOR$MAGENTA[jldc]$NOR" 

jldc=`curl --silent --insecure https://jldc.me/anubis/subdomains/$dom | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u`

jldc_num=$(printf "%s\n" "$jldc" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[jldc]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$jldc_num]$NOR"
echo "$jldc" >> temp_sub.txt

#-------------------------------------------

#------------------------------------------
echo  -ne "	[~] searching$BOLD $dom $NOR$MAGENTA[alienvault]$NOR" 

alienvault=`curl --silent --insecure  https://otx.alienvault.com/api/v1/indicators/domain/$dom/passive_dns | jq --raw-output '.passive_dns[]?.hostname'  | grep -P "${dom}" | sort -u`

alienvault_num=$(printf "%s\n" "$alienvault" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[alienvault]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$alienvault_num]$NOR"
echo "$alienvault" >> temp_sub.txt

#-------------------------------------------
echo  -ne "	[~] searching$BOLD $dom $NOR$MAGENTA[Certspotter]$NOR " 
certspotter=`curl --silent --insecure --request GET --url "https://api.certspotter.com/v1/issuances?domain=$dom&include_subdomains=true&expand=dns_names" | jq --raw-output -r '.[].dns_names[]' | sed 's/\*\.//g' | tr -d "\"" | grep -P "${dom}" | sort -u` 

certspotter_num=$(printf "%s\n" "$certspotter" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[Certspotter]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$certspotter_num]$NOR"
echo "$certspotter" >> temp_sub.txt

#-------------------------------------------
echo  -ne "	[~] searching$BOLD $dom $NOR$MAGENTA[rapiddns]$NOR "

rapiddns1=`curl --silent --insecure https://rapiddns.io/subdomain/$dom | grep "$dom" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep -P "${dom}" | sort -u`

rapiddns2=`curl --silent --insecure https://rapiddns.io/subdomain/$dom?page=2 | grep "$dom" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep -P "${dom}" | sort -u`

rapiddns3=`curl --silent --insecure https://rapiddns.io/subdomain/$dom?page=2 | grep "$dom" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep -P "${dom}" | sort -u`


echo "$rapiddns1" >> rapid
echo "$rapiddns2" >> rapid
echo "$rapiddns3" >> rapid

rapiddns_num=$(cat rapid | sort -u | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[rapiddns]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$rapiddns_num]$NOR"
cat rapid | grep -v 'Rapid DNS Information'| sort -u >> temp_sub.txt

rm -rf rapid

#-------------------------------------------
echo  -ne "	[>] searching$BOLD $dom $NOR$MAGENTA[Shodan]$NOR "

curl --silent --insecure --url "https://api.shodan.io/dns/domain/$dom?key=$SHODAN_APIKEY" | jq --raw-output -r .subdomains[]? | egrep -iv "_dmarc" |  sort -u > temp
 
     for i in $(cat temp);do echo ${i}.${dom} >> temp2 ; done ; rm -r temp
     
shodan_num=$(cat temp2 | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[Shodan]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$shodan_num]$NOR"
echo "$temp2" >> temp_sub.txt     
rm -r temp2     

#-------------------------------------------
echo  -ne "	[>] searching$BOLD $dom $NOR$MAGENTA[hackertarget]$NOR "

hackertarget=`curl -s --insecure https://api.hackertarget.com/hostsearch/?q=$dom| grep -o -E "[a-zA-Z0-9._-]+\.$dom" | sort -u`

hackertarget_num=$(printf "%s\n" "$hackertarget" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[hackertarget]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$hackertarget_num]$NOR"
echo "$hackertarget" >> temp_sub.txt


#-------------------------------------------
echo  -ne "	[>] searching$BOLD $dom $NOR$MAGENTA[urlscan]$NOR "

urlscan=`curl -s "https://urlscan.io/api/v1/search/?q=$dom" | jq --raw-output '.results[].page.url?' | grep -e "$dom" | sort -u | sed -e 's_https*://__' -e "s/\/.*//" -e 's/:.*//' -e 's/^www\.//'  | sed "/@/d" | sed -e 's/\.$//' | grep -P "${dom}" | sort -u`

urlscan_num=$(printf "%s\n" "$urlscan" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[urlscan]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$urlscan_num]$NOR"
echo "$urlscan" >> temp_sub.txt

#-------------------------------------------
echo  -ne "	[>] searching$BOLD $dom $NOR[webarchive] "

webarchive=`curl --silent --insecure "http://web.archive.org/cdx/search/cdx?url=*.$dom/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" -e 's/:.*//' -e 's/^www\.//' | sed "/@/d" | sed -e 's/\.$//' | grep -P "${dom}" | sort -u`

webarchive_num=$(printf "%s\n" "$webarchive" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[webarchive]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$webarchive_num]$NOR"
echo "$webarchive" >> temp_sub.txt

#-------------------------------------------
echo  -ne "	[>] searching$BOLD $dom $NOR$MAGENTA[assetfinder]$NOR "

af=`assetfinder -subs-only $dom -silent`

af_num=$(printf "%s\n" "$af" | wc -l)

echo -e "\r	[~] searching $dom $MAGENTA[assetfinder]$NOR$BOLD Done!$NOR Result: $BOLD$GREEN [$af_num]$NOR"
echo "$af" >> temp_sub.txt

#-------------------------------------------

cat temp_sub.txt | awk '{gsub("www.","")}1' | sort -u > subs.txt

subs_num=$(cat subs.txt | wc -l)

echo -e "\r	[~]$BOLD Total Subdomains:$RED [$subs_num]$NOR"

rm -rf temp_sub.txt

}



mybanner()
{
echo '
	░██████╗██╗░░░██╗██████╗░░██████╗███████╗░█████╗░██████╗░░█████╗░██╗░░██╗███████╗██████╗░
	██╔════╝██║░░░██║██╔══██╗██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██║░░██║██╔════╝██╔══██╗
	╚█████╗░██║░░░██║██████╦╝╚█████╗░█████╗░░███████║██████╔╝██║░░╚═╝███████║█████╗░░██████╔╝
	░╚═══██╗██║░░░██║██╔══██╗░╚═══██╗██╔══╝░░██╔══██║██╔══██╗██║░░██╗██╔══██║██╔══╝░░██╔══██╗
	██████╔╝╚██████╔╝██████╦╝██████╔╝███████╗██║░░██║██║░░██║╚█████╔╝██║░░██║███████╗██║░░██║
	╚═════╝░░╚═════╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
'
}


mainbrain()
{

    mybanner
    echo       "	----------------------------------------------------------------" 
if test "$#" -ne 1; then
    echo "	[!] Please give the target list file : bash sublister.sh targets.txt "
    echo "	> Note : Targets should not include http/https/www !"
    echo       "	---------------------------------------------------------------"
    exit
fi

for dom in `cat $TARGET_LIST`
do
	find_subdomain $dom
done
}


mainbrain $TARGET_LIST;




