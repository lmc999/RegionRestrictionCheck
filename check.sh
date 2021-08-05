#!/bin/bash
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)";

disneyauth="grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Atoken-exchange&latitude=0&longitude=0&platform=browser&subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiNDAzMjU0NS0yYmE2LTRiZGMtOGFlOS04ZWI3YTY2NzBjMTIiLCJhdWQiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOnRva2VuIiwibmJmIjoxNjIyNjM3OTE2LCJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmRldmljZSIsImV4cCI6MjQ4NjYzNzkxNiwiaWF0IjoxNjIyNjM3OTE2LCJqdGkiOiI0ZDUzMTIxMS0zMDJmLTQyNDctOWQ0ZC1lNDQ3MTFmMzNlZjkifQ.g-QUcXNzMJ8DwC9JqZbbkYUSKkB1p4JGW77OON5IwNUcTGTNRLyVIiR8mO6HFyShovsR38HRQGVa51b15iAmXg&subject_token_type=urn%3Abamtech%3Aparams%3Aoauth%3Atoken-type%3Adevice"
disneyheader="authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84"
WOWOW_Cookie=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==3')
TVer_Cookie="Accept: application/json;pk=BCpkADawqM3ZdH8iYjCnmIpuIRqzCn12gVrtpk_qOePK3J9B6h7MuqOw5T_qIqdzpLvuvb_hTvu7hs-7NsvXnPTYKd9Cgw7YiwI9kFfOOCDDEr20WDEYMjGiLptzWouXXdfE996WWM8myP3Z"



Font_Black="\033[30m";
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_Purple="\033[35m";
Font_SkyBlue="\033[36m";
Font_White="\033[37m";
Font_Suffix="\033[0m";

checkos(){

	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	if [[ "$os_version" == "2004" ]];then
		ssll="-k --ciphers DEFAULT@SECLEVEL=1"
	elif [[ "$os_version" == "10" ]];then	
		ssll="-k --ciphers DEFAULT@SECLEVEL=1"
	else
		ssll=""
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
	fi
}	
checkCPU

check_dependencies(){

	os_detail=$(cat /etc/os-release)
	if_debian=$(echo $os_detail | grep 'ebian')
	if_redhat=$(echo $os_detail | grep 'rhel')
	local os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	
	python -V > /dev/null 2>&1
		if [[ "$?" -ne "0" ]];then
			python3 -V > /dev/null 2>&1
			if [[ "$?" -ne "0" ]];then
				python3_patch=$(which python3)
				ln -s $python3_patch /usr/bin/python > /dev/null 2>&1
			else
				if [ -n "$if_debian" ];then
					echo -e "${Font_Green}正在安装python${Font_Suffix}" 
					apt update  > /dev/null 2>&1
					apt install python -y  > /dev/null 2>&1
					
				elif [ -n "$if_redhat" ];then
					echo -e "${Font_Green}正在安装python${Font_Suffix}"
					if [[ "$os_version" -gt 7 ]];then
						dnf install python3 -y > /dev/null 2>&1
						python3_patch=$(which python3)
						ln -s $python3_patch /usr/bin/python
					else
						yum install python -y > /dev/null 2>&1
					fi	
					
					
				fi
			fi	
		fi
}		
check_dependencies

local_ipv4=$(curl -4 -s --max-time 30 api64.ipify.org)
local_ipv6=$(curl -6 -s --max-time 20 api64.ipify.org)
if [ -n "$local_ipv4" ]
	then
		local_isp=$(curl -s -4 --max-time 30 https://api.ip.sb/geoip/${local_ipv4} | cut -f1 -d"," | cut -f4 -d '"')
	else
		local_isp=$(curl -s -6 --max-time 30 https://api.ip.sb/geoip/${local_ipv6} | cut -f1 -d"," | cut -f4 -d '"')
fi		

ShowRegion(){
	echo -e "${Font_Yellow} ---${1}---${Font_Suffix}"
}	

function GameTest_Steam(){
    echo -n -e " Steam Currency:\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 https://store.steampowered.com/app/761830 2>&1 | grep priceCurrency | cut -d '"' -f4`;
    
    if [ ! -n "$result" ]; then
        echo -n -e "\r Steam Currency:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    else
        echo -n -e "\r Steam Currency:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_HBONow() {
    echo -n -e " HBO Now:\t\t\t\t->\c";
    # 尝试获取成功的结果
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 --write-out "%{url_effective}\n" --output /dev/null https://play.hbonow.com/ 2>&1`;
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
    local tmpresult=$(curl -${1} --user-agent "${UA_Browser}" --max-time 30 -fsSL 'https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=14667' 2>&1);
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
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
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
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
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
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
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
    local tempresult=$(curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --max-time 30 "https://api.abema.io/v1/ip/check?device=android" 2>&1);
    if [[ "$tempresult" == "000" ]]; then
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
    result=$(curl --user-agent "${UA_Dalvik}" -${1} -fsL --max-time 30 "https://api.abema.io/v1/ip/check?device=android" | python -m json.tool 2> /dev/null | grep isoCountryCode | awk '{print $2}' | cut -f2 -d'"')
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
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-priconne-redive.cygames.jp/`;
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
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-umamusume.cygames.jp/`;
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
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://203.104.209.7/kcscontents/`;
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --max-time 30 https://open.live.bbc.co.uk/mediaselector/6/select/version/2.0/mediaset/pc/vpid/bbc_one_london/format/json/jsfunc/JS_callbacks0)
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
    local result1=$(curl -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://www.netflix.com/title/81215567" 2>&1)
	
    if [[ "$result1" == "404" ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}[N] Mark Only${Font_Suffix}\n"
        return;
		
	elif  [[ "$result1" == "403" ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return;
		
	elif [[ "$result1" == "200" ]];then
		local region=`tr [:lower:] [:upper:] <<< $(curl -${1} --user-agent "${UA_Browser}" -fs --max-time 30 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
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
    local result=`curl --user-agent "${UA_Browser}" -${1} -sSL --max-time 30 "https://www.youtube.com/" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    local result=`curl --user-agent "${UA_Browser}" -${1} -sL --max-time 30 "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4`;
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
        return;
    fi
    
    echo -n -e "\r YouTube Region:\t\t\t${Font_Green}US${Font_Suffix}\n"
    return;
}

function MediaUnlockTest_DisneyPlus() {
    echo -n -e " DisneyPlus:\t\t\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL --max-time 30 "https://global.edge.bamgrid.com/token" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
	
	previewcheck=$(curl -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://disneyplus.com" | grep preview)
	if [ -n "$previewcheck" ];then
		echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi	
		
    
	curl -${1} -s --user-agent "$UA_Browser" -H "Content-Type: application/x-www-form-urlencoded" -H "$disneyheader" -d ''${disneyauth}'' -X POST  "https://global.edge.bamgrid.com/token" | python -m json.tool 2> /dev/null | grep 'access_token' >/dev/null 2>&1

    if [[ "$?" -eq 0 ]]; then
		region=$(curl -${1} -s --max-time 30 https://www.disneyplus.com | grep '"regionCode":' | sed 's/.*"regionCode"://' | cut -f2 -d'"')
		if [ -n "$region" ]
			then
				echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
				return;
			else
				website=$(curl -${1} --user-agent "${UA_Browser}" -fs --max-time 30 --write-out '%{redirect_url}\n' --output /dev/null "https://www.disneyplus.com")
				if [[ "${website}" == "https://disneyplus.disney.co.jp/" ]]
					then
						echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Green}Yes (Region: JP)${Font_Suffix}\n"
						return;
					else
						echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
						return;
				fi
		fi		
	else
		echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
    fi
    
    
}

function MediaUnlockTest_Dazn() {
    echo -n -e " Dazn:\t\t\t\t\t->\c";
    local tmpresult=$(curl -${1} -sS --max-time 30 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' https://startup.core.indazn.com/misl/v5/Startup 2>&1);
    
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
    local result=$(curl -${1} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://id.hulu.jp" | grep login);
    
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
    local result=$(curl -s -${1} --max-time 30 https://www.mytvsuper.com/iptest.php | grep 'HK');
    
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
    local result=$(curl -${1} ${ssll} -s --max-time 30 -X POST -H "Content-Type: application/json" -d '{"contentId":"202105121370235","contentType":"Vod","pin":"","deviceId":"W-60b8d30a-9294-d251-617b-c12f9d0c","deviceType":"WEB"}' "https://webtvapi.nowe.com/16/1/getVodURL" | python -m json.tool 2> /dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"' 2>&1);
    
	if [[ "$result" == "SUCCESS" ]]; then
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 -X POST -H "Content-Type: application/json" -d '{"callerReferenceNo":"20210726112323","contentId":"099","contentType":"Channel","channelno":"099","mode":"prod","deviceId":"29b3cb117a635d5b56","deviceType":"ANDROID_WEB"}' "https://api.viu.now.com/p8/3/getLiveURL");
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
    local result=$(curl -${1} -s --max-time 30 "https://video-api.unext.jp/api/1/player?entity%5B%5D=playlist_url&episode_code=ED00148814&title_code=SID0028118&keyonly_flg=0&play_mode=caption&bitrate_low=1500" | python -m json.tool 2> /dev/null | grep 'result_status' | awk '{print $2}' | cut -d ',' -f1);
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
    local tmpresult=$(curl -${1} -Ss --max-time 30 -H "Content-Type: application/json" -d '{"meta_id":71885,"vuid":"3b64a775a4e38d90cc43ea4c7214702b","device_code":1,"app_id":1}' https://api.paravi.jp/api/v1/playback/auth  2>&1 | python -m json.tool 2> /dev/null);
	
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Paravi:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkiffaild=$(echo $tmpresult | grep code | awk '{print $2}' | cut -d ',' -f1)
    if [[ "$checkiffaild" == "2055" ]]; then
		echo -n -e "\r Paravi:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi
	
	echo ${tmpresult} | grep 'playback_validity_end_at' >/dev/null 2>&1
	
	if [[ "$?" -eq 0 ]]; then
		echo -n -e "\r Paravi:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r Paravi:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_wowow(){
    echo -n -e " WOWOW:\t\t\t\t\t->\c";
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} -Ss --max-time 30 -b "${WOWOW_Cookie}" -H "x-wod-app-version: 91.0.4472.106" -H "x-wod-model: Chrome" -H "x-wod-os: Windows" -H "x-wod-os-version: 10" -H "x-wod-platform: Windows"  "https://wod.wowow.co.jp/api/streaming/url?contentId=&channel=Live" 2>&1 );
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} -Ss --max-time 30 -H "${TVer_Cookie}" "https://edge.api.brightcove.com/playback/v1/accounts/5102072603001/videos/ref%3Afree_episode_code_8121" 2>&1 );
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -Ss --max-time 30 "https://hamivideo.hinet.net/api/play.do?id=OTT_VOD_0000249064&freeProduct=1" 2>&1);
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -sS --max-time 30 -X POST -d 'value=D33jXJ0JVFkBqV%2BZSi1mhPltbejAbPYbDnyI9hmfqjKaQwRQdj7ZKZRAdb16%2FRUrE8vGXLFfNKBLKJv%2BfDSiD%2BZJlUa5Msps2P4IWuTrUP1%2BCnS255YfRadf%2BKLUhIPj' "https://api2.4gtv.tv//Vod/GetVodUrl3" 2>&1 );
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'Success' |  awk '{print $2}')
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
    local result=`curl --user-agent "${UA_Dalvik}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://www.sling.com/`;
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
    local tmpresult=$(curl -${1} ${ssll} -sS -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://pluto.tv/" 2>&1);
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
    local tmpresult=$(curl -${1} ${ssll} -sS -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.hbomax.com/" 2>&1);
	if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    local result=$(echo $tmpresult | grep 'geo-availability')
	if [ -n "$result" ]; then
		echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
     else
		echo -n -e "\r HBO Max:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi
	
	echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

}

function MediaUnlockTest_Channel4() {
    echo -n -e " Channel 4:\t\t\t\t->\c";
    local result=$(curl -${1} ${ssll} -s --max-time 30 "https://ais.channel4.com/simulcast/C4?client=c4" | grep 'status' |  cut -f2 -d'"');
    
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
    local result=$(curl -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://simulcast.itv.com/playlist/itvonline/ITV");
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
    curl -${1} ${ssll} -s -I --max-time 30 "https://www.iq.com/" > /tmp/iqiyi
    
    if [ $? -eq 1 ];then
        echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    result=$(cat /tmp/iqiyi | grep 'mod=' | awk '{print $2}' | cut -f2 -d'=' | cut -f1 -d';')
    if [ -n "$result" ]; then
		if [[ "$result" == "ntw" ]]; then
			result=TW 
			echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
			rm /tmp/iqiyi >/dev/null 2>&1
			return;
		else
			result=$(echo $result | tr [:lower:] [:upper:]) 
			echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
			rm /tmp/iqiyi >/dev/null 2>&1
			return;
		fi	
    else
		echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		rm /tmp/iqiyi >/dev/null 2>&1
		return;
	fi	
}

function MediaUnlockTest_HuluUS(){
    if [[ "$1" == "4" ]];then
		wget -O ./Hulu4.sh.x https://github.com/lmc999/RegionRestrictionCheck/raw/main/binary/Hulu4${arch}.sh.x  > /dev/null 2>&1
		chmod +x ./Hulu4.sh.x
		./Hulu4.sh.x > /dev/null 2>&1
	elif [[ "$1" == "6" ]];then	
		wget -O ./Hulu6.sh.x https://github.com/lmc999/RegionRestrictionCheck/raw/main/binary/Hulu6${arch}.sh.x  > /dev/null 2>&1
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
    tmpresult=$(curl -${1} ${ssll} -sS --max-time 30 -H "Accept: application/json;pk=BCpkADawqM2Gpjj8SlY2mj4FgJJMfUpxTNtHWXOItY1PvamzxGstJbsgc-zFOHkCVcKeeOhPUd9MNHEGJoVy1By1Hrlh9rOXArC5M5MTcChJGU6maC8qhQ4Y8W-QYtvi8Nq34bUb9IOvoKBLeNF4D9Avskfe9rtMoEjj6ImXu_i4oIhYS0dx7x1AgHvtAaZFFhq3LBGtR-ZcsSqxNzVg-4PRUI9zcytQkk_YJXndNSfhVdmYmnxkgx1XXisGv1FG5GOmEK4jZ_Ih0riX5icFnHrgniADr4bA2G7TYh4OeGBrYLyFN_BDOvq3nFGrXVWrTLhaYyjxOr4rZqJPKK2ybmMsq466Ke1ZtE-wNQ" -H "Origin: https://www.encoretvb.com" "https://edge.api.brightcove.com/playback/v1/accounts/5324042807001/videos/6005570109001" 2>&1 );
    
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
    local tmpresult=$(curl -${1} ${ssll} -sS --max-time 30 "https://fapi.molotov.tv/v1/open-europe/is-france" 2>&1 );
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
    local tmpresult=$(curl -${1} ${ssll} -sS --max-time 30 "https://geo.salto.fr/v1/geoInfo/");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.linetv.tw/api/part/11829/eps/1/part?chocomemberId=");
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
    local tmpresult=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.viu.com/");
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
    local tmpresult=$(curl -${1} ${ssll} -sSL --max-time 30 "https://www.nicovideo.jp/watch/so23017073" 2>&1);
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
    local result=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.paramountplus.com/" | grep 'intl');
    
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://api.kktv.me/v3/ipcheck");
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
    local result=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.peacocktv.com/" | grep 'unavailable');
    
	if [ -n "$result" ]; then
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://geocontrol1.stream.ne.jp/fod-geo/check.xml?time=1624504256");
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 30 "https://www.tiktok.com/")
	
	if [ "$tmpresult" = "curl"* ]; then
		echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
    
	local result=$(echo $tmpresult | grep '"$region":"' | sed 's/.*"$region//' | cut -f3 -d'"')
    if [ -n "$result" ];then
        echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Green}${result}${Font_Suffix}\n"
        return;
	else
		echo -n -e "\r Tiktok Region:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
    fi
    
}

function MediaUnlockTest_YouTube_Premium() {
    echo -n -e " YouTube Premium:\t\t\t->\c";
    local tmpresult=$(curl -${1} -sS -H "Accept-Language: en" "https://www.youtube.com/premium" 2>&1 )
    local region=$(curl --user-agent "${UA_Browser}" -${1} -sL --max-time 30 "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4)
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
	local tmpresult=$(curl -${1} ${ssll} -sS --max-time 30 https://redirector.googlevideo.com/report_mapping 2>&1)
    
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
		curl -s --max-time 30 "https://www.iata.org/AirportCodesSearch/Search?currentBlock=314384&currentPage=12572&airport.search=${iata}" > /tmp/iata.txt
		local line=$(cat /tmp/iata.txt | grep -n "<td>"$iata | awk '{print $1}' | cut -f1 -d":")
		local nline=$(expr $line - 2)
		local location=$(cat /tmp/iata.txt | awk NR==${nline} | sed 's/.*<td>//' | cut -f1 -d"<")
		echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Green}$location${Font_Suffix}\n"
		return;
	else
		echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Red}Undetectable${Font_Suffix}\n"
		return;
	fi
	
	rm /tmp/iata.txt
}

function MediaUnlockTest_BritBox() {
    echo -n -e " BritBox:\t\t\t\t->\c";
    local tmpresult=$(curl -${1} ${ssll} -sS -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.britbox.com/" 2>&1);
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
    local tmpresult=$(curl -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 30 "https://www.primevideo.com")
	
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
    local tmpresult=$(curl -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 30 "https://radiko.jp/area?_=1625406539531")
	
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
    local tmpresult=$(curl -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 30 "https://api-p.videomarket.jp/v3/api/play/keyauth?playKey=4c9e93baa7ca1fc0b63ccf418275afc2&deviceType=3&bitRate=0&loginFlag=0&connType=" -H "X-Authorization: 2bCf81eLJWOnHuqg6nNaPZJWfnuniPTKz9GXv5IS")
	
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://sunapi.catchplay.com/geo" -H "authorization: Basic NTQ3MzM0NDgtYTU3Yi00MjU2LWE4MTEtMzdlYzNkNjJmM2E0Ok90QzR3elJRR2hLQ01sSDc2VEoy");
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
    local result=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://api.hotstar.com/o/v1/page/1557?offset=0&size=20&tao=0&tas=20")
    if [ "$result" = "000" ]; then
		echo -n -e "\r HotStar:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	elif [ "$result" = "401" ]; then
		local region=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -sI "https://www.hotstar.com" | grep 'geo=' | sed 's/.*geo=//' | cut -f1 -d",")
		local site_region=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.hotstar.com" | sed 's@.*com/@@' | tr [:lower:] [:upper:] )
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
    local tmpresult=$(curl -${1} ${ssll} -sS --max-time 30 -X POST "https://www.LiTV.tv/vod/ajax/getUrl" -d '{"type":"noauth","assetId":"vod44868-010001M001_800K","puid":"6bc49a81-aad2-425c-8124-5b16e9e01337"}'  -H "Content-Type: application/json" 2>&1);
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.fubo.tv/welcome" | gunzip 2> /dev/null)
    
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
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://foxvideo.akamaized.net/pulsar-test/p-2mb.png?t=y9t0kj")
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
    local tmpauth=$(curl -${1} ${ssll} -s --max-time 30 -X POST "https://auth.joyn.de/auth/anonymous" -H "Content-Type: application/json" -d '{"client_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7","client_name":"web","anon_device_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7"}');
    if [ -z "$tmpauth" ]; then
		echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi	
	auth=$(echo $tmpauth | python -m json.tool 2> /dev/null | grep access_token | awk '{print $2}' | cut -f2 -d'"')	
	local result=$(curl -s "https://api.joyn.de/content/entitlement-token" -H "x-api-key: 36lp1t4wto5uu2i2nk57ywy9on1ns5yg" -H "content-type: application/json" -d '{"content_id":"daserste-de-hd","content_type":"LIVE"}' -H "authorization: Bearer $auth")
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://edge.api.brightcove.com/playback/v1/accounts/1050888051001/videos/6247131490001" -H "Accept: application/json;pk=BCpkADawqM0OXCLe4eIkpyuir8Ssf3kIQAM62a1KMa4-1_vTOWQIxoHHD4-oL-dPmlp-rLoS-WIAcaAMKuZVMR57QY4uLAmP4Ov3V416hHbqr0GNNtzVXamJ6d4-rA3Xi98W-8wtypdEyjGEZNepUCt3D7UdMthbsG-Ean3V4cafT4nZX03st5HlyK1chp51SfA-vKcAOhHZ4_Oa9TTN61tEH6YqML9PWGyKrbuN5myICcGsFzP3R2aOF8c5rPCHT2ZAiG7MoavHx8WMjhfB0QdBr2fphX24CSpUKlcjEnQJnBiA1AdLg9iyReWrAdQylX4Eyhw5OwKiCGJznfgY6BDtbUmeq1I9r9RfmhP5bfxVGjILSEFZgXbMqGOvYdrdare0aW2fTCxeHdHt0vyKOWTC6CS1lrGJF2sFPKn1T1csjVR8s4MODqCBY1PTbHY4A9aZ-2MDJUVJDkOK52hGej6aXE5b9N9_xOT2B9wbXL1B1ZB4JLjeAdBuVtaUOJ44N0aCd8Ns0o02E1APxucQqrjnEociLFNB0Bobe1nkGt3PS74IQcs-eBvWYSpolldMH6TKLu8JqgdnM4WIp3FZtTWJRADgAmvF9tVDUG9pcJoRx_CZ4im-rn-AzN3FeOQrM4rTlU3Q8YhSmyEIoxYYqsFDwbFlhsAcvqQkgaElYtuciCL5i3U8N4W9rIhPhQJzsPafmLdWxBP_FXicyek25GHFdQzCiT8nf1o860Jv2cHQ4xUNcnP-9blIkLy9JmuB2RgUXOHzWsrLGGW6hq9wLUtqwEoxcEAAcNJgmoC0k8HE-Ga-NHXng6EFWnqiOg_mZ_MDd7gmHrrKLkQV" -H "Origin: https://www.sky.de");
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
    local result=$(curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://ssl.zdf.de/geo/de/geo.txt/)
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://api2.hbogoasia.com/v1/geog?lang=undefined&version=0&bundleId=www.hbogoasia.com");
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
	local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://api.ugw.hbogo.eu/v3.0/GeoCheck/json/HUN")
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
    local tmpresult=$(curl -${1} ${ssll} -X POST -s --max-time 30 "https://api.epix.com/v2/movies/16921/play" -d '{}' -H "X-Session-Token: eyJraWQiOiI5YjFjYjViZDYxZGNmMWU3ZmJkMWM2YjRmOGNhOTgzNmFkZmY5YjViNjYwMDQ5ZDIzMWZlZjBmMDllMTkwMmFmIiwiYWxnIjoiUlMyNTYifQ.eyJndWlkIjoiZDExOTg2N2UtZmIwYS00NjAyLWE2NmUtYjRhNmY3OTJiMGM5IiwidGVuYW50IjoiZXBpeCIsImV4cCI6MTYyNzIyNjg1OH0.rFxD8RdL4rOeNWwmlV1phE2h-aoz1WpVP4iYhvc-Sy7834PbrzK2gjMcebrTcBi61ndZDlCmr5iAeaNmKrylPVWRCJ3kIIxCovMW7wBV7TgGyJAb2xo5kVz1CTIW4frzj-JzSWHUBYgam1nZ9U1liuNAz58CDs62By58ohT1XEojOp3Nv5sCwBVF-hNSUJTNJ1fxQXOBBR9FLhd0YDvNJBAzC8vHJSgfmtkBdO35PbESYlR6_XZ8tHNOGQr2KKlp9ejsQA-KWdmxUTsexMmH1kCBXZ4n6i7Ijb-W7GR3rSUmsnfeHh5XgYf1VRVoTHjmJ7ce0CdrgUgBOvjWAv_0Kw");
    if [ -z "$tmpresult" ]; then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
		return;
	fi
	
	local result=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep status | cut -f4 -d'"')	
	if [[ "$result" == "PROXY_DETECTED" ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;
	elif [[ "$result" == "GEO_BLOCKED" ]];then
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	else
		echo -n -e "\r Epix:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;
	fi

}

function MediaUnlockTest_NLZIET() {
    echo -n -e " NLZIET:\t\t\t\t->\c";
	TmpFallBackCode=$(curl -X GET -${1} ${ssll} -s --max-time 30 "https://id.nlziet.nl/connect/authorize/callback?client_id=triple-web&redirect_uri=https%3A%2F%2Fapp.nlziet.nl%2Fcallback&response_type=code&scope=openid%20api&state=91b508206f154b8381d3cc9061170527&code_challenge=EF_HpSX8a_leJOXmHqsYpBKjNRX0D8oZh_HfremhSWE&code_challenge_method=S256&response_mode=query" -b "optanonStatus=,C0001,; _gid=GA1.2.301664903.1627130663; OptanonConsent=isIABGlobal=false&datestamp=Sat+Jul+24+2021+20%3A44%3A23+GMT%2B0800+(%E9%A6%99%E6%B8%AF%E6%A0%87%E5%87%86%E6%97%B6%E9%97%B4)&version=6.17.0&hosts=&landingPath=https%3A%2F%2Fapp.nlziet.nl%2F&groups=C0001%3A1%2CC0002%3A0%2CC0003%3A0%2CC0004%3A0; _ga=GA1.2.1715247671.1627130661; _ga_LQL66TVRW1=GS1.1.1627130674.1.1.1627130679.0; _ga_QVB71SF0T8=GS1.1.1627130674.1.1.1627130679.0; .AspNetCore.Antiforgery.iEdXBvgZzA4=CfDJ8IdkGvI8o6RKkusMbm16dgZLQ3gjhTBrGZ5YAf7IYcvZ_uyXtvFmF8n87s9O1A6_hGU2cylV3fP7KrNnOndoMYFzeQTtFjYYe6rKr7G7tnvK5nDlZ1voXmUWbOynzDibE8HvkIICFkMzAZQksRtufiA; _ga_YV1B2GE80N=GS1.1.1627130661.1.1.1627130679.0; idsrv.session=3AF23B3FB60D818D8D6B519258D305C4; idsrv=CfDJ8IdkGvI8o6RKkusMbm16dgY4Sqm-8MQ1fT9qsFj38GA2PTr53t9IZNOTNbfRBqf4_2ymzxFOJr3WeVh_xbqM-yiQtvZ3LKdkZW8jR8g6jE9WeZj5kxdUZYSYRsOkUc-ZCQJA59txaiunIwwgwPfbRYW86mL_ZL_cTVZZldVNHswXPKvDKeeD9ieyXVGvLFEjgEUsNXzukaPN6SFuC0UISPcU8rqU9DdLp0y5QeoqE_z_nTlVgB65F-bGYeKtFVtk1uf7TYDgxnFeTJt5NpigsRk2zcIi0bmrzkgKd7oUQrAfVkUoy8T1-SnHAjN0VpDn4fRE4t1LdsU89IbV99pMVN2hvx5UrNT09lsSllkqzJXYoxC2dLQihWWcfH5J0lUn9GjFPTZWFOSw_6i164eYY2cpfvROcr3MJH0dXPf1kgLXNjN5ejjjCEPmgeMGvFdYS4cusx0tgvDp5R2hpbZGpRXneTgwAjFs9vgYuf_-r7cdb-fdSy-oohsdEDIIz5Zz_-7TvOl3hHEShAYaHjyUYWcm90E-6N3mjm7sBXUe9cDqbqbfpwgr1ciW0GbuZCqXaShrFvjE48EXnwt46TuBDAJJtVm4OZPE8ngJYscQrel7AJvm8tPpv10P6vw_Hva5IvCPxcLkyFj4xnbmY6hBU3-WQNawtZ67098QTEvMKgF44_QI0x5xP8NZ8HR2GDabLtMh88enklIB8_j7dp3RwoSLn9N61gZJWhBj9mU5FioAOGKsNJD4iWtPXKwUU0Yz4XnjD1KYL88BE3j7-Z5qiLQQGWj5GkKk7PLhPMA_PghLjE6KKKoWTny6NSXXyPSGZIHwlV2NGTH8EQmKoBq_xfejG-oBqSP0aCAf2apl6bwDHrBK3YVigLWPlej_4OKj7BC-KXhHxW7bNY4vHQ5EUHw" -I | grep Location | sed 's/.*callback?code=//' | cut -f1 -d"&")
    local tmpauth=$(curl -${1} ${ssll} -s --max-time 30 -X POST "https://id.nlziet.nl/connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=triple-web&code=${TmpFallBackCode}&redirect_uri=https%3A%2F%2Fapp.nlziet.nl%2Fcallback&code_verifier=04850de4083d48adb0bf6db3ebfd038fe27a7881de914b95a18d90ceb350316ed05a0e39e72440e6ace015ddc11d28b5&grant_type=authorization_code");
    
	if [ -z "$tmpauth" ]; then
		echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;
	fi	
	
	local auth=$(echo $tmpauth | python -m json.tool 2> /dev/null | grep access_token | awk '{print $2}' | cut -f2 -d'"')	
	local result=$(curl -X GET -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://api.nlziet.nl/v7/stream/handshake/Widevine/Dash/VOD/rJDaXnOP4kaRXnZdR_JofA?playerName=BitmovinWeb" -H "authorization: Bearer $auth")
    
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.videoland.com/api/v3/geo");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://start-player.npo.nl/video/KN_1726624/streams?profile=dash-widevine&quality=npo&tokenId=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzbWFydHRhZyI6eyJzaXRlSWQiOiI0In0sImhhc1N1YnNjcmlwdGlvbiI6IiIsImhhc1ByZW1pdW1TdWJzY3JpcHRpb24iOiIiLCJlbGVtZW50SWQiOiJwbGF5ZXItS05fMTcyNjYyNCIsIm1lZGlhSWQiOiJLTl8xNzI2NjI0IiwidG9wc3BpbiI6eyJwYXJ0eUlkIjoiIiwicHJvZmlsZUlkIjoiIn0sImhhc1NldHRpbmdzIjoiMSIsImhhc0FkQ29uc2VudCI6IjAiLCJzaGFyZSI6IjAiLCJlbmFibGVUaHVtYm5haWxTY3JvbGwiOiIxIiwibWFya2VycyI6IjEiLCJyZWNvbW1lbmRhdGlvbnMiOiIyNSIsImVuZHNjcmVlbiI6eyJoaWRlX2Zvcl90eXBlcyI6WyJmcmFnbWVudCIsImNsaXAiLCJ0cmFpbGVyIl19LCJzdHlsZVZlcnNpb24iOiIyIiwibW9yZUJ1dHRvbiI6IjEiLCJlbmRPZkNvbnRlbnRUZXh0IjoiMSIsImNocm9tZWNhc3QiOnsiZW5hYmxlZCI6IjEifSwic3R5bGluZyI6eyJ0aXRsZSI6eyJkaXNwbGF5Ijoibm9uZSJ9fSwiYXV0b3BsYXkiOiIwIiwicGFnZVVybCI6Imh0dHA6XC9cL3d3dy5ucG9zdGFydC5ubFwvc3dhbmVuYnVyZ1wvMTktMDctMjAyMVwvS05fMTcyNjYyNCIsInN0ZXJSZWZlcnJhbFVybCI6Imh0dHA6XC9cL3d3dy5ucG9zdGFydC5ubFwvc3dhbmVuYnVyZ1wvMTktMDctMjAyMVwvS05fMTcyNjYyNCIsInN0ZXJTaXRlSWQiOiJucG9zdGFydCIsInN0eWxlc2hlZXQiOiJodHRwczpcL1wvd3d3Lm5wb3N0YXJ0Lm5sXC9zdHlsZXNcL3BsYXllci5jc3MiLCJjb252aXZhIjp7ImVuYWJsZWQiOiIxIiwiYnJvYWRjYXN0ZXJOYW1lIjoiTlBPU1RBUlQifSwiaWF0IjoxNjI3MTM2MTEzLCJuYmYiOjE2MjcxMzYxMTMsImV4cCI6MTYyNzE2NDkxMywiY29uc3VtZXJJZCI6bnVsbCwiaXNQbGF5bGlzdCI6ZmFsc2UsInJlZmVycmVyVXJsIjpudWxsLCJza2lwQ2F0YWxvZyI6MCwibm9BZHMiOjAsImlzcyI6ImV5SnBkaUk2SWpkdldrUjFSbFJRWVcwclREVkZjVWRxWVhOY0x6RkJQVDBpTENKMllXeDFaU0k2SW5KelkwcGFUbVpwWTNoV2MyMXphMXBRU0VOeGVEVkJXamN4YXl0UFZraHJOblJQTTBwM2JsZERabFpxSzBneFRtdzJhV3c1UW1SaGJFcDFWV2hvYUZZaUxDSnRZV01pT2lKbU1EUXdNRE5sTlRGbVlUSmpPR05tTTJVMFpEYzBaREF3TURObU9EaGxNelZoWTJNelltSXhaalJtWTJaa05UUTJZVFF6TURNNE9USTJNVFUzWlRsaUluMD0ifQ.aMQGym3tnPu9JM6Mb8XWCm46cB980Sk-ZGvRX0V2gV8&streamType=broadcast&isYospace=0&videoAgeRating=12&isChromecast=0&mobile=0&ios=0");
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
    local tmpresult=$(curl -${1} ${ssll} -sS -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://rakuten.tv" 2>&1);
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://api-discovery.hbo.eu/v1/discover/hbo?language=null&product=hboe" -H "X-Client-Name: web");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://auth.pantaya.com/api/v4/User/geolocation" -H "AuthTokenAuthorization: PLAYAUTH1.0 x=nonce=EM4kj2xL, apikey=B9FFD1A3BC9E42A893A4D09644389344, signature_method=SHA256, requesttime=2021-07-25T12:23:00.293Z, deviceid=ec0d0994f7ec4cca9e090b9d4bd05171, AllowAuthNOnly=true, platformtype=HTML5, platformversion=Chrome, platformostype=Windows, platformosversion=10, signature=kquBKo2kySXumR5j3hpmO/TnnLEEcZFNx7kMdQhGE9g=");
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

function MediaUnlockTest_CanalPlus() {
    echo -n -e " Canal+:\t\t\t\t->\c";
    local tmpresult=$(curl -${1} ${ssll} -sS -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://boutique-tunnel.canalplus.com/" 2>&1);
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.cbc.ca/g/stats/js/cbc-stats-top.js");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30  "https://acorn.tv/");
	local isblocked=$(curl -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://acorn.tv/")
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://capi.9c9media.com/destinations/se_atexace/platforms/desktop/bond/contents/2205173/contentpackages/4279732/manifest.mpd");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.amediateka.ru/");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://ctx.playfamily.ru/screenapi/v4/preparepurchase/web/1?elementId=0b974dc3-d4c5-4291-9df5-81a8132f67c5&elementAlias=51459024&elementType=GAME&withUpgradeSubscriptionReturnAmount=true&forceSvod=true&includeProductsForUpsale=false&sid=mDRnXOffdh_l2sBCyUIlbA" -H "X-SCRAPI-CLIENT-TS: 1627391624026");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://mediapolisvod.rai.it/relinker/relinkerServlet.htm?cont=VxXwi7UcqjApssSlashbjsAghviAeeqqEEqualeeqqEEqual&output=64");
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://uapisfm.tvbanywhere.com.sg/geoip/check/platform/android");
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
    local result=$(curl --user-agent "User-Agent: pjsekai/48 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://game-version.sekai.colorfulpalette.org/1.8.1/3ed70b6a-8352-4532-b819-108837926ff5")
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
    local result=$(curl --user-agent "User-Agent: pj0007/212 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://api.konosubafd.jp/api/masterlist")
    if [ "$result" = "000" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "$result" = "500" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Green}Yes${Font_Suffix}\n"
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Konosuba Fantastic Days:\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function US_UnlockTest() {
	echo "=============美加地区解锁=============="
	MediaUnlockTest_Fox ${1};
	#MediaUnlockTest_EPIX ${1};
	MediaUnlockTest_HuluUS ${1};
	MediaUnlockTest_HBONow ${1};
	MediaUnlockTest_HBOMax ${1};
	MediaUnlockTest_BritBox ${1};
	MediaUnlockTest_SlingTV ${1};
	MediaUnlockTest_FuboTV ${1};
	MediaUnlockTest_PlutoTV ${1};
	MediaUnlockTest_encoreTVB ${1};
	MediaUnlockTest_ParamountPlus ${1};
	MediaUnlockTest_PeacockTV ${1};
	ShowRegion CA
	MediaUnlockTest_CBCGem ${1};
	MediaUnlockTest_AcornTV ${1};
	MediaUnlockTest_Crave ${1};
	echo "======================================="
}	

function EU_UnlockTest() {
	echo "=============欧洲地区解锁=============="
	MediaUnlockTest_RakutenTV ${1};
	MediaUnlockTest_HBOGO_EUROPE ${1};
	ShowRegion GB
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
	#MediaUnlockTest_PANTAYA ${1};
	ShowRegion IT
	MediaUnlockTest_RaiPlay ${1};
	ShowRegion RU
	MediaUnlockTest_MegogoTV ${1};
	MediaUnlockTest_Amediateka ${1};
	echo "======================================="
}	
	
function HK_UnlockTest(){	
	echo "=============香港地区解锁=============="
	MediaUnlockTest_NowE ${1};
	MediaUnlockTest_ViuTV ${1};
	MediaUnlockTest_MyTVSuper ${1};
	MediaUnlockTest_HBOGO_ASIA ${1};
	MediaUnlockTest_BilibiliHKMCTW ${1};
	echo "======================================="
}

function TW_UnlockTest(){	
	echo "=============台湾地区解锁=============="
	MediaUnlockTest_KKTV ${1};
	MediaUnlockTest_LiTV ${1};
	MediaUnlockTest_4GTV ${1};
	MediaUnlockTest_LineTV.TW ${1};
	MediaUnlockTest_HamiVideo ${1};
	MediaUnlockTest_Catchplay ${1};
	MediaUnlockTest_HBOGO_ASIA ${1};
	MediaUnlockTest_BahamutAnime ${1};
	MediaUnlockTest_BilibiliTW ${1};
	echo "======================================="
}
	
function JP_UnlockTest() {	
	echo "==============日本地区解锁============="	
	MediaUnlockTest_DMM ${1};
	MediaUnlockTest_AbemaTV_IPTest ${1};
	MediaUnlockTest_Niconico ${1};
	MediaUnlockTest_Paravi ${1};
	MediaUnlockTest_unext ${1};
	MediaUnlockTest_HuluJP ${1};
	MediaUnlockTest_TVer ${1};
	MediaUnlockTest_wowow ${1};
	MediaUnlockTest_FOD ${1};
	MediaUnlockTest_Radiko ${1};
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
	echo "=============跨国平台解锁=============="	
	MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_HotStar ${1};
	MediaUnlockTest_Netflix ${1};
	MediaUnlockTest_DisneyPlus ${1};
	MediaUnlockTest_YouTube_Premium ${1};
	MediaUnlockTest_PrimeVideo_Region ${1};
	MediaUnlockTest_TVBAnywhere ${1};
	MediaUnlockTest_Tiktok_Region ${1};
	MediaUnlockTest_iQYI_Region ${1};
	MediaUnlockTest_Viu.com ${1};
	MediaUnlockTest_YouTube_CDN ${1};
	GameTest_Steam ${1};
	echo "======================================="	
}

function CheckV4() {
	echo -e " ${Font_SkyBlue}** 正在测试IPv4解锁情况${Font_Suffix} "
	echo "--------------------------------"
	echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp}${Font_Suffix} "
	check4=`ping 1.1.1.1 -c 1 2>&1`;
	if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
		isv4=1
	else
		echo -e "${Font_SkyBlue}当前主机不支持IPv4,跳过...${Font_Suffix}"
		isv4=0
	fi

	echo ""
}

function CheckV6() {
check6=$(curl -fsL --write-out %{http_code} --output /dev/null --max-time 30 ipv6.google.com)
if [[ "$check6" -eq "200" ]];then
	echo ""
	echo ""
	echo -e " ${Font_SkyBlue}** 正在测试IPv6解锁情况${Font_Suffix} "
	echo "--------------------------------"
	echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp}${Font_Suffix} "
    isv6=1
else
    echo -e "${Font_SkyBlue}当前主机不支持IPv6,跳过...${Font_Suffix}"
	isv6=0
fi
echo -e "";
}

function Goodbye(){
echo -e "${Font_Green}本次测试已结束，感谢使用此脚本 ${Font_Suffix}";
echo -e "${Font_Blue}【其他检测脚本推荐】： ${Font_Suffix}"
echo -e "${Font_Yellow}游戏延迟检测脚本： bash <(curl -L -s https://raw.githubusercontent.com/lmc999/GamePing/main/GamePing.sh) ${Font_Suffix}"
}

clear;

function ScriptTitle(){
echo -e "流媒体平台及游戏区域限制测试";
echo ""
echo -e "${Font_Green}项目地址${Font_Suffix} ${Font_Yellow}https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}";
echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/gameaccelerate ${Font_Suffix}";
echo ""
echo -e " ** 测试时间: $(date)";
echo ""
}
ScriptTitle

function Start(){
echo -e "${Font_Blue}请选择检测项目，直接按回车将进行全区域检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【1】：【跨国平台+美加平台】检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【2】：【跨国平台+日本平台】检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【3】：【跨国平台+香港平台】检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【4】：【跨国平台+台湾平台】检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【5】：【跨国平台+欧洲平台】检测${Font_Suffix}"
echo -e "${Font_SkyBlue}输入数字【6】：【  只进行跨国平台 】检测${Font_Suffix}"
read -p "请输入正确数字或直接按回车:" num
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
				US_UnlockTest 4
			fi
			CheckV6
			if 	[[ "$isv6" -eq 1 ]];then
				Global_UnlockTest 6
				US_UnlockTest 6
			fi	
			Goodbye
			
		elif [[ "$num" -eq 2 ]]; then
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
			
		elif [[ "$num" -eq 3 ]]; then
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
			
		elif [[ "$num" -eq 4 ]]; then
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
			
		elif [[ "$num" -eq 5 ]]; then
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
			
		elif [[ "$num" -eq 6 ]]; then
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
			return
		fi
	else
		clear
		ScriptTitle
		CheckV4
		if [[ "$isv4" -eq 1 ]];then
			Global_UnlockTest 4
			US_UnlockTest 4	
			JP_UnlockTest 4
			HK_UnlockTest 4
			TW_UnlockTest 4
			EU_UnlockTest 4
		fi	
		CheckV6
		if [[ "$isv6" -eq 1 ]];then
			Global_UnlockTest 6
			US_UnlockTest 6	
			JP_UnlockTest 6
			HK_UnlockTest 6
			TW_UnlockTest 6
			EU_UnlockTest 6	
		fi
		Goodbye	
	fi
}	
RunScript
