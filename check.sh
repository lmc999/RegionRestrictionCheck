#!/bin/bash

Font_Black="\033[30m";
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_Purple="\033[35m";
Font_SkyBlue="\033[36m";
Font_White="\033[37m";
Font_Suffix="\033[0m";

while getopts ":I:M:L:" optname
do
    case "$optname" in
		"I")
        iface="$OPTARG"
		useNIC="--interface $iface"
        ;;
		"M")
        if [[ "$OPTARG" == "4" ]];then
			NetworkType=4
		elif [[ "$OPTARG" == "6" ]];then
			NetworkType=6
		fi	
        ;;
		"L")
        language="e"
        ;;
		":")
        echo "Unknown error while processing options"
		exit 1
        ;;
    esac
    
done

if [ -z "$iface" ];then
	useNIC=""
fi	

UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)";
WOWOW_Cookie=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==3')
TVer_Cookie="Accept: application/json;pk=BCpkADawqM3ZdH8iYjCnmIpuIRqzCn12gVrtpk_qOePK3J9B6h7MuqOw5T_qIqdzpLvuvb_hTvu7hs-7NsvXnPTYKd9Cgw7YiwI9kFfOOCDDEr20WDEYMjGiLptzWouXXdfE996WWM8myP3Z"

CountRunTimes(){
RunTimes=$(curl -s --max-time 10 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fraw.githubusercontent.com%2Flmc999%2FRegionRestrictionCheck%2Fmain%2Fcheck.sh&count_bg=%2379C83D&title_bg=%2300B1FF&icon=&icon_color=%23E7E7E7&title=script+run+times&edge_flat=false" > ~/couting.txt)
TodayRunTimes=$(cat ~/couting.txt | tail -3 | head -n 1 | awk '{print $5}')
TotalRunTimes=$(cat ~/couting.txt | tail -3 | head -n 1 | awk '{print $7}')
rm -rf ~/couting.txt
}
CountRunTimes

checkos(){
	ifTermux=$(echo $PWD | grep termux)
	ifMacOS=$(uname -a | grep Darwin)
	if [ -n "$ifTermux" ];then
		os_version=Termux
	elif [ -n "$ifMacOS" ];then
		os_version=MacOS	
	else	
		os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	fi
	
	if [[ "$os_version" == "2004" ]] || [[ "$os_version" == "10" ]] || [[ "$os_version" == "11" ]];then
		ssll="-k --ciphers DEFAULT@SECLEVEL=1"
	fi
}
checkos	

checkCPU(){
	CPUArch=$(uname -m)
	if [[ "$CPUArch" == "aarch64" ]];then
		arch=_arm64
	elif [[ "$CPUArch" == "i686" ]];then
		arch=_i686
	elif [[ "$CPUArch" == "arm" ]];then
		arch=_arm
	elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ];then
		arch=_darwin	
	fi
}	
checkCPU

check_dependencies(){

	os_detail=$(cat /etc/os-release 2> /dev/null)
	if_debian=$(echo $os_detail | grep 'ebian')
	if_redhat=$(echo $os_detail | grep 'rhel')
	if [ -n "$if_debian" ];then
		InstallMethod="apt"
	elif [ -n "$if_redhat" ] && [[ "$os_version" -gt 7 ]];then
		InstallMethod="dnf"
	elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
		InstallMethod="yum"
	elif [[ "$os_version" == "Termux" ]];then
		InstallMethod="pkg"
	elif [[ "$os_version" == "MacOS" ]];then
		InstallMethod="brew"	
	fi
	
	python -V > /dev/null 2>&1
		if [[ "$?" -ne "0" ]];then
			python3 -V > /dev/null 2>&1
			if [[ "$?" -eq "0" ]];then
				python3_patch=$(which python3)
				ln -s $python3_patch /usr/bin/python > /dev/null 2>&1
			else
				if [ -n "$if_debian" ];then
					echo -e "${Font_Green}Installing python${Font_Suffix}" 
					$InstallMethod update  > /dev/null 2>&1
					$InstallMethod install python -y  > /dev/null 2>&1
				elif [ -n "$if_redhat" ];then
					echo -e "${Font_Green}Installing python${Font_Suffix}"
					if [[ "$os_version" -gt 7 ]];then
						$InstallMethod update  > /dev/null 2>&1
						$InstallMethod install python3 -y > /dev/null 2>&1
						python3_patch=$(which python3)
						ln -s $python3_patch /usr/bin/python
					else
						$InstallMethod update  > /dev/null 2>&1
						$InstallMethod install python -y > /dev/null 2>&1
					fi	
					
				elif [[ "$os_version" == "Termux" ]];then
					echo -e "${Font_Green}Installing python${Font_Suffix}"
					$InstallMethod update -y > /dev/null 2>&1
					$InstallMethod install python -y > /dev/null 2>&1
					
				elif [[ "$os_version" == "MacOS" ]];then
					echo -e "${Font_Green}Installing python${Font_Suffix}"
					$InstallMethod install python	
					
				fi
			fi	
		fi
	
	dig -v  > /dev/null 2>&1
	if [[ "$?" -ne "0" ]];then
		if [[ "$InstallMethod" == "apt" ]];then
			echo -e "${Font_Green}Installing dnsutils${Font_Suffix}"
			$InstallMethod update  > /dev/null 2>&1
			$InstallMethod install dnsutils -y > /dev/null 2>&1
		elif [[ "$InstallMethod" == "yum" ]];then
			echo -e "${Font_Green}Installing bind-utils${Font_Suffix}"
			$InstallMethod update  > /dev/null 2>&1
			$InstallMethod install bind-utils -y > /dev/null 2>&1
		elif [[ "$InstallMethod" == "pkg" ]];then
			echo -e "${Font_Green}Installing dnsutils${Font_Suffix}"
			$InstallMethod update -y > /dev/null 2>&1
			$InstallMethod install dnsutils -y > /dev/null 2>&1	
		elif [[ "$InstallMethod" == "brew" ]];then
			echo -e "${Font_Green}Installing bind${Font_Suffix}"
			$InstallMethod install bind	
		fi
	fi	
	
	if [[ "$os_version" == "MacOS" ]];then
		md5sum /dev/null > /dev/null 2>&1
		if [[ "$?" -ne "0" ]];then
			echo -e "${Font_Green}Installing md5sha1sum${Font_Suffix}"
			$InstallMethod install md5sha1sum
		fi
	fi		
}		
check_dependencies

local_ipv4=$(curl $useNIC -4 -s --max-time 10 api64.ipify.org)
local_ipv6=$(curl $useNIC -6 -s --max-time 20 api64.ipify.org)
local_isp4=$(curl $useNIC -s -4 --max-time 10 https://api.ip.sb/geoip/${local_ipv4} | cut -f1 -d"," | cut -f4 -d '"')
local_isp6=$(curl $useNIC -s -6 --max-time 10 https://api.ip.sb/geoip/${local_ipv6} | cut -f1 -d"," | cut -f4 -d '"')
		

ShowRegion(){
	echo -e "${Font_Yellow} ---${1}---${Font_Suffix}"
}	

function GameTest_Steam(){
    echo -n -e " Steam Currency:\t\t\t->\c";
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 https://store.steampowered.com/app/761830 2>&1 | grep priceCurrency | cut -d '"' -f4`;
    
    if [ ! -n "$result" ]; then
        echo -n -e "\r Steam Currency:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    else
        echo -n -e "\r Steam Currency:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_HBONow() {
    echo -n -e " HBO Now:\t\t\t\t->\c";
    # 尝试获取成功的结果
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 --write-out "%{url_effective}\n" --output /dev/null https://play.hbonow.com/ 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        # 下载页面成功，开始解析跳转
        if [ "${result}" = "https://play.hbonow.com" ] || [ "${result}" = "https://play.hbonow.com/" ]; then
            echo -n -e "\r HBO Now:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "${result}" = "http://hbogeo.cust.footprint.net/hbonow/geo.html" ] || [ "${result}" = "http://geocust.hbonow.com/hbonow/geo.html" ]; then
            echo -n -e "\r HBO Now:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        fi
    else
        # 下载页面失败，返回错误代码
        echo -e "\r HBO Now:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    fi
}

# 流媒体解锁测试-动画疯
function MediaUnlockTest_BahamutAnime() {
    echo -n -e " Bahamut Anime:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} --user-agent "${UA_Browser}" --max-time 10 -fsSL 'https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=14667' 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
    local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'animeSn');
    if [ -n "$result" ]; then
            echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        else
            echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            
    fi
}

# 流媒体解锁测试-哔哩哔哩大陆限定
function MediaUnlockTest_BilibiliChinaMainland() {
    echo -n -e " BiliBili China Mainland Only:\t\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2> /dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)";
        if [ "${result}" = "0" ]; then
            echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "${result}" = "-10403" ]; then
            echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}No${Font_Suffix}\n"
        else
            echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n"
        fi
    else
        echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"    
    fi
}

# 流媒体解锁测试-哔哩哔哩港澳台限定
function MediaUnlockTest_BilibiliHKMCTW() {
    echo -n -e " BiliBili Hongkong/Macau/Taiwan:\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2> /dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)";
        if [ "${result}" = "0" ]; then
            echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "${result}" = "-10403" ]; then
            echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}No${Font_Suffix}\n"
        else
            echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n"
        fi
    else
        echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"   
    fi
}

# 流媒体解锁测试-哔哩哔哩台湾限定
function MediaUnlockTest_BilibiliTW() {
    echo -n -e " Bilibili Taiwan Only:\t\t\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2> /dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)";
        if [ "${result}" = "0" ]; then
            echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "${result}" = "-10403" ]; then
            echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}No${Font_Suffix}\n"
        else
            echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n"
        fi
    else
        echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"    
    fi
}

# 流媒体解锁测试-Abema.TV
#
function MediaUnlockTest_AbemaTV_IPTest() {
    echo -n -e " Abema.TV:\t\t\t\t->\c";
    #
    local tempresult=$(curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --max-time 10 "https://api.abema.io/v1/ip/check?device=android" 2>&1);
    if [[ "$tempresult" == "000" ]]; then
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
    result=$(curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --max-time 10 "https://api.abema.io/v1/ip/check?device=android" | python -m json.tool 2> /dev/null | grep isoCountryCode | awk '{print $2}' | cut -f2 -d'"')
	if [ -n "$result" ]; then
		if [[ "$result" == "JP" ]]
			then
				echo -n -e "\r Abema.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			else
				echo -n -e "\r Abema.TV:\t\t\t\t${Font_Yellow}Oversea Only${Font_Suffix}\n"
		fi		
	else
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_PCRJP() {
    echo -n -e " Princess Connect Re:Dive Japan:\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 https://api-priconne-redive.cygames.jp/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "404" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_UMAJP() {
    echo -n -e " Pretty Derby Japan:\t\t\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 https://api-umamusume.cygames.jp/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "404" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Kancolle() {
    echo -n -e " Kancolle Japan:\t\t\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 http://203.104.209.7/kcscontents/news/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "200" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_BBCiPLAYER() {
    echo -n -e " BBC iPLAYER:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --max-time 10 https://open.live.bbc.co.uk/mediaselector/6/select/version/2.0/mediaset/pc/vpid/bbc_one_london/format/json/jsfunc/JS_callbacks0)
    if [ "${tmpresult}" = "000" ]; then
        echo -n -e "\r BBC iPLAYER:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return
		
	fi
	
	if [ -n "$tmpresult" ]; then
		result=$(echo $tmpresult | grep 'geolocation')	
		if [ -n "$result" ]; then
			echo -n -e "\r BBC iPLAYER:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		else
			echo -n -e "\r BBC iPLAYER:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		fi
	else
		echo -n -e "\r BBC iPLAYER:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi
}

function MediaUnlockTest_Netflix() {
    echo -n -e " Netflix:\t\t\t\t->\c";
    local result1=$(curl $useNIC -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567" 2>&1)
	
    if [[ "$result1" == "404" ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}Originals Only${Font_Suffix}\n"
        return;
		
	elif  [[ "$result1" == "403" ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return;
		
	elif [[ "$result1" == "200" ]];then
		local region=`tr [:lower:] [:upper:] <<< $(curl $useNIC -${1} --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
		if [[ ! -n "$region" ]];then
			region="US";
		fi
		echo -n -e "\r Netflix:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n"
		return;
		
	elif  [[ "$result1" == "000" ]];then
		echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi   
}

function MediaUnlockTest_YouTube_Region() {
    echo -n -e " YouTube Region:\t\t\t->\c";
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -sSL --max-time 10 "https://www.youtube.com/" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    local result=`curl $useNIC --user-agent "${UA_Browser}" -${1} -sL --max-time 10 "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4`;
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
        return;
    fi
    
    echo -n -e "\r YouTube Region:\t\t\t${Font_Green}US${Font_Suffix}\n"
    return;
}

function MediaUnlockTest_DisneyPlus() {
	echo -n -e " Disney+:\t\t\t\t->\c";
    local disneycookie=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '1p')
	local TokenContent=$(curl $useNIC -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://global.edge.bamgrid.com/token" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycookie")
	local isBanned=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'forbidden-location')
	local is403=$(echo $TokenContent | grep '403 ERROR')
	
	if [ -n "$isBanned" ] || [ -n "$is403" ];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local fakecontent=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '8p')
	local refreshToken=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
    local disneycontent=$(echo $fakecontent | sed "s/ILOVEDISNEY/${refreshToken}/g")
	local tmpresult=$(curl $useNIC -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycontent" 2>&1)
	local previewcheck=$(curl $useNIC -${1} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://disneyplus.com" | grep preview)
	local isUnabailable=$(echo $previewcheck | grep 'unavailable')	
    
    if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
	local region=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
	local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')
	
    if [[ "$region" == "JP" ]];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Green}Yes (Region: JP)${Font_Suffix}\n"
		return;
	elif [ -n "$region" ] && [[ "$inSupportedLocation" == "false" ]] && [ -z "$isUnabailable" ];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Yellow}Available For [Disney+ $region] Soon${Font_Suffix}\n"
		return;
	elif [ -n "$region" ] && [ -n "$isUnavailable" ];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [ -n "$region" ] && [[ "$inSupportedLocation" == "true" ]];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
		return;
	elif [ -z "$region" ];then
		echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Disney+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi
    
    
}

function MediaUnlockTest_Dazn() {
    echo -n -e " Dazn:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} -sS --max-time 10 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' https://startup.core.indazn.com/misl/v5/Startup 2>&1);
    
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    	fi
	isAllowed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'isAllowed' | awk '{print $2}' | cut -f1 -d',')
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"GeolocatedCountry":' | awk '{print $2}' | cut -f2 -d'"')
	
	if [[ "$isAllowed" == "true" ]]; then
		local CountryCode=$(echo $result | tr [:lower:] [:upper:])
		echo -n -e "\r Dazn:\t\t\t\t\t${Font_Green}Yes (Region: ${CountryCode})${Font_Suffix}\n"
		return;
	elif [[ "$isAllowed" == "false" ]]; then
		echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n"
		return;

    fi
}

function MediaUnlockTest_HuluJP() {
    echo -n -e " Hulu Japan:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://id.hulu.jp" | grep login);
    
	if [ -n "$result" ]; then
		echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_MyTVSuper() {
    echo -n -e " MyTVSuper:\t\t\t\t->\c";
    local result=$(curl $useNIC -s -${1} --max-time 10 https://www.mytvsuper.com/iptest.php | grep 'HK');
    
	if [ -n "$result" ]; then
		echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_NowE() {
    echo -n -e " Now E:\t\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"contentId":"202105121370235","contentType":"Vod","pin":"","deviceId":"W-60b8d30a-9294-d251-617b-c12f9d0c","deviceType":"WEB"}' "https://webtvapi.nowe.com/16/1/getVodURL" | python -m json.tool 2> /dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"' 2>&1);
    
	if [[ "$result" == "SUCCESS" ]]; then
		echo -n -e "\r Now E:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "PRODUCT_INFORMATION_INCOMPLETE" ]]; then
		echo -n -e "\r Now E:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
    elif [[ "$result" == "GEO_CHECK_FAIL" ]]; then
		echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
        echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_ViuTV() {
    echo -n -e " Viu.TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"callerReferenceNo":"20210726112323","contentId":"099","contentType":"Channel","channelno":"099","mode":"prod","deviceId":"29b3cb117a635d5b56","deviceType":"ANDROID_WEB"}' "https://api.viu.now.com/p8/3/getLiveURL");
    if [ -z "$tmpresult" ];then
		echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;	
	fi	
		
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"')	
	if [[ "$result" == "SUCCESS" ]]; then
		echo -n -e "\r Viu.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [[ "$result" == "GEO_CHECK_FAIL" ]]; then
		echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
        echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_unext() {
    echo -n -e " U-NEXT:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} -s --max-time 10 "https://video-api.unext.jp/api/1/player?entity%5B%5D=playlist_url&episode_code=ED00148814&title_code=SID0028118&keyonly_flg=0&play_mode=caption&bitrate_low=1500" | python -m json.tool 2> /dev/null | grep 'result_status' | awk '{print $2}' | cut -d ',' -f1);
    if [ -n "$result" ]; then 
		if [[ "$result" == "475" ]]; then
			echo -n -e "\r U-NEXT:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		elif [[ "$result" == "200" ]]; then
			echo -n -e "\r U-NEXT:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;	
		elif [[ "$result" == "467" ]]; then
			echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
			return;
		fi	
	else
		echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_Paravi(){
    echo -n -e " Paravi:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} -Ss --max-time 10 -H "Content-Type: application/json" -d '{"meta_id":17414,"vuid":"3b64a775a4e38d90cc43ea4c7214702b","device_code":1,"app_id":1}' "https://api.paravi.jp/api/v1/playback/auth" 2>&1);
	
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Paravi:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep type | awk '{print $2}' | cut -f2 -d'"')
    if [[ "$result" == "Forbidden" ]]; then
		echo -n -e "\r Paravi:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$result" == "Unauthorized" ]]; then
		echo -n -e "\r Paravi:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
}

function MediaUnlockTest_wowow(){
    echo -n -e " WOWOW:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} -Ss --max-time 10 -b "${WOWOW_Cookie}" -H "x-wod-app-version: 91.0.4472.106" -H "x-wod-model: Chrome" -H "x-wod-os: Windows" -H "x-wod-os-version: 10" -H "x-wod-platform: Windows"  "https://wod.wowow.co.jp/api/streaming/url?contentId=&channel=Live" 2>&1 );
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep code | cut -f4 -d'"')
    if [[ "$checkfailed" == "E0004" ]]; then
		echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$checkfailed" == "E5101" ]]; then	
		echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_TVer(){
    echo -n -e " TVer:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} -Ss --max-time 10 -H "${TVer_Cookie}" "https://edge.api.brightcove.com/playback/v1/accounts/5102072603001/videos/ref%3Afree_episode_code_8121" 2>&1 );
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'error_code' |  cut -f4 -d'"')
    if [[ "$checkfailed" == "ACCESS_DENIED" ]]; then
		echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	fi
	
	checksuccess=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"id":' |  cut -f4 -d'"' | awk 'NR==1')
	if [ -n "$checksuccess" ]; then
		echo -n -e "\r TVer:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_HamiVideo(){
    echo -n -e " Hami Video:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -Ss --max-time 10 "https://hamivideo.hinet.net/api/play.do?id=OTT_VOD_0000249064&freeProduct=1" 2>&1);
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'code' |  cut -f4 -d'"')
    if [[ "$checkfailed" == "06001-106" ]]; then
		echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	elif [[ "$checkfailed" == "06001-107" ]]; then
		echo -n -e "\r Hami Video:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi
}

function MediaUnlockTest_4GTV(){
    echo -n -e " 4GTV.TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -sS --max-time 10 -X POST -d 'value=D33jXJ0JVFkBqV%2BZSi1mhPltbejAbPYbDnyI9hmfqjKaQwRQdj7ZKZRAdb16%2FRUrE8vGXLFfNKBLKJv%2BfDSiD%2BZJlUa5Msps2P4IWuTrUP1%2BCnS255YfRadf%2BKLUhIPj' "https://api2.4gtv.tv//Vod/GetVodUrl3" 2>&1 );
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'Success' |  awk '{print $2}' | cut -f1 -d',')
    if [[ "$checkfailed" == "false" ]]; then
		echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	elif [[ "$checkfailed" == "true" ]]; then
		echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi
}

function MediaUnlockTest_SlingTV() {
    echo -n -e " Sling TV:\t\t\t\t->\c";
    local result=`curl $useNIC --user-agent "${UA_Dalvik}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 https://www.sling.com/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi
}

function MediaUnlockTest_PlutoTV() {
    echo -n -e " Pluto TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://pluto.tv/" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
	local result=$(echo $tmpresult | grep 'thanks-for-watching')
	if [ -n "$result" ]; then
		echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Pluto TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_HBOMax() {
    echo -n -e " HBO Max:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.hbomax.com/" 2>&1);
	if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    local isUnavailable=$(echo $tmpresult | grep 'geo-availability')
	local region=$(echo $tmpresult | cut -f4 -d"/" | tr [:lower:] [:upper:]) 
	if [ -n "$isUnavailable" ]; then
		echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    elif [ -z "$isUnavailable" ] && [ -n "$region" ];then
		echo -n -e "\r HBO Max:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
		return;
	elif [ -z "$isUnavailable" ] && [ -z "$region" ];then
		echo -n -e "\r HBO Max:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
	fi
	
	echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_Channel4() {
    echo -n -e " Channel 4:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://ais.channel4.com/simulcast/C4?client=c4" | grep 'status' |  cut -f2 -d'"');
    
	if [[ "$result" == "ERROR" ]]; then
		echo -n -e "\r Channel 4:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    elif [[ "$result" == "OK" ]]; then
		echo -n -e "\r Channel 4:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Channel 4:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_ITVHUB() {
    echo -n -e " ITV Hub:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://simulcast.itv.com/playlist/itvonline/ITV");
    if [ "$result" = "000" ]; then
		echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "404" ]; then
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_iQYI_Region(){
    echo -n -e " iQyi Oversea Region:\t\t\t->\c";
    curl $useNIC -${1} ${ssll} -s -I --max-time 10 "https://www.iq.com/" > ~/iqiyi
    
    if [ $? -eq 1 ];then
        echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    result=$(cat ~/iqiyi | grep 'mod=' | awk '{print $2}' | cut -f2 -d'=' | cut -f1 -d';')
    if [ -n "$result" ]; then
		if [[ "$result" == "ntw" ]]; then
			result=TW 
			echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
			rm ~/iqiyi >/dev/null 2>&1
			return;
		else
			result=$(echo $result | tr [:lower:] [:upper:]) 
			echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
			rm ~/iqiyi >/dev/null 2>&1
			return;
		fi	
    else
		echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		rm ~/iqiyi >/dev/null 2>&1
		return;
	fi	
}

function MediaUnlockTest_HuluUS(){
    if [[ "$1" == "4" ]];then
		curl $useNIC -fsL -o ./Hulu4.sh.x https://github.com/lmc999/RegionRestrictionCheck/raw/main/binary/Hulu4${arch}.sh.x  > /dev/null 2>&1
		chmod +x ./Hulu4.sh.x
		./Hulu4.sh.x > /dev/null 2>&1
	elif [[ "$1" == "6" ]];then	
		curl $useNIC -fsL -o ./Hulu6.sh.x https://github.com/lmc999/RegionRestrictionCheck/raw/main/binary/Hulu6${arch}.sh.x  > /dev/null 2>&1
		chmod +x ./Hulu6.sh.x
		./Hulu6.sh.x > /dev/null 2>&1
	fi
	
	local result=$?
    
	echo -n -e " Hulu:\t\t\t\t\t->\c";
	if [[ "$result" == "1" ]];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	elif [[ "$result" == "0" ]];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
	elif [[ "$result" == "10" ]];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi
	rm -rf ./*.sh.x
}

function MediaUnlockTest_encoreTVB() {
    echo -n -e " encoreTVB:\t\t\t\t->\c";
    tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 -H "Accept: application/json;pk=BCpkADawqM2Gpjj8SlY2mj4FgJJMfUpxTNtHWXOItY1PvamzxGstJbsgc-zFOHkCVcKeeOhPUd9MNHEGJoVy1By1Hrlh9rOXArC5M5MTcChJGU6maC8qhQ4Y8W-QYtvi8Nq34bUb9IOvoKBLeNF4D9Avskfe9rtMoEjj6ImXu_i4oIhYS0dx7x1AgHvtAaZFFhq3LBGtR-ZcsSqxNzVg-4PRUI9zcytQkk_YJXndNSfhVdmYmnxkgx1XXisGv1FG5GOmEK4jZ_Ih0riX5icFnHrgniADr4bA2G7TYh4OeGBrYLyFN_BDOvq3nFGrXVWrTLhaYyjxOr4rZqJPKK2ybmMsq466Ke1ZtE-wNQ" -H "Origin: https://www.encoretvb.com" "https://edge.api.brightcove.com/playback/v1/accounts/5324042807001/videos/6005570109001" 2>&1 );
    
	if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'error_subcode' | cut -f4 -d'"' )
	if [[ "$result" == "CLIENT_GEO" ]]; then
		echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep 'account_id' > /dev/null 2>&1
    if [ $? -eq 0 ];then
		echo -n -e "\r encoreTVB:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_Molotov(){
    echo -n -e " Molotov:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 "https://fapi.molotov.tv/v1/open-europe/is-france" 2>&1 );
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep 'false' > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -n -e "\r Molotov:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep 'true' > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -n -e "\r Molotov:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
	else
		echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;	
	fi

}

function MediaUnlockTest_Salto(){
    echo -n -e " Salto:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 "https://geo.salto.fr/v1/geoInfo/");
    if [[ "$tmpresult" == "curl"* ]];then
            echo -n -e "\r Salto:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
            return;
    fi

    local CountryCode=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'country_code' | cut -f4 -d'"')
	local AllowedCode="FR,GP,MQ,GF,RE,YT,PM,BL,MF,WF,PF,NC"
	echo ${AllowedCode} | grep ${CountryCode} > /dev/null 2>&1
	
    if [ $? -eq 0 ];then
        echo -n -e "\r Salto:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return;
    else
        echo -n -e "\r Salto:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return;
    fi
}

function MediaUnlockTest_LineTV.TW() {
    echo -n -e " LineTV.TW:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://www.linetv.tw/api/part/11829/eps/1/part?chocomemberId=");
    if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' |awk '{print $2}' | cut -f1 -d',')	
    if [ -n "$result" ];then
		if [ "$result" = "228" ]; then
			echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		fi	
    else
        echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_Viu.com() {
    echo -n -e " Viu.com:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.viu.com/");
    if [ "$tmpresult" = "000" ]; then
		echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	
	result=$(echo $tmpresult | cut -f5 -d"/")
	if [ -n "$result" ]; then
		if [[ "$result" == "no-service" ]]; then
			echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			result=$(echo $result | tr [:lower:] [:upper:])
			echo -n -e "\r Viu.com:\t\t\t\t${Font_Green}Yes (Region: ${result})${Font_Suffix}\n"
			return;
		fi
		
    else
		echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi
}

function MediaUnlockTest_Niconico() {
    echo -n -e " Niconico:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sSL --max-time 10 "https://www.nicovideo.jp/watch/so23017073" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
		echo -n -e "\r Niconico:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	echo $tmpresult | grep '同じ地域' > /dev/null 2>&1 
     if [[ "$?" -eq 0 ]]; then
			echo -n -e "\r Niconico:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r Niconico:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
    fi

}

function MediaUnlockTest_ParamountPlus() {
    echo -n -e " Paramount+:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.paramountplus.com/" | grep 'intl');
    
	if [ -n "$result" ]; then
		echo -n -e "\r Paramount+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Paramount+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Paramount+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_KKTV() {
    echo -n -e " KKTV:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api.kktv.me/v3/ipcheck");
    if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r KKTV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'country' | cut -f4 -d'"')	
    if [[ "$result" == "TW" ]];then
		echo -n -e "\r KKTV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
    else
        echo -n -e "\r KKTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_PeacockTV() {
    echo -n -e " Peacock TV:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.peacocktv.com/" | grep 'unavailable');
    if [[ "$result" == "curl"* ]]; then
        echo -n -e "\r Peacock TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    elif [ -n "$result" ]; then
		echo -n -e "\r Peacock TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Peacock TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Peacock TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_FOD() {
	echo -n -e " FOD(Fuji TV):\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://geocontrol1.stream.ne.jp/fod-geo/check.xml?time=1624504256");
	if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	
    echo $tmpresult | grep 'true' > /dev/null 2>&1
	if [[ "$?" -eq 0 ]]; then
		echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
}

function MediaUnlockTest_Tiktok_Region(){
    echo -n -e " Tiktok Region:\t\t\t\t->\c";
    local Ftmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 10 "https://www.tiktok.com/")
	
	if [ "$Ftmpresult" = "curl"* ]; then
		echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
    
	local FRegion=$(echo $Ftmpresult | grep '"$region":"' | sed 's/.*"$region//' | cut -f3 -d'"')
    if [ -n "$FRegion" ];then
        echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Green}${FRegion}${Font_Suffix}\n"
        return;
	fi
	
	local STmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 10 "https://www.tiktok.com/" -b "s_v_web_id=verify_57c6380f8e4c609135d2afc9894e35ca; tt_csrf_token=73Z-2VskmVwMX0PyUtin6WWI; MONITOR_WEB_ID=verify_57c6380f8e4c609135d2afc9894e35ca")
	local SRegion=$(echo $STmpresult | grep '"$region":"' | sed 's/.*"$region//' | cut -f3 -d'"')
	if [ -n "$SRegion" ];then
        echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Yellow}${SRegion} (IDC IP Detected)${Font_Suffix}\n"
        return;
	else	
		echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi
    
}

function MediaUnlockTest_YouTube_Premium() {
    echo -n -e " YouTube Premium:\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} -sS -H "Accept-Language: en" "https://www.youtube.com/premium" 2>&1 )
    local region=$(curl $useNIC --user-agent "${UA_Browser}" -${1} -sL --max-time 10 "https://www.youtube.com/premium" | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
	if [ -n "$region" ]; then
        sleep 0
	else
		isCN=$(echo $tmpresult | grep 'www.google.cn')
		if [ -n "$isCN" ]; then
			region=CN
		else	
			region=US
		fi	
	fi	
	
    if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    local result=$(echo $tmpresult | grep 'Premium is not available in your country')
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}No${Font_Suffix} ${Font_Green} (Region: $region)${Font_Suffix} \n"
        return;
		
    fi
    local result=$(echo $tmpresult | grep 'YouTube and YouTube Music ad-free')
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return;
	else
		echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		
    fi	
	
    
}

function MediaUnlockTest_YouTube_CDN() {
    echo -n -e " YouTube CDN:\t\t\t\t->\c";
	local tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 https://redirector.googlevideo.com/report_mapping 2>&1)
    
    if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Check Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
	iata=$(echo $tmpresult | grep router | cut -f2 -d'"' | cut -f2 -d"." | sed 's/.\{2\}$//' | tr [:lower:] [:upper:])
	checkfailed=$(echo $tmpresult | grep "=>")
	if [ -z "$iata" ] && [ -n "$checkfailed" ];then
		CDN_ISP=$(echo $checkfailed | awk '{print $3}' | cut -f1 -d"-" | tr [:lower:] [:upper:])
		echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Yellow}Associated with $CDN_ISP${Font_Suffix}\n"
		return;
	elif [ -n "$iata" ];then
		curl $useNIC -s --max-time 10 "https://www.iata.org/AirportCodesSearch/Search?currentBlock=314384&currentPage=12572&airport.search=${iata}" > ~/iata.txt
		local line=$(cat ~/iata.txt | grep -n "<td>"$iata | awk '{print $1}' | cut -f1 -d":")
		local nline=$(expr $line - 2)
		local location=$(cat ~/iata.txt | awk NR==${nline} | sed 's/.*<td>//' | cut -f1 -d"<")
		echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Green}$location${Font_Suffix}\n"
		rm ~/iata.txt
		return;
	else
		echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Red}Undetectable${Font_Suffix}\n"
		rm ~/iata.txt
		return;
	fi
	
}

function MediaUnlockTest_BritBox() {
    echo -n -e " BritBox:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.britbox.com/" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r BritBox:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    local result=$(echo $tmpresult | grep 'locationnotsupported')
	if [ -n "$result" ]; then
		echo -n -e "\r BritBox:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r BritBox:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r BritBox:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_PrimeVideo_Region(){
    echo -n -e " Amazon Prime Video:\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://www.primevideo.com")
	
	if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
    
	local result=$(echo $tmpresult | grep '"currentTerritory":' | sed 's/.*currentTerritory//' | cut -f3 -d'"' | head -n 1)
    if [ -n "$result" ];then
        echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Green}Yes (Region: $result)${Font_Suffix}\n"
        return;
	else
		echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
		return;
    fi
    
}

function MediaUnlockTest_Radiko(){
    echo -n -e " Radiko:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://radiko.jp/area?_=1625406539531")
	
	if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r Radiko:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
    
	local checkfailed=$(echo $tmpresult | grep 'class="OUT"')
    if [ -n "$checkfailed" ];then
		echo -n -e "\r Radiko:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local checksuccess=$(echo $tmpresult | grep 'JAPAN')
	if [ -n "$checksuccess" ];then
		area=$(echo $tmpresult | awk '{print $2}' | sed 's/.*>//')
        echo -n -e "\r Radiko:\t\t\t\t${Font_Green}Yes (City: $area)${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r Radiko:\t\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
		return;
    fi
    
}

function MediaUnlockTest_DMM(){
    echo -n -e " DMM:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://api-p.videomarket.jp/v3/api/play/keyauth?playKey=4c9e93baa7ca1fc0b63ccf418275afc2&deviceType=3&bitRate=0&loginFlag=0&connType=" -H "X-Authorization: 2bCf81eLJWOnHuqg6nNaPZJWfnuniPTKz9GXv5IS")
	
	if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
    
	local checkfailed=$(echo $tmpresult | grep 'Access is denied')
    if [ -n "$checkfailed" ];then
		echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local checksuccess=$(echo $tmpresult | grep 'PlayKey has expired')
	if [ -n "$checksuccess" ];then
		echo -n -e "\r DMM:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
		return;
    fi
    
}

function MediaUnlockTest_Catchplay() {
    echo -n -e " CatchPlay+:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://sunapi.catchplay.com/geo" -H "authorization: Basic NTQ3MzM0NDgtYTU3Yi00MjU2LWE4MTEtMzdlYzNkNjJmM2E0Ok90QzR3elJRR2hLQ01sSDc2VEoy");
    if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'code' |awk '{print $2}' | cut -f2 -d'"')	
    if [ -n "$result" ];then
		if [ "$result" = "0" ]; then
			echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		elif [ "$result" = "100016" ]; then
			echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
			return;
		fi	
	else
		echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_HotStar() {
    echo -n -e " HotStar:\t\t\t\t->\c";
    local result=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.hotstar.com/o/v1/page/1557?offset=0&size=20&tao=0&tas=20")
    if [ "$result" = "000" ]; then
		echo -n -e "\r HotStar:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	elif [ "$result" = "401" ]; then
		local region=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -sI "https://www.hotstar.com" | grep 'geo=' | sed 's/.*geo=//' | cut -f1 -d",")
		local site_region=$(curl $useNIC -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.hotstar.com" | sed 's@.*com/@@' | tr [:lower:] [:upper:] )
		if [ -n "$region" ] && [ "$region" = "$site_region" ];then
			echo -n -e "\r HotStar:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"	
			return;
		else
			echo -n -e "\r HotStar:\t\t\t\t${Font_Red}No${Font_Suffix}\n"	
			return;
		fi	
	elif [ "$result" = "475" ]; then	
		echo -n -e "\r HotStar:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r HotStar:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}


function MediaUnlockTest_LiTV() {
    echo -n -e " LiTV:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 -X POST "https://www.litv.tv/vod/ajax/getUrl" -d '{"type":"noauth","assetId":"vod44868-010001M001_800K","puid":"6bc49a81-aad2-425c-8124-5b16e9e01337"}'  -H "Content-Type: application/json" 2>&1);
    if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'errorMessage' | awk '{print $2}' | cut -f1 -d"," | cut -f2 -d'"')	
    if [ -n "$result" ];then
		if [ "$result" = "null" ]; then
			echo -n -e "\r LiTV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		elif [ "$result" = "vod.error.outsideregionerror" ]; then
			echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		fi	
	else
		echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_FuboTV() {
    echo -n -e " Fubo TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://www.fubo.tv/welcome" | gunzip 2> /dev/null)
    
	local result=$(echo $tmpresult | grep 'countryCode' | sed 's/.*countryCode//' | cut -f3 -d'"')
    if [ -n "$result" ]; then
		if [[ "$result" == "USA" ]];then
			echo -n -e "\r Fubo TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r Fubo TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		fi	
	else
		echo -n -e "\r Fubo TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_Fox() {
    echo -n -e " Fox:\t\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://x-live-fox-stgec.uplynk.com/ausw/slices/8d1/d8e6eec26bf544f084bad49a7fa2eac5/8d1de292bcc943a6b886d029e6c0dc87/G00000000.ts?pbs=c61e60ee63ce43359679fb9f65d21564&cloud=aws&si=0")
    if [ "$result" = "000" ]; then
        echo -n -e "\r FOX:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "200" ]; then
        echo -n -e "\r FOX:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [ "$result" = "403" ]; then
        echo -n -e "\r FOX:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r FOX:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Joyn() {
    echo -n -e " Joyn:\t\t\t\t\t->\c";
    local tmpauth=$(curl $useNIC -${1} ${ssll} -s --max-time 10 -X POST "https://auth.joyn.de/auth/anonymous" -H "Content-Type: application/json" -d '{"client_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7","client_name":"web","anon_device_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7"}');
    if [ -z "$tmpauth" ]; then
		echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	auth=$(echo $tmpauth | python -m json.tool 2> /dev/null | grep access_token | awk '{print $2}' | cut -f2 -d'"')	
	local result=$(curl $useNIC -s "https://api.joyn.de/content/entitlement-token" -H "x-api-key: 36lp1t4wto5uu2i2nk57ywy9on1ns5yg" -H "content-type: application/json" -d '{"content_id":"daserste-de-hd","content_type":"LIVE"}' -H "authorization: Bearer $auth")
    if [ -n "$result" ];then
		isBlock=$(echo $result | python -m json.tool 2> /dev/null | grep 'code' | awk '{print $2}' | cut -f2 -d'"')
		if [[ "$isBlock" == "ENT_AssetNotAvailableInCountry" ]]; then
			echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r Joyn:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		fi	
	else
		echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_SKY_DE() {
    echo -n -e " Sky:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://edge.api.brightcove.com/playback/v1/accounts/1050888051001/videos/6247131490001" -H "Accept: application/json;pk=BCpkADawqM0OXCLe4eIkpyuir8Ssf3kIQAM62a1KMa4-1_vTOWQIxoHHD4-oL-dPmlp-rLoS-WIAcaAMKuZVMR57QY4uLAmP4Ov3V416hHbqr0GNNtzVXamJ6d4-rA3Xi98W-8wtypdEyjGEZNepUCt3D7UdMthbsG-Ean3V4cafT4nZX03st5HlyK1chp51SfA-vKcAOhHZ4_Oa9TTN61tEH6YqML9PWGyKrbuN5myICcGsFzP3R2aOF8c5rPCHT2ZAiG7MoavHx8WMjhfB0QdBr2fphX24CSpUKlcjEnQJnBiA1AdLg9iyReWrAdQylX4Eyhw5OwKiCGJznfgY6BDtbUmeq1I9r9RfmhP5bfxVGjILSEFZgXbMqGOvYdrdare0aW2fTCxeHdHt0vyKOWTC6CS1lrGJF2sFPKn1T1csjVR8s4MODqCBY1PTbHY4A9aZ-2MDJUVJDkOK52hGej6aXE5b9N9_xOT2B9wbXL1B1ZB4JLjeAdBuVtaUOJ44N0aCd8Ns0o02E1APxucQqrjnEociLFNB0Bobe1nkGt3PS74IQcs-eBvWYSpolldMH6TKLu8JqgdnM4WIp3FZtTWJRADgAmvF9tVDUG9pcJoRx_CZ4im-rn-AzN3FeOQrM4rTlU3Q8YhSmyEIoxYYqsFDwbFlhsAcvqQkgaElYtuciCL5i3U8N4W9rIhPhQJzsPafmLdWxBP_FXicyek25GHFdQzCiT8nf1o860Jv2cHQ4xUNcnP-9blIkLy9JmuB2RgUXOHzWsrLGGW6hq9wLUtqwEoxcEAAcNJgmoC0k8HE-Ga-NHXng6EFWnqiOg_mZ_MDd7gmHrrKLkQV" -H "Origin: https://www.sky.de");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Sky:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep error_subcode | cut -f4 -d'"')	
	    if [[ "$result" == "CLIENT_GEO" ]];then
			echo -n -e "\r Sky:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		elif [ -z "$result" ] && [ -n "$tmpresult" ];then
			echo -n -e "\r Sky:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r Sky:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		fi

}

function MediaUnlockTest_ZDF() {
    echo -n -e " ZDF: \t\t\t\t\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 https://ssl.zdf.de/geo/de/geo.txt/)
    if [ "$result" = "000" ]; then
        echo -n -e "\r ZDF: \t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "404" ]; then
        echo -n -e "\r ZDF: \t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r ZDF: \t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r ZDF: \t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_HBOGO_ASIA() {
    echo -n -e " HBO GO Asia:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api2.hbogoasia.com/v1/geog?lang=undefined&version=0&bundleId=www.hbogoasia.com");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep territory)	
	    if [ -z "$result" ];then
			echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		elif [ -n "$result" ];then
			local CountryCode=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep country | cut -f4 -d'"')
			echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Green}Yes (Region: $CountryCode)${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		fi

}

function MediaUnlockTest_HBOGO_EUROPE() {
    echo -n -e " HBO GO Europe:\t\t\t\t->\c";
	local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api.ugw.hbogo.eu/v3.0/GeoCheck/json/HUN")
	if [ -z "$tmpresult" ];then
		echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep allow | awk '{print $2}' | cut -f1 -d",")
	if [[ "$result" == "1" ]];then
		echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "0" ]];then
		echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi	
	
}

function MediaUnlockTest_EPIX() {
    echo -n -e " Epix:\t\t\t\t\t->\c";
	tmpToken=$(curl $useNIC -${1} ${ssll} -s -X POST "https://api.epix.com/v2/sessions" -H "Content-Type: application/json" -d '{"device":{"guid":"e2add88e-2d92-4392-9724-326c2336013b","format":"console","os":"web","app_version":"1.0.2","model":"browser","manufacturer":"google"},"apikey":"f07debfcdf0f442bab197b517a5126ec","oauth":{"token":null}}')
	if [ -z "$tmpToken" ];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	elif [[ "$tmpToken" == "error code"* ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi	
	
	EpixToken=$(echo $tmpToken | python -m json.tool 2> /dev/null | grep 'session_token' | cut -f4 -d'"')
	local tmpresult=$(curl $useNIC -${1} ${ssll} -X POST -s --max-time 10 "https://api.epix.com/v2/movies/16921/play" -d '{}' -H "X-Session-Token: $EpixToken");
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep status | cut -f4 -d'"')	
	if [[ "$result" == "PROXY_DETECTED" ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$result" == "GEO_BLOCKED" ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	elif [[ "$result" == "NOT_SUBSCRIBED" ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_NLZIET() {
    echo -n -e " NLZIET:\t\t\t\t->\c";
	TmpFallBackCode=$(curl $useNIC -X GET -${1} ${ssll} -s --max-time 10 "https://id.nlziet.nl/connect/authorize/callback?client_id=triple-web&redirect_uri=https%3A%2F%2Fapp.nlziet.nl%2Fcallback&response_type=code&scope=openid%20api&state=91b508206f154b8381d3cc9061170527&code_challenge=EF_HpSX8a_leJOXmHqsYpBKjNRX0D8oZh_HfremhSWE&code_challenge_method=S256&response_mode=query" -b "optanonStatus=,C0001,; _gid=GA1.2.301664903.1627130663; OptanonConsent=isIABGlobal=false&datestamp=Sat+Jul+24+2021+20%3A44%3A23+GMT%2B0800+(%E9%A6%99%E6%B8%AF%E6%A0%87%E5%87%86%E6%97%B6%E9%97%B4)&version=6.17.0&hosts=&landingPath=https%3A%2F%2Fapp.nlziet.nl%2F&groups=C0001%3A1%2CC0002%3A0%2CC0003%3A0%2CC0004%3A0; _ga=GA1.2.1715247671.1627130661; _ga_LQL66TVRW1=GS1.1.1627130674.1.1.1627130679.0; _ga_QVB71SF0T8=GS1.1.1627130674.1.1.1627130679.0; .AspNetCore.Antiforgery.iEdXBvgZzA4=CfDJ8IdkGvI8o6RKkusMbm16dgZLQ3gjhTBrGZ5YAf7IYcvZ_uyXtvFmF8n87s9O1A6_hGU2cylV3fP7KrNnOndoMYFzeQTtFjYYe6rKr7G7tnvK5nDlZ1voXmUWbOynzDibE8HvkIICFkMzAZQksRtufiA; _ga_YV1B2GE80N=GS1.1.1627130661.1.1.1627130679.0; idsrv.session=3AF23B3FB60D818D8D6B519258D305C4; idsrv=CfDJ8IdkGvI8o6RKkusMbm16dgY4Sqm-8MQ1fT9qsFj38GA2PTr53t9IZNOTNbfRBqf4_2ymzxFOJr3WeVh_xbqM-yiQtvZ3LKdkZW8jR8g6jE9WeZj5kxdUZYSYRsOkUc-ZCQJA59txaiunIwwgwPfbRYW86mL_ZL_cTVZZldVNHswXPKvDKeeD9ieyXVGvLFEjgEUsNXzukaPN6SFuC0UISPcU8rqU9DdLp0y5QeoqE_z_nTlVgB65F-bGYeKtFVtk1uf7TYDgxnFeTJt5NpigsRk2zcIi0bmrzkgKd7oUQrAfVkUoy8T1-SnHAjN0VpDn4fRE4t1LdsU89IbV99pMVN2hvx5UrNT09lsSllkqzJXYoxC2dLQihWWcfH5J0lUn9GjFPTZWFOSw_6i164eYY2cpfvROcr3MJH0dXPf1kgLXNjN5ejjjCEPmgeMGvFdYS4cusx0tgvDp5R2hpbZGpRXneTgwAjFs9vgYuf_-r7cdb-fdSy-oohsdEDIIz5Zz_-7TvOl3hHEShAYaHjyUYWcm90E-6N3mjm7sBXUe9cDqbqbfpwgr1ciW0GbuZCqXaShrFvjE48EXnwt46TuBDAJJtVm4OZPE8ngJYscQrel7AJvm8tPpv10P6vw_Hva5IvCPxcLkyFj4xnbmY6hBU3-WQNawtZ67098QTEvMKgF44_QI0x5xP8NZ8HR2GDabLtMh88enklIB8_j7dp3RwoSLn9N61gZJWhBj9mU5FioAOGKsNJD4iWtPXKwUU0Yz4XnjD1KYL88BE3j7-Z5qiLQQGWj5GkKk7PLhPMA_PghLjE6KKKoWTny6NSXXyPSGZIHwlV2NGTH8EQmKoBq_xfejG-oBqSP0aCAf2apl6bwDHrBK3YVigLWPlej_4OKj7BC-KXhHxW7bNY4vHQ5EUHw" -I | grep Location | sed 's/.*callback?code=//' | cut -f1 -d"&")
    local tmpauth=$(curl $useNIC -${1} ${ssll} -s --max-time 10 -X POST "https://id.nlziet.nl/connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=triple-web&code=${TmpFallBackCode}&redirect_uri=https%3A%2F%2Fapp.nlziet.nl%2Fcallback&code_verifier=04850de4083d48adb0bf6db3ebfd038fe27a7881de914b95a18d90ceb350316ed05a0e39e72440e6ace015ddc11d28b5&grant_type=authorization_code");
    
	if [ -z "$tmpauth" ]; then
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi	
	
	local auth=$(echo $tmpauth | python -m json.tool 2> /dev/null | grep access_token | awk '{print $2}' | cut -f2 -d'"')	
	local result=$(curl $useNIC -X GET -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.nlziet.nl/v7/stream/handshake/Widevine/Dash/VOD/rJDaXnOP4kaRXnZdR_JofA?playerName=BitmovinWeb" -H "authorization: Bearer $auth")
    
	if [ "$result" = "000" ]; then
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	elif [ "$result" = "500" ]; then	
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	elif [ "$result" = "200" ]; then	
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
	else
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_videoland() {
    echo -n -e " videoland:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://www.videoland.com/api/v3/geo");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r videoland:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep has_access | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "true" ]];then
		echo -n -e "\r videoland:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "false" ]];then
		echo -n -e "\r videoland:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r videoland:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_NPO_Start_Plus() {
    echo -n -e " NPO Start Plus:\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://start-player.npo.nl/video/KN_1726624/streams?profile=dash-widevine&quality=npo&tokenId=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzbWFydHRhZyI6eyJzaXRlSWQiOiI0In0sImhhc1N1YnNjcmlwdGlvbiI6IiIsImhhc1ByZW1pdW1TdWJzY3JpcHRpb24iOiIiLCJlbGVtZW50SWQiOiJwbGF5ZXItS05fMTcyNjYyNCIsIm1lZGlhSWQiOiJLTl8xNzI2NjI0IiwidG9wc3BpbiI6eyJwYXJ0eUlkIjoiIiwicHJvZmlsZUlkIjoiIn0sImhhc1NldHRpbmdzIjoiMSIsImhhc0FkQ29uc2VudCI6IjAiLCJzaGFyZSI6IjAiLCJlbmFibGVUaHVtYm5haWxTY3JvbGwiOiIxIiwibWFya2VycyI6IjEiLCJyZWNvbW1lbmRhdGlvbnMiOiIyNSIsImVuZHNjcmVlbiI6eyJoaWRlX2Zvcl90eXBlcyI6WyJmcmFnbWVudCIsImNsaXAiLCJ0cmFpbGVyIl19LCJzdHlsZVZlcnNpb24iOiIyIiwibW9yZUJ1dHRvbiI6IjEiLCJlbmRPZkNvbnRlbnRUZXh0IjoiMSIsImNocm9tZWNhc3QiOnsiZW5hYmxlZCI6IjEifSwic3R5bGluZyI6eyJ0aXRsZSI6eyJkaXNwbGF5Ijoibm9uZSJ9fSwiYXV0b3BsYXkiOiIwIiwicGFnZVVybCI6Imh0dHA6XC9cL3d3dy5ucG9zdGFydC5ubFwvc3dhbmVuYnVyZ1wvMTktMDctMjAyMVwvS05fMTcyNjYyNCIsInN0ZXJSZWZlcnJhbFVybCI6Imh0dHA6XC9cL3d3dy5ucG9zdGFydC5ubFwvc3dhbmVuYnVyZ1wvMTktMDctMjAyMVwvS05fMTcyNjYyNCIsInN0ZXJTaXRlSWQiOiJucG9zdGFydCIsInN0eWxlc2hlZXQiOiJodHRwczpcL1wvd3d3Lm5wb3N0YXJ0Lm5sXC9zdHlsZXNcL3BsYXllci5jc3MiLCJjb252aXZhIjp7ImVuYWJsZWQiOiIxIiwiYnJvYWRjYXN0ZXJOYW1lIjoiTlBPU1RBUlQifSwiaWF0IjoxNjI3MTM2MTEzLCJuYmYiOjE2MjcxMzYxMTMsImV4cCI6MTYyNzE2NDkxMywiY29uc3VtZXJJZCI6bnVsbCwiaXNQbGF5bGlzdCI6ZmFsc2UsInJlZmVycmVyVXJsIjpudWxsLCJza2lwQ2F0YWxvZyI6MCwibm9BZHMiOjAsImlzcyI6ImV5SnBkaUk2SWpkdldrUjFSbFJRWVcwclREVkZjVWRxWVhOY0x6RkJQVDBpTENKMllXeDFaU0k2SW5KelkwcGFUbVpwWTNoV2MyMXphMXBRU0VOeGVEVkJXamN4YXl0UFZraHJOblJQTTBwM2JsZERabFpxSzBneFRtdzJhV3c1UW1SaGJFcDFWV2hvYUZZaUxDSnRZV01pT2lKbU1EUXdNRE5sTlRGbVlUSmpPR05tTTJVMFpEYzBaREF3TURObU9EaGxNelZoWTJNelltSXhaalJtWTJaa05UUTJZVFF6TURNNE9USTJNVFUzWlRsaUluMD0ifQ.aMQGym3tnPu9JM6Mb8XWCm46cB980Sk-ZGvRX0V2gV8&streamType=broadcast&isYospace=0&videoAgeRating=12&isChromecast=0&mobile=0&ios=0");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local isGeoBlocked=$(echo $tmpresult | sed 's/.*"error":"//' | grep 'Dit programma mag niet bekeken worden vanaf jouw locatie')
	local isError=$(echo $tmpresult | grep erro)	
	if [ -z "$isGeoBlocked" ]; then
		echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [ -z "$isError" ]; then
		echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r NPO Start Plus:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_RakutenTV() {
    echo -n -e " Rakuten TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://rakuten.tv" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    local result=$(echo $tmpresult  | grep 'waitforit')
	if [ -n "$result" ]; then
		echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_HBO_Spain() {
    echo -n -e " HBO Spain:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api-discovery.hbo.eu/v1/discover/hbo?language=null&product=hboe" -H "X-Client-Name: web");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep signupAllowed | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "true" ]];then
		echo -n -e "\r HBO Spain:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "false" ]];then
		echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_PANTAYA() {
    echo -n -e " PANTAYA:\t\t\t\t->\c";
	local authorization=$(curl $useNIC -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://www.pantaya.com/sapi/header/v1/pantaya/us/735a16260c2b450686e68532ccd7f742" -H "Referer: https://www.pantaya.com/es/")
	local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://auth.pantaya.com/api/v4/User/geolocation" -H "AuthTokenAuthorization: $authorization");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r PANTAYA:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local isAllowedAccess=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isAllowedAccess | awk '{print $2}' | cut -f1 -d",")
	local isAllowedCountry=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isAllowedCountry | awk '{print $2}' | cut -f1 -d",")
	local isKnownProxy=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isKnownProxy | awk '{print $2}' | cut -f1 -d",")
	if [[ "$isAllowedAccess" == "true" ]] && [[ "$isAllowedCountry" == "true" ]] && [[ "$isKnownProxy" == "false" ]];then
		echo -n -e "\r PANTAYA:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$isAllowedAccess" == "false" ]];then
		echo -n -e "\r PANTAYA:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$isKnownProxy" == "false" ]];then	
		echo -n -e "\r PANTAYA:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r PANTAYA:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_Starz() {
    echo -n -e " Starz:\t\t\t\t\t->\c";
	local authorization=$(curl $useNIC -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://www.starz.com/sapi/header/v1/starz/us/09b397fc9eb64d5080687fc8a218775b" -H "Referer: https://www.starz.com/us/en/")
	local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://auth.starz.com/api/v4/User/geolocation" -H "AuthTokenAuthorization: $authorization");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local isAllowedAccess=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isAllowedAccess | awk '{print $2}' | cut -f1 -d",")
	local isAllowedCountry=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isAllowedCountry | awk '{print $2}' | cut -f1 -d",")
	local isKnownProxy=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isKnownProxy | awk '{print $2}' | cut -f1 -d",")
	if [[ "$isAllowedAccess" == "true" ]] && [[ "$isAllowedCountry" == "true" ]] && [[ "$isKnownProxy" == "false" ]];then
		echo -n -e "\r Starz:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$isAllowedAccess" == "false" ]];then
		echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$isKnownProxy" == "false" ]];then	
		echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_CanalPlus() {
    echo -n -e " Canal+:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://boutique-tunnel.canalplus.com/" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Canal+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    local result=$(echo $tmpresult | grep 'othercountry') 
	if [ -n "$result" ]; then
		echo -n -e "\r Canal+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Canal+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Canal+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_CBCGem() {
    echo -n -e " CBC Gem:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://www.cbc.ca/g/stats/js/cbc-stats-top.js");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r CBC Gem:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | sed 's/.*country":"//' | cut -f1 -d"}" | cut -f1 -d'"')	
	if [[ "$result" == "CA" ]];then
		echo -n -e "\r CBC Gem:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r CBC Gem:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_AcornTV() {
    echo -n -e " Acorn TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s -L --max-time 10  "https://acorn.tv/");
	local isblocked=$(curl $useNIC -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://acorn.tv/")
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	elif [[ "$isblocked" == "403" ]];then
		echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | grep 'Not yet available in your country')
	if [ -n "$result" ]; then
		echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Acorn TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_Crave() {
    echo -n -e " Crave:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://capi.9c9media.com/destinations/se_atexace/platforms/desktop/bond/contents/2205173/contentpackages/4279732/manifest.mpd");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Crave:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	local result=$(echo $tmpresult | grep 'Geo Constraint Restrictions')
	if [ -n "$result" ]; then
		echo -n -e "\r Crave:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Crave:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_Amediateka() {
    echo -n -e " Amediateka:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://www.amediateka.ru/");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Amediateka:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	local result=$(echo $tmpresult | grep 'VPN')
	if [ -n "$result" ]; then
		echo -n -e "\r Amediateka:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Amediateka:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_MegogoTV() {
    echo -n -e " Megogo TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://ctx.playfamily.ru/screenapi/v4/preparepurchase/web/1?elementId=0b974dc3-d4c5-4291-9df5-81a8132f67c5&elementAlias=51459024&elementType=GAME&withUpgradeSubscriptionReturnAmount=true&forceSvod=true&includeProductsForUpsale=false&sid=mDRnXOffdh_l2sBCyUIlbA" -H "X-SCRAPI-CLIENT-TS: 1627391624026");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep status | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "0" ]];then
		echo -n -e "\r Megogo TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "502" ]];then
		echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_RaiPlay() {
    echo -n -e " Rai Play:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://mediapolisvod.rai.it/relinker/relinkerServlet.htm?cont=VxXwi7UcqjApssSlashbjsAghviAeeqqEEqualeeqqEEqual&output=64");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Rai Play:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	local result=$(echo $tmpresult | grep 'no_available')
	if [ -n "$result" ]; then
		echo -n -e "\r Rai Play:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r Rai Play:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_TVBAnywhere() {
    echo -n -e " TVBAnywhere+:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://uapisfm.tvbanywhere.com.sg/geoip/check/platform/android");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'allow_in_this_country' | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "true" ]];then
		echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "false" ]];then
		echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_ProjectSekai() {
    echo -n -e " Project Sekai: Colorful Stage:\t\t->\c";
    local result=$(curl $useNIC --user-agent "User-Agent: pjsekai/48 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://game-version.sekai.colorfulpalette.org/1.8.1/3ed70b6a-8352-4532-b819-108837926ff5")
    if [ "$result" = "000" ]; then
        echo -n -e "\r Project Sekai: Colorful Stage:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "200" ]; then
        echo -n -e "\r Project Sekai: Colorful Stage:\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Project Sekai: Colorful Stage:\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Project Sekai: Colorful Stage:\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_KonosubaFD() {
    echo -n -e " Konosuba Fantastic Days:\t\t->\c";
    local result=$(curl $useNIC -X POST --user-agent "User-Agent: pj0007/212 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.konosubafd.jp/api/masterlist")
    if [ "$result" = "000" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "200" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_SHOWTIME() {
    echo -n -e " SHOWTIME:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.showtime.com/");
    if [ "$result" = "000" ]; then
		echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_NBATV() {
    echo -n -e " NBA TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sSL --max-time 10 "https://www.nba.com/watch/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
		echo -n -e "\r NBA TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	local result=$(echo $tmpresult | grep 'Service is not available in your region')
     if [ -n "$result" ]; then
			echo -n -e "\r NBA TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r NBA TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
    fi

}

function MediaUnlockTest_ATTNOW() {
    echo -n -e " AT&T NOW:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.atttvnow.com/");
    if [ "$result" = "000" ]; then
		echo -n -e "\r AT&T NOW:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r AT&T NOW:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r AT&T NOW:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_CineMax() {
    echo -n -e " CineMax Go:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://play.maxgo.com/");
    if [ "$result" = "000" ]; then
		echo -n -e "\r CineMax Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r CineMax Go:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r CineMax Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_NetflixCDN(){
	echo -n -e " Netflix Preferred CDN:\t\t\t->\c"
	local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=1")
	if [ -z "$tmpresult" ];then
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return
	elif [ -n "$(echo $tmpresult | grep '>403<')" ];then
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed (IP Banned By Netflix)${Font_Suffix}\n"
		return
	fi
	
	local CDNAddr=$(echo $tmpresult | sed 's/.*"url":"//' | cut -f3 -d"/")
	if [[ "$1" == "6" ]];then
		nslookup -q=AAAA $CDNAddr > ~/v6_addr.txt
		ifAAAA=$(cat ~/v6_addr.txt | grep 'AAAA address' | awk '{print $NF}')
		if [ -z "$ifAAAA" ];then
			CDNIP=$(cat ~/v6_addr.txt | grep Address | sed -n '$p' | awk '{print $NF}')
		else	
			CDNIP=${ifAAAA}
		fi	
	else
		CDNIP=$(nslookup $CDNAddr | sed '/^\s*$/d' | awk 'END {print}' | awk '{print $2}')
	fi
		
	if [ -z "$CDNIP" ];then
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed (CDN IP Not Found)${Font_Suffix}\n"
		rm -rf ~/v6_addr.txt
		return
	fi	
	
	local CDN_ISP=$(curl $useNIC -s --max-time 20 https://api.ip.sb/geoip/$CDNIP | python -m json.tool 2> /dev/null | grep 'isp' | cut -f4 -d'"')
	local iata=$(echo $CDNAddr | cut -f3 -d"-" | sed 's/.\{3\}$//' | tr [:lower:] [:upper:])
	curl $useNIC -s --max-time 10 "https://www.iata.org/AirportCodesSearch/Search?currentBlock=314384&currentPage=12572&airport.search=${iata}" > ~/iata.txt
	local line=$(cat ~/iata.txt | grep -n "<td>"$iata | awk '{print $1}' | cut -f1 -d":")
	local nline=$(expr $line - 2)
	local location=$(cat ~/iata.txt | awk NR==${nline} | sed 's/.*<td>//' | cut -f1 -d"<")
	
	if [ -n "$location" ] && [[ "$CDN_ISP" == "Netflix Streaming Services" ]];then
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Green}$location ${Font_Suffix}\n"
		rm ~/iata.txt
		rm -rf ~/v6_addr.txt
		return
	elif [ -n "$location" ] && [[ "$CDN_ISP" != "Netflix Streaming Services" ]];then
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Yellow}Associated with [$CDN_ISP] in [$location]${Font_Suffix}\n"
		rm ~/iata.txt
		rm -rf ~/v6_addr.txt
		return
	elif [ -n "$location" ] && [ -z "$CDN_ISP" ];then	
		echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}No ISP Info Founded${Font_Suffix}\n"
		rm ~/iata.txt
		rm -rf ~/v6_addr.txt
		return
	fi
}	

function MediaUnlockTest_HBO_Nordic() {
    echo -n -e " HBO Nordic:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api-discovery.hbo.eu/v1/discover/hbo?language=null&product=hbon" -H "X-Client-Name: web");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep signupAllowed | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "true" ]];then
		echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "false" ]];then
		echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_HBO_Portugal() {
    echo -n -e " HBO Portugal:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://api.ugw.hbogo.eu/v3.0/GeoCheck/json/PRT");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep allow | awk '{print $2}' | cut -f1 -d",")	
	if [[ "$result" == "1" ]];then
		echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	elif [[ "$result" == "0" ]];then
		echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_SkyGo() {
    echo -n -e " Sky Go:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sL --max-time 10 "https://skyid.sky.com/authorise/skygo?response_type=token&client_id=sky&appearance=compact&redirect_uri=skygo://auth");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Sky Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | grep "You don't have permission to access")	
	if [ -z "$result" ];then
		echo -n -e "\r Sky Go:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Sky Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_ElevenSportsTW() {
    echo -n -e " Eleven Sports TW:\t\t\t->\c";
	local tmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 10 "https://apis.v-saas.com:9501/member/api/viewAuthorization?contentId=1&memberId=384030&menuId=3&platform=5&imei=c959b475-f846-4a86-8e9b-508048372508")
	local qq=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"qq"' | cut -f4 -d'"')
	local st=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"st"' | cut -f4 -d'"')
	local m3u_RUL=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep boostStreamUrl | cut -f4 -d'"')
    local result=$(curl $useNIC --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "${m3u_RUL}?st=${st}&qq=${qq}")
    if [ "$result" = "000" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "401" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi
}

function MediaUnlockTest_StarPlus() {
	echo -n -e " Star+:\t\t\t\t\t->\c";
    local starcookie=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '9p')
	local TokenContent=$(curl $useNIC -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://star.api.edge.bamgrid.com/token" -H "authorization: Bearer c3RhciZicm93c2VyJjEuMC4w.COknIGCR7I6N0M5PGnlcdbESHGkNv7POwhFNL-_vIdg" -d "$starcookie")
	local isBanned=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'forbidden-location')
	local is403=$(echo $TokenContent | grep '403 ERROR')
	
	if [ -n "$isBanned" ] || [ -n "$is403" ];then
		echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local fakecontent=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '10p')
	local refreshToken=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
    local starcontent=$(echo $fakecontent | sed "s/ILOVESTAR/${refreshToken}/g")
	local tmpresult=$(curl $useNIC -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://star.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: c3RhciZicm93c2VyJjEuMC4w.COknIGCR7I6N0M5PGnlcdbESHGkNv7POwhFNL-_vIdg" -d "$starcontent" 2>&1)
	local previewcheck=$(curl $useNIC -${1} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.starplus.com/login")
	local isUnavailable=$(echo $previewcheck | grep unavailable)
	
    if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	local region=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
    local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')

    if [ -n "$region" ] && [ -z "$isUnavailable" ] && [[ "$inSupportedLocation" == "false" ]];then
		echo -n -e "\r Star+:\t\t\t\t\t${Font_Yellow}CDN Relay Available${Font_Suffix}\n"
		return;
	elif [ -n "$region" ] && [ -n "$isUnavailable" ];then
		echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [ -n "$region" ] && [[ "$inSupportedLocation" == "true" ]];then
		echo -n -e "\r Star+:\t\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
		return;
	elif [ -z "$region" ];then
		echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
    
    
}

function MediaUnlockTest_DirecTVGO() {
    echo -n -e " DirecTV Go:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.directvgo.com/registrarse" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local isForbidden=$(echo $tmpresult | grep 'proximamente')
	local region=$(echo $tmpresult | cut -f4 -d"/" | tr [:lower:] [:upper:])
	if [ -n "$isForbidden" ]; then
		echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    elif [ -z "$isForbidden" ] && [ -n "$region" ];then
		echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_DAM() {
    echo -n -e " Karaoke@DAM:\t\t\t\t->\c";
    local result=$(curl $useNIC --user-agent "${UA_Browser}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "http://cds1.clubdam.com/vhls-cds1/site/xbox/sample_1.mp4.m3u8")
	if [[ "$result" == "000" ]]; then
        echo -n -e "\r Karaoke@DAM:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "200" ]; then
        echo -n -e "\r Karaoke@DAM:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Karaoke@DAM:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Karaoke@DAM:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_DiscoveryPlus() {
    echo -n -e " Discovery+:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://us1-prod-direct.discoveryplus.com/users/me" -b "_gcl_au=1.1.858579665.1632206782; _rdt_uuid=1632206782474.6a9ad4f2-8ef7-4a49-9d60-e071bce45e88; _scid=d154b864-8b7e-4f46-90e0-8b56cff67d05; _pin_unauth=dWlkPU1qWTRNR1ZoTlRBdE1tSXdNaTAwTW1Nd0xUbGxORFV0WWpZMU0yVXdPV1l6WldFeQ; _sctr=1|1632153600000; aam_fw=aam%3D9354365%3Baam%3D9040990; aam_uuid=24382050115125439381416006538140778858; st=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJVU0VSSUQ6Z286NmY4N2JhOTktN2FiOC00NWFjLTg5ZDUtZTRlN2JhMTA3NDU4IiwianRpIjoidG9rZW4tN2UyMGFmMTAtYzBlMi00OWNkLTg2ZWUtYTNkYmYxYzYyMWQxIiwiYW5vbnltb3VzIjp0cnVlLCJpYXQiOjE2MzIyMDY3ODZ9.HakR2iZ9Ma9Hmcp1PXkR9J5GUjDAhEHu5b6ifzU5CIQ; gi_ls=0; _uetvid=a25161a01aa711ec92d47775379d5e4d; AMCV_BC501253513148ED0A490D45%40AdobeOrg=-1124106680%7CMCIDTS%7C18894%7CMCMID%7C24223296309793747161435877577673078228%7CMCAAMLH-1633011393%7C9%7CMCAAMB-1633011393%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1632413793s%7CNONE%7CvVersion%7C5.2.0; ass=19ef15da-95d6-4b1d-8fa2-e9e099c9cc38.1632408400.1632406594" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep currentLocationTerritory | cut -f4 -d'"')
	if [[ "$result" == "us" ]]; then
		echo -n -e "\r Discovery+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_ESPNPlus() {
	echo -n -e " ESPN+:${Font_SkyBlue}[Sponsored by Jam]${Font_Suffix}\t\t->\c";
    local espncookie=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '11p')
	local TokenContent=$(curl -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://espn.api.edge.bamgrid.com/token" -H "authorization: Bearer ZXNwbiZicm93c2VyJjEuMC4w.ptUt7QxsteaRruuPmGZFaJByOoqKvDP2a5YkInHrc7c" -d "$espncookie")
	local isBanned=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'forbidden-location')
	local is403=$(echo $TokenContent | grep '403 ERROR')
	
	if [ -n "$isBanned" ] || [ -n "$is403" ];then
		echo -n -e "\r ESPN+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	local fakecontent=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '10p')
	local refreshToken=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
    local espncontent=$(echo $fakecontent | sed "s/ILOVESTAR/${refreshToken}/g")
	local tmpresult=$(curl -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://espn.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZXNwbiZicm93c2VyJjEuMC4w.ptUt7QxsteaRruuPmGZFaJByOoqKvDP2a5YkInHrc7c" -d "$espncontent" 2>&1)
	
    if [[ "$tmpresult" == "curl"* ]];then
        echo -n -e "\r ESPN+:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	local region=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
    local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')

    if [[ "$region" == "US" ]] && [[ "$inSupportedLocation" == "true" ]];then
		echo -n -e "\r ESPN+:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r ESPN+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
    
    
}

function MediaUnlockTest_Stan() {
    echo -n -e " Stan:\t\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -X POST -sS --max-time 10 "https://api.stan.com.au/login/v1/sessions/web/account");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Stan:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | grep VPNDetected)	
	if [ -z "$result" ];then
		echo -n -e "\r Stan:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Stan:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_Binge() {
    echo -n -e " Binge:\t\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://auth.streamotion.com.au");
    if [ "$result" = "000" ]; then
		echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		is
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_Docplay() {
    echo -n -e " Docplay:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.docplay.com/subscribe" | grep 'geoblocked');
    if [[ "$result" == "curl"* ]]; then
        echo -n -e "\r Docplay:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		isKayoSportsOK=2
        return;
    elif [ -n "$result" ]; then
		echo -n -e "\r Docplay:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		isKayoSportsOK=0
		return;
     else
		echo -n -e "\r Docplay:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		isKayoSportsOK=1
		return;
	fi
	
	echo -n -e "\r Docplay:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	isKayoSportsOK=2
	return;

}

function MediaUnlockTest_OptusSports() {
    echo -n -e " Optus Sports:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://sport.optus.com.au/api/userauth/validate/web/username/restriction.check@gmail.com");
    if [ "$result" = "000" ]; then
		echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_KayoSports() {
    echo -n -e " Kayo Sports:\t\t\t\t->\c";
    if [[ "$isKayoSportsOK" = "2" ]]; then
		echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    elif [[ "$isKayoSportsOK" = "1" ]]; then
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [[ "$isKayoSportsOK" = "0" ]]; then
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_NeonTV() {
    echo -n -e " Neon TV:\t\t\t\t->\c";
	local NeonHeader=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '12p')
	local NeonContent=$(curl -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '13p')
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS -X POST "https://api.neontv.co.nz/api/client/gql?" -H "content-type: application/json" -H "$NeonHeader" -d "$NeonContent");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Neon TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | grep 'RESTRICTED_GEOLOCATION')	
	if [ -z "$result" ];then
		echo -n -e "\r Neon TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Neon TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_SkyGONZ() {
    echo -n -e " SkyGo NZ:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://login.sky.co.nz/authorize?audience=https%3A%2F%2Fapi.sky.co.nz&client_id=dXhXjmK9G90mOX3B02R1kV7gsC4bp8yx&redirect_uri=https%3A%2F%2Fwww.skygo.co.nz&connection=Sky-Internal-Connection&scope=openid%20profile%20email%20offline_access&response_type=code&response_mode=query&state=OXg3QjBGTHpoczVvdG1fRnJFZXVoNDlPc01vNzZjWjZsT3VES2VhN1dDWA%3D%3D&nonce=OEdvci4xZHBHU3VLb1M0T1JRbTZ6WDZJVGQ3R3J0TTdpTndvWjNMZDM5ZA%3D%3D&code_challenge=My5fiXIl-cX79KOUe1yDFzA6o2EOGpJeb6w1_qeNkpI&code_challenge_method=S256&auth0Client=eyJuYW1lIjoiYXV0aDAtcmVhY3QiLCJ2ZXJzaW9uIjoiMS4zLjAifQ%3D%3D");
    if [ "$result" = "000" ]; then
		echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		is
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_ThreeNow() {
    echo -n -e " ThreeNow:\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://bravo-livestream.fullscreen.nz/index.m3u8");
    if [ "$result" = "000" ]; then
		echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		is
		return;
    elif [ "$result" = "200" ]; then
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "403" ]; then
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_MaoriTV() {
    echo -n -e " Maori TV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -s --max-time 10 "https://edge.api.brightcove.com/playback/v1/accounts/1614493167001/videos/6275380737001" -H "Accept: application/json;pk=BCpkADawqM2E9yW4lLgKIEIV5majz5djzZCIqJiYMkP5yYaYdF6AQYq4isPId1ZLtQdGnK1ErLYG0-r1N-3DzAEdbfvw9SFdDWz_i09pLp8Njx1ybslyIXid-X_Dx31b7-PLdQhJCws-vk6Y" -H "Origin: https://www.maoritelevision.com");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep error_subcode | cut -f4 -d'"')	
	    if [[ "$result" == "CLIENT_GEO" ]];then
			echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
		elif [ -z "$result" ] && [ -n "$tmpresult" ];then
			echo -n -e "\r Maori TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
			return;
		else
			echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		fi

}

function MediaUnlockTest_SBSonDemand() {
    echo -n -e " SBS on Demand:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://www.sbs.com.au/api/v3/network?context=odwebsite" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep country_code | cut -f4 -d'"')
	if [[ "$result" == "AU" ]]; then
		echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_ABCiView() {
    echo -n -e " ABC iView:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS --max-time 10 "https://api.iview.abc.net.au/v2/show/abc-kids-live-stream/video/LS1604H001S00?embed=highlightVideo,selectedSeries");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r ABC iView:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | grep 'unavailable outside Australia')	
	if [ -z "$result" ];then
		echo -n -e "\r ABC iView:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r ABC iView:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
	fi

}

function MediaUnlockTest_9Now() {
    echo -n -e " 9Now:\t\t\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://login.nine.com.au" | grep 'geoblock');
    if [[ "$result" == "curl"* ]]; then
        echo -n -e "\r 9Now:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
    elif [ -n "$result" ]; then
		echo -n -e "\r 9Now:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r 9Now:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r 9Now:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_Telasa() {
    echo -n -e " Telasa:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://api-videopass-anon.kddi-video.com/v1/playback/system_status" -H "X-Device-ID: d36f8e6b-e344-4f5e-9a55-90aeb3403799" 2>&1);
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Telasa:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local isForbidden=$(echo $tmpresult | grep IPLocationNotAllowed)
	local isAllowed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"type"' | cut -f4 -d'"')
	if [ -n "$isForbidden" ]; then
		echo -n -e "\r Telasa:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    elif [ -z "$isForbidden" ] && [[ "$isAllowed" == "OK" ]];then
		echo -n -e "\r Telasa:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Telasa:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_SetantaSports() {
    echo -n -e " Setanta Sports:\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://dce-frontoffice.imggaming.com/api/v2/consent-prompt" -H "Realm: dce.adjara" -H "x-api-key: 857a1e5d-e35e-4fdf-805b-a87b6f8364bf" 2>&1);
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return;
	elif [[ "$tmpresult" == "curl"* ]];then
		echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local result=$(echo $tmpresult  | python -m json.tool 2> /dev/null | grep outsideAllowedTerritories | awk '{print $2}' | cut -f1 -d",")
	if [[ "$result" == "true" ]]; then
		echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    elif [[ "$result" == "false" ]]; then
		echo -n -e "\r Setanta Sports:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_MolaTV() {
    echo -n -e " MolaTV:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://mola.tv/api/v2/videos/geoguard/check/vd30491025" 2>&1);
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r MolaTV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return;
	elif [[ "$tmpresult" == "curl"* ]];then
		echo -n -e "\r MolaTV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep isAllowed | awk '{print $2}')
	if [[ "$result" == "true" ]]; then
		echo -n -e "\r MolaTV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [[ "$result" == "false" ]]; then
		echo -n -e "\r MolaTV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r MolaTV:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_BeinConnect() {
    echo -n -e " Bein Sports Connect:\t\t\t->\c";
    local result=$(curl $useNIC -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://proxies.bein-mena-production.eu-west-2.tuc.red/proxy/availableOffers");
    if [ "$result" = "000" ] && [[ "$1" == "6" ]]; then
		echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
		return;
	elif [ "$result" = "000" ]; then
		echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;	
    elif [ "$result" = "500" ]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
    elif [ "$result" = "451" ]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
		return;
    fi

}

function MediaUnlockTest_EurosportRO() {
    echo -n -e " Eurosport RO:\t\t\t\t->\c";
    local tmpresult=$(curl $useNIC -${1} ${ssll} -sS "https://eu3-prod-direct.eurosport.ro/playback/v2/videoPlaybackInfo/sourceSystemId/eurosport-vid1560178?usePreAuth=true" -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJVU0VSSUQ6ZXVyb3Nwb3J0OjlkMWU3MmYyLTdkYjItNDE2Yy1iNmIyLTAwZjQyMWRiN2M4NiIsImp0aSI6InRva2VuLTc0MDU0ZDE3LWFhNWUtNGI0ZS04MDM4LTM3NTE4YjBiMzE4OCIsImFub255bW91cyI6dHJ1ZSwiaWF0IjoxNjM0NjM0MzY0fQ.T7X_JOyvAr3-spU_6wh07re4W-fmbCxZdGaUSZiu1mw' 2>&1);
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return;
	elif [[ "$tmpresult" == "curl"* ]];then
		echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
	fi
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep access.denied.geoblocked)
	if [ -n "$result" ]; then
		echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    else
		echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
	return;

}


function NA_UnlockTest() {
	echo "===========[ North America ]==========="
	MediaUnlockTest_Fox ${1};
	MediaUnlockTest_HuluUS ${1};
	MediaUnlockTest_ESPNPlus ${1};
	MediaUnlockTest_EPIX ${1};
	MediaUnlockTest_Starz ${1};
	MediaUnlockTest_HBONow ${1};
	MediaUnlockTest_HBOMax ${1};
	MediaUnlockTest_BritBox ${1};
	MediaUnlockTest_NBATV ${1};
	MediaUnlockTest_FuboTV ${1};
	MediaUnlockTest_SlingTV ${1};
	MediaUnlockTest_PlutoTV ${1};
	MediaUnlockTest_AcornTV ${1};
	MediaUnlockTest_SHOWTIME ${1};
	MediaUnlockTest_ATTNOW ${1};
	MediaUnlockTest_encoreTVB ${1};
	MediaUnlockTest_CineMax ${1};
	MediaUnlockTest_DiscoveryPlus ${1};
	MediaUnlockTest_ParamountPlus ${1};
	MediaUnlockTest_PeacockTV ${1};
	ShowRegion CA
	MediaUnlockTest_CBCGem ${1};
	MediaUnlockTest_Crave ${1};
	echo "======================================="
}	

function EU_UnlockTest() {
	echo "===============[ Europe ]=============="
	MediaUnlockTest_RakutenTV ${1};
	MediaUnlockTest_HBO_Nordic ${1};
	MediaUnlockTest_HBOGO_EUROPE ${1};
	ShowRegion GB
	MediaUnlockTest_SkyGo ${1};
	MediaUnlockTest_BritBox ${1};
	MediaUnlockTest_ITVHUB ${1};
	MediaUnlockTest_Channel4 ${1};
	MediaUnlockTest_BBCiPLAYER ${1};
	ShowRegion FR	
	MediaUnlockTest_Salto ${1};
	MediaUnlockTest_CanalPlus ${1};
	MediaUnlockTest_Molotov ${1};
	ShowRegion DE		
	MediaUnlockTest_Joyn ${1};
	MediaUnlockTest_SKY_DE ${1};
	MediaUnlockTest_ZDF ${1};
	ShowRegion NL
	MediaUnlockTest_NLZIET ${1};
	MediaUnlockTest_videoland ${1};
	MediaUnlockTest_NPO_Start_Plus ${1};
	ShowRegion ES
	MediaUnlockTest_HBO_Spain ${1};
	MediaUnlockTest_PANTAYA ${1};
	ShowRegion IT
	MediaUnlockTest_RaiPlay ${1};
	ShowRegion RU
	#MediaUnlockTest_MegogoTV ${1};
	MediaUnlockTest_Amediateka ${1};
	ShowRegion PT
	MediaUnlockTest_HBO_Portugal ${1};
	echo "======================================="
}	
	
function HK_UnlockTest(){	
	echo "=============[ Hong Kong ]============="
	MediaUnlockTest_NowE ${1};
	MediaUnlockTest_ViuTV ${1};
	MediaUnlockTest_MyTVSuper ${1};
	MediaUnlockTest_HBOGO_ASIA ${1};
	MediaUnlockTest_BilibiliHKMCTW ${1};
	echo "======================================="
}

function TW_UnlockTest(){	
	echo "==============[ Taiwan ]==============="
	MediaUnlockTest_KKTV ${1};
	MediaUnlockTest_LiTV ${1};
	MediaUnlockTest_4GTV ${1};
	MediaUnlockTest_LineTV.TW ${1};
	MediaUnlockTest_HamiVideo ${1};
	MediaUnlockTest_Catchplay ${1};
	MediaUnlockTest_HBOGO_ASIA ${1};
	MediaUnlockTest_BahamutAnime ${1};
	MediaUnlockTest_ElevenSportsTW ${1};
	MediaUnlockTest_BilibiliTW ${1};
	echo "======================================="
}
	
function JP_UnlockTest() {	
	echo "===============[ Japan ]==============="	
	MediaUnlockTest_DMM ${1};
	MediaUnlockTest_AbemaTV_IPTest ${1};
	MediaUnlockTest_Niconico ${1};
	MediaUnlockTest_Telasa ${1};
	MediaUnlockTest_Paravi ${1};
	MediaUnlockTest_unext ${1};
	MediaUnlockTest_HuluJP ${1};
	MediaUnlockTest_TVer ${1};
	MediaUnlockTest_wowow ${1};
	MediaUnlockTest_FOD ${1};
	MediaUnlockTest_Radiko ${1};
	MediaUnlockTest_DAM ${1};
	ShowRegion Game
	MediaUnlockTest_Kancolle ${1};
	MediaUnlockTest_UMAJP ${1};
	MediaUnlockTest_KonosubaFD ${1};
	MediaUnlockTest_PCRJP ${1};
	MediaUnlockTest_ProjectSekai ${1};
	echo "======================================="
}	

function Global_UnlockTest() {		
	echo ""		
	echo "============[ Multination ]============"	
	MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_HotStar ${1};
	MediaUnlockTest_DisneyPlus ${1};
	MediaUnlockTest_Netflix ${1};
	MediaUnlockTest_YouTube_Premium ${1};
	MediaUnlockTest_PrimeVideo_Region ${1};
	MediaUnlockTest_TVBAnywhere ${1};
	MediaUnlockTest_Tiktok_Region ${1};
	MediaUnlockTest_iQYI_Region ${1};
	MediaUnlockTest_Viu.com ${1};
	MediaUnlockTest_YouTube_CDN ${1};
	MediaUnlockTest_NetflixCDN ${1};
	GameTest_Steam ${1};
	echo "======================================="	
}

function SA_UnlockTest() {
	echo "===========[ South America ]==========="
	MediaUnlockTest_StarPlus ${1};
	MediaUnlockTest_HBOMax ${1};
	MediaUnlockTest_DirecTVGO ${1};
	echo "======================================="
}

function OA_UnlockTest(){	
	echo "==============[ Oceania ]=============="
	MediaUnlockTest_NBATV ${1};
	MediaUnlockTest_AcornTV ${1};
	MediaUnlockTest_SHOWTIME ${1};
	MediaUnlockTest_BritBox ${1};
	MediaUnlockTest_ParamountPlus ${1};
	ShowRegion AU
	MediaUnlockTest_Stan ${1};
	MediaUnlockTest_9Now ${1};
	MediaUnlockTest_Binge ${1};
	MediaUnlockTest_Docplay ${1};
	MediaUnlockTest_ABCiView ${1};
	MediaUnlockTest_KayoSports ${1};
	MediaUnlockTest_OptusSports ${1};
	MediaUnlockTest_SBSonDemand ${1};
	ShowRegion NZ
	MediaUnlockTest_NeonTV ${1};
	MediaUnlockTest_SkyGONZ ${1};
	MediaUnlockTest_ThreeNow ${1};
	MediaUnlockTest_MaoriTV ${1};
	echo "======================================="
}

function Sport_UnlockTest(){	
	echo "===============[ Sport ]==============="
	MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_StarPlus ${1};
	MediaUnlockTest_ESPNPlus ${1};
	MediaUnlockTest_NBATV ${1};
	MediaUnlockTest_FuboTV ${1};
	MediaUnlockTest_MolaTV ${1};
	MediaUnlockTest_SetantaSports ${1};
	MediaUnlockTest_ElevenSportsTW ${1};
	MediaUnlockTest_OptusSports ${1};
	MediaUnlockTest_BeinConnect ${1};
	MediaUnlockTest_EurosportRO ${1};
	
	echo "======================================="
}

function CheckV4() {
	if [[ "$language" == "e" ]];then
		if [[ "$NetworkType" == "6" ]];then
			isv4=0
			echo -e "${Font_SkyBlue}User Choose to Test Only IPv6 Results, Skipping IPv4 Testing...${Font_Suffix}"
			
		else
			echo -e " ${Font_SkyBlue}** Checking Results Under IPv4${Font_Suffix} "
			echo "--------------------------------"
			echo -e " ${Font_SkyBlue}** Your Network Provider: ${local_isp4}${Font_Suffix} "
			check4=`ping 1.1.1.1 -c 1 2>&1`;
			if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
				isv4=1
			else
				echo -e "${Font_SkyBlue}No IPv4 Connectivity Found, Abort IPv4 Testing...${Font_Suffix}"
				isv4=0
			fi

			echo ""
		fi	
	else
		if [[ "$NetworkType" == "6" ]];then
			isv4=0
			echo -e "${Font_SkyBlue}用户选择只检测IPv6结果，跳过IPv4检测...${Font_Suffix}"
			
		else
			echo -e " ${Font_SkyBlue}** 正在测试IPv4解锁情况${Font_Suffix} "
			echo "--------------------------------"
			echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp4}${Font_Suffix} "
			check4=`ping 1.1.1.1 -c 1 2>&1`;
			if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
				isv4=1
			else
				echo -e "${Font_SkyBlue}当前主机不支持IPv4,跳过...${Font_Suffix}"
				isv4=0
			fi

			echo ""
		fi	
	fi	
}

function CheckV6() {
	if [[ "$language" == "e" ]];then
		if [[ "$NetworkType" == "4" ]];then
			isv6=0
			echo -e "${Font_SkyBlue}User Choose to Test Only IPv4 Results, Skipping IPv6 Testing...${Font_Suffix}"
		else	
			check6_1=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.google.com)
			check6_2=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.ip.sb)
			if [[ "$check6_1" -ne "000" ]] || [[ "$check6_2" -ne "000" ]];then
				echo ""
				echo ""
				echo -e " ${Font_SkyBlue}** Checking Results Under IPv6${Font_Suffix} "
				echo "--------------------------------"
				echo -e " ${Font_SkyBlue}** Your Network Provider: ${local_isp6}${Font_Suffix} "
				isv6=1
			else
				echo -e "${Font_SkyBlue}No IPv6 Connectivity Found, Abort IPv6 Testing...${Font_Suffix}"
				isv6=0
			fi
			echo -e "";
		fi	

	else
	
		if [[ "$NetworkType" == "4" ]];then
			isv6=0
			echo -e "${Font_SkyBlue}用户选择只检测IPv4结果，跳过IPv6检测...${Font_Suffix}"
		else	
			check6_1=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.google.com)
			check6_2=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.ip.sb)
			if [[ "$check6_1" -ne "000" ]] || [[ "$check6_2" -ne "000" ]];then
				echo ""
				echo ""
				echo -e " ${Font_SkyBlue}** 正在测试IPv6解锁情况${Font_Suffix} "
				echo "--------------------------------"
				echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp6}${Font_Suffix} "
				isv6=1
			else
				echo -e "${Font_SkyBlue}当前主机不支持IPv6,跳过...${Font_Suffix}"
				isv6=0
			fi
			echo -e "";
		fi	
	fi	
}

function Goodbye(){

	if [[ "$language" == "e" ]];then
		echo -e "${Font_Green}Testing Done! Thanks for Using This Script! ${Font_Suffix}";
		echo -e ""
		echo -e "${Font_Yellow}Number of Script Runs for Today：${TodayRunTimes}; Total Number of Script Runs: ${TotalRunTimes} ${Font_Suffix}"
		echo -e ""
		echo -e "========================================================="
		echo -e "${Font_Red}If you found this script helpful, you can but me a coffee${Font_Suffix}"
		echo -e "USDT: TL2iHGTADmAyWYCafBHF5vMbPe13zSyJu2"
		echo -e "BTC: 3GmeB6zsrgu8FMB4z7dBAGmDEq4v6Td8EB"
		echo -e "ETH：0x5A1a337270a36Bbbb5477BdD9C438c70a212C7fD"
		echo -e "LTC：LQD4S6Y5bu3bHX6hx8ASsGHVfaqFGFNTbx"
		echo -e "========================================================="
	else	
		echo -e "${Font_Green}本次测试已结束，感谢使用此脚本 ${Font_Suffix}";
		echo -e ""
		echo -e "${Font_Yellow}检测脚本当天运行次数：${TodayRunTimes}; 共计运行次数：${TotalRunTimes} ${Font_Suffix}"
		echo -e ""
		echo -e "================================================"
		echo -e "${Font_Red}如本项目对你有帮助，可考虑请作者喝一瓶营养快线${Font_Suffix}"
		echo -e "USDT: TL2iHGTADmAyWYCafBHF5vMbPe13zSyJu2"
		echo -e "BTC: 3GmeB6zsrgu8FMB4z7dBAGmDEq4v6Td8EB"
		echo -e "ETH：0x5A1a337270a36Bbbb5477BdD9C438c70a212C7fD"
		echo -e "LTC：LQD4S6Y5bu3bHX6hx8ASsGHVfaqFGFNTbx"
		echo -e "================================================"
	fi	
}

clear;

function ScriptTitle(){
	if [[ "$language" == "e" ]];then
		echo -e "【Stream Platform & Game Region Restriction Test】";
		echo ""
		echo -e "${Font_Green}Github Repository:${Font_Suffix} ${Font_Yellow} https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}";
		echo -e "${Font_Green}Telegram Discussion Group:${Font_Suffix} ${Font_Yellow} https://t.me/gameaccelerate ${Font_Suffix}";
		echo -e "${Font_Purple}Supporting OS: CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android with Termux${Font_Suffix}"
		echo ""
		echo -e " ** Test Starts At: $(date)";
		echo ""
	else
		echo -e "【流媒体平台及游戏区域限制测试】";
		echo ""
		echo -e "${Font_Green}项目地址${Font_Suffix} ${Font_Yellow}https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}";
		echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/gameaccelerate ${Font_Suffix}";
		echo -e "${Font_Purple}脚本适配OS: CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android with Termux${Font_Suffix}"
		echo ""
		echo -e " ** 测试时间: $(date)";
		echo ""
	fi
}
ScriptTitle

function Start(){
	if [[ "$language" == "e" ]];then
		echo -e "${Font_Blue}Please Select Test Region or Press ENTER to Test All Regions${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【1】：【 Multination + Taiwan 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【2】：【 Multination + Hong Kong 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【3】：【 Multination + Japan 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【4】：【 Multination + North America 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【5】：【 Multination + South America 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【6】：【 Multination + Europe 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【7】：【 Multination + Oceania 】${Font_Suffix}"
		echo -e "${Font_SkyBlue}Input Number【0】：【 Multination Only 】${Font_Suffix}" 
		echo -e "${Font_SkyBlue}Input Number【99】：【 Sport Platforms 】${Font_Suffix}"
		read -p "Please Input the Correct Number or Press ENTER:" num
	else
		echo -e "${Font_Blue}请选择检测项目，直接按回车将进行全区域检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【1】：【 跨国平台+台湾平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【2】：【 跨国平台+香港平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【3】：【 跨国平台+日本平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【4】：【 跨国平台+北美平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【5】：【 跨国平台+南美平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【6】：【 跨国平台+欧洲平台 】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【7】：【跨国平台+大洋洲平台】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【0】：【   只进行跨国平台  】检测${Font_Suffix}"
		echo -e "${Font_SkyBlue}输入数字【99】 【   体育直播平台    】检测${Font_Suffix}"
		read -p "请输入正确数字或直接按回车:" num
	fi	
}
Start

function RunScript(){
	if [[ -n "${num}" ]]; then
		if [[ "$num" -eq 1 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				TW_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				TW_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 2 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				HK_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				HK_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 3 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				JP_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				JP_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 4 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				NA_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				NA_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 5 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				SA_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				SA_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 6 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				EU_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				EU_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 7 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
				OA_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				OA_UnlockTest 6
			fi	
			Goodbye	
			
		elif [[ "$num" -eq 99 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Sport_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Sport_UnlockTest 6
			fi	
			Goodbye	
		
		elif [[ "$num" -eq 0 ]]; then
			clear
			ScriptTitle
			CheckV4
			if [[ "$isv4" -eq 1 ]];then
				Global_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
			fi	
			Goodbye
			
		else
			echo -e "${Font_Red}请重新执行脚本并输入正确号码${Font_Suffix}"
			echo -e "${Font_Red}Please Re-run the Script with Correct Number Input${Font_Suffix}"
			return
		fi
	else
		clear
		ScriptTitle
		CheckV4
		if [[ "$isv4" -eq 1 ]];then
			Global_UnlockTest 4
			TW_UnlockTest 4
			HK_UnlockTest 4
			JP_UnlockTest 4
			NA_UnlockTest 4	
			SA_UnlockTest 4
			EU_UnlockTest 4
			OA_UnlockTest 4
		fi	
		CheckV6
		if [[ "$isv6" -eq 1 ]];then
			Global_UnlockTest 6
			TW_UnlockTest 6
			HK_UnlockTest 6
			JP_UnlockTest 6
			NA_UnlockTest 6	
			SA_UnlockTest 6
			EU_UnlockTest 6	
			OA_UnlockTest 6
		fi
		Goodbye	
	fi
}

RunScript
