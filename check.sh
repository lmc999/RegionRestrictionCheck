#!/bin/bash
shopt -s expand_aliases
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

while getopts ":I:M:EX:P:" optname; do
    case "$optname" in
    "I")
        iface="$OPTARG"
        useNIC="--interface $iface"
        ;;
    "M")
        if [[ "$OPTARG" == "4" ]]; then
            NetworkType=4
        elif [[ "$OPTARG" == "6" ]]; then
            NetworkType=6
        fi
        ;;
    "E")
        language="e"
        ;;
    "X")
        XIP="$OPTARG"
        xForward="--header X-Forwarded-For:$XIP"
        ;;
    "P")
        proxy="$OPTARG"
        usePROXY="-x $proxy"
    	;;
    ":")
        echo "Unknown error while processing options"
        exit 1
        ;;
    esac

done

if [ -z "$iface" ]; then
    useNIC=""
fi

if [ -z "$XIP" ]; then
    xForward=""
fi

if [ -z "$proxy" ]; then
    usePROXY=""
elif [ -n "$proxy" ]; then
    NetworkType=4
fi

if ! mktemp -u --suffix=RRC &>/dev/null; then
    is_busybox=1
fi

UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
UA_SecCHUA='"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"'
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)"
Media_Cookie=$(curl -s --retry 3 --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies")
IATACode=$(curl -s --retry 3 --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/reference/IATACode.txt")
IATACode2=$(curl -s --retry 3 --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/reference/IATACode2.txt" 2>&1)

countRunTimes() {
    if [ "$is_busybox" == 1 ]; then
        count_file=$(mktemp)
    else
        count_file=$(mktemp --suffix=RRC)
    fi
    RunTimes=$(curl -s --max-time 10 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fcheck.unclock.media&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=visit&edge_flat=false" >"${count_file}")
    TodayRunTimes=$(cat "${count_file}" | tail -3 | head -n 1 | awk '{print $5}')
    TotalRunTimes=$(($(cat "${count_file}" | tail -3 | head -n 1 | awk '{print $7}') + 2527395))
}
countRunTimes

checkOS() {
    ifTermux=$(echo $PWD | grep termux)
    ifMacOS=$(uname -a | grep Darwin)
    if [ -n "$ifTermux" ]; then
        os_version=Termux
        is_termux=1
    elif [ -n "$ifMacOS" ]; then
        os_version=MacOS
        is_macos=1
    else
        os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    fi

    if [[ "$os_version" == "2004" ]] || [[ "$os_version" == "10" ]] || [[ "$os_version" == "11" ]]; then
        is_windows=1
        ssll="-k --ciphers DEFAULT@SECLEVEL=1"
    fi

    if [ "$(which apt 2>/dev/null)" ]; then
        InstallMethod="apt"
        is_debian=1
    elif [ "$(which dnf 2>/dev/null)" ] || [ "$(which yum 2>/dev/null)" ]; then
        InstallMethod="yum"
        is_redhat=1
    elif [[ "$os_version" == "Termux" ]]; then
        InstallMethod="pkg"
    elif [[ "$os_version" == "MacOS" ]]; then
        InstallMethod="brew"
    fi
}
checkOS

checkCPU() {
    CPUArch=$(uname -m)
    if [[ "$CPUArch" == "aarch64" ]]; then
        arch=_arm64
    elif [[ "$CPUArch" == "i686" ]]; then
        arch=_i686
    elif [[ "$CPUArch" == "arm" ]]; then
        arch=_arm
    elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ]; then
        arch=_darwin
    fi
}
checkCPU

checkDependencies() {

    # os_detail=$(cat /etc/os-release 2> /dev/null)

    if ! command -v python &>/dev/null; then
        if command -v python3 &>/dev/null; then
            alias python="python3"
        else
            if [ "$is_debian" == 1 ]; then
                echo -e "${Font_Green}Installing python${Font_Suffix}"
                $InstallMethod update >/dev/null 2>&1
                $InstallMethod install python -y >/dev/null 2>&1
            elif [ "$is_redhat" == 1 ]; then
                echo -e "${Font_Green}Installing python${Font_Suffix}"
                if [[ "$os_version" -gt 7 ]]; then
                    $InstallMethod makecache >/dev/null 2>&1
                    $InstallMethod install python3 -y >/dev/null 2>&1
                    alias python="python3"
                else
                    $InstallMethod makecache >/dev/null 2>&1
                    $InstallMethod install python -y >/dev/null 2>&1
                fi

            elif [ "$is_termux" == 1 ]; then
                echo -e "${Font_Green}Installing python${Font_Suffix}"
                $InstallMethod update -y >/dev/null 2>&1
                $InstallMethod install python -y >/dev/null 2>&1

            elif [ "$is_macos" == 1 ]; then
                echo -e "${Font_Green}Installing python${Font_Suffix}"
                $InstallMethod install python
            fi
        fi
    fi

    if ! command -v dig &>/dev/null; then
        if [ "$is_debian" == 1 ]; then
            echo -e "${Font_Green}Installing dnsutils${Font_Suffix}"
            $InstallMethod update >/dev/null 2>&1
            $InstallMethod install dnsutils -y >/dev/null 2>&1
        elif [ "$is_redhat" == 1 ]; then
            echo -e "${Font_Green}Installing bind-utils${Font_Suffix}"
            $InstallMethod makecache >/dev/null 2>&1
            $InstallMethod install bind-utils -y >/dev/null 2>&1
        elif [ "$is_termux" == 1 ]; then
            echo -e "${Font_Green}Installing dnsutils${Font_Suffix}"
            $InstallMethod update -y >/dev/null 2>&1
            $InstallMethod install dnsutils -y >/dev/null 2>&1
        elif [ "$is_macos" == 1 ]; then
            echo -e "${Font_Green}Installing bind${Font_Suffix}"
            $InstallMethod install bind
        fi
    fi

    if [ "$is_macos" == 1 ]; then
        if ! command -v md5sum &>/dev/null; then
            echo -e "${Font_Green}Installing md5sha1sum${Font_Suffix}"
            $InstallMethod install md5sha1sum
        fi
    fi

}
checkDependencies

local_ipv4=$(curl $useNIC $usePROXY -4 -s --max-time 10 api64.ipify.org)
local_ipv4_asterisk=$(awk -F"." '{print $1"."$2".*.*"}' <<<"${local_ipv4}")
local_ipv6=$(curl $useNIC -6 -s --max-time 20 api64.ipify.org)
local_ipv6_asterisk=$(awk -F":" '{print $1":"$2":"$3":*:*"}' <<<"${local_ipv6}")
local_isp4=$(curl $useNIC -s -4 --max-time 10 --user-agent "${UA_Browser}" "https://api.ip.sb/geoip/${local_ipv4}" | grep organization | cut -f4 -d '"')
local_isp6=$(curl $useNIC -s -6 --max-time 10 --user-agent "${UA_Browser}" "https://api.ip.sb/geoip/${local_ipv6}" | grep organization | cut -f4 -d '"')

ShowRegion() {
    echo -e "${Font_Yellow} ---${1}---${Font_Suffix}"
}

function GameTest_Steam() {
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://store.steampowered.com/app/761830" 2>&1 | grep priceCurrency | cut -d '"' -f4)

    if [ ! -n "$result" ]; then
        echo -n -e "\r Steam Currency:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    else
        echo -n -e "\r Steam Currency:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_HBONow() {
    # 尝试获取成功的结果
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 --write-out "%{url_effective}\n" --output /dev/null "https://play.hbonow.com/" 2>&1)
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
    local tmpdeviceid=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" --max-time 10 -fsSL "https://ani.gamer.com.tw/ajax/getdeviceid.php" --cookie-jar bahamut_cookie.txt 2>&1)
    if [[ "$tmpdeviceid" == "curl"* ]]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local tempdeviceid=$(echo $tmpdeviceid | python -m json.tool 2>/dev/null | grep 'deviceid' | awk '{print $2}' | tr -d '"' )
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" --max-time 10 -fsSL "https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=14667&device=${tempdeviceid}" -b bahamut_cookie.txt 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    rm bahamut_cookie.txt
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'animeSn')
    if [ -n "$result" ]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

# 流媒体解锁测试-哔哩哔哩大陆限定
function MediaUnlockTest_BilibiliChinaMainland() {
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    # 尝试获取成功的结果
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
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
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    # 尝试获取成功的结果
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
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
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    # 尝试获取成功的结果
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
    if [[ "$result" != "curl"* ]]; then
        local result="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
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
    #
    local tempresult=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --max-time 10 "https://api.abema.io/v1/ip/check?device=android" 2>&1)
    if [[ "$tempresult" == "000" ]]; then
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --max-time 10 "https://api.abema.io/v1/ip/check?device=android" 2>&1 | python -m json.tool 2>/dev/null | grep isoCountryCode | awk '{print $2}' | cut -f2 -d'"')
    if [ -n "$result" ]; then
        if [[ "$result" == "JP" ]]; then
            echo -n -e "\r Abema.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        else
            echo -n -e "\r Abema.TV:\t\t\t\t${Font_Yellow}Oversea Only${Font_Suffix}\n"
        fi
    else
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_PCRJP() {
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api-priconne-redive.cygames.jp/" 2>&1)
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
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api-umamusume.cygames.jp/" 2>&1)
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

function MediaUnlockTest_WFJP() {
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.worldflipper.jp/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r World Flipper Japan:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "200" ]; then
        echo -n -e "\r World Flipper Japan:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [ "$result" = "403" ]; then
        echo -n -e "\r World Flipper Japan:\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r World Flipper Japan:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Kancolle() {
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "http://203.104.209.7/kcscontents/news/" 2>&1)
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

function MediaUnlockTest_Lemino() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 'https://if.lemino.docomo.ne.jp/v1/user/delivery/watch/ready' --user-agent "${UA_Browser}" -H 'accept: application/json, text/plain, */*' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' -H 'content-type: application/json' -H 'origin: https://lemino.docomo.ne.jp' -H 'referer: https://lemino.docomo.ne.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' -H 'x-service-token: f365771afd91452fa279863f240c233d' -H 'x-trace-id: 556db33f-d739-4a82-84df-dd509a8aa179' --data-raw '{"inflow_flows":[null,"crid://plala.iptvf.jp/group/b100ce3"],"play_type":1,"key_download_only":null,"quality":null,"groupcast":null,"avail_status":"1","terminal_type":3,"test_account":0,"content_list":[{"kind":"main","service_id":null,"cid":"00lm78dz30","lid":"a0lsa6kum1","crid":"crid://plala.iptvf.jp/vod/0000000000_00lm78dymn","preview":0,"trailer":0,"auto_play":0,"stop_position":0}]}')
    if [ "$result" = "000" ]; then
        echo -n -e "\r Lemino:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Lemino:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Lemino:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Lemino:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_mora() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 'https://mora.jp/buy?__requestToken=1713764407153&returnUrl=https%3A%2F%2Fmora.jp%2Fpackage%2F43000087%2FTFDS01006B00Z%2F%3Ffmid%3DTOPRNKS%26trackMaterialNo%3D31168909&fromMoraUx=false&deleteMaterial=' -H 'host: mora.jp' 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r Mora:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Mora:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "500" ]; then
        echo -n -e "\r Mora:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Mora:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_BBCiPLAYER() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --max-time 10 "https://open.live.bbc.co.uk/mediaselector/6/select/version/2.0/mediaset/pc/vpid/bbc_one_london/format/json/jsfunc/JS_callbacks0" 2>&1)
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
    local result1=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 'https://www.netflix.com/title/81280792' --user-agent "${UA_Browser}" -H 'host: www.netflix.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document' -H 'accept-language: zh-CN,zh;q=0.9')
    local result2=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 'https://www.netflix.com/title/70143836' --user-agent "${UA_Browser}" -H 'host: www.netflix.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document' -H 'accept-language: zh-CN,zh;q=0.9')

    if [[ "$result1" == "404" ]] && [[ "$result2" == "404" ]]; then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}Originals Only${Font_Suffix}\n"
        return
    elif [[ "$result1" == "403" ]] && [[ "$result2" == "403" ]]; then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result1" == "200" ]] || [[ "$result2" == "200" ]]; then
        local region=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fsL --max-time 10 "https://www.netflix.com/title/70143836" 2>&1 | grep -oP '"requestCountry":{"id":"\K\w\w' | head -n 1)
        echo -n -e "\r Netflix:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_DisneyPlus() {
    local PreAssertion=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/devices" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -H "content-type: application/json; charset=UTF-8" -d '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}' 2>&1)
    if [[ "$PreAssertion" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$PreAssertion" == "curl"* ]]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local assertion=$(echo $PreAssertion | python -m json.tool 2>/dev/null | grep assertion | cut -f4 -d'"')
    local PreDisneyCookie=$(echo "$Media_Cookie" | sed -n '1p')
    local disneycookie=$(echo $PreDisneyCookie | sed "s/DISNEYASSERTION/${assertion}/g")
    local TokenContent=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/token" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycookie" 2>&1)
    local isBanned=$(echo $TokenContent | python -m json.tool 2>/dev/null | grep 'forbidden-location')
    local is403=$(echo $TokenContent | grep '403 ERROR')

    if [ -n "$isBanned" ] || [ -n "$is403" ]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local fakecontent=$(echo "$Media_Cookie" | sed -n '8p')
    local refreshToken=$(echo $TokenContent | python -m json.tool 2>/dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
    local disneycontent=$(echo $fakecontent | sed "s/ILOVEDISNEY/${refreshToken}/g")
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycontent" 2>&1)
    local previewcheck=$(curl $useNIC $usePROXY $xForward -${1} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://disneyplus.com" | grep preview)
    local isUnabailable=$(echo $previewcheck | grep 'unavailable')
    local region=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'countryCode' | cut -f4 -d'"')
    local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')

    if [[ "$region" == "JP" ]]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Green}Yes (Region: JP)${Font_Suffix}\n"
        return
    elif [ -n "$region" ] && [[ "$inSupportedLocation" == "false" ]] && [ -z "$isUnabailable" ]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Yellow}Available For [Disney+ $region] Soon${Font_Suffix}\n"
        return
    elif [ -n "$region" ] && [ -n "$isUnavailable" ]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$region" ] && [[ "$inSupportedLocation" == "true" ]]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    elif [ -z "$region" ]; then
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Disney+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Dazn() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} -sS --max-time 10 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' "https://startup.core.indazn.com/misl/v5/Startup" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    isAllowed=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'isAllowed' | awk '{print $2}' | cut -f1 -d',')
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"GeolocatedCountry":' | awk '{print $2}' | cut -f2 -d'"')

    if [[ "$isAllowed" == "true" ]]; then
        local CountryCode=$(echo $result | tr [:lower:] [:upper:])
        echo -n -e "\r Dazn:\t\t\t\t\t${Font_Green}Yes (Region: ${CountryCode})${Font_Suffix}\n"
        return
    elif [[ "$isAllowed" == "false" ]]; then
        echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_HuluJP() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://id.hulu.jp" 2>&1 | grep 'restrict')

    if [ -n "$result" ]; then
        echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_MyTVSuper() {
    local result=$(curl $useNIC $usePROXY $xForward -s -${1} --max-time 10 "https://www.mytvsuper.com/api/auth/getSession/self/" 2>&1 | sed -n 's/.*"country_code":"\([A-Z]*\)".*/\1/p')

    if [[ "$result" == "HK" ]]; then
        echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_NowE() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"contentId":"202403181904703","contentType":"Vod","pin":"","deviceName":"Browser","deviceId":"w-663bcc51-913c-913c-913c-913c913c","deviceType":"WEB","secureCookie":null,"callerReferenceNo":"W17151951620081575","profileId":null,"mupId":null}' "https://webtvapi.nowe.com/16/1/getVodURL" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"')
    case "$result" in
        "GEO_CHECK_FAIL") echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n" ;;
        "SUCCESS") echo -n -e "\r Now E:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" ;;
        *) echo -n -e "\r Now E:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" ;;
    esac
}

function MediaUnlockTest_ViuTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"callerReferenceNo":"20210726112323","contentId":"099","contentType":"Channel","channelno":"099","mode":"prod","deviceId":"29b3cb117a635d5b56","deviceType":"ANDROID_WEB"}' "https://api.viu.now.com/p8/3/getLiveURL" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"')
    if [[ "$result" == "SUCCESS" ]]; then
        echo -n -e "\r Viu.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "GEO_CHECK_FAIL" ]]; then
        echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_unext() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} -s --max-time 10 "https://cc.unext.jp" -H 'content-type: application/json' --data-raw '{"operationName":"cosmo_getPlaylistUrl","variables":{"code":"ED00479780","playMode":"caption","bitrateLow":192,"bitrateHigh":null,"validationOnly":false},"query":"query cosmo_getPlaylistUrl($code: String, $playMode: String, $bitrateLow: Int, $bitrateHigh: Int, $validationOnly: Boolean) {\n  webfront_playlistUrl(\n    code: $code\n    playMode: $playMode\n    bitrateLow: $bitrateLow\n    bitrateHigh: $bitrateHigh\n    validationOnly: $validationOnly\n  ) {\n    subTitle\n    playToken\n    playTokenHash\n    beaconSpan\n    result {\n      errorCode\n      errorMessage\n      __typename\n    }\n    resultStatus\n    licenseExpireDate\n    urlInfo {\n      code\n      startPoint\n      resumePoint\n      endPoint\n      endrollStartPosition\n      holderId\n      saleTypeCode\n      sceneSearchList {\n        IMS_AD1\n        IMS_L\n        IMS_M\n        IMS_S\n        __typename\n      }\n      movieProfile {\n        cdnId\n        type\n        playlistUrl\n        movieAudioList {\n          audioType\n          __typename\n        }\n        licenseUrlList {\n          type\n          licenseUrl\n          __typename\n        }\n        __typename\n      }\n      umcContentId\n      movieSecurityLevelCode\n      captionFlg\n      dubFlg\n      commodityCode\n      movieAudioList {\n        audioType\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"}' | python -m json.tool 2>/dev/null | grep 'resultStatus' | awk '{print $2}' | cut -d ',' -f1 2>&1)
    if [ -n "$result" ]; then
        if [[ "$result" == "475" ]]; then
            echo -n -e "\r U-NEXT:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        elif [[ "$result" == "200" ]]; then
            echo -n -e "\r U-NEXT:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        elif [[ "$result" == "467" ]]; then
            echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        else
            echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r U-NEXT:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_wowow() {
    local timestamp=$[$(date +%s%N)/1000000]
    # 取原创剧集列表
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://www.wowow.co.jp/drama/original/json/lineup.json?_=${timestamp}" -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://www.wowow.co.jp/drama/original/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'X-Requested-With: XMLHttpRequest' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' --user-agent "${UA_Browser}")
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 取第一个剧集来播放 example: https://www.wowow.co.jp/drama/original/hakubo/
    local playUrl=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"link"' | awk '{print $2}' | cut -f2 -d'"' | head -n 1)
    # 访问并获取真实链接
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "${playUrl}" --user-agent "${UA_Browser}")
    if [ -z "$tmpresult2" ]; then
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 取得真实链接
    local wodUrl=$(echo $tmpresult2 | grep -o '"https://wod.wowow.co.jp/content/.*"' | cut -f2 -d'"')
    # 访问并获取 meta_id
    local tmpresult3=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "${wodUrl}" --user-agent "${UA_Browser}")
    local metaId=$(echo $tmpresult3 | grep -o '"https://wod.wowow.co.jp/watch/.*"' | cut -f2 -d'"' | sed 's/https:\/\/wod.wowow.co.jp\/watch\///')
    # Fake Vistor UID
    local vUid=$(echo -n $timestamp | md5sum | cut -f1 -d' ')
    # 最终测试
    local tmpresult4=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s 'https://mapi.wowow.co.jp/api/v1/playback/auth' -H 'accept: application/json, text/plain, */*' -H 'content-type: application/json;charset=UTF-8' -H 'origin: https://wod.wowow.co.jp' -H 'referer: https://wod.wowow.co.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' -H 'x-requested-with: XMLHttpRequest' --data-raw "{\"meta_id\":${metaId},\"vuid\":\"${vUid}\",\"device_code\":1,\"app_id\":1,\"ua\":\"${UA_Browser}\"}" --user-agent "${UA_Browser}")
    if [ -z "$tmpresult4" ]; then
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local isBlocked=$(echo $tmpresult4 | python -m json.tool 2>/dev/null | grep 'VPN')
    local isOK=$(echo $tmpresult4 | python -m json.tool 2>/dev/null | grep 'playback_session_id')
    if [ -n "$isBlocked" ]; then
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
    if [ -n "$isOK" ]; then
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r WOWOW:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_TVer() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s 'https://platform-api.tver.jp/v2/api/platform_users/browser/create' -H 'content-type: application/x-www-form-urlencoded' -H 'origin: https://s.tver.jp' -H 'referer: https://s.tver.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' --data-raw 'device_type=pc' --user-agent "${UA_Browser}")
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 先取 UID 和 TOKEN
    local platformUid=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"platform_uid"' | cut -f4 -d'"')
    local platformToken=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"platform_token"' | cut -f4 -d'"')
    # 根据 UID 和 TOKEN 取得当前正在播放的剧集
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://platform-api.tver.jp/service/api/v1/callHome?platform_uid=${platformUid}&platform_token=${platformToken}&require_data=mylist%2Cresume%2Clater" -H 'origin: https://tver.jp' -H 'referer: https://tver.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' -H 'x-tver-platform-type: web' --user-agent "${UA_Browser}")
    if [ -z "$tmpresult2" ]; then
        echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 返回结果取新电视剧第一个值
    # echo $tmpresult2 | jq  -r '.result.components.[] | select(.componentID | contains("newer-drama")) | limit(1; .contents.[].content.id)'
    local episodeId=$(echo $tmpresult2 | sed 's/.*"newer-drama"//' | sed 's/"componentID".*//' | sed 's/"id"/_TAG_/;s/.*_TAG_//' | cut -f2 -d'"')
    # 取得该剧集信息
    local tmpresult3=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://statics.tver.jp/content/episode/${episodeId}.json" -H 'origin: https://tver.jp' -H 'referer: https://tver.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' --user-agent "${UA_Browser}")
    if [ -z "$tmpresult3" ]; then
        echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 取 accountID / playerID / videoID / videoRefID
    local accountID=$(echo $tmpresult3 | python -m json.tool 2>/dev/null | grep '"accountID"' | cut -f4 -d'"')
    local playerID=$(echo $tmpresult3 | python -m json.tool 2>/dev/null | grep '"playerID"' | cut -f4 -d'"')
    local videoID=$(echo $tmpresult3 | python -m json.tool 2>/dev/null | grep '"videoID"' | cut -f4 -d'"')
    local videoRefID=$(echo $tmpresult3 | python -m json.tool 2>/dev/null | grep '"videoRefID"' | cut -f4 -d'"')
    # 取得 brightcove 播放器信息
    local tmpresult4=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://players.brightcove.net/${accountID}/${playerID}_default/index.min.js" -H 'Referer: https://tver.jp/' -H 'Sec-Fetch-Dest: script' -H 'Sec-Fetch-Mode: no-cors' -H 'Sec-Fetch-Site: cross-site' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' --user-agent "${UA_Browser}")
    if [ -z "$tmpresult4" ]; then
        echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    # 取 policy_key
    local policyKey=$(echo $tmpresult4 | sed 's/.*policyKey:"//' | awk -F'"' '{print $1}')

    if [ -z "${videoRefID}" ]; then
        # 取 deliveryConfigId
        local deliveryConfigId=$(echo $tmpresult4 | sed 's/.*deliveryConfigId:"//' | awk -F'"' '{print $1}')
        # 最终检查
        local tmpresult5=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://edge.api.brightcove.com/playback/v1/accounts/${accountID}/videos/${videoID}?config_id=${deliveryConfigId}" -H "accept: application/json;pk=${policyKey}" -H 'origin: https://tver.jp' -H 'referer: https://tver.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: cross-site' --user-agent "${UA_Browser}")
    else
        # 最终检查
        local tmpresult5=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 -s "https://edge.api.brightcove.com/playback/v1/accounts/${accountID}/videos/ref%3A${videoRefID}" -H "accept: application/json;pk=${policyKey}" -H 'origin: https://tver.jp' -H 'referer: https://tver.jp/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: cross-site' --user-agent "${UA_Browser}")
    fi

    if [ -z "$tmpresult5" ]; then
        echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult5 | python -m json.tool 2>/dev/null | grep error_subcode | cut -f4 -d'"')
    case "$result" in
        "CLIENT_GEO") echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n" ;;
        '') echo -n -e "\r TVer:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" ;;
        *) echo -n -e "\r TVer:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" ;;
    esac
}

function MediaUnlockTest_HamiVideo() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -Ss --max-time 10 "https://hamivideo.hinet.net/api/play.do?id=OTT_VOD_0000249064&freeProduct=1" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    checkfailed=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'code' | cut -f4 -d'"')
    if [[ "$checkfailed" == "06001-106" ]]; then
        echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$checkfailed" == "06001-107" ]]; then
        echo -n -e "\r Hami Video:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Hami Video:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_4GTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -sS --max-time 10 -X POST -d 'value=D33jXJ0JVFkBqV%2BZSi1mhPltbejAbPYbDnyI9hmfqjKaQwRQdj7ZKZRAdb16%2FRUrE8vGXLFfNKBLKJv%2BfDSiD%2BZJlUa5Msps2P4IWuTrUP1%2BCnS255YfRadf%2BKLUhIPj' "https://api2.4gtv.tv//Vod/GetVodUrl3" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    checkfailed=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'Success' | awk '{print $2}' | cut -f1 -d',')
    if [[ "$checkfailed" == "false" ]]; then
        echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$checkfailed" == "true" ]]; then
        echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r 4GTV.TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_SlingTV() {
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.sling.com/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Sling TV:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_PlutoTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://pluto.tv/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'thanks-for-watching')
    if [ -n "$result" ]; then
        echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Pluto TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Pluto TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_HBOMax() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.max.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local isUnavailable=$(echo $tmpresult | grep 'geo-availability')
    local region=$(echo $tmpresult | cut -f4 -d"/" | tr [:lower:] [:upper:])
    if [ -n "$isUnavailable" ]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$isUnavailable" ] && [ -n "$region" ]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    elif [ -z "$isUnavailable" ] && [ -z "$region" ]; then
        echo -n -e "\r HBO Max:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r HBO Max:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Showmax() {
    local region=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -si 'https://www.showmax.com/' -H 'host: www.showmax.com' -H 'connection: keep-alive' -H 'sec-ch-ua: "Chromium";v="124", "Microsoft Edge";v="124", "Not-A.Brand";v="99"' -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document' -H 'accept-language: zh-CN,zh;q=0.9' 2>&1 | grep 'activeTerritory'| awk -F'[=;]' '{print $2}')
    if [[ "$region" == "curl"* ]]; then
        echo -n -e "\r Showmax:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [ -n "$region" ]; then
        echo -n -e "\r Showmax:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    elif [ -z "$region" ]; then
        echo -n -e "\r Showmax:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Showmax:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Channel4() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.channel4.com/simulcast/channels/C4" 2>&1)

    if [[ "$result" == "403" ]]; then
        echo -n -e "\r Channel 4:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result" == "200" ]]; then
        echo -n -e "\r Channel 4:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Channel 4:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_ITVHUB() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://simulcast.itv.com/playlist/itvonline/ITV" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "404" ]; then
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r ITV Hub:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_DSTV() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://authentication.dstv.com/favicon.ico" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r DSTV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "404" ]; then
        echo -n -e "\r DSTV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ] || [ "$result" = "451" ]; then
        echo -n -e "\r DSTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r DSTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_iQYI_Region() {
    curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -I --max-time 10 "https://www.iq.com/" >~/iqiyi

    if [ $? -eq 1 ]; then
        echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    result=$(cat ~/iqiyi | grep 'mod=' | awk '{print $2}' | cut -f2 -d'=' | cut -f1 -d';')
    rm ~/iqiyi >/dev/null 2>&1

    if [ -n "$result" ]; then
        if [[ "$result" == "ntw" ]]; then
            result=TW
            echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
            return
        else
            result=$(echo $result | tr [:lower:] [:upper:])
            echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r iQyi Oversea Region:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_HuluUS() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://auth.hulu.com/v4/web/password/authenticate' --user-agent "${UA_Browser}" -H 'Accept: application/json' -H 'Accept-Language: zh-CN,zh;q=0.9' -H 'Connection: keep-alive' -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' -H 'Cookie: _hulu_at=eyJhbGciOiJSUzI1NiJ9.eyJhc3NpZ25tZW50cyI6ImV5SjJNU0k2VzExOSIsInJlZnJlc2hfaW50ZXJ2YWwiOjg2NDAwMDAwLCJ0b2tlbl9pZCI6IjQyZDk0YzA5LWYyZTEtNDdmNC1iYzU4LWUwNTA2NGNhYTdhZCIsImFub255bW91c19pZCI6IjYzNDUzMjA2LWFmYzgtNDU4Yi1iODBkLWNiMzk2MmYzZGQyZCIsImlzc3VlZF9hdCI6MTcwNjYwOTUzODc5MiwidHRsIjozMTUzNjAwMDAwMCwiZGV2aWNlX3VwcGVyIjoxfQ.e7sRCOndgn1j30XYkenLcLSQ7vwc2PXk-gFHMIF2gu_3UNEJ3pp3xNOZMN0n7DQRw5Jv68WiGxIvf65s8AetOoD4NLt4sZUDDz9HCRmFHzpmAJdtXWZ-HZ4fYucENuqDDDrsdQ-FCc0mgIe2IXkmQJ6tpIN3Zgcgmpmbeoq6jYyLlqg6f8eMsI1bNAsBGGj-9DXw2PMotlYHWB22pw2NRfJw1TjWXwywRBodAOve7rsu2Vhx-A2-OH4GplRvxLqzCpl2pcjkYg9atmUB7jnNIf_jHqlek4oRRawahWq-2vWnWmb1eMQcH-v2IHs3YdVk7I-t4iS19auPQrdgo6jPaA; _hulu_assignments=eyJ2MSI6W119; bm_mi=8896E057E2FC39F20852615A0C46A2B4~YAAQZB0gFyQrnlSNAQAAU/naWRaCMaJFIPi3L8KYSiCL3AN7XHCPw0gKvdIl0XZ/VE3QiKEr31qjm9sPulHbdQ4XXIXPXZ53DpIK43fLybrT6WxIpmGz3iThk6+xefI2dPLzwBAdoTrsbAbHC2q4LDx0SBM+n21LvTD7UnT2+DyVBK75YCDJJKHlJ5jzB3Q81JIlmqfTzibjgVmPIxXrFdTs5Ll8mtp6WzE3VDISmjGjTRTrSOVYM0YGpyhye1nsm3zBCO13vDjKMCJ/6oAsVqBfgfW07e7sWkWeUiDYLUifRDymc4GaMhavenBvCma/G1qW~1; bm_sv=FEE04D9D797D0237C312D77F57DABBFD~YAAQZB0gFyUrnlSNAQAAU/naWRaMNI8KmoGX9XNJkm9x9VeeGzGQyPfu49M9MnLObz8D4ZYk9Td+3Y8Z/Jfx+kl2qOPXmtOC5GZpA++9bxUKV0SwaoGhivl+ibIJSQTc7lw4kzdM/2w8b3rwItRaHXFa+shMtD3eiKvBePrqCiezucqrcss1U4ojLKEOvcsKJGt6ZTGGs2H+Qu6cyns9BVN0BprMHRY3njHXyxbFIcGy8Lq7aPn6nuZ0ehfZ9Q==~1; ak_bmsc=55F791116713DDB91AB0978225853B77~000000000000000000000000000000~YAAQZB0gF6ErnlSNAQAAHALbWRaA625r4bWVW8g2gHV797RN8bfCwNy6KfnGEucUPiPt4QKjJUldR6lyaM7sarag6A7WLqxEFr/zAFlPQI12Uxsqdzg3IgU0R8g2eMQRnRoGMNSUPyt4rdCWWwGjEcM+dQ8TI+y1vKw9dLXoBJAHofaWe/dZhY4fx2mYKhKFibvdpwJT6UPe4rBz8igd9oTQBn69Ebi6/9YFykqGuKsllxa5+QZWczb0+HLLDRKV4CkZdhbFj0yljEOyz4GHqqP8qg3Xa3lCKzdzsrmPn6zdFbgzCE8HsyPjsmy+/rRfFxagH5rYudLqFXg5o5dXFFJPTiLXtZ/S30ckc/OUWk4JP2ywAQVm/zbp8nlRVMFDEdjIPh/F+5QXfYBV+yL4a85ThlBEXSr54/QWXiHxBRiOwhv2ydoZDfT78r9bUHbMOra37C0xutfo37fbYEw9LWlLdZCub9U5HA/zSeIN3KxrZr0yNKfJjOau7BqdHL+AuvDj134ZPZPVig==; _customer_type=anonymous; s_fid=66C80912997F4CF8-2D3140F8EDC76274; s_cc=true; _rdt_uuid=1706609517486.d5b309e4-2b0b-440f-9817-cf619e4ce15d; _gcl_au=1.1.602757068.1706609518; _scid=cc980fef-26dc-479a-b9a8-b0e531c87cd3; _scid_r=cc980fef-26dc-479a-b9a8-b0e531c87cd3; _tt_enable_cookie=1; _ttp=1h5M9exzlSz7wAFDR78KCHCsnDC; utag_main=v_id:018d59da9a5c00215e601dada5700507d001c07500bd0$_sn:1$_ss:0$_st:1706611329541$ses_id:1706609515101%3Bexp-session$_pn:1%3Bexp-session$_prevpage:%2Fwelcome%3Bexp-1706613129564$trial_duration:undefined%3Bexp-session$program_id:undefined%3Bexp-session$vapi_domain:hulu.com$g_sync_ran:1%3Bexp-session$dc_visit:1$dc_event:1%3Bexp-session$dc_region:ap-east-1%3Bexp-session; _hulu_metrics_context_v1_=%7B%22cookie_session_guid%22%3A%227dc4f3a6826f2c35125268f5ddab1849%22%2C%22referrer_url%22%3A%22%22%2C%22curr_page_uri%22%3A%22www.hulu.com%2Fwelcome%22%2C%22primary_ref_page_uri%22%3Anull%2C%22secondary_ref_page_uri%22%3Anull%2C%22curr_page_type%22%3A%22landing%22%2C%22primary_ref_page_type%22%3Anull%2C%22secondary_ref_page_type%22%3Anull%2C%22secondary_ref_click%22%3A%22%22%2C%22primary_ref_click%22%3A%22%22%7D; metrics_tracker_session_manager=%7B%22session_id%22%3A%22B26515EB8A7952D4D35F374465362A72-529671c4-c8c2-4c7c-8bff-cc201bcd4075%22%2C%22creation_time%22%3A1706609513429%2C%22visit_count%22%3A1%2C%22session_seq%22%3A4%2C%22idle_time%22%3A1706609529579%7D; guid=B26515EB8A7952D4D35F374465362A72; JSESSIONID=ED7031784C3B1843BFC9AACBB156C6BA; s_sq=wdghuluwebprod%3D%2526c.%2526a.%2526activitymap.%2526page%253Dwelcome%2526link%253DLOG%252520IN%2526region%253Dlogin-modal%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c%2526pid%253Dwelcome%2526pidt%253D1%2526oid%253Dfunctionsn%252528%252529%25257B%25257D%2526oidt%253D2%2526ot%253DBUTTON; XSRF-TOKEN=bcfa1766-1f73-442d-a71b-e1cf6c275f45; _h_csrf_id=2a52618e9d006ac2e0b3e65740aa55e2584359553466051c3b01a2f1fb91726a' -H 'Origin: https://www.hulu.com' -H 'Referer: https://www.hulu.com/welcome' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' --data-raw 'user_email=me%40jamchoi.cc&password=Jam0.5cm~&recaptcha_type=web_invisible&rrventerprise=03AFcWeA6UFet_b_82RUmGfFWJCWuqy6kIn854Rhqjwd7vrkjH6Vku1wBZy8-FBA3Efx1p2cuNnKeJRuk7yJWm-xZgFfUx0Wdj2OAhiGvIdWrcpfeuQSXEqaXH4FKdmAHVZ3EqHwe5-h_zgtcyIxq-Nn1-sjeUfx1Y7QyVkb_GWJcr0GLoKgTFLzbF4kmJ8Qsi4IFx9hyYo9TFbBqtYdgxCI2q9DnEzOHrxK-987PEY8qzsR08Hrb9oDvumqLp1gs4uEVTwDKWt37aNB3CMVBKL2lHj7n768kXpgkXFDIhcM2eiJJ-H22qxKzNUpg-Q_N1xzkYsavCJG3ckQgsCTRRP2NU3nIERTWDTVXRBEq52-_ZQWu_Ds4W4UZyP0hEhCD2gambN4YJqEzaeHdGPwOR943nFbG6GILBx4vY-UUc7zjMf2HRjkNPvPpQiHMIYo21JXq6l8-IWyTeHY26NU6M4vCCbzwZEsdSln48rXM_fdBcDHC-8AxUFuBR8j3DMsB6Q3xMS2EHeGVrmhDY1izDNJZsVC_cN0W2tRneOJmni7ZU1iAYoBAGBBM5FDTE4UbYUTnuUn-htm9Q0RzukpYTumF_WwQ3HnEL0JK1Q1xea-hteI8lB4oAkhVOBOHVPii9atdZR9ZLpxRh1pdy3Lwmr1ltsubxE05wqmrmt33P2WsvH_3nBJXC_FhTD06BxT60RuiGtFr2gscHjjl_NCa1F-Dv9Hgi5ek2nLHK37a84bRSoKwLL3Lnpi9byuBntlpf-UXj7nveawKZmZTUBOSc7j6Vmmf124DTPJXsFeofMfUXkqTauPTWJBOz0OdKnLKDHMSsk7oSJVKsDUEeq0iKMdtCMBPvQBaPYAb79LDRwv_ereqyklKcUKQxeZRZmEXLKIWp8BS4U9uTXA2w8hwZWe7goLnUBQATIwojeHKpypSLnzQBu9JCwMU4aXfKIplL8sXuAx3QFD52eGZSCEyuFXP3ACN53QOlTAjjlP2eDT9fEwWHT4o8eJfviyjvm8xDmzKtq4F3u5XB3tL86-dK40XYbGcTI0Irw1nz1UTcxplFgHQgb6i8WEAqb69CQkpGWAUlmnknBirRAv2adqPaW2d_lv6L3Eo-ZupWcZ9Cu4PibM5BruVNXifBwPNPXHKw-sWBj-UP1g9VtxHVEVwoTXrbB-lT8EvjDEDQKrvOwnri4_tzVzn6YKvQMELbxSegvmc2w7xypT2qFzKRFXqwTMLT9d0rf2p9tbwbe39REMR8oI7wPfbjyJjK2XF4DmEAyVvBMuJlBaBsKBs5VynITHFWs4xvkAOe4jO_fzkKXzB6F6DB03ldasxbrNK_cepUOF6FD39-pHvbAGcoTrDrx6FSfecYXwSvc3GxM3IHSKwISKWav2iqPMtIt6ClCgUPgTCBDng2ZptXeVG8FckGIGMEdVlgGt5DG2tdMO2p8Hs5tKXuu8anc_csaaSfLIQ1_kav0dp8vpSXhCxeg899o5coXderUoIBcUsfaBJJm80YnCAc4LaM8HmYtJBcKqCC_uwCckPDOuC0SQy3d07LEi6wyifvY0Kv_-ER6wXvhNWnDZIXJNlH2369X7y8o3y2HMisOwAhfmKN7_ZAaODEOO-5x9JHocAYnt4a8_focwU9JQ_hUQgtdzYpP1ACEqxVjJb0A0NlABpm-CG8V9n9y6XpZkGQiMYJIH3jr6VilHSEM9rQSEv6LN8NFigl3-5Y4Ri7W4joz3LUMQcjFj3qXd3AXonarXhwglVNB9BYquCdA5eq4wVUeAkm3R-e56TK5IZwpb5wNJDO3PhuXHSMwv1k-NEAIfI9_w&scenario=web_password_login&csrf=c2c20e89ce4e314771dcda79994b2cd020b9c30fc25faccdc1ebef3351a5b36b')
    local isOK=$(echo "$tmpresult" | grep 'LOGIN_FORBIDDEN')
    local isBlocked=$(echo "$tmpresult" | grep 'GEO_BLOCKED')

    if [ -n "$isBlocked" ]; then
        echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [ -n "$isOK" ]; then
        echo -n -e "\r Hulu:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_encoreTVB() {
    tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 -H "Accept: application/json;pk=BCpkADawqM2Gpjj8SlY2mj4FgJJMfUpxTNtHWXOItY1PvamzxGstJbsgc-zFOHkCVcKeeOhPUd9MNHEGJoVy1By1Hrlh9rOXArC5M5MTcChJGU6maC8qhQ4Y8W-QYtvi8Nq34bUb9IOvoKBLeNF4D9Avskfe9rtMoEjj6ImXu_i4oIhYS0dx7x1AgHvtAaZFFhq3LBGtR-ZcsSqxNzVg-4PRUI9zcytQkk_YJXndNSfhVdmYmnxkgx1XXisGv1FG5GOmEK4jZ_Ih0riX5icFnHrgniADr4bA2G7TYh4OeGBrYLyFN_BDOvq3nFGrXVWrTLhaYyjxOr4rZqJPKK2ybmMsq466Ke1ZtE-wNQ" -H "Origin: https://www.encoretvb.com" "https://edge.api.brightcove.com/playback/v1/accounts/5324042807001/videos/6005570109001" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'error_subcode' | cut -f4 -d'"')
    if [[ "$result" == "CLIENT_GEO" ]]; then
        echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo $tmpresult | python -m json.tool 2>/dev/null | grep 'account_id' >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -n -e "\r encoreTVB:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r encoreTVB:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Molotov() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 "https://fapi.molotov.tv/v1/open-europe/is-france" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    echo $tmpresult | python -m json.tool 2>/dev/null | grep 'false' >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -n -e "\r Molotov:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo $tmpresult | python -m json.tool 2>/dev/null | grep 'true' >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -n -e "\r Molotov:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Salto() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 "https://geo.salto.fr/v1/geoInfo/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Salto:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local CountryCode=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'country_code' | cut -f4 -d'"')
    local AllowedCode="FR,GP,MQ,GF,RE,YT,PM,BL,MF,WF,PF,NC"
    echo ${AllowedCode} | grep ${CountryCode} >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -n -e "\r Salto:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Salto:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_LineTV.TW() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://www.linetv.tw/api/part/11829/eps/1/part?chocomemberId=" 2>&1)
    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'countryCode' | awk '{print $2}' | cut -f1 -d',')
    if [ -n "$result" ]; then
        if [ "$result" = "228" ]; then
            echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        else
            echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r LineTV.TW:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Viu.com() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.viu.com/" 2>&1)
    if [ "$tmpresult" = "000" ]; then
        echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    result=$(echo $tmpresult | cut -f5 -d"/")
    if [ -n "$result" ]; then
        if [[ "$result" == "no-service" ]]; then
            echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        else
            result=$(echo $result | tr [:lower:] [:upper:])
            echo -n -e "\r Viu.com:\t\t\t\t${Font_Green}Yes (Region: ${result})${Font_Suffix}\n"
            return
        fi

    else
        echo -n -e "\r Viu.com:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_Niconico() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sSL --max-time 10 "https://www.nicovideo.jp/watch/so23017073" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Niconico:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    echo $tmpresult | grep '同じ地域' >/dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        echo -n -e "\r Niconico:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Niconico:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_ParamountPlus() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.paramountplus.com/" 2>&1 | grep 'intl')

    if [ -n "$result" ]; then
        echo -n -e "\r Paramount+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Paramount+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Paramount+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_KKTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api.kktv.me/v3/ipcheck" 2>&1)
    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r KKTV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'country' | cut -f4 -d'"')
    if [[ "$result" == "TW" ]]; then
        echo -n -e "\r KKTV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r KKTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_PeacockTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL -w "%{http_code}\n%{url_effective}\n" -o dev/null "https://www.peacocktv.com/" 2>&1)
    if [[ "$tmpresult" == "000"* ]]; then
        echo -n -e "\r Peacock TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'unavailable')
    if [ -n "$result" ]; then
        echo -n -e "\r Peacock TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Peacock TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_FOD() {

    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://geocontrol1.stream.ne.jp/fod-geo/check.xml?time=1624504256" 2>&1)
    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    echo $tmpresult | grep 'true' >/dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r FOD(Fuji TV):\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_YouTube_Premium() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --max-time 10 -sSL -H "Accept-Language: en" -b "YSC=BiCUU3-5Gdk; CONSENT=YES+cb.20220301-11-p0.en+FX+700; GPS=1; VISITOR_INFO1_LIVE=4VwPMkB7W5A; PREF=tz=Asia.Shanghai; _gcl_au=1.1.1809531354.1646633279" "https://www.youtube.com/premium" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local isCN=$(echo $tmpresult | grep 'www.google.cn')
    if [ -n "$isCN" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}No${Font_Suffix} ${Font_Green} (Region: CN)${Font_Suffix} \n"
        return
    fi
    local isNotAvailable=$(echo $tmpresult | grep 'Premium is not available in your country')
    local region=$(echo $tmpresult | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
    local isAvailable=$(echo $tmpresult | grep 'ad-free')

    if [ -n "$isNotAvailable" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}No${Font_Suffix} \n"
        return
    elif [ -n "$isAvailable" ] && [ -n "$region" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    elif [ -z "$region" ] && [ -n "$isAvailable" ]; then
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r YouTube Premium:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_YouTube_CDN() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 "https://redirector.googlevideo.com/report_mapping" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Check Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local iata=$(echo $tmpresult | grep '=>'| awk "NR==1" | awk '{print $3}' | cut -f2 -d'-' | cut -c 1-3 | tr [:lower:] [:upper:])

    local isIataFound1=$(echo "$IATACode" | grep $iata)
    local isIataFound2=$(echo "$IATACode2" | grep $iata)
    if [ -n "$isIataFound1" ]; then
        local lineNo=$(echo "$IATACode" | cut -f3 -d"|" | sed -n "/${iata}/=")
        local location=$(echo "$IATACode" | awk "NR==${lineNo}" | cut -f1 -d"|" | sed -e 's/^[[:space:]]*//')
    elif [ -z "$isIataFound1" ] && [ -n "$isIataFound2" ]; then
        local lineNo=$(echo "$IATACode2" | awk '{print $1}' | sed -n "/${iata}/=")
        local location=$(echo "$IATACode2" | awk "NR==${lineNo}" | cut -f2 -d"," | sed -e 's/^[[:space:]]*//' | tr [:upper:] [:lower:] | sed 's/\b[a-z]/\U&/g')
    fi

    local isIDC=$(echo $tmpresult | grep "router")
    if [ -n "$iata" ] && [ -z "$isIDC" ]; then
        local CDN_ISP=$(echo $tmpresult | awk "NR==1" | awk '{print $3}' | cut -f1 -d"-" | tr [:lower:] [:upper:])
        echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Yellow}$CDN_ISP in $location${Font_Suffix}\n"
        return
    elif [ -n "$iata" ] && [ -n "$isIDC" ]; then
        echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Green}$location${Font_Suffix}\n"
        return
    else
        echo -n -e "\r YouTube CDN:\t\t\t\t${Font_Red}Undetectable${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_BritBox() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.britbox.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r BritBox:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'locationnotsupported')
    if [ -n "$result" ]; then
        echo -n -e "\r BritBox:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r BritBox:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r BritBox:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_PrimeVideo_Region() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -sL --max-time 10 "https://www.primevideo.com" 2>&1)

    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep '"currentTerritory":' | sed 's/.*currentTerritory//' | cut -f3 -d'"' | head -n 1)
    if [ -n "$result" ]; then
        echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Green}Yes (Region: $result)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Amazon Prime Video:\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Radiko() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://radiko.jp/area?_=1625406539531" 2>&1)

    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r Radiko:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local checkfailed=$(echo $tmpresult | grep 'class="OUT"')
    if [ -n "$checkfailed" ]; then
        echo -n -e "\r Radiko:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local checksuccess=$(echo $tmpresult | grep 'JAPAN')
    if [ -n "$checksuccess" ]; then
        area=$(echo $tmpresult | awk '{print $2}' | sed 's/.*>//')
        echo -n -e "\r Radiko:\t\t\t\t${Font_Green}Yes (City: $area)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Radiko:\t\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_DMM() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://bitcoin.dmm.com/" 2>&1)

    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'This page is not available in your area')
    if [ -n "$checkfailed" ]; then
        echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local checksuccess=$(echo $tmpresult | grep '暗号資産')
    if [ -n "$checksuccess" ]; then
        echo -n -e "\r DMM:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r DMM:\t\t\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_DMMTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 -X POST -d '{"player_name":"dmmtv_browser","player_version":"0.0.0","content_type_detail":"VOD_SVOD","content_id":"11uvjcm4fw2wdu7drtd1epnvz","purchase_product_id":null}' "https://api.beacon.dmm.com/v1/streaming/start" 2>&1)

    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r DMM TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local checkfailed=$(echo $tmpresult | grep 'FOREIGN')
    if [ -n "$checkfailed" ]; then
        echo -n -e "\r DMM TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local checksuccess=$(echo $tmpresult | grep 'UNAUTHORIZED')
    if [ -n "$checksuccess" ]; then
        echo -n -e "\r DMM TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r DMM TV:\t\t\t\t${Font_Red}Unsupported${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Catchplay() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://sunapi.catchplay.com/geo" -H "authorization: Basic NTQ3MzM0NDgtYTU3Yi00MjU2LWE4MTEtMzdlYzNkNjJmM2E0Ok90QzR3elJRR2hLQ01sSDc2VEoy" 2>&1)
    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'code' | awk '{print $2}' | cut -f2 -d'"')
    if [ -n "$result" ]; then
        if [ "$result" = "0" ]; then
            echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        elif [ "$result" = "100016" ]; then
            echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        else
            echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r CatchPlay+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_HotStar() {
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.hotstar.com/o/v1/page/1557?offset=0&size=20&tao=0&tas=20" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r HotStar:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "401" ]; then
        local region=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -sI "https://www.hotstar.com" | grep 'geo=' | sed 's/.*geo=//' | cut -f1 -d",")
        local site_region=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.hotstar.com" | sed 's@.*com/@@' | tr [:lower:] [:upper:])
        if [ -n "$region" ] && [ "$region" = "$site_region" ]; then
            echo -n -e "\r HotStar:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
            return
        else
            echo -n -e "\r HotStar:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        fi
    elif [ "$result" = "475" ]; then
        echo -n -e "\r HotStar:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HotStar:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_LiTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 -X POST "https://www.litv.tv/vod/ajax/getUrl" -d '{"type":"noauth","assetId":"vod44868-010001M001_800K","puid":"6bc49a81-aad2-425c-8124-5b16e9e01337"}' -H "Content-Type: application/json" 2>&1)
    if [[ "$tmpresult" = "curl"* ]]; then
        echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'errorMessage' | awk '{print $2}' | cut -f1 -d"," | cut -f2 -d'"')
    if [ -n "$result" ]; then
        if [ "$result" = "null" ]; then
            echo -n -e "\r LiTV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        elif [ "$result" = "vod.error.outsideregionerror" ]; then
            echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r LiTV:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_FuboTV() {
    local radom_num=${RANDOM:0-1}
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -sSL --max-time 10 "https://api.fubo.tv/appconfig/v1/homepage?platform=web&client_version=R20230310.${radom_num}&nav=v0" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Fubo TV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Fubo TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'No Subscription')
    if [ -n "$result" ]; then
        echo -n -e "\r Fubo TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Fubo TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Fox() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://x-live-fox-stgec.uplynk.com/ausw/slices/8d1/d8e6eec26bf544f084bad49a7fa2eac5/8d1de292bcc943a6b886d029e6c0dc87/G00000000.ts?pbs=c61e60ee63ce43359679fb9f65d21564&cloud=aws&si=0" 2>&1)
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
    local tmpauth=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 -X POST "https://auth.joyn.de/auth/anonymous" -H "Content-Type: application/json" -d '{"client_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7","client_name":"web","anon_device_id":"b74b9f27-a994-4c45-b7eb-5b81b1c856e7"}' 2>&1)
    if [ -z "$tmpauth" ]; then
        echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    auth=$(echo $tmpauth | python -m json.tool 2>/dev/null | grep access_token | awk '{print $2}' | cut -f2 -d'"')
    local result=$(curl $useNIC $usePROXY $xForward -s "https://api.joyn.de/content/entitlement-token" -H "x-api-key: 36lp1t4wto5uu2i2nk57ywy9on1ns5yg" -H "content-type: application/json" -d '{"content_id":"daserste-de-hd","content_type":"LIVE"}' -H "authorization: Bearer $auth" 2>&1)
    if [ -n "$result" ]; then
        isBlock=$(echo $result | python -m json.tool 2>/dev/null | grep 'code' | awk '{print $2}' | cut -f2 -d'"')
        if [[ "$isBlock" == "ENT_AssetNotAvailableInCountry" ]]; then
            echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
            return
        else
            echo -n -e "\r Joyn:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
            return
        fi
    else
        echo -n -e "\r Joyn:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_SpotvNow() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://edge.api.brightcove.com/playback/v1/accounts/5764318566001/videos/6349973203112' --user-agent "${UA_Browser}" -H 'accept: application/json;pk=BCpkADawqM0U3mi_PT566m5lvtapzMq3Uy7ICGGjGB6v4Ske7ZX_ynzj8ePedQJhH36nym_5mbvSYeyyHOOdUsZovyg2XlhV6rRspyYPw_USVNLaR0fB_AAL2HSQlfuetIPiEzbUs1tpNF9NtQxt3BAPvXdOAsvy1ltLPWMVzJHiw9slpLRgI2NUufc' -H 'accept-language: en,zh-CN;q=0.9,zh;q=0.8' -H 'origin: https://www.spotvnow.co.kr' -H 'referer: https://www.spotvnow.co.kr/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: cross-site')
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r SPOTV NOW:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep error_subcode | cut -f4 -d'"')
    if [[ "$result" == "CLIENT_GEO" ]]; then
        echo -n -e "\r SPOTV NOW:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$result" ] && [ -n "$tmpresult" ]; then
        echo -n -e "\r SPOTV NOW:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SPOTV NOW:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_SKY_DE() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://edge.api.brightcove.com/playback/v1/accounts/1050888051001/videos/6247131490001" -H "Accept: application/json;pk=BCpkADawqM0OXCLe4eIkpyuir8Ssf3kIQAM62a1KMa4-1_vTOWQIxoHHD4-oL-dPmlp-rLoS-WIAcaAMKuZVMR57QY4uLAmP4Ov3V416hHbqr0GNNtzVXamJ6d4-rA3Xi98W-8wtypdEyjGEZNepUCt3D7UdMthbsG-Ean3V4cafT4nZX03st5HlyK1chp51SfA-vKcAOhHZ4_Oa9TTN61tEH6YqML9PWGyKrbuN5myICcGsFzP3R2aOF8c5rPCHT2ZAiG7MoavHx8WMjhfB0QdBr2fphX24CSpUKlcjEnQJnBiA1AdLg9iyReWrAdQylX4Eyhw5OwKiCGJznfgY6BDtbUmeq1I9r9RfmhP5bfxVGjILSEFZgXbMqGOvYdrdare0aW2fTCxeHdHt0vyKOWTC6CS1lrGJF2sFPKn1T1csjVR8s4MODqCBY1PTbHY4A9aZ-2MDJUVJDkOK52hGej6aXE5b9N9_xOT2B9wbXL1B1ZB4JLjeAdBuVtaUOJ44N0aCd8Ns0o02E1APxucQqrjnEociLFNB0Bobe1nkGt3PS74IQcs-eBvWYSpolldMH6TKLu8JqgdnM4WIp3FZtTWJRADgAmvF9tVDUG9pcJoRx_CZ4im-rn-AzN3FeOQrM4rTlU3Q8YhSmyEIoxYYqsFDwbFlhsAcvqQkgaElYtuciCL5i3U8N4W9rIhPhQJzsPafmLdWxBP_FXicyek25GHFdQzCiT8nf1o860Jv2cHQ4xUNcnP-9blIkLy9JmuB2RgUXOHzWsrLGGW6hq9wLUtqwEoxcEAAcNJgmoC0k8HE-Ga-NHXng6EFWnqiOg_mZ_MDd7gmHrrKLkQV" -H "Origin: https://www.sky.de" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r SKY DE:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep error_subcode | cut -f4 -d'"')
    if [[ "$result" == "CLIENT_GEO" ]]; then
        echo -n -e "\r SKY DE:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$result" ] && [ -n "$tmpresult" ]; then
        echo -n -e "\r SKY DE:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SKY DE:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_ZDF() {
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://ssl.zdf.de/geo/de/geo.txt/" 2>&1)
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

    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api2.hbogoasia.com/v1/geog?lang=undefined&version=0&bundleId=www.hbogoasia.com" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep territory)
    if [ -z "$result" ]; then
        echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$result" ]; then
        local CountryCode=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep country | cut -f4 -d'"')
        echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Green}Yes (Region: $CountryCode)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HBO GO Asia:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_HBOGO_EUROPE() {

    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api.ugw.hbogo.eu/v3.0/GeoCheck/json/HUN" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep allow | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "1" ]]; then
        echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "0" ]]; then
        echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HBO GO Europe:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_EPIX() {
    tmpToken=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -X POST --max-time 10 'https://api.epix.com/v2/sessions' --user-agent "${UA_Browser}" -H 'host: api.epix.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'traceparent: 00-000000000000000015b7efdb572b7bf2-4aefaea90903bd1f-01' -H 'sec-ch-ua-mobile: ?0' -H 'x-datadog-origin: rum' -H 'x-datadog-sampling-priority: 1' -H 'accept: application/json' -H 'x-datadog-trace-id: 1564983120873880562' -H 'x-datadog-parent-id: 5399726519264460063' -H 'sec-ch-ua-platform: "Windows"' -H 'origin: https://www.mgmplus.com' -H 'sec-fetch-site: cross-site' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://www.mgmplus.com/' -H 'accept-language: zh-CN,zh;q=0.9' -H 'content-type: application/json' -d '{"device":{"guid":"7a0baaaf-384c-45cd-a21d-310ca5d3002a","format":"console","os":"web","display_width":1865,"display_height":942,"app_version":"1.0.2","model":"browser","manufacturer":"google"},"apikey":"53e208a9bbaee479903f43b39d7301f7"}')
    if [ -z "$tmpToken" ]; then
        echo -n -e "\r MGM+:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [[ "$tmpToken" == "error code"* ]]; then
        echo -n -e "\r MGM+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    EpixToken=$(echo $tmpToken | python -m json.tool 2>/dev/null | grep 'session_token' | cut -f4 -d'"')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -X POST -s --max-time 10 'https://api.epix.com/graphql' --user-agent "${UA_Browser}" -H 'host: api.epix.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'traceparent: 00-0000000000000000603047c112148412-32d64f8c890631ef-01' -H 'sec-ch-ua-mobile: ?0' -H 'x-datadog-origin: rum' -H 'x-datadog-sampling-priority: 1' -H 'accept: application/json' -H "x-session-token: ${EpixToken}" -H 'x-datadog-trace-id: 6931118721080787986' -H 'x-datadog-parent-id: 3663202811925377519' -H 'sec-ch-ua-platform: "Windows"' -H 'origin: https://www.mgmplus.com' -H 'sec-fetch-site: cross-site' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://www.mgmplus.com/' -H 'accept-language: zh-CN,zh;q=0.9' -H 'content-type: application/json' -d '{"operationName":"PlayFlow","variables":{"id":"c2VyaWVzOzEwMTc=","supportedActions":["open_url","show_notice","start_billing","play_content","log_in","noop","confirm_provider","unlinked_provider"],"streamTypes":[{"encryptionScheme":"CBCS","packagingSystem":"DASH"},{"encryptionScheme":"CENC","packagingSystem":"DASH"},{"encryptionScheme":"NONE","packagingSystem":"HLS"},{"encryptionScheme":"SAMPLE_AES","packagingSystem":"HLS"}]},"query":"fragment ShowNotice on ShowNotice {\n  type\n  actions {\n    continuationContext\n    text\n    __typename\n  }\n  description\n  title\n  __typename\n}\n\nfragment OpenUrl on OpenUrl {\n  type\n  url\n  __typename\n}\n\nfragment Content on Content {\n  title\n  __typename\n}\n\nfragment Movie on Movie {\n  id\n  shortName\n  __typename\n}\n\nfragment Episode on Episode {\n  id\n  series {\n    shortName\n    __typename\n  }\n  seasonNumber\n  number\n  __typename\n}\n\nfragment Preroll on Preroll {\n  id\n  __typename\n}\n\nfragment ContentUnion on ContentUnion {\n  ...Content\n  ...Movie\n  ...Episode\n  ...Preroll\n  __typename\n}\n\nfragment PlayContent on PlayContent {\n  type\n  continuationContext\n  heartbeatToken\n  currentItem {\n    content {\n      ...ContentUnion\n      __typename\n    }\n    __typename\n  }\n  nextItem {\n    content {\n      ...ContentUnion\n      __typename\n    }\n    showNotice {\n      ...ShowNotice\n      __typename\n    }\n    showNoticeAt\n    __typename\n  }\n  amazonPlaybackData {\n    pid\n    playbackToken\n    materialType\n    __typename\n  }\n  playheadPosition\n  vizbeeStreamInfo {\n    customStreamInfo\n    __typename\n  }\n  closedCaptions {\n    ttml {\n      location\n      __typename\n    }\n    vtt {\n      location\n      __typename\n    }\n    xml {\n      location\n      __typename\n    }\n    __typename\n  }\n  hints {\n    duration\n    seekAllowed\n    trackingEnabled\n    trackingId\n    __typename\n  }\n  streams(types: $streamTypes) {\n    playlistUrl\n    closedCaptionsEmbedded\n    packagingSystem\n    encryptionScheme\n    videoQuality {\n      height\n      width\n      __typename\n    }\n    widevine {\n      authenticationToken\n      licenseServerUrl\n      __typename\n    }\n    playready {\n      authenticationToken\n      licenseServerUrl\n      __typename\n    }\n    fairplay {\n      authenticationToken\n      certificateUrl\n      licenseServerUrl\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nfragment StartBilling on StartBilling {\n  type\n  __typename\n}\n\nfragment LogIn on LogIn {\n  type\n  __typename\n}\n\nfragment Noop on Noop {\n  type\n  __typename\n}\n\nfragment PreviewContent on PreviewContent {\n  type\n  title\n  description\n  stream {\n    sources {\n      hls {\n        location\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nfragment ConfirmProvider on ConfirmProvider {\n  type\n  __typename\n}\n\nfragment UnlinkedProvider on UnlinkedProvider {\n  type\n  __typename\n}\n\nquery PlayFlow($id: String!, $supportedActions: [PlayFlowActionEnum!]!, $context: String, $behavior: BehaviorEnum = DEFAULT, $streamTypes: [StreamDefinition!]) {\n  playFlow(\n    id: $id\n    supportedActions: $supportedActions\n    context: $context\n    behavior: $behavior\n  ) {\n    ...ShowNotice\n    ...OpenUrl\n    ...PlayContent\n    ...StartBilling\n    ...LogIn\n    ...Noop\n    ...PreviewContent\n    ...ConfirmProvider\n    ...UnlinkedProvider\n    __typename\n  }\n}"}')

    local isBlocked=$(echo $tmpresult | grep 'MGM+ is only available in the United States')
    local isOK=$(echo $tmpresult | grep StartBilling)
    if [ -n "$isBlocked" ]; then
        echo -n -e "\r MGM+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$isOK" ]; then
        echo -n -e "\r MGM+:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r MGM+:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_NLZIET() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -s --max-time 10 'https://api.nlziet.nl/v7/stream/handshake/Widevine/Dash/VOD/rzIL9rb-TkSn-ek_wBmvaw?playerName=BitmovinWeb' --user-agent "${UA_Browser}" -H 'accept: application/json, text/plain, */*' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' -H 'authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkM4M0YzQUFGOTRCOTM0ODA2NkQwRjZDRTNEODhGQkREIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE3MTIxMjY0NTMsImV4cCI6MTcxMjE1NTI0OCwiaXNzIjoiaHR0cHM6Ly9pZC5ubHppZXQubmwiLCJhdWQiOiJhcGkiLCJjbGllbnRfaWQiOiJ0cmlwbGUtd2ViIiwic3ViIjoiMDAzMTZiNGEtMDAwMC0wMDAwLWNhZmUtZjFkZTA1ZGVlZmVlIiwiYXV0aF90aW1lIjoxNzEyMTI2NDUzLCJpZHAiOiJsb2NhbCIsImVtYWlsIjoibXVsdGkuZG5zMUBvdXRsb29rLmNvbSIsInVzZXJJZCI6IjMyMzg3MzAiLCJjdXN0b21lcklkIjoiMCIsImRldmljZUlkZW50aWZpZXIiOiJJZGVudGl6aWV0LTI0NWJiNmYzLWM2ZjktNDNjZS05ODhmLTgxNDc2OTcwM2E5OCIsImV4dGVybmFsVXNlcklkIjoiZTM1ZjdkMzktMjQ0ZC00ZTkzLWFkOTItNGFjYzVjNGY0NGNlIiwicHJvZmlsZUlkIjoiMjdDMzM3RjktOTRDRS00NjBDLTlBNjktMTlDNjlCRTYwQUIzIiwicHJvZmlsZUNvbG9yIjoiRkY0MjdDIiwicHJvZmlsZVR5cGUiOiJBZHVsdCIsIm5hbWUiOiJTdHJlYW1pbmciLCJqdGkiOiI4Q0M1QzYzNkJGRjg3MEE2REJBOERBNUMwQTk0RUZDRiIsImlhdCI6MTcxMjEyNjQ1Mywic2NvcGUiOlsiYXBpIiwib3BlbmlkIl0sImFtciI6WyJwcm9maWxlIiwicHdkIl19.bk-ziFPJM00bpE7TcgPmIYFFx-2Q5N3BkUzEvQ_dDMK9O1F9f7DEe-Qzmnb5ym7ChlnXwrCV3QyOOA24hu_gCrlNlD7-vI3XGZR-54zFD-F7cRDOoL-1-iO_10tmgwb5Io-svY0bn0EDYKeRxYYBi0w_3bFVFDM2CxxA6tWeBYIfN5rCSzBHd3RPPjYtqX-sogyh_5W_7KJ83GK5kpsywT3mz8q7Cs1mtKs9QA1-o01N0RvTxZAcfzsHg3-qGgLnvaAuZ_XqRK9kLWqJWeJTWKWtUI6OlPex22sY3keKFpfZnUtFv-BvkCM6tvbIlMZAClk3lhI8rMFAWDpUcbcS3w' -H 'nlziet-appname: WebApp' -H 'nlziet-appversion: 5.43.24' -H 'origin: https://app.nlziet.nl' -H 'referer: https://app.nlziet.nl/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site')
    local isBlocked=$(echo $tmpresult | grep 'CountryNotAllowed')
    local isOK=$(echo $tmpresult | grep 'streamSessionId')
    if [ -n "$isBlocked" ]; then
        echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$isOK" ]; then
        echo -n -e "\r NLZIET:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r NLZIET:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_videoland() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://api.videoland.com/subscribe/videoland-account/graphql' -X POST --user-agent "${UA_Browser}" -H 'host: api.videoland.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'apollographql-client-name: apollo_accounts_base' -H 'traceparent: 00-cab2dbd109bf1e003903ec43eb4c067d-623ef8e56174b85a-01' -H 'sec-ch-ua-mobile: ?0' -H 'accept: */*' -H 'sec-ch-ua-platform: "Windows"' -H 'origin: https://www.videoland.com' -H 'sec-fetch-site: same-site' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://www.videoland.com/' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' -H 'content-type: application/json' -d '{"operationName":"IsOnboardingGeoBlocked","variables":{},"query":"query IsOnboardingGeoBlocked {\n  isOnboardingGeoBlocked\n}\n"}')
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r videoland:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep isOnboardingGeoBlocked | awk '{print $2}')
    if [[ "$result" == "false" ]]; then
        echo -n -e "\r videoland:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "true" ]]; then
        echo -n -e "\r videoland:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r videoland:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_NPO_Start_Plus() {
    local token=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sL --max-time 10 'https://www.npo.nl/start/api/domain/player-token?productId=LI_NL1_4188102' --user-agent "${UA_Browser}" -H 'host: www.npo.nl' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'accept: application/json, text/plain, */*' -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://www.npo.nl/start/live?channel=NPO1' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' | cut -f4 -d'"')
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 --write-out %{http_code} --output /dev/null 'https://prod.npoplayer.nl/stream-link' --user-agent "${UA_Browser}" -H 'accept: */*' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' -H "authorization: ${token}" -H 'content-type: application/json' -H 'origin: https://npo.nl' -H 'referer: https://npo.nl/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: cross-site' --data-raw '{"profileName":"dash","drmType":"playready","referrerUrl":"https://npo.nl/start/live?channel=NPO1"}')
    if [ -z "$result" ]; then
        echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    if [[ "$result" == "451" ]]; then
        echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result" == "200" ]]; then
        echo -n -e "\r NPO Start Plus:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r NPO Start Plus:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_RakutenTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://rakuten.tv" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'waitforit')
    if [ -n "$result" ]; then
        echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Rakuten TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_HBO_Spain() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api-discovery.hbo.eu/v1/discover/hbo?language=null&product=hboe" -H "X-Client-Name: web" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep signupAllowed | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r HBO Spain:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HBO Spain:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_MoviStarPlus() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s "https://contratar.movistarplus.es/" --write-out %{http_code} --output /dev/null)
    if [[ "$result" == "200" ]]; then
        echo -n -e "\r Movistar+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "403" ]]; then
        echo -n -e "\r Movistar+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result" == "000" ]]; then
        echo -n -e "\r Movistar+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Movistar+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_Starz() {
    local authorization=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 "https://www.starz.com/sapi/header/v1/starz/us/09b397fc9eb64d5080687fc8a218775b" -H "Referer: https://www.starz.com/us/en/" 2>&1)
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://auth.starz.com/api/v4/User/geolocation" -H "AuthTokenAuthorization: $authorization")
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local isAllowedAccess=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep isAllowedAccess | awk '{print $2}' | cut -f1 -d",")
    local isAllowedCountry=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep isAllowedCountry | awk '{print $2}' | cut -f1 -d",")
    local isKnownProxy=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep isKnownProxy | awk '{print $2}' | cut -f1 -d",")
    if [[ "$isAllowedAccess" == "true" ]] && [[ "$isAllowedCountry" == "true" ]] && [[ "$isKnownProxy" == "false" ]]; then
        echo -n -e "\r Starz:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$isAllowedAccess" == "false" ]]; then
        echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$isKnownProxy" == "false" ]]; then
        echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Starz:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_CanalPlus() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://boutique-tunnel.canalplus.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Canal+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'othercountry')
    if [ -n "$result" ]; then
        echo -n -e "\r Canal+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Canal+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Canal+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Sky_CH() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://sky.ch/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r SKY CH:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'out-of-country')
    if [ -n "$result" ]; then
        echo -n -e "\r SKY CH:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SKY CH:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r SKY CH:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_CBCGem() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://www.cbc.ca/g/stats/js/cbc-stats-top.js" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r CBC Gem:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | sed 's/.*country":"//' | cut -f1 -d"}" | cut -f1 -d'"')
    if [[ "$result" == "CA" ]]; then
        echo -n -e "\r CBC Gem:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r CBC Gem:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_AcornTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -L --max-time 10 "https://acorn.tv/")
    local isblocked=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://acorn.tv/" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [[ "$isblocked" == "403" ]]; then
        echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'Not yet available in your country')
    if [ -n "$result" ]; then
        echo -n -e "\r Acorn TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Acorn TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Crave() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://capi.9c9media.com/destinations/se_atexace/platforms/desktop/bond/contents/2205173/contentpackages/4279732/manifest.mpd" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Crave:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'Geo Constraint Restrictions')
    if [ -n "$result" ]; then
        echo -n -e "\r Crave:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Crave:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Amediateka() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://www.amediateka.ru/" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Amediateka:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'VPN')
    if [ -n "$result" ]; then
        echo -n -e "\r Amediateka:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Amediateka:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_MegogoTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://ctx.playfamily.ru/screenapi/v4/preparepurchase/web/1?elementId=0b974dc3-d4c5-4291-9df5-81a8132f67c5&elementAlias=51459024&elementType=GAME&withUpgradeSubscriptionReturnAmount=true&forceSvod=true&includeProductsForUpsale=false&sid=mDRnXOffdh_l2sBCyUIlbA" -H "X-SCRAPI-CLIENT-TS: 1627391624026" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep status | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "0" ]]; then
        echo -n -e "\r Megogo TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "502" ]]; then
        echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Megogo TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_RaiPlay() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://mediapolisvod.rai.it/relinker/relinkerServlet.htm?cont=VxXwi7UcqjApssSlashbjsAghviAeeqqEEqualeeqqEEqual&output=64" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Rai Play:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'no_available')
    if [ -n "$result" ]; then
        echo -n -e "\r Rai Play:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Rai Play:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_TVBAnywhere() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://uapisfm.tvbanywhere.com.sg/geoip/check/platform/android" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'allow_in_this_country' | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r TVBAnywhere+:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_ProjectSekai() {
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "User-Agent: pjsekai/48 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://game-version.sekai.colorfulpalette.org/1.8.1/3ed70b6a-8352-4532-b819-108837926ff5" 2>&1)
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
    local result=$(curl $useNIC $usePROXY $xForward -X POST --user-agent "User-Agent: pj0007/212 CFNetwork/1240.0.4 Darwin/20.6.0" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.konosubafd.jp/api/masterlist" 2>&1)
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
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.showtime.com/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SHOWTIME:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_NBATV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sSL --max-time 10 "https://www.nba.com/watch/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r NBA TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'Service is not available in your region')
    if [ -n "$result" ]; then
        echo -n -e "\r NBA TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r NBA TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_ATTNOW() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.atttvnow.com/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r Directv Stream:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Directv Stream:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Directv Stream:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_CineMax() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://play.maxgo.com/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r CineMax Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r CineMax Go:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r CineMax Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_NetflixCDN() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=1" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    elif [ -n "$(echo $tmpresult | grep '>403<')" ]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed (IP Banned By Netflix)${Font_Suffix}\n"
        return
    fi

    local CDNAddr=$(echo $tmpresult | sed 's/.*"url":"//' | cut -f3 -d"/")
    if [[ "$1" == "6" ]]; then
        nslookup -q=AAAA $CDNAddr >~/v6_addr.txt
        ifAAAA=$(cat ~/v6_addr.txt | grep 'AAAA address' | awk '{print $NF}')
        if [ -z "$ifAAAA" ]; then
            CDNIP=$(cat ~/v6_addr.txt | grep Address | sed -n '$p' | awk '{print $NF}')
        else
            CDNIP=${ifAAAA}
        fi
    else
        CDNIP=$(nslookup $CDNAddr | sed '/^\s*$/d' | awk 'END {print}' | awk '{print $2}')
    fi

    if [ -z "$CDNIP" ]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}Failed (CDN IP Not Found)${Font_Suffix}\n"
        rm -rf ~/v6_addr.txt
        return
    fi

    local CDN_ISP=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -s --max-time 20 "https://api.ip.sb/geoip/$CDNIP" 2>&1 | python -m json.tool 2>/dev/null | grep 'isp' | cut -f4 -d'"')
    local iata=$(echo $CDNAddr | cut -f3 -d"-" | sed 's/.\{3\}$//' | tr [:lower:] [:upper:])

    #local IATACode2=$(curl -s --retry 3 --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/reference/IATACode2.txt" 2>&1)

    local isIataFound1=$(echo "$IATACode" | grep $iata)
    local isIataFound2=$(echo "$IATACode2" | grep $iata)

    if [ -n "$isIataFound1" ]; then
        local lineNo=$(echo "$IATACode" | cut -f3 -d"|" | sed -n "/${iata}/=")
        local location=$(echo "$IATACode" | awk "NR==${lineNo}" | cut -f1 -d"|" | sed -e 's/^[[:space:]]*//')
    elif [ -z "$isIataFound1" ] && [ -n "$isIataFound2" ]; then
        local lineNo=$(echo "$IATACode2" | awk '{print $1}' | sed -n "/${iata}/=")
        local location=$(echo "$IATACode2" | awk "NR==${lineNo}" | cut -f2 -d"," | sed -e 's/^[[:space:]]*//' | tr [:upper:] [:lower:] | sed 's/\b[a-z]/\U&/g')
    fi

    if [ -n "$location" ] && [[ "$CDN_ISP" == "Netflix Streaming Services" ]]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Green}$location ${Font_Suffix}\n"
        rm -rf ~/v6_addr.txt
        return
    elif [ -n "$location" ] && [[ "$CDN_ISP" != "Netflix Streaming Services" ]]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Yellow}Associated with [$CDN_ISP] in [$location]${Font_Suffix}\n"
        rm -rf ~/v6_addr.txt
        return
    elif [ -n "$location" ] && [ -z "$CDN_ISP" ]; then
        echo -n -e "\r Netflix Preferred CDN:\t\t\t${Font_Red}No ISP Info Founded${Font_Suffix}\n"
        rm -rf ~/v6_addr.txt
        return
    fi
}

function MediaUnlockTest_HBO_Nordic() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api-discovery.hbo.eu/v1/discover/hbo?language=null&product=hbon" -H "X-Client-Name: web" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep signupAllowed | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HBO Nordic:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_HBO_Portugal() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://api.ugw.hbogo.eu/v3.0/GeoCheck/json/PRT" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep allow | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "1" ]]; then
        echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "0" ]]; then
        echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r HBO Portugal:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_SkyGo() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} -sL --max-time 10 "https://skyid.sky.com/authorise/skygo?response_type=token&client_id=sky&appearance=compact&redirect_uri=skygo://auth" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Sky Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep "You don't have permission to access")
    if [ -z "$result" ]; then
        echo -n -e "\r Sky Go:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Sky Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_ElevenSportsTW() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 10 "https://apis.v-saas.com:9501/member/api/viewAuthorization?contentId=1&memberId=384030&menuId=3&platform=5&imei=c959b475-f846-4a86-8e9b-508048372508" 2>&1)
    local qq=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"qq"' | cut -f4 -d'"')
    local st=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"st"' | cut -f4 -d'"')
    local m3u_RUL=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep boostStreamUrl | cut -f4 -d'"')
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "${m3u_RUL}?st=${st}&qq=${qq}")
    if [ "$result" = "000" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Eleven Sports TW:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_StarPlus() {
    local starcontent=$(echo "$Media_Cookie" | sed -n '10p')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://star.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: c3RhciZicm93c2VyJjEuMC4w.COknIGCR7I6N0M5PGnlcdbESHGkNv7POwhFNL-_vIdg" -d "$starcontent" 2>&1 )
    local previewcheck=$(curl $useNIC $usePROXY $xForward -${1} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.starplus.com/login" 2>&1)
    local isUnavailable=$(echo $previewcheck | grep unavailable)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local region=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'countryCode' | cut -f4 -d'"')
    local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')

    if [ -n "$region" ] && [ -z "$isUnavailable" ] && [[ "$inSupportedLocation" == "false" ]]; then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Yellow}CDN Relay Available${Font_Suffix}\n"
        return
    elif [ -n "$region" ] && [ -n "$isUnavailable" ]; then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$region" ] && [[ "$inSupportedLocation" == "true" ]]; then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    elif [ -z "$region" ]; then
        echo -n -e "\r Star+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_DirecTVGO() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.directvgo.com/registrarse" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local isForbidden=$(echo $tmpresult | grep 'proximamente')
    local region=$(echo $tmpresult | cut -f4 -d"/" | tr [:lower:] [:upper:])
    if [ -n "$isForbidden" ]; then
        echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$isForbidden" ] && [ -n "$region" ]; then
        echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r DirecTV Go:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_DAM() {
    local result=$(curl $useNIC $usePROXY $xForward --user-agent "${UA_Browser}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "http://cds1.clubdam.com/vhls-cds1/site/xbox/sample_1.mp4.m3u8" 2>&1)
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
    local GetToken=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://us1-prod-direct.discoveryplus.com/token?deviceId=d1a4a5d25212400d1e6985984604d740&realm=go&shortlived=true" 2>&1)
    if [[ "$GetToken" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$GetToken" == "curl"* ]]; then
        echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local Token=$(echo $GetToken | python -m json.tool 2>/dev/null | grep '"token":' | cut -f4 -d'"')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://us1-prod-direct.discoveryplus.com/users/me" -b "_gcl_au=1.1.858579665.1632206782; _rdt_uuid=1632206782474.6a9ad4f2-8ef7-4a49-9d60-e071bce45e88; _scid=d154b864-8b7e-4f46-90e0-8b56cff67d05; _pin_unauth=dWlkPU1qWTRNR1ZoTlRBdE1tSXdNaTAwTW1Nd0xUbGxORFV0WWpZMU0yVXdPV1l6WldFeQ; _sctr=1|1632153600000; aam_fw=aam%3D9354365%3Baam%3D9040990; aam_uuid=24382050115125439381416006538140778858; st=${Token}; gi_ls=0; _uetvid=a25161a01aa711ec92d47775379d5e4d; AMCV_BC501253513148ED0A490D45%40AdobeOrg=-1124106680%7CMCIDTS%7C18894%7CMCMID%7C24223296309793747161435877577673078228%7CMCAAMLH-1633011393%7C9%7CMCAAMB-1633011393%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1632413793s%7CNONE%7CvVersion%7C5.2.0; ass=19ef15da-95d6-4b1d-8fa2-e9e099c9cc38.1632408400.1632406594" 2>&1)
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep currentLocationTerritory | cut -f4 -d'"')
    if [[ "$result" == "us" ]]; then
        echo -n -e "\r Discovery+:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Discovery+:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_ESPNPlus() {
    local espncookie=$(echo "$Media_Cookie" | sed -n '11p')
    local TokenContent=$(curl -${1} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://espn.api.edge.bamgrid.com/token" -H "authorization: Bearer ZXNwbiZicm93c2VyJjEuMC4w.ptUt7QxsteaRruuPmGZFaJByOoqKvDP2a5YkInHrc7c" -d "$espncookie" 2>&1)
    local isBanned=$(echo $TokenContent | python -m json.tool 2>/dev/null | grep 'forbidden-location')
    local is403=$(echo $TokenContent | grep '403 ERROR')

    if [ -n "$isBanned" ] || [ -n "$is403" ]; then
        echo -n -e "\r ESPN+:${Font_SkyBlue}[Sponsored by Jam]${Font_Suffix}\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local fakecontent=$(echo "$Media_Cookie" | sed -n '10p')
    local refreshToken=$(echo $TokenContent | python -m json.tool 2>/dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
    local espncontent=$(echo $fakecontent | sed "s/ILOVESTAR/${refreshToken}/g")
    local tmpresult=$(curl -${1} --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://espn.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZXNwbiZicm93c2VyJjEuMC4w.ptUt7QxsteaRruuPmGZFaJByOoqKvDP2a5YkInHrc7c" -d "$espncontent" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r ESPN+:${Font_SkyBlue}[Sponsored by Jam]${Font_Suffix}\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local region=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'countryCode' | cut -f4 -d'"')
    local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')

    if [[ "$region" == "US" ]] && [[ "$inSupportedLocation" == "true" ]]; then
        echo -n -e "\r ESPN+:${Font_SkyBlue}[Sponsored by Jam]${Font_Suffix}\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r ESPN+:${Font_SkyBlue}[Sponsored by Jam]${Font_Suffix}\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Stan() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -X POST -sS --max-time 10 "https://api.stan.com.au/login/v1/sessions/web/account" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Stan:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep VPNDetected)
    if [ -z "$result" ]; then
        echo -n -e "\r Stan:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Stan:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_Binge() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://auth.streamotion.com.au" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Binge:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Docplay() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.docplay.com/subscribe" 2>&1 | grep 'geoblocked')
    if [[ "$result" == "curl"* ]]; then
        echo -n -e "\r Docplay:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        isKayoSportsOK=2
        return
    elif [ -n "$result" ]; then
        echo -n -e "\r Docplay:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        isKayoSportsOK=0
        return
    else
        echo -n -e "\r Docplay:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        isKayoSportsOK=1
        return
    fi

    echo -n -e "\r Docplay:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    isKayoSportsOK=2
    return

}

function MediaUnlockTest_OptusSports() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://sport.optus.com.au/api/userauth/validate/web/username/restriction.check@gmail.com" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Optus Sports:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_KayoSports() {
    if [[ "$isKayoSportsOK" = "2" ]]; then
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    elif [[ "$isKayoSportsOK" = "1" ]]; then
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$isKayoSportsOK" = "0" ]]; then
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Kayo Sports:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_NeonTV() {
    local NeonHeader=$(echo "$Media_Cookie" | sed -n '12p')
    local NeonContent=$(echo "$Media_Cookie" | sed -n '13p')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -X POST "https://api.neontv.co.nz/api/client/gql?" -H "content-type: application/json" -H "$NeonHeader" -d "$NeonContent" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Neon TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'RESTRICTED_GEOLOCATION')
    if [ -z "$result" ]; then
        echo -n -e "\r Neon TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Neon TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_SkyGONZ() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://login.sky.co.nz/authorize?audience=https%3A%2F%2Fapi.sky.co.nz&client_id=dXhXjmK9G90mOX3B02R1kV7gsC4bp8yx&redirect_uri=https%3A%2F%2Fwww.skygo.co.nz&connection=Sky-Internal-Connection&scope=openid%20profile%20email%20offline_access&response_type=code&response_mode=query&state=OXg3QjBGTHpoczVvdG1fRnJFZXVoNDlPc01vNzZjWjZsT3VES2VhN1dDWA%3D%3D&nonce=OEdvci4xZHBHU3VLb1M0T1JRbTZ6WDZJVGQ3R3J0TTdpTndvWjNMZDM5ZA%3D%3D&code_challenge=My5fiXIl-cX79KOUe1yDFzA6o2EOGpJeb6w1_qeNkpI&code_challenge_method=S256&auth0Client=eyJuYW1lIjoiYXV0aDAtcmVhY3QiLCJ2ZXJzaW9uIjoiMS4zLjAifQ%3D%3D" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SkyGo NZ:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_ThreeNow() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://bravo-livestream.fullscreen.nz/index.m3u8" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "200" ]; then
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r ThreeNow:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_MaoriTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://edge.api.brightcove.com/playback/v1/accounts/1614493167001/videos/6275380737001" -H "Accept: application/json;pk=BCpkADawqM2E9yW4lLgKIEIV5majz5djzZCIqJiYMkP5yYaYdF6AQYq4isPId1ZLtQdGnK1ErLYG0-r1N-3DzAEdbfvw9SFdDWz_i09pLp8Njx1ybslyIXid-X_Dx31b7-PLdQhJCws-vk6Y" -H "Origin: https://www.maoritelevision.com" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep error_subcode | cut -f4 -d'"')
    if [[ "$result" == "CLIENT_GEO" ]]; then
        echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$result" ] && [ -n "$tmpresult" ]; then
        echo -n -e "\r Maori TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Maori TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_SBSonDemand() {

    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://www.sbs.com.au/api/v3/network?context=odwebsite" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep country_code | cut -f4 -d'"')
    if [[ "$result" == "AU" ]]; then
        echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r SBS on Demand:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_ABCiView() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 "https://api.iview.abc.net.au/v2/show/abc-kids-live-stream/video/LS1604H001S00?embed=highlightVideo,selectedSeries" 2>&1)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r ABC iView:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'unavailable outside Australia')
    if [ -z "$result" ]; then
        echo -n -e "\r ABC iView:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r ABC iView:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_Channel9() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -Ss -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://login.nine.com.au" 2>&1 | grep 'geoblock')
    if [[ "$result" == "curl"* ]]; then
        echo -n -e "\r Channel 9:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ -n "$result" ]; then
        echo -n -e "\r Channel 9:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Channel 9:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Channel 9:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Telasa() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://api-videopass-anon.kddi-video.com/v1/playback/system_status" -H "X-Device-ID: d36f8e6b-e344-4f5e-9a55-90aeb3403799" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Telasa:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local isForbidden=$(echo $tmpresult | grep IPLocationNotAllowed)
    local isAllowed=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"type"' | cut -f4 -d'"')
    if [ -n "$isForbidden" ]; then
        echo -n -e "\r Telasa:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$isForbidden" ] && [[ "$isAllowed" == "OK" ]]; then
        echo -n -e "\r Telasa:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Telasa:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_SetantaSports() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://dce-frontoffice.imggaming.com/api/v2/consent-prompt" -H "Realm: dce.adjara" -H "x-api-key: 857a1e5d-e35e-4fdf-805b-a87b6f8364bf" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep outsideAllowedTerritories | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r Setanta Sports:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Setanta Sports:\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_MolaTV() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://mola.tv/api/v2/videos/geoguard/check/vd30491025" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Mola TV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Mola TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep isAllowed | awk '{print $2}')
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r Mola TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r Mola TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Mola TV:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_BeinConnect() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://proxies.bein-mena-production.eu-west-2.tuc.red/proxy/availableOffers" 2>&1)
    if [ "$result" = "000" ] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [ "$result" = "000" ]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "500" ]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ "$result" = "451" ]; then
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Bein Sports Connect:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_EurosportRO() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://eu3-prod-direct.eurosport.ro/playback/v2/videoPlaybackInfo/sourceSystemId/eurosport-vid1560178?usePreAuth=true" -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJVU0VSSUQ6ZXVyb3Nwb3J0OjlkMWU3MmYyLTdkYjItNDE2Yy1iNmIyLTAwZjQyMWRiN2M4NiIsImp0aSI6InRva2VuLTc0MDU0ZDE3LWFhNWUtNGI0ZS04MDM4LTM3NTE4YjBiMzE4OCIsImFub255bW91cyI6dHJ1ZSwiaWF0IjoxNjM0NjM0MzY0fQ.T7X_JOyvAr3-spU_6wh07re4W-fmbCxZdGaUSZiu1mw' 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep access.denied.geoblocked)
    if [ -n "$result" ]; then
        echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Eurosport RO:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_DiscoveryPlusUK() {
    local GetToken=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://disco-api.discoveryplus.co.uk/token?realm=questuk&deviceId=61ee588b07c4df08c02861ecc1366a592c4ad02d08e8228ecfee67501d98bf47&shortlived=true" 2>&1)
    if [[ "$GetToken" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Discovery+ UK:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$GetToken" == "curl"* ]]; then
        echo -n -e "\r Discovery+ UK:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local Token=$(echo $GetToken | python -m json.tool 2>/dev/null | grep '"token":' | cut -f4 -d'"')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS "https://disco-api.discoveryplus.co.uk/users/me" -b "st=${Token}" 2>&1)
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep currentLocationTerritory | cut -f4 -d'"')
    if [[ "$result" == "gb" ]]; then
        echo -n -e "\r Discovery+ UK:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Discovery+ UK:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Discovery+ UK:\t\t\t\t${Font_Red}Failed ${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Channel5() {
    local Timestamp=$(date +%s)
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sL --max-time 10 "https://cassie.channel5.com/api/v2/live_media/my5desktopng/C5.json?timestamp=${Timestamp}&auth=0_rZDiY0hp_TNcDyk2uD-Kl40HqDbXs7hOawxyqPnbI" 2>&1)
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep code | cut -f4 -d'"')
    if [ -z "$result" ] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Channel 5:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
    elif [[ "$result" == "4003" ]]; then
        echo -n -e "\r Channel 5:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [ -n "$result" ] && [[ "$result" != "4003" ]]; then
        echo -n -e "\r Channel 5:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Channel 5:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_MyVideo() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.myvideo.net.tw/login.do" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r MyVideo:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r MyVideo:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result=$(echo $tmpresult | grep 'serviceAreaBlock')
    if [ -n "$result" ]; then
        echo -n -e "\r MyVideo:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r MyVideo:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r MyVideo:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_7plus() {
    local result1=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://7plus-sevennetwork.akamaized.net/media/v1/dash/live/cenc/5303576322001/68dca38b-85d7-4dae-b1c5-c88acc58d51c/f4ea4711-514e-4cad-824f-e0c87db0a614/225ec0a0-ef18-4b7c-8fd6-8dcdd16cf03a/1x/segment0.m4f?akamai_token=exp=1672500385~acl=/media/v1/dash/live/cenc/5303576322001/68dca38b-85d7-4dae-b1c5-c88acc58d51c/f4ea4711-514e-4cad-824f-e0c87db0a614/*~hmac=800e1e1d1943addf12b71339277c637c7211582fe12d148e486ae40d6549dbde" 2>&1)
    if [[ "$GetPlayURL" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r 7plus:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$GetPlayURL" == "curl"* ]]; then
        echo -n -e "\r 7plus:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "200" ]]; then
        echo -n -e "\r 7plus:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r 7plus:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_Channel10() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sL --max-time 10 "https://e410fasadvz.global.ssl.fastly.net/geo" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Channel 10:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Channel 10:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'allow' | awk '{print $2}' | cut -f1 -d",")
    if [[ "$result" == "false" ]]; then
        echo -n -e "\r Channel 10:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [[ "$result" == "true" ]]; then
        echo -n -e "\r Channel 10:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Channel 10:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    return

}

function MediaUnlockTest_Funimation() {
    if [ "$is_busybox" == 1 ]; then
        tmp_file=$(mktemp)
    else
        tmp_file=$(mktemp --suffix=RRC)
    fi

    curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -ILs --max-time 10 --insecure "https://www.funimation.com" >${tmp_file}
    result=$(cat ${tmp_file} | awk 'NR==1' | awk '{print $2}')
    isHasRegion=$(cat ${tmp_file} | grep 'region=')
    if [[ "$1" == "6" ]]; then
        echo -n -e "\r Funimation:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [ "$result" = "000" ]; then
        echo -n -e "\r Funimation:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Funimation:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$isHasRegion" ]; then
        local region=$(cat ${tmp_file} | grep region= | awk '{print $2}' | cut -f1 -d";" | cut -f2 -d"=")
        echo -n -e "\r Funimation:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r Funimation:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function MediaUnlockTest_Spotify() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://spclient.wg.spotify.com/signup/public/v1/account" -d "birth_day=11&birth_month=11&birth_year=2000&collect_personal_info=undefined&creation_flow=&creation_point=https%3A%2F%2Fwww.spotify.com%2Fhk-en%2F&displayname=Gay%20Lord&gender=male&iagree=1&key=a1e486e2729f46d6bb368d6b2bcda326&platform=www&referrer=&send-email=0&thirdpartyemail=0&identifier_token=AgE6YTvEzkReHNfJpO114514" -H "Accept-Language: en" 2>&1)
    local region=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"country":' | cut -f4 -d'"')
    local isLaunched=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep is_country_launched | cut -f1 -d',' | awk '{print $2}')
    local StatusCode=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep status | cut -f1 -d',' | awk '{print $2}')

    if [ "$tmpresult" = "000" ]; then
        echo -n -e "\r Spotify Registration:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ "$StatusCode" = "320" ] || [ "$StatusCode" = "120" ]; then
        echo -n -e "\r Spotify Registration:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ "$StatusCode" = "311" ] && [ "$isLaunched" = "true" ]; then
        echo -n -e "\r Spotify Registration:\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_VideoMarket() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://www.videomarket.jp/graphql' --user-agent "${UA_Browser}" -H 'authority: www.videomarket.jp' -H 'accept: */*' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' -H 'authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ4MTkxNTkyMDIsImlhdCI6MTY2NTU1OTIwMiwiaXNzIjoiaHR0cHM6Ly9hdXRoLnZpZGVvbWFya2V0LmpwIiwic3ViIjoiY2ZjZDIwODQ5NWQ1NjVlZjY2ZTdkZmY5Zjk4NzY0ZGEiLCJ1c2VyX3R5cGUiOjAsInNpdGVfdHlwZSI6MiwiY2xpZW50X2lkIjoiYmVkNDdkOTFiMDVhYjgzMGM4YzBhYmFiYjQwNTg5MTFhY2E5NTdkMDBkMTUzNjA2MjI3NzNhOTQ0Y2RlNzRhNSIsInZtaWQiOjB9.Tq18RCxpVz1oV1lja52uRmF0nT6Oa0QsZMTVlPfANwb-RrcSn7PwE9vh7GdNIBc0ydDxRoUMuhStz_Kbu8KxvAh25eafFh7hf0DDqWKKU4ayPMueaR12t74SjFIRC7Cla1NR4uRn3_mgJfZFqOkIf6L5OR9LOVIBhrQPkhbMyqwZyh_kxTH7ToJIQoINb036ftqcF1KfR8ndtBlkrrWWnDpfkmE7-fJQHh92oKKd9l98W5awuEQo0MFspIdSNgt3gLi9t1RRKPDISGlzJkwMLPkHIUlWWZaAmnEkwSeZCPj_WJaqUqBATYKhi3yJZNGlHsScQ_KgAopxlsI6-c88Gps8i6yHvPVYw3hQ9XYq9gVL_SpyW9dKKSPE9MY6I19JHLBXuFXi5OJccqtQzTnKm_ZQM3EcKt5s0cNlXm9RMt0fNdRTQdJ53noD9o-b6hUIxDcHScJ_-30Emiv-55g5Sq9t5KPWO6o0Ggokkj42zin69MxCiUSHXk5FgeY8rX76yGBeLPLPIaaRPXEC1Jeo1VO56xNnQpyX_WHqHWDKhmOh1qSzaxiAiC5POMsTfwGr19TwXHUldYXxuNMIfeAaPZmNTzR5J6XdenFkLnrssVzXdThdlqHpfguLFvHnXTCAm0ZhFIJmacMNw1IxGmCQfkM4HtgKB9ZnWm6P0jIISdg' -H 'content-type: application/json' -H 'cookie: _gid=GA1.2.1853799793.1706147718; VM_REGIST_BANNER_REF_LINK=%2Ftitle%2F292072; __ulfpc=202401250957239984; _im_vid=01HMZ5C5GNNC6VWSPKD3E4W7YP; __td_signed=true; _td_global=0d11678b-5151-473e-b3a8-4f4d780f26a6; __juicer_sesid_9i3nsdfP_=d36a2e17-0117-47ce-95de-fbd5ffcda2d9; __juicer_session_referrer_9i3nsdfP_=d36a2e17-0117-47ce-95de-fbd5ffcda2d9___https%253A%252F%252Fwww.videomarket.jp%252Fplayer%252F292072%252FA292072001999H01; _gat_UA-221872486-2=1; _ga=GA1.2.777206008.1706147718; _ga_8HZQ9F8HV0=GS1.1.1706147717.1.1.1706147941.0.0.0; _td=3317738c-2329-4b61-ad5a-4e0ad230841d; dc_cl_id=ab38GzrmoV7muvtI' -H 'origin: https://www.videomarket.jp' -H 'referer: https://www.videomarket.jp/player/292072/A292072001999H01' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-origin' -H 'x-videomarket-requested: spa' --data-raw $'{"operationName":"repPacks","variables":{"repFullPackIds":["A292072001999H01"],"isOnSale":false,"isOnlyLatest":true},"query":"query repPacks($repFullPackIds: [String], $fullPacksIds: [String], $isOnSale: Boolean\u0021, $isOnlyLatest: Boolean\u0021) {\\n  repPacks(\\n    repFullPackIds: $repFullPackIds\\n    fullPackIds: $fullPacksIds\\n    onSale: $isOnSale\\n    onlyLatest: $isOnlyLatest\\n  ) {\\n    repFullPackId\\n    groupType\\n    packName\\n    fullTitleId\\n    titleName\\n    storyImageUrl16x9\\n    playTime\\n    subtitleDubType\\n    outlines\\n    courseIds\\n    price\\n    discountRate\\n    couponPrice\\n    couponDiscountRate\\n    rentalDays\\n    viewDays\\n    deliveryExpiredAt\\n    salesType\\n    counter {\\n      currentPage\\n      currentResult\\n      totalPages\\n      totalResults\\n      __typename\\n    }\\n    undiscountedPrice\\n    packs {\\n      undiscountedPrice\\n      canPurchase\\n      fullPackId\\n      subGroupType\\n      fullTitleId\\n      qualityConsentType\\n      courseIds\\n      price\\n      discountRate\\n      couponPrice\\n      couponDiscountRate\\n      rentalDays\\n      viewDays\\n      deliveryExpiredAt\\n      salesType\\n      extId\\n      stories {\\n        fullStoryId\\n        subtitleDubType\\n        encodeVersion\\n        isDownloadable\\n        isBonusMaterial\\n        fileSize\\n        __typename\\n      }\\n      __typename\\n    }\\n    status {\\n      hasBeenPlayed\\n      isCourseRegistered\\n      isEstPurchased\\n      isNowPlaying\\n      isPlayable\\n      isRented\\n      playExpiredAt\\n      playableQualityType\\n      rentalExpiredAt\\n      __typename\\n    }\\n    __typename\\n  }\\n}\\n"}')
    local isBlocked=$(echo $tmpresult | grep 'OverseasAccess')
    local isOK=$(echo $tmpresult | grep '292072')
    if [ -n "$isBlocked" ]; then
        echo -n -e "\r VideoMarket:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [ -n "$isOK" ]; then
        echo -n -e "\r VideoMarket:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r VideoMarket:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function MediaUnlockTest_J:COM_ON_DEMAND() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://id.zaq.ne.jp" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r J:com On Demand:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "502" ]; then
        echo -n -e "\r J:com On Demand:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [ "$result" = "403" ]; then
        echo -n -e "\r J:com On Demand:\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r J:com On Demand:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_music.jp() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -sL --max-time 10 "https://overseaauth.music-book.jp/globalIpcheck.js" 2>&1)
    if [ -n "$result" ]; then
        echo -n -e "\r music.jp:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r music.jp:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Instagram.Music() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://www.instagram.com/api/graphql'   -H 'Accept: */*'   -H 'Accept-Language: zh-CN,zh;q=0.9'   -H 'Connection: keep-alive'   -H 'Content-Type: application/x-www-form-urlencoded'   -H 'Cookie: csrftoken=mmCtHhtfZRG-K3WgoYMemg; dpr=1.75; _js_ig_did=809EA442-22F7-4844-9470-ABC2AC4DE7AE; _js_datr=rb21ZbL7KR_5DN8m_43oEtgn; mid=ZbW9rgALAAECR590Ukv8bAlT8YQX; ig_did=809EA442-22F7-4844-9470-ABC2AC4DE7AE; ig_nrcb=1'   -H 'Origin: https://www.instagram.com'   -H 'Referer: https://www.instagram.com/p/C2YEAdOh9AB/'   -H 'Sec-Fetch-Dest: empty'   -H 'Sec-Fetch-Mode: cors'   -H 'Sec-Fetch-Site: same-origin'   -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'   -H 'X-ASBD-ID: 129477'   -H 'X-CSRFToken: mmCtHhtfZRG-K3WgoYMemg'   -H 'X-FB-Friendly-Name: PolarisPostActionLoadPostQueryQuery'   -H 'X-FB-LSD: AVrkL73GMdk'   -H 'X-IG-App-ID: 936619743392459'   -H 'dpr: 1.75'   -H 'sec-ch-prefers-color-scheme: light'   -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"'   -H 'sec-ch-ua-full-version-list: "Not_A Brand";v="8.0.0.0", "Chromium";v="120.0.6099.225", "Google Chrome";v="120.0.6099.225"'   -H 'sec-ch-ua-mobile: ?0'   -H 'sec-ch-ua-model: ""'   -H 'sec-ch-ua-platform: "Windows"'   -H 'sec-ch-ua-platform-version: "10.0.0"'   -H 'viewport-width: 1640'   --data-raw 'av=0&__d=www&__user=0&__a=1&__req=3&__hs=19750.HYP%3Ainstagram_web_pkg.2.1..0.0&dpr=1&__ccg=UNKNOWN&__rev=1011068636&__s=drshru%3Agu4p3s%3A0d8tzk&__hsi=7328972521009111950&__dyn=7xeUjG1mxu1syUbFp60DU98nwgU29zEdEc8co2qwJw5ux609vCwjE1xoswIwuo2awlU-cw5Mx62G3i1ywOwv89k2C1Fwc60AEC7U2czXwae4UaEW2G1NwwwNwKwHw8Xxm16wUwtEvw4JwJCwLyES1Twoob82ZwrUdUbGwmk1xwmo6O1FwlE6PhA6bxy4UjK5V8&__csr=gtneJ9lGF4HlRX-VHjmipBDGAhGuWV4uEyXyp22u6pU-mcx3BCGjHS-yabGq4rhoWBAAAKamtnBy8PJeUgUymlVF48AGGWxCiUC4E9HG78og01bZqx106Ag0clE0kVwdy0Nx4w2TU0iGDgChwmUrw2wVFQ9Bg3fw4uxfo2ow0asW&__comet_req=7&lsd=AVrkL73GMdk&jazoest=2909&__spin_r=1011068636&__spin_b=trunk&__spin_t=1706409389&fb_api_caller_class=RelayModern&fb_api_req_friendly_name=PolarisPostActionLoadPostQueryQuery&variables=%7B%22shortcode%22%3A%22C2YEAdOh9AB%22%2C%22fetch_comment_count%22%3A40%2C%22fetch_related_profile_media_count%22%3A3%2C%22parent_comment_count%22%3A24%2C%22child_comment_count%22%3A3%2C%22fetch_like_count%22%3A10%2C%22fetch_tagged_user_count%22%3Anull%2C%22fetch_preview_comment_count%22%3A2%2C%22has_threaded_comments%22%3Atrue%2C%22hoisted_comment_id%22%3Anull%2C%22hoisted_reply_id%22%3Anull%7D&server_timestamps=true&doc_id=10015901848480474' | grep -oP '"should_mute_audio":\K(false|true)')
    echo -n -e " Instagram Licensed Audio:\t\t->\c"
    if [[ "$result" == "false" ]]; then
        echo -n -e "\r Instagram Licensed Audio:\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [[ "$result" == "true" ]]; then
        echo -n -e "\r Instagram Licensed Audio:\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Instagram Licensed Audio:\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi

}

function RedditUnlockTest() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.reddit.com/" 2>&1)
    case "$result" in
        "000") echo -n -e "\r Reddit:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" ;;
        "403") echo -n -e "\r Reddit:\t\t\t\t${Font_Red}No${Font_Suffix}\n" ;;
        "200") echo -n -e "\r Reddit:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" ;;
        *) echo -n -e "\r Reddit:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" ;;
    esac
}

function MediaUnlockTest_Popcornflix(){
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 "https://popcornflix-prod.cloud.seachange.com/cms/popcornflix/clientconfiguration/versions/2" 2>&1)
    if [ "$result" = "000" ] && [ "$1" == "6" ]; then
        echo -n -e "\r Popcornflix:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
    elif [ "$result" = "000" ] && [ "$1" == "4" ]; then
        echo -n -e "\r Popcornflix:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "403" ]; then
        echo -n -e "\r Popcornflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [ "$result" = "200" ]; then
        echo -n -e "\r Popcornflix:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Popcornflix:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_TubiTV(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --user-agent "${UA_Browser}" --max-time 10 "https://tubitv.com/home" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Tubi TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep '302 Found')
    if [ -n "$result" ]; then
        echo -n -e "\r Tubi TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Tubi TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Philo(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsSL --user-agent "${UA_Browser}" --max-time 10 "https://content-us-east-2-fastly-b.www.philo.com/geo" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Philo:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Philo:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"status":' | cut -f1 -d',' | awk '{print $2}' | sed 's/"//g')
    if [[ "$result" == 'FAIL' ]]; then
        echo -n -e "\r Philo:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [[ "$result" == 'SUCCESS' ]]; then
        echo -n -e "\r Philo:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Philo:\t\t\t\t\t${Font_Green}Failed${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_FXNOW(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsSL --user-agent "${UA_Browser}" --max-time 10 "https://fxnow.fxnetworks.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r FXNOW:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r FXNOW:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'is not accessible')
    if [ -n "$result" ]; then
        echo -n -e "\r FXNOW:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r FXNOW:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Crunchyroll(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsSL --user-agent "${UA_Browser}" --max-time 10 "https://c.evidon.com/geo/country.js" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Crunchyroll:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Crunchyroll:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep "'code':'us'")
    if [ -z "$result" ]; then
        echo -n -e "\r Crunchyroll:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Crunchyroll:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}


function MediaUnlockTest_CWTV(){
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 --retry 3 "https://www.cwtv.com/" 2>&1)
    if [ "$result" = "000" ]; then
        echo -n -e "\r CW TV:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "403" ]; then
        echo -n -e "\r CW TV:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [ "$result" = "200" ]; then
        echo -n -e "\r CW TV:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r CW TV:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Shudder(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --user-agent "${UA_Browser}" --max-time 10 "https://www.shudder.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Shudder:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'not available')
    if [ -n "$result" ]; then
        echo -n -e "\r Shudder:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Shudder:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_TLCGO(){
    onetrustresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --user-agent "${UA_Browser}" --max-time 10 "https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location/dnsfeed" 2>&1)
    if [ "$1" == "6" ]; then
        echo -n -e "\r TLC GO:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$onetrustresult" == "curl"* ]]; then
        echo -n -e "\r TLC GO:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ -z "$onetrustresult" ]; then
        echo -n -e "\r TLC GO:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
    local result=$(echo $onetrustresult | grep '"country":"US"')
    if [ -z "$result" ]; then
        echo -n -e "\r TLC GO:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r TLC GO:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Wavve() {
    local result1=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://apis.wavve.com/fz/streaming?device=pc&partner=pooq&apikey=E5F3E0D30947AA5440556471321BB6D9&credential=none&service=wavve&pooqzone=none&region=kor&drm=pr&targetage=all&contentid=MV_C3001_C300000012559&contenttype=movie&hdr=sdr&videocodec=avc&audiocodec=ac3&issurround=n&format=normal&withinsubtitle=n&action=dash&protocol=dash&quality=auto&deviceModelId=Windows%2010&guid=1a8e9c88-6a3b-11ed-8584-eed06ef80652&lastplayid=none&authtype=cookie&isabr=y&ishevc=n" 2>&1)
    if [[ "$result1" == "000" ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Wavve:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result1" == "000" ]]; then
        echo -n -e "\r Wavve:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "200" ]]; then
        echo -n -e "\r Wavve:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Wavve:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Tving() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fSsL --max-time 10 "https://api.tving.com/v2a/media/stream/info?apiKey=1e7952d0917d6aab1f0293a063697610&mediaCode=RV60891248" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Tving:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Tving:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result1=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 'play')
    if [ -z "$result1" ]; then
        echo -n -e "\r Tving:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Tving:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_CoupangPlay() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.coupangplay.com/" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Coupang Play:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Coupang Play:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmpresult" | grep 'not-available' )
    if [ -n "$result" ]; then
        echo -n -e "\r Coupang Play:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Coupang Play:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_NaverTV() {
    local ts=$(date +%s%3N)
    local base_url="https://apis.naver.com/"
    local key="nbxvs5nwNG9QKEWK0ADjYA4JZoujF4gHcIwvoCxFTPAeamq5eemvt5IWAYXxrbYM"
    local sign_text="https://apis.naver.com/now_web2/now_web_api/v1/clips/31030608/play-info${ts}"
    local signature=$(printf "%s" "${sign_text}" | openssl dgst -sha1 -hmac "${key}" -binary | openssl base64)
    local signature_encoded=$(printf "%s" "${signature}" | sed 's/ /%20/g;s/!/%21/g;s/"/%22/g;s/#/%23/g;s/\$/%24/g;s/\&/%26/g;s/'\''/%27/g;s/(/%28/g;s/)/%29/g;s/\*/%2a/g;s/+/%2b/g;s/,/%2c/g;s/\//%2f/g;s/:/%3a/g;s/;/%3b/g;s/=/%3d/g;s/?/%3f/g;s/@/%40/g;s/\[/%5b/g;s/\]/%5d/g')
    local req_url="${base_url}now_web2/now_web_api/v1/clips/31030608/play-info?msgpad=${ts}&md=${signature_encoded}"
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} -s --max-time 10 "${req_url}" --user-agent "${UA_Browser}" -H 'host: apis.naver.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'accept: application/json, text/plain, */*' -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'origin: https://tv.naver.com' -H 'sec-fetch-site: same-site' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://tv.naver.com/v/31030608' -H 'accept-language: en,zh-CN;q=0.9,zh;q=0.8')
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Naver TV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Naver TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local playable=$(echo "$tmpresult" | python -m json.tool 2>/dev/null | grep -o '"playable": *"[^"]*"' | cut -d'"' -f4)

    if [[ "$playable" == "NOT_COUNTRY_AVAILABLE" ]]; then
        echo -n -e "\r Naver TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r Naver TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
    # local result=$(echo "$tmpresult" | python -m json.tool 2>/dev/null | grep ctry | cut -f4 -d'"')
    # if [[ "$result" == "KR" ]]; then
    #     echo -n -e "\r Naver TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    # else
    #     echo -n -e "\r Naver TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    # fi
}

function MediaUnlockTest_Afreeca() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fSsL --max-time 10 "https://vod.afreecatv.com/player/97464151" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r Afreeca TV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Afreeca TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result1=$(echo "$tmpresult" | grep "document.location.href='https://vod.afreecatv.com'" )
    if [ -z "$result1" ]; then
        echo -n -e "\r Afreeca TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Afreeca TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_KBSDomestic() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fSsL --max-time 10 "https://vod.kbs.co.kr/index.html?source=episode&sname=vod&stype=vod&program_code=T2022-0690&program_id=PS-2022164275-01-000&broadcast_complete_yn=N&local_station_code=00&section_code=03 " 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r KBS Domestic:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r KBS Domestic:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result1=$(echo "$tmpresult" | grep "ipck" | grep 'Domestic\\\":true' )
    if [ -z "$result1" ]; then
        echo -n -e "\r KBS Domestic:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r KBS Domestic:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Watcha() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 10 'https://watcha.com/' --user-agent "${UA_Browser}" -H 'host: watcha.com' -H 'connection: keep-alive' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'upgrade-insecure-requests: 1' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6')
    if [ "$result" = "000" ]; then
        echo -n -e "\r WATCHA:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
    elif [ "$result" = "200" ]; then
        echo -n -e "\r WATCHA:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [ "$result" = "451" ]; then
        echo -n -e "\r WATCHA:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r WATCHA:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_KBSAmerican() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fSsL --max-time 10 "https://vod.kbs.co.kr/index.html?source=episode&sname=vod&stype=vod&program_code=T2022-0690&program_id=PS-2022164275-01-000&broadcast_complete_yn=N&local_station_code=00&section_code=03 " 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r KBS American:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r KBS American:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result1=$(echo "$tmpresult" | grep "ipck" | grep 'American\\\":true' )
    if [ -z "$result1" ]; then
        echo -n -e "\r KBS American:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r KBS American:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_KOCOWA() {
    local result1=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.kocowa.com/" 2>&1)
    if [[ "$result1" == "000" ]] && [ "$1" == "6" ]; then
        echo -n -e "\r KOCOWA:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result1" == "000" ]]; then
        echo -n -e "\r KOCOWA:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "200" ]]; then
        echo -n -e "\r KOCOWA:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r KOCOWA:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_NBCTV(){
    if [[ "$onetrustresult" == "curl"* ]]; then
        echo -n -e "\r NBC TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ -z "$onetrustresult" ]; then
        echo -n -e "\r NBC TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
    local result=$(echo $onetrustresult | grep '"country":"US"')
    if [ -z "$result" ]; then
        echo -n -e "\r NBC TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r NBC TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Crackle(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -I --user-agent "${UA_Browser}" --max-time 10 "https://prod-api.crackle.com/appconfig" 2>&1 | grep -E 'x-crackle-region:|curl')
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Crackle:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    elif [ -z "$tmpresult" ]; then
        echo -n -e "\r Crackle:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | awk '{print $2}' | sed 's/[[:space:]]//g')
    if [[ "$result" == "US" ]]; then
        echo -n -e "\r Crackle:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r Crackle:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_AETV(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS -X POST --user-agent "${UA_Browser}" --max-time 10 "https://ccpa-service.sp-prod.net/ccpa/consent/10265/display-dns" 2>&1)
    if [[ "$tmpresult" == "curl"* ]] && [ "$1" == "6" ]; then
        echo -n -e "\r A&E TV:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r A&E TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep '"ccpaApplies":' | cut -f1 -d',' | awk '{print $2}')
    if [[ "$result" == "true" ]]; then
        echo -n -e "\r A&E TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [[ "$result" == "false" ]]; then
        echo -n -e "\r A&E TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r A&E TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_NFLPlus() {
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -fsL -w "%{http_code}\n%{url_effective}\n" -o dev/null "https://www.nfl.com/plus/" 2>&1)
    if [[ "$tmpresult" == "000"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r NFL+:\t\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult" == "000"* ]]; then
        echo -n -e "\r NFL+:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo $tmpresult | grep 'nflgamepass')
    if [ -n "$result" ]; then
        echo -n -e "\r NFL+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r NFL+:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_SkyShowTime(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -fSsi --max-time 10 "https://www.skyshowtime.com/" -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' 2>&1)
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r SkyShowTime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local result1=$(echo "$tmpresult" | grep 'location' | head -1 | awk '{print $2}' )
    if [[ "$result1" == *"where-can-i-stream"* ]]; then
        echo -n -e "\r SkyShowTime:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        local region1=$(echo -n "$result1" | sed 's#https://www.skyshowtime.com/\([0-9a-zA-Z][0-9a-zA-Z]\)?\r#\1#i' | tr [:lower:] [:upper:] )
        echo -n -e "\r SkyShowTime:\t\t\t\t${Font_Green}Yes (Region: ${region1})${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_MathsSpot() {
    local tmpresult1=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -sS --max-time 10 "https://netv2.now.gg/v3/playtoken" 2>&1)
    if [[ "$tmpresult1" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$tmpresult1" == "curl"* ]]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local blocked=$(echo "$tmpresult1" | grep 'Request blocked')
    if [ -n "$blocked" ]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}No (Proxy/VPN Detected)${Font_Suffix}\n"
        return
    fi
    local playtoken=$(echo "$tmpresult1" | python -m json.tool 2>/dev/null | grep '"playToken":' | awk '{print $2}' | cut -f2 -d'"')
    local region=$(echo "$tmpresult1" | python -m json.tool 2>/dev/null | grep '"countryCode":' | awk '{print $2}' | cut -f2 -d'"')
    local host=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -sS --max-time 10 "https://mathsspot.com/2/api/play/v1/startSession?uaId=ua-KzV6fgcCBHQDU9DHCt2uG&uaSessionId=uasess-IdEux1e80EUstUlnnnHG0&appId=5349&initialOrientation=landscape&utmSource=NA&utmMedium=NA&utmCampaign=NA&deviceType=&playToken=${playtoken}&deepLinkUrl=&accessCode=" 2>&1)
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} --user-agent "${UA_Browser}" -sS --max-time 10 "https://mathsspot.com/2/api/play/v1/startSession?uaId=ua-KzV6fgcCBHQDU9DHCt2uG&uaSessionId=uasess-IdEux1e80EUstUlnnnHG0&appId=5349&initialOrientation=landscape&utmSource=NA&utmMedium=NA&utmCampaign=NA&deviceType=&playToken=${playtoken}&deepLinkUrl=&accessCode=" -H "x-ngg-fe-version: ${host}" 2>&1)
    if [[ "$host" == "curl"* ]] || [[ "$tmpresult2" == "curl"* ]]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmpresult2" | python -m json.tool 2>/dev/null | grep '"status":' | awk '{print $2}' | cut -f2 -d'"')
    if [[ "$result" == "FailureServiceNotInRegion" ]]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    elif [[ "$result" == "Success" ]]; then
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n"
    else
        echo -n -e "\r Maths Spot:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi
}

function MediaUnblockTest_BGlobalSEA() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=347666" 2>&1)
    local result1="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
    if [[ "$result" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r B-Global SouthEastAsia:\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result" == "curl"* ]]; then
        echo -n -e "\r B-Global SouthEastAsia:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "0" ]]; then
        echo -n -e "\r B-Global SouthEastAsia:\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r B-Global SouthEastAsia:\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r B-Global SouthEastAsia:\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function MediaUnblockTest_BGlobalTH() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=10077726" 2>&1)
    local result1="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
    if [[ "$result" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r B-Global Thailand Only:\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result" == "curl"* ]]; then
        echo -n -e "\r B-Global Thailand Only:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "0" ]]; then
        echo -n -e "\r B-Global Thailand Only:\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r B-Global Thailand Only:\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r B-Global Thailand Only:\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function MediaUnblockTest_BGlobalID() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=11130043" 2>&1)
    local result1="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
    if [[ "$result" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r B-Global Indonesia Only:\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result" == "curl"* ]]; then
        echo -n -e "\r B-Global Indonesia Only:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "0" ]]; then
        echo -n -e "\r B-Global Indonesia Only:\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r B-Global Indonesia Only:\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r B-Global Indonesia Only:\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function MediaUnblockTest_BGlobalVN() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} --user-agent "${UA_Browser}" -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=11405745" 2>&1)
    local result1="$(echo "${result}" | python -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
    if [[ "$result" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r B-Global Việt Nam Only:\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result" == "curl"* ]]; then
        echo -n -e "\r B-Global Việt Nam Only:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$result1" == "0" ]]; then
        echo -n -e "\r B-Global Việt Nam Only:\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r B-Global Việt Nam Only:\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r B-Global Việt Nam Only:\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function MediaUnlockTest_AISPlay() {
    local result=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sSLI --max-time 10 "https://49-231-37-237-rewriter.ais-vidnt.com/ais/play/origin/VOD/playlist/ais-yMzNH1-bGUxc/index.m3u8" 2>&1)
    if [[ "$result" == "curl"* ]] && [[ "$1" == "6" ]]; then
        echo -n -e "\r AIS Play:\t\t\t\t${Font_Red}IPv6 Not Support${Font_Suffix}\n"
        return
    elif [[ "$result" == "curl"* ]]; then
        echo -n -e "\r AIS Play:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result1="$(echo "${result}" | grep 'X-Geo-Protection-System-Status' | awk '{print $2}' )"
    if [[ "$result1" == *"ALLOW"* ]]; then
        echo -n -e "\r AIS Play:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result1" == *"BLOCK"* ]]; then
        echo -n -e "\r AIS Play:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r AIS Play:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
}

function OpenAITest(){
    local tmpresult1=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 'https://api.openai.com/compliance/cookie_requirements' --user-agent "${UA_Browser}" -H 'authority: api.openai.com' -H 'accept: */*' -H 'accept-language: zh-CN,zh;q=0.9' -H 'authorization: Bearer null' -H 'content-type: application/json' -H 'origin: https://platform.openai.com' -H 'referer: https://platform.openai.com/' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' 2>&1)
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sS --max-time 10 'https://ios.chat.openai.com/' -H 'authority: ios.chat.openai.com' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'accept-language: zh-CN,zh;q=0.9' -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: none' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1' 2>&1)
    local result1=$(echo $tmpresult1 | grep unsupported_country)
    local result2=$(echo $tmpresult2 | grep VPN)
    if [ -z "$result2" ] && [ -z "$result1" ] && [[ "$tmpresult1" != "curl"* ]] && [[ "$tmpresult2" != "curl"* ]]; then
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ -n "$result2" ] && [ -n "$result1" ]; then
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$result1" ] && [ -n "$result2" ] && [[ "$tmpresult1" != "curl"* ]]; then
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Yellow}Only Available with Web Browser${Font_Suffix}\n"
        return
    elif [ -n "$result1" ] && [ -z "$result2" ]; then
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Yellow}Only Available with Mobile APP${Font_Suffix}\n"
        return
    elif [[ "$tmpresult1" == "curl"* ]] && [ -n "$result2" ]; then
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r ChatGPT:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return

    fi
}

function Bing_Region(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://www.bing.com/search?q=curl")
    local isCN=$(echo $tmpresult | grep 'cn.bing.com')
    local Region=$(echo $tmpresult | sed -n 's/.*Region:"\([^"]*\)".*/\1/p')
    if [ -n "$isCN" ]; then
        echo -n -e "\r Bing Region:\t\t\t\t${Font_Yellow}CN${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Bing Region:\t\t\t\t${Font_Green}${Region}${Font_Suffix}\n"
        return
    fi
}

function Wikipedia_Editable(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://zh.wikipedia.org/w/index.php?title=Wikipedia%3A%E6%B2%99%E7%9B%92&action=edit")
    local result=$(echo $tmpresult | grep Banned)
    if [ -z "$result" ]; then
        echo -n -e "\r Wikipedia Editability:\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Wikipedia Editability:\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_K_PLUS(){
    local token=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 -H "Origin: https://xem.kplus.vn" -H "Referer: https://xem.kplus.vn/" -X POST -d '{"osVersion":"Windows NT 10.0","appVersion":"114.0.0.0","deviceModel":"Chrome","deviceType":"PC","deviceSerial":"w39db81c0-a2e9-11ed-952a-49b91c9e6f09","deviceOem":"Chrome","devicePrettyName":"Chrome","ssoToken":"eyJrZXkiOiJ2c3R2IiwiZW5jIjoiQTEyOENCQy1IUzI1NiIsImFsZyI6ImRpciJ9..MWbBlLuci2KNLl9lvMe63g.IbBX7-dg3BWaXzzoxTQz-pJFulm_Y8axWLuG5DcJxQ9jTUPOhA2e6dzOP2hryAFVPFoIRs97ONGTHEYTFQgUtRlvqvx53jyTi3yegU6zWhJnhYZA2sdaj9khsNvVAth0zcWFoWA9GGwfNE5TZLOwczAexIxqC1Ee-tQDILC4XklFrJfvdzoCQBABRXpD_O4HHHIYFs0jBMtYSyD9Vq7dTD61sAVca_83lav7jvpP17PuAo3HHIFQtUdcugpgkB91mJbABIDTPdo0mqdzbgTA_FilwO1Z5qnpwqIZIXy0bhVXFFcwUZPIUxjLEVzP3SyHceFF5N-v7OeYhYZRLYuBKxWj1cRb3LAa3FGJvefqRsBadlsr0cZnOgx0TsL51a2SaIpNyyGtaq8KTTLULIZBb2Zsq2jmBkZtxjoPxUR8ku7J4sL0tfLDoMlWVZkrX4_1tls3E-l8Ael-wd0kbS1i2vpf-Vdh80lRClpDg3ibSSUFPsp3wYMFsuKfyY8vpHrCfYDJDDbYOSv20sfnU7q7gcmizTCFBuiszmXbFX9_aH8UOaCGeqkYDV1ZZ3mQ26TM7JEquuZTV09wdi81ABoM8RZcb2ua0cuocaO4-asMh8KQWNea9BCYlKK5NSPz--oGgGxSdvxZ63qQz1Lr4QZytA2buoQV5OlMoEP7k87fPcig5rPqsK7aeWUXJSmfiOBbSLztoiamvvHClMpds3frv0ud8NWUUoijmS_JUGfF7XYNxWWqEGJuDUoSllV5MVwtIb5wM069gR7zknrr5aRVDi3Nho16KHQ_iB3vxoIr-ExajWLNlvo44CopGhxhgOAKPkULV356uamZpB7twY_iEVrwGMQA1_hEH4usO-UbzuxL_pssLhJKD4NjVcTe86Z08Bfm0IyiNWESmFkA6FVfsxu57Yfd4bXT8mxnfXXmklb7u7vB0RVYRo4i26QGJbPknybHdfgQWEvRCMoAjEG-E2LymBAMwFneWEpPTwBMpfvlTHnGnUtfViA4Zy1xqF2q95g9AF9nF3sE4YpYuSFSkUQB4sZd8emDApIdP6Avqsq809Gg06_R2sUGrD9SQ-XbXhvtAYMcaUcSv54hJvRcSUkygqU8tdg4tJHR23UBb-I.UfpC5BKhvt8EE5gpIFMQoQ","brand":"vstv","environment":"p","language":"en_US","memberId":"0","featureLevel":4,"provisionData":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYyI6dHJ1ZSwiaWF0IjoxNjg2NTc4NzYyLCJ1cCI6ImNwaSIsImRlIjoiYnJhbmRNYXBwaW5nIiwiYnIiOiJ2c3R2IiwiZHMiOiJ3MzlkYjgxYzAtYTJlOS0xMWVkLTk1MmEtNDliOTFjOWU2ZjA5In0.3mbI7wnJKtRf3493yc_ZEMEvzUXldwDx0sSZdwQnlNk"}' "https://tvapi-sgn.solocoo.tv/v1/session" | python -m json.tool 2>/dev/null | grep '"token"' | awk '{print $2}' | cut -f2 -d'"')
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 -X POST -d '{"player":{"name":"RxPlayer","version":"3.29.0","capabilities":{"mediaTypes":["DASH","DASH"],"drmSystems":["PlayReady","Widevine"],"smartLib":true}}}' -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://tvapi-sgn.solocoo.tv/v1/assets/BJO0h8jMwJWg5Id_4VLxIJ-VscUzRry_myp4aC21/play")
    local result=$(echo $tmpresult | grep geoblock)
    if [ -n "$tmpresult" ] && [ -z "$result" ]; then
        echo -n -e "\r K+:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ -n "$result" ]; then
        echo -n -e "\r K+:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$tmpresult" ] && [[ "$1" == "6" ]]; then
        echo -n -e "\r K+:\t\t\t\t\t${Font_Red}IPv6 Not Supported${Font_Suffix}\n"
        return
    else
        echo -n -e "\r K+:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi

}

function MediaUnlockTest_TV360(){
    local tmpresult=$(curl -s $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 "http://api-v2.tv360.vn/public/v1/composite/get-link?childId=998335&device_type=WEB_IPHONE&id=19474&network_device_id=prIUMaumjI7dNWKSUxFkEViFygs%3D&t=1686572228&type=film" -H "User-Agent: TV360/31 CFNetwork/1402.0.8 Darwin/22.2.0" -H "userid: 182551343" -H "devicetype: WEB_IPHONE" -H "deviceName: iPad Air 5th Gen (WiFi)" -H "profileid: 182733455" -H "s: cSkV/vwUfX6tahDwe6xh9Bl0yhNs/TdWTaOJiWDt3gHekijGnNYh9i4YaUmdfBfI4oKOwvioKJ7PuKMH7ctWA6rEHeGXH/nUYOY1g7l4Umh6zoed5bBwWCgUuh5eMqdNNoptwaeCee58USTteOkbHQ==" -H "deviceid: 69FFABD6-F9D8-4C2E-8C44-7195CF0A2930" -H "devicedrmid: prIUMaumjI7dNWKSUxFkEViFygs=" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxODI1NTEzNDMiLCJ1c2VySWQiOjE4MjU1MTM0MywicHJvZmlsZUlkIjoxODI3MzM0NTUsImR2aSI6MjY5NDY3MTUzLCJjb250ZW50RmlsdGVyIjoiMTAwIiwiZ25hbWUiOiIiLCJpYXQiOjE2ODY1NzIyMDEsImV4cCI6MTY4NzE3NzAwMX0.oi0BKvATgBzPEkqR_liBrvMKXBUiWzp2BQme-biDnwiVhuta0qn_aZo6z3azLdjW5kH6PfEwEkc4K9jCfAK5rw" -H "osappversion: 1.9.27" -H "sessionid: C5017358-5327-4185-999A-CA3291CC66AC" -H "zoneid: 1" -H "Accept: application/json, text/html" -H "Content-Type: application/json" -H "osapptype: IPAD" -H "tv360transid: 1686572228_69FFABD6-F9D8-4C2E-8C44-7195CF0A2930")
    local result=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep errorCode | awk '{print $2}' |cut -f1 -d',')
    if [[ "$result" == "200" ]]; then
        echo -n -e "\r TV360:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [[ "$result" == "310" ]]; then
        echo -n -e "\r TV360:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$tmpresult" ] && [[ "$1" == "6" ]]; then
        echo -n -e "\r TV360:\t\t\t\t\t${Font_Red}IPv6 Not Supported${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_MeWatch(){
    local tmpresult=$(curl -s $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 https://cdn.mewatch.sg/api/items/97098/videos?delivery=stream%2Cprogressive&ff=idp%2Cldp%2Crpt%2Ccd&lang=en&resolution=External&segments=all)
    local checkfail=$(echo $tmpresult | python -m json.tool 2>/dev/null | grep 8002)
    if [ -n "$tmpresult" ] && [ -z "$checkfail" ]; then
        echo -n -e "\r MeWatch:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    elif [ -n "$checkfail" ]; then
        echo -n -e "\r MeWatch:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -z "$tmpresult" ] && [[ "$1" == "6" ]]; then
        echo -n -e "\r MeWatch:\t\t\t\t${Font_Red}IPv6 Not Supported${Font_Suffix}\n"
        return
    else
        echo -n -e "\r MeWatch:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_trueID(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sL --max-time 10 "https://tv.trueid.net/th-en/live/thairathtv-hd" --user-agent "${UA_Browser}" -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1')
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r trueID:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local channelId=$(echo $tmpresult | grep '"channelId"' | sed 's/.*channelId//' | cut -f3 -d'"' | head -n 1)
    local authUser=$(echo $tmpresult | grep '"buildId"' | sed 's/.*buildId//' | cut -f3 -d'"' | head -n 1)
    local authKey=${authUser:10}
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://tv.trueid.net/api/stream/checkedPlay?channelId=${channelId}&lang=en&country=th" --user-agent "${UA_Browser}" -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1' -u ${authUser}:${authKey} -H 'accept: application/json, text/plain, */*' -H 'referer: https://tv.trueid.net/th-en/live/thairathtv-hd')

    local result=$(echo $tmpresult2 | python -m json.tool 2>/dev/null | grep 'billboardType' | awk '{print $2}' | cut -f2 -d'"')
    case "$result" in
        "GEO_BLOCK") echo -n -e "\r trueID:\t\t\t\t${Font_Red}No${Font_Suffix}\n" ;;
        "LOADING") echo -n -e "\r trueID:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" ;;
        *) echo -n -e "\r trueID:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" ;;
    esac
}

function MediaUnlockTest_SonyLiv(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -sL --max-time 10 "https://www.sonyliv.com/" --user-agent "${UA_Browser}" -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: none' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1')
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r SonyLiv:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local isBlocked=$(echo $tmpresult | grep 'geolocation_notsupported')
    if [ -n "$isBlocked" ]; then
        echo -n -e "\r SonyLiv:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
    # 取得 JWT Token
    local jwtToken=$(echo $tmpresult | grep 'securityToken' | sed 's/.*securityToken//' | sed 's/.*resultObj//' | cut -f2 -d'"' | head -n 1)
    # 取得国家代码
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://apiv2.sonyliv.com/AGL/1.4/A/ENG/WEB/ALL/USER/ULD' --user-agent "${UA_Browser}" -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'accept: application/json, text/plain, */*' -H 'referer: https://www.sonyliv.com/' -H 'device_id: 25a417c3b5f246a393fadb022adc82d5-1715309762699' -H 'app_version: 3.5.59' -H "security_token: ${jwtToken}")
    local region=$(echo $tmpresult2 | python -m json.tool 2>/dev/null | grep '"country_code"' | awk '{print $2}' | cut -f2 -d'"')
    # 取得播放详情
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 "https://apiv2.sonyliv.com/AGL/3.8/A/ENG/WEB/${region}/ALL/CONTENT/VIDEOURL/VOD/1000273613/prefetch" --user-agent "${UA_Browser}" -H "sec-ch-ua: ${UA_SecCHUA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1' -H 'accept: application/json, text/plain, */*' -H 'origin: https://www.sonyliv.com' -H 'referer: https://www.sonyliv.com/' -H 'device_id: 25a417c3b5f246a393fadb022adc82d5-1715309762699' -H "security_token: ${jwtToken}")

    local result=$(echo $tmpresult2 | python -m json.tool 2>/dev/null | grep 'resultCode' | awk '{print $2}' | cut -f2 -d'"')
    case "$result" in
        "KO") echo -n -e "\r SonyLiv:\t\t\t\t${Font_Red}No${Font_Suffix}\n" ;;
        "OK") echo -n -e "\r SonyLiv:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n" ;;
        *) echo -n -e "\r SonyLiv:\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" ;;
    esac
}

function MediaUnlockTest_JioCinema(){
    local tmpresult1=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://apis-jiocinema.voot.com/location' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'   -H 'Cache-Control: no-cache'   -H 'Connection: keep-alive'   -H 'Origin: https://www.jiocinema.com'   -H 'Pragma: no-cache'   -H 'Referer: https://www.jiocinema.com/'   -H 'Sec-Fetch-Dest: empty'   -H 'Sec-Fetch-Mode: cors'   -H 'Sec-Fetch-Site: cross-site' -H "sec-ch-ua: ${UA_SecCHUA}"   -H 'sec-ch-ua-mobile: ?0'   -H 'sec-ch-ua-platform: "Windows"')
    local isBlocked1=$(echo $tmpresult1 | grep 'Access Denied')
    local isOK1=$(echo $tmpresult1 | grep 'Success')
    local tmpresult2=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s --max-time 10 'https://content-jiovoot.voot.com/psapi/voot/v1/voot-web//view/show/3500210?subNavId=38fa57ba_1706064514668&excludeTray=player-tray,subnav&responseType=common&devicePlatformType=desktop&page=1&layoutCohort=default&supportedChips=comingsoon'   -X 'OPTIONS'   -H 'Accept: */*'   -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'   -H 'Access-Control-Request-Headers: app-version'   -H 'Access-Control-Request-Method: GET'   -H 'Connection: keep-alive'   -H 'Origin: https://www.jiocinema.com'   -H 'Referer: https://www.jiocinema.com/'   -H 'Sec-Fetch-Dest: empty'   -H 'Sec-Fetch-Mode: cors'   -H 'Sec-Fetch-Site: cross-site'   -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0')
    local isBlocked2=$(echo $tmpresult2 | grep 'JioCinema is unavailable at your location')
    local isOK2=$(echo $tmpresult2 | grep 'Ok')
    if [ -n "$isBlocked1" ] || [ -n "$isBlocked2" ]; then
        echo -n -e "\r Jio Cinema:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$isOK1" ] && [ -n "$isOK2" ]; then
        echo -n -e "\r Jio Cinema:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Jio Cinema:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_MXPlayer(){
    local tmpresult1=$(curl -sLI $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 'https://www.mxplayer.in/')
    local tmpresult2=$(curl -s $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 'https://www.mxplayer.in/')
    local isOK=$(echo $tmpresult1 | grep 'set-cookie')
    local isBlocked1=$(echo $tmpresult2 | grep 'We are currently not available in your region')
    local isBlocked2=$(echo $tmpresult2 | grep '403 ERROR')
    if [ -n "$isBlocked1" ] || [ -n "$isBlocked2" ]; then
        echo -n -e "\r MX Player:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    elif [ -n "$isOK" ]; then
        echo -n -e "\r MX Player:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r MX Player:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_Zee5(){
    local countrycode=$(curl -sfi $useNIC $usePROXY $xForward -${1} ${ssll} --max-time 10 'https://www.zee5.com/'   -H 'Upgrade-Insecure-Requests: 1'   -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0' | grep -oP 'country=\K[A-Z]{2}')
    if [ -n "$countrycode" ]; then
        echo -n -e "\r Zee5:\t\t\t\t\t${Font_Green}Yes (Region: $countrycode)${Font_Suffix}\n"
        return
    elif [ -z "$countrycode" ]; then
        echo -n -e "\r Zee5:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_EroGameSpace(){
    local result=$(curl $usePROXY $xForward -${1} -sSL --max-time 3  "https://erogamescape.org" 2>/dev/null | grep '18歳')
    if [ -n "$result" ]; then
        echo -n -e "\r EroGameSpace:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    else
        echo -n -e "\r EroGameSpace:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_DAnimeStore(){
    local tmpresult=$(curl $usePROXY $xForward -${1} -sSL --max-time 10 -sL 'https://animestore.docomo.ne.jp/animestore/reg_pc' 2>/dev/null)
    if [ -z "$tmpresult" ]; then
        echo -n -e "\r D Anime Store:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi

    local isBlocked=$(echo $tmpresult | grep '海外')
    if [ -n "$isBlocked" ];then
        echo -n -e "\r D Anime Store:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    else
        echo -n -e "\r D Anime Store:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
        return
    fi
}

function MediaUnlockTest_NETRIDE(){
    local tmpresult=$(curl $useNIC $usePROXY $xForward -${1} ${ssll} -s -X POST -I --max-time 10 "http://trial.net-ride.com/free/free_dl.php?R_sm_code=456&R_km_url=cabb" 2>/dev/null)
    if [[ $tmpresult =~ "302 Found" ]]; then
        echo -n -e "\r NETRIDE:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    elif [[ $tmpresult =~ "403 Forbidden" ]]; then
        echo -n -e "\r NETRIDE:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
    else
        echo -n -e "\r NETRIDE:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
    fi
}

function echo_Result() {
    for ((i=0;i<${#array[@]};i++)); do
        echo "$result" | grep "${array[i]}"
        sleep 0.03
    done
}

function NA_UnlockTest() {
    echo "===========[ North America ]==========="
    local result=$(
        MediaUnlockTest_Fox ${1} &
        MediaUnlockTest_HuluUS ${1} &
        MediaUnlockTest_NFLPlus ${1} &
        MediaUnlockTest_ESPNPlus ${1} &
        MediaUnlockTest_EPIX ${1} &
        MediaUnlockTest_Starz ${1} &
        MediaUnlockTest_Philo ${1} &
        MediaUnlockTest_FXNOW ${1} &
        MediaUnlockTest_HBOMax ${1} &
    )
    wait
    local array=("FOX:" "Hulu:" "NFL+" "ESPN+:" "MGM+:" "Starz:" "Philo:" "FXNOW:")
    echo_Result ${result} ${array}
    MediaUnlockTest_TLCGO ${1}
    echo "$result" | grep "HBO Max:"
    local result=$(
        MediaUnlockTest_Shudder ${1} &
        MediaUnlockTest_BritBox ${1} &
        MediaUnlockTest_Crackle ${1} &
        MediaUnlockTest_CWTV ${1} &
        MediaUnlockTest_AETV ${1} &
        MediaUnlockTest_NBATV ${1} &
        MediaUnlockTest_FuboTV ${1} &
        MediaUnlockTest_TubiTV ${1} &
    )
    wait
    local array=("Shudder:" "BritBox:" "Crackle:" "CW TV:" "A&E TV:" "NBA TV:")
    echo_Result ${result} ${array}
    MediaUnlockTest_NBCTV ${1}
    echo "$result" | grep "Fubo TV:"
    echo "$result" | grep "Tubi TV:"
    local result=$(
        MediaUnlockTest_SlingTV ${1} &
        MediaUnlockTest_PlutoTV ${1} &
        MediaUnlockTest_AcornTV ${1} &
        MediaUnlockTest_SHOWTIME ${1} &
        MediaUnlockTest_encoreTVB ${1} &
        # MediaUnlockTest_Funimation ${1} &
        MediaUnlockTest_DiscoveryPlus ${1} &
        MediaUnlockTest_ParamountPlus ${1} &
        MediaUnlockTest_PeacockTV ${1} &
        MediaUnlockTest_Popcornflix ${1} &
        MediaUnlockTest_Crunchyroll ${1} &
        MediaUnlockTest_ATTNOW ${1} &
        # MediaUnlockTest_KBSAmerican ${1} &
        MediaUnlockTest_KOCOWA ${1} &
        # MediaUnlockTest_MathsSpot ${1} &
        MediaUnlockTest_SonyLiv ${1} &
    )
    wait
    local array=("Sling TV:" "Pluto TV:" "Acorn TV:" "SHOWTIME:" "encoreTVB:" "Discovery" "Paramount+:" "Peacock TV:" "Popcornflix:" "Crunchyroll:" "Directv Stream:" "KOCOWA:" "SonyLiv:")
    echo_Result ${result} ${array}
    ShowRegion CA
    local result=$(
        MediaUnlockTest_HotStar ${1} &
        MediaUnlockTest_CBCGem ${1} &
        MediaUnlockTest_Crave ${1} &
    )
    wait
    local array=("HotStar:" "CBC Gem:" "Crave:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function EU_UnlockTest() {
    echo "===============[ Europe ]=============="
    local result=$(
        MediaUnlockTest_RakutenTV ${1} &
        # MediaUnlockTest_Funimation ${1} &
        MediaUnlockTest_SkyShowTime ${1} &
        MediaUnlockTest_HBOMax ${1} &
        MediaUnlockTest_SetantaSports ${1} &
        # MediaUnlockTest_MathsSpot ${1} &
        # MediaUnlockTest_HBO_Nordic ${1}
        # MediaUnlockTest_HBOGO_EUROPE ${1}
        MediaUnlockTest_SonyLiv ${1} &
    )
    wait
    local array=("Rakuten TV:" "SkyShowTime:" "HBO Max:" "Setanta Sports:" "SonyLiv:")
    echo_Result ${result} ${array}
    ShowRegion GB
    local result=$(
        MediaUnlockTest_HotStar ${1} &
        MediaUnlockTest_SkyGo ${1} &
        MediaUnlockTest_BritBox ${1} &
        MediaUnlockTest_ITVHUB ${1} &
        MediaUnlockTest_Channel4 ${1} &
        MediaUnlockTest_Channel5 ${1} &
        MediaUnlockTest_BBCiPLAYER ${1} &
        MediaUnlockTest_DiscoveryPlusUK ${1} &
    )
    wait
    local array=("HotStar:" "Sky Go:" "BritBox:" "ITV Hub:" "Channel 4:" "Channel 5" "BBC iPLAYER:" "Discovery+ UK:")
    echo_Result ${result} ${array}
    ShowRegion FR
    local result=$(
        # MediaUnlockTest_Salto ${1} &
        MediaUnlockTest_CanalPlus ${1} &
        MediaUnlockTest_Molotov ${1} &
        MediaUnlockTest_Joyn ${1} &
        MediaUnlockTest_SKY_DE ${1} &
        MediaUnlockTest_ZDF ${1} &
    )
    wait
    local array=("Canal+:" "Molotov:")
    echo_Result ${result} ${array}
    ShowRegion DE
    local array=("Joyn:" "SKY DE:" "ZDF:")
    echo_Result ${result} ${array}
    ShowRegion NL
    local result=$(
        MediaUnlockTest_NLZIET ${1} &
        MediaUnlockTest_videoland ${1} &
        MediaUnlockTest_NPO_Start_Plus ${1} &
        # MediaUnlockTest_HBO_Spain ${1}
        MediaUnlockTest_MoviStarPlus ${1} &
        MediaUnlockTest_RaiPlay ${1} &
        MediaUnlockTest_Sky_CH ${1} &
        # MediaUnlockTest_MegogoTV ${1}
        MediaUnlockTest_Amediateka ${1} &
    )
    wait
    local array=("NLZIET:" "videoland:" "NPO Start Plus:")
    echo_Result ${result} ${array}
    ShowRegion ES
    echo "$result" | grep "Movistar+:"
    ShowRegion IT
    echo "$result" | grep "Rai Play:"
    ShowRegion CH
    echo "$result" | grep "SKY CH:"
    ShowRegion RU
    echo "$result" | grep "Amediateka:"
    echo "======================================="
}

function HK_UnlockTest() {
    echo "=============[ Hong Kong ]============="
    local result=$(
        MediaUnlockTest_NowE ${1} &
        MediaUnlockTest_Viu.com ${1} &
        MediaUnlockTest_ViuTV ${1} &
        MediaUnlockTest_MyTVSuper ${1} &
        MediaUnlockTest_HBOGO_ASIA ${1} &
        MediaUnlockTest_SonyLiv ${1} &
        MediaUnlockTest_BilibiliHKMCTW ${1} &
    )
    wait
    local array=("Now E:" "Viu.com:" "Viu.TV:" "MyTVSuper:" "HBO GO Asia:" "SonyLiv:" "BiliBili Hongkong/Macau/Taiwan:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function AF_UnlockTest() {
    echo "==============[ Africa ]=============="
    local result=$(
        MediaUnlockTest_DSTV ${1} &
        MediaUnlockTest_Showmax ${1} &
        MediaUnlockTest_Viu.com ${1} &
    )
    wait
    local array=("DSTV:" "Showmax:" "Viu.com:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function IN_UnlockTest() {
    echo "===============[ India ]==============="
    local result=$(
        MediaUnlockTest_HotStar ${1} &
        MediaUnlockTest_Zee5 ${1} &
        MediaUnlockTest_SonyLiv ${1} &
        MediaUnlockTest_JioCinema ${1} &
        MediaUnlockTest_MXPlayer ${1} &
        MediaUnlockTest_NBATV ${1} &
    )
    wait
    local array=("HotStar:" "Zee5:" "SonyLiv:" "Jio Cinema:" "MX Player:" "NBA TV:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function TW_UnlockTest() {
    echo "==============[ Taiwan ]==============="
    local result=$(
        MediaUnlockTest_KKTV ${1} &
        MediaUnlockTest_LiTV ${1} &
        MediaUnlockTest_MyVideo ${1} &
        MediaUnlockTest_4GTV ${1} &
        MediaUnlockTest_LineTV.TW ${1} &
        MediaUnlockTest_HamiVideo ${1} &
        MediaUnlockTest_Catchplay ${1} &
        MediaUnlockTest_HBOGO_ASIA ${1} &
        MediaUnlockTest_BahamutAnime ${1} &
        # MediaUnlockTest_ElevenSportsTW ${1}
        MediaUnlockTest_SonyLiv ${1} &
        MediaUnlockTest_BilibiliTW ${1} &
    )
    wait
    local array=("KKTV:" "LiTV:" "MyVideo:" "4GTV.TV:" "LineTV.TW:" "Hami Video:" "CatchPlay+:" "HBO GO Asia:" "Bahamut Anime:" "SonyLiv:" "Bilibili Taiwan Only:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function JP_UnlockTest() {
    echo "===============[ Japan ]==============="
    local result=$(
        MediaUnlockTest_DMM ${1} &
        MediaUnlockTest_DMMTV ${1} &
        MediaUnlockTest_AbemaTV_IPTest ${1} &
        MediaUnlockTest_Niconico ${1} &
        MediaUnlockTest_Telasa ${1} &
        MediaUnlockTest_unext ${1} &
        MediaUnlockTest_HuluJP ${1} &
    )
    wait
    local array=("DMM:" "DMM TV:" "Abema.TV:" "Niconico:" "Telasa:" "U-NEXT:" "Hulu Japan:")
    echo_Result ${result} ${array}
    local result=$(
        MediaUnlockTest_TVer ${1} &
        MediaUnlockTest_Lemino ${1} &
        MediaUnlockTest_wowow ${1} &
        MediaUnlockTest_VideoMarket ${1} &
        MediaUnlockTest_DAnimeStore ${1} &
        MediaUnlockTest_FOD ${1} &
        MediaUnlockTest_Radiko ${1} &
        MediaUnlockTest_DAM ${1} &
        MediaUnlockTest_J:COM_ON_DEMAND ${1} &
        MediaUnlockTest_NETRIDE ${1} &
    )
    wait
    local array=("TVer:" "Lemino:" "WOWOW:" "VideoMarket:" "D Anime Store:" "FOD(Fuji TV):" "Radiko:" "Karaoke@DAM:" "J:com On Demand:" "NETRIDE:")
    echo_Result ${result} ${array}
    ShowRegion Game
    local result=$(
        MediaUnlockTest_Kancolle ${1} &
        MediaUnlockTest_UMAJP ${1} &
        MediaUnlockTest_KonosubaFD ${1} &
        MediaUnlockTest_PCRJP ${1} &
        MediaUnlockTest_WFJP ${1} &
        MediaUnlockTest_ProjectSekai ${1} &
    )
    wait
    local array=("Kancolle Japan:" "Pretty Derby Japan:" "Konosuba Fantastic Days:" "Princess Connect Re:Dive Japan:" "World Flipper Japan:" "Project Sekai: Colorful Stage:")
    echo_Result ${result} ${array}

    ShowRegion Music
    local result=$(
        MediaUnlockTest_mora ${1} &
        MediaUnlockTest_music.jp ${1} &
    )
    wait
    local array=("Mora:" "music.jp:")
    echo_Result ${result} ${array}
    ShowRegion Forum
    MediaUnlockTest_EroGameSpace ${1}
    echo "======================================="

}

function Global_UnlockTest() {
    echo ""
    echo "============[ Multination ]============"
    local result=$(
        MediaUnlockTest_Dazn ${1} &
        # MediaUnlockTest_HotStar ${1} &
        MediaUnlockTest_DisneyPlus ${1} &
        MediaUnlockTest_Netflix ${1} &
        MediaUnlockTest_YouTube_Premium ${1} &
        MediaUnlockTest_PrimeVideo_Region ${1} &
        MediaUnlockTest_TVBAnywhere ${1} &
        MediaUnlockTest_iQYI_Region ${1} &
        # MediaUnlockTest_Viu.com ${1} &
        MediaUnlockTest_YouTube_CDN ${1} &
        MediaUnlockTest_NetflixCDN ${1} &
        MediaUnlockTest_Spotify ${1} &
        OpenAITest ${1} &
        Bing_Region ${1} &
        Wikipedia_Editable ${1} &
        MediaUnlockTest_Instagram.Music ${1} &
        GameTest_Steam ${1} &
    )
    wait
    local array=("Dazn:" "Disney+:" "Netflix:" "YouTube Premium:" "Amazon Prime Video:" "TVBAnywhere+:" "iQyi Oversea Region:" "YouTube CDN:" "YouTube Region:" "Netflix Preferred CDN:" "Spotify Registration:" "Steam Currency:" "ChatGPT:" "Bing Region:" "Wikipedia Editability:" "Instagram Licensed Audio:")
    echo_Result ${result} ${array}
    ShowRegion Forum
    RedditUnlockTest ${1}
    echo "======================================="
}

function SA_UnlockTest() {
    echo "===========[ South America ]==========="
    local result=$(
        MediaUnlockTest_StarPlus ${1} &
        MediaUnlockTest_HBOMax ${1} &
        MediaUnlockTest_DirecTVGO ${1} &
        # MediaUnlockTest_Funimation ${1} &
    )
    wait
    local array=("Star+:" "HBO Max:" "DirecTV Go:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function OA_UnlockTest() {
    echo "==============[ Oceania ]=============="
    local result=$(
        MediaUnlockTest_NBATV ${1} &
        MediaUnlockTest_AcornTV ${1} &
        MediaUnlockTest_SHOWTIME ${1} &
        MediaUnlockTest_BritBox ${1} &
        # MediaUnlockTest_Funimation ${1} &
        MediaUnlockTest_ParamountPlus ${1} &
        MediaUnlockTest_SonyLiv ${1} &
    )
    wait
    local array=("NBA TV:" "Acorn TV:" "SHOWTIME:" "BritBox:" "Paramount+:" "SonyLiv:")
    echo_Result ${result} ${array}
    ShowRegion AU
    local result=$(
        MediaUnlockTest_Stan ${1} &
        MediaUnlockTest_Binge ${1} &
        MediaUnlockTest_7plus ${1} &
        MediaUnlockTest_Channel9 ${1} &
        MediaUnlockTest_Channel10 ${1} &
        MediaUnlockTest_ABCiView ${1} &
        MediaUnlockTest_OptusSports ${1} &
        MediaUnlockTest_SBSonDemand ${1} &
    )
    wait
    echo "$result" | grep "Stan:"
    echo "$result" | grep "Binge:"
    MediaUnlockTest_Docplay ${1}
    local array=("7plus:" "Channel 9:" "Channel 10:" "ABC iView:")
    echo_Result ${result} ${array}
    MediaUnlockTest_KayoSports ${1}
    echo "$result" | grep "Optus Sports:"
    echo "$result" | grep "SBS on Demand:"
    ShowRegion NZ
    local result=$(
        MediaUnlockTest_NeonTV ${1} &
        MediaUnlockTest_SkyGONZ ${1} &
        MediaUnlockTest_ThreeNow ${1} &
        MediaUnlockTest_MaoriTV ${1} &
    )
    wait
    local array=("Neon TV:" "SkyGo NZ:" "ThreeNow:" "Maori TV:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function KR_UnlockTest() {
    echo "==============[ Korean ]==============="
    local result=$(
        MediaUnlockTest_Wavve ${1} &
        MediaUnlockTest_Tving ${1} &
        MediaUnlockTest_Watcha ${1} &
        MediaUnlockTest_CoupangPlay ${1} &
        MediaUnlockTest_SpotvNow ${1} &
        MediaUnlockTest_NaverTV ${1} &
        MediaUnlockTest_Afreeca ${1} &
        MediaUnlockTest_KBSDomestic ${1} &
        # MediaUnlockTest_KOCOWA ${1} &
    )
    wait
    local array=("Wavve:" "Tving:" "WATCHA:" "Coupang Play:" "Naver TV:" "SPOTV NOW" "Afreeca TV:" "KBS Domestic:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function SEA_UnlockTest(){
    echo "==========[ SouthEastAsia ]============"
    local result=$(
        MediaUnlockTest_Viu.com ${1} &
        MediaUnlockTest_HotStar ${1} &
        MediaUnlockTest_HBOGO_ASIA ${1} &
        MediaUnlockTest_SonyLiv ${1} &
        MediaUnblockTest_BGlobalSEA ${1} &
    )
    wait
    local array=("Viu.com:" "HotStar:" "HBO GO Asia:" "SonyLiv:" "B-Global SouthEastAsia:")
    echo_Result ${result} ${array}

    ShowRegion SG
    local result=$(
        MediaUnlockTest_MeWatch ${1} &
    )
    wait
    local array=("MeWatch:")
    echo_Result ${result} ${array}

    ShowRegion TH
    local result=$(
        MediaUnlockTest_AISPlay ${1} &
        MediaUnlockTest_trueID ${1} &
        MediaUnblockTest_BGlobalTH ${1} &
    )
    wait
    local array=("AIS Play:" "trueID:" "B-Global Thailand Only:")
    echo_Result ${result} ${array}

    ShowRegion ID
    local result=$(
        MediaUnblockTest_BGlobalID ${1} &
    )
    wait
    local array=("B-Global Indonesia Only:")
    echo_Result ${result} ${array}
    ShowRegion VN
    local result=$(
        MediaUnlockTest_K_PLUS ${1} &
        MediaUnlockTest_TV360 ${1} &
        MediaUnblockTest_BGlobalVN ${1} &
    )
    wait
    local array=("K+:" "TV360:" "B-Global Việt Nam Only:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function Sport_UnlockTest() {
    echo "===============[ Sport ]==============="
    local result=$(
        MediaUnlockTest_Dazn ${1} &
        MediaUnlockTest_StarPlus ${1} &
        MediaUnlockTest_ESPNPlus ${1} &
        MediaUnlockTest_NBATV ${1} &
        MediaUnlockTest_FuboTV ${1} &
        MediaUnlockTest_MolaTV ${1} &
        MediaUnlockTest_SetantaSports ${1} &
        # MediaUnlockTest_ElevenSportsTW ${1}
        MediaUnlockTest_OptusSports ${1} &
        MediaUnlockTest_BeinConnect ${1} &
        MediaUnlockTest_EurosportRO ${1} &
    )
    wait
    local array=("Dazn:" "Star+:" "ESPN+:" "NBA TV:" "Fubo TV:" "Mola TV:" "Setanta Sports:" "Optus Sports:" "Bein Sports Connect:" "Eurosport RO:")
    echo_Result ${result} ${array}
    echo "======================================="
}

function CheckPROXY() {
    if [ -n "$usePROXY" ]; then
        local proxy=$(echo $usePROXY | tr A-Z a-z)
        if [[ "$proxy" == *"socks:"* ]] ; then
            proxyType=Socks
        elif [[ "$proxy" == *"socks4:"* ]]; then
            proxyType=Socks4
        elif [[ "$proxy" == *"socks5:"* ]]; then
            proxyType=Socks5
        elif [[ "$proxy" == *"http"* ]]; then
            proxyType=http
        else
            proxyType=""
        fi
        local result1=$(curl $useNIC $usePROXY -sS --user-agent "${UA_Browser}" ip.sb 2>&1)
        local result2=$(curl $useNIC $usePROXY -sS --user-agent "${UA_Browser}" https://1.0.0.1/cdn-cgi/trace 2>&1)
        if [[ "$result1" == "curl"* ]] && [[ "$result2" == "curl"* ]] || [ -z "$proxyType" ]; then
            isproxy=0
        else
            isproxy=1
        fi
    else
        isproxy=0
    fi
}

function CheckV4() {
    CheckPROXY
    if [[ "$language" == "e" ]]; then
        if [[ "$NetworkType" == "6" ]]; then
            isv4=0
            echo -e "${Font_SkyBlue}User Choose to Test Only IPv6 Results, Skipping IPv4 Testing...${Font_Suffix}"
        else
            if [ -n "$usePROXY" ] && [[ "$isproxy" -eq 1 ]]; then
                echo -e " ${Font_SkyBlue}** Checking Results Under Proxy${Font_Suffix} "
                isv6=0
            elif [ -n "$usePROXY" ] && [[ "$isproxy" -eq 0 ]]; then
                echo -e " ${Font_SkyBlue}** Unable to connect to this proxy${Font_Suffix} "
                isv6=0
                return
            else
                echo -e " ${Font_SkyBlue}** Checking Results Under IPv4${Font_Suffix} "
                check4=$(ping 1.1.1.1 -c 1 2>&1)
            fi
            echo "--------------------------------"
            echo -e " ${Font_SkyBlue}** Your Network Provider: ${local_isp4} (${local_ipv4_asterisk})${Font_Suffix} "
            if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]]; then
                isv4=1
            else
                echo -e "${Font_SkyBlue}No IPv4 Connectivity Found, Abort IPv4 Testing...${Font_Suffix}"
                isv4=0
            fi

            echo ""
        fi
    else
        if [[ "$NetworkType" == "6" ]]; then
            isv4=0
            echo -e "${Font_SkyBlue}用户选择只检测IPv6结果，跳过IPv4检测...${Font_Suffix}"
        else
            if [ -n "$usePROXY" ] && [[ "$isproxy" -eq 1 ]]; then
                echo -e " ${Font_SkyBlue}** 正在测试代理解锁情况${Font_Suffix} "
                isv6=0
            elif [ -n "$usePROXY" ] && [[ "$isproxy" -eq 0 ]]; then
                echo -e " ${Font_SkyBlue}** 无法连接到此${proxyType}代理${Font_Suffix} "
                isv6=0
                return
            else
                echo -e " ${Font_SkyBlue}** 正在测试IPv4解锁情况${Font_Suffix} "
                check4=$(ping 1.1.1.1 -c 1 2>&1)
            fi
            echo "--------------------------------"
            echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp4} (${local_ipv4_asterisk})${Font_Suffix} "
            if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]]; then
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
    if [[ "$language" == "e" ]]; then
        if [[ "$NetworkType" == "4" ]]; then
            isv6=0
            if [ -z "$usePROXY" ]; then
                echo -e "${Font_SkyBlue}User Choose to Test Only IPv4 Results, Skipping IPv6 Testing...${Font_Suffix}"
            fi
        else
            check6_1=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.google.com)
            check6_2=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.ip.sb)
            if [[ "$check6_1" -ne "000" ]] || [[ "$check6_2" -ne "000" ]]; then
                echo ""
                echo ""
                echo -e " ${Font_SkyBlue}** Checking Results Under IPv6${Font_Suffix} "
                echo "--------------------------------"
                echo -e " ${Font_SkyBlue}** Your Network Provider: ${local_isp6} (${local_ipv6_asterisk})${Font_Suffix} "
                isv6=1
            else
                echo -e "${Font_SkyBlue}No IPv6 Connectivity Found, Abort IPv6 Testing...${Font_Suffix}"
                isv6=0
            fi
            echo -e ""
        fi

    else
        if [[ "$NetworkType" == "4" ]]; then
            isv6=0
            if [ -z "$usePROXY" ]; then
                echo -e "${Font_SkyBlue}用户选择只检测IPv4结果，跳过IPv6检测...${Font_Suffix}"
            fi
        else
            check6_1=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.google.com)
            check6_2=$(curl $useNIC -fsL --write-out %{http_code} --output /dev/null --max-time 10 ipv6.ip.sb)
            if [[ "$check6_1" -ne "000" ]] || [[ "$check6_2" -ne "000" ]]; then
                echo ""
                echo ""
                echo -e " ${Font_SkyBlue}** 正在测试IPv6解锁情况${Font_Suffix} "
                echo "--------------------------------"
                echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp6} (${local_ipv6_asterisk})${Font_Suffix} "
                isv6=1
            else
                echo -e "${Font_SkyBlue}当前主机不支持IPv6,跳过...${Font_Suffix}"
                isv6=0
            fi
            echo -e ""
        fi
    fi
}


function Goodbye() {
    if [ "${num}" == 1 ]; then
        ADN=TW
    elif [ "${num}" == 3 ]; then
        ADN=JP
    elif [ "${num}" == 8 ]; then
        ADN=KR
    elif [ "${num}" == 4 ]; then
        ADN=US
    else
        ADN=$(echo $(($RANDOM % 2 + 1)))
    fi

    if [[ "$language" == "e" ]]; then
        echo -e "${Font_Green}Testing Done! Thanks for Using This Script! ${Font_Suffix}"
        echo -e ""
        echo -e "${Font_Yellow}Number of Script Runs for Today: ${TodayRunTimes}; Total Number of Script Runs: ${TotalRunTimes} ${Font_Suffix}"
        echo -e ""
        echo -e "========================================================="
        echo -e "${Font_Red}If you found this script helpful, you can but me a coffee${Font_Suffix}"
        echo -e ""
        echo -e "LTC: LQD4S6Y5bu3bHX6hx8ASsGHVfaqFGFNTbx"
        echo -e "========================================================="
    else
        echo -e "${Font_Green}本次测试已结束，感谢使用此脚本 ${Font_Suffix}"
        echo -e ""
        echo -e "${Font_Yellow}检测脚本当天运行次数: ${TodayRunTimes}; 共计运行次数: ${TotalRunTimes} ${Font_Suffix}"
        echo -e ""
        #bash <(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/reference/AD/AD${ADN})
        echo -e ""
        bash <(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/reference/AD/AD2)
    fi
}

clear

function ScriptTitle() {
    if [[ "$language" == "e" ]]; then
        echo -e " [Stream Platform & Game Region Restriction Test]"
        echo ""
        echo -e "${Font_Green}Github Repository:${Font_Suffix} ${Font_Yellow} https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}"
        echo -e "${Font_Green}Telegram Discussion Group:${Font_Suffix} ${Font_Yellow} https://t.me/gameaccelerate ${Font_Suffix}"
        echo -e "${Font_Purple}Supporting OS: CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android (Termux), iOS (iSH)${Font_Suffix}"
        echo ""
        echo -e " ** Test Starts At: $(date)"
        echo ""
    else
        echo -e " [流媒体平台及游戏区域限制测试]"
        echo ""
        echo -e "${Font_Green}项目地址${Font_Suffix} ${Font_Yellow}https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}"
        echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/gameaccelerate ${Font_Suffix}"
        echo -e "${Font_Purple}脚本适配OS: CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android (Termux), iOS (iSH)${Font_Suffix}"
        echo ""
        echo -e " ** 测试时间: $(date)"
        echo ""
    fi
}
ScriptTitle

function Start() {
    if [[ "$language" == "e" ]]; then
        echo -e "${Font_Blue}Please Select Test Region or Press ENTER to Test All Regions${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [1]: [ Multination + Taiwan ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [2]: [ Multination + Hong Kong ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [3]: [ Multination + Japan ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [4]: [ Multination + North America ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [5]: [ Multination + South America ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [6]: [ Multination + Europe ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [7]: [ Multination + Oceania ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [8]: [ Multination + Korean ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [9]: [ Multination + SouthEast Asia ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [10]: [ Multination + India ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [11]: [ Multination + Africa ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number  [0]: [ Multination Only ]${Font_Suffix}"
        echo -e "${Font_SkyBlue}Input Number [99]: [ Sport Platforms ]${Font_Suffix}"
        read -p "Please Input the Correct Number or Press ENTER:" num
    else
        echo -e "${Font_Blue}请选择检测项目，直接按回车将进行全区域检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [1]: [ 跨国平台+台湾平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [2]: [ 跨国平台+香港平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [3]: [ 跨国平台+日本平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [4]: [ 跨国平台+北美平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [5]: [ 跨国平台+南美平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [6]: [ 跨国平台+欧洲平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [7]: [跨国平台+大洋洲平台]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [8]: [ 跨国平台+韩国平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [9]: [跨国平台+东南亚平台]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字 [10]: [ 跨国平台+印度平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字 [11]: [ 跨国平台+非洲平台 ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字  [0]: [   只进行跨国平台  ]检测${Font_Suffix}"
        echo -e "${Font_SkyBlue}输入数字 [99]: [   体育直播平台    ]检测${Font_Suffix}"
        echo -e "${Font_Purple}输入数字 [69]: [   广告推广投放    ]咨询${Font_Suffix}"
        read -p "请输入正确数字或直接按回车:" num
    fi
}
Start

function RunScript() {
    if [[ -n "${num}" ]]; then
        if [[ "$num" -eq 1 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                TW_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                TW_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 2 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                HK_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                HK_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 3 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                JP_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                JP_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 4 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                NA_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                NA_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 5 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                SA_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                SA_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 6 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                EU_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                EU_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 7 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                OA_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                OA_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 8 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                KR_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                KR_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 9 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                SEA_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                SEA_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 10 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                IN_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                IN_UnlockTest 6
            fi
            Goodbye

            elif [[ "$num" -eq 11 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
                AF_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
                AF_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 99 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Sport_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Sport_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 0 ]]; then
            clear
            ScriptTitle
            CheckV4
            if [[ "$isv4" -eq 1 ]]; then
                Global_UnlockTest 4
            fi
            CheckV6
            if [[ "$isv6" -eq 1 ]]; then
                Global_UnlockTest 6
            fi
            Goodbye

        elif [[ "$num" -eq 69 ]]; then
            clear
            ScriptTitle
            echo ""
            echo ""
            echo -e "${Font_Red}**************************${Font_Suffix}"
            echo -e "${Font_Red}*                        *${Font_Suffix}"
            echo -e "${Font_Red}*${Font_Suffix} 广告招租               ${Font_Red}*${Font_Suffix}"
            echo -e "${Font_Red}*${Font_Suffix} 请联系：@reidschat_bot ${Font_Red}*${Font_Suffix}"
            echo -e "${Font_Red}*                        *${Font_Suffix}"
            echo -e "${Font_Red}**************************${Font_Suffix}"

        else
            echo -e "${Font_Red}请重新执行脚本并输入正确号码${Font_Suffix}"
            echo -e "${Font_Red}Please Re-run the Script with Correct Number Input${Font_Suffix}"
            return
        fi
    else
        clear
        ScriptTitle
        CheckV4
        if [[ "$isv4" -eq 1 ]]; then
            Global_UnlockTest 4
            TW_UnlockTest 4
            HK_UnlockTest 4
            JP_UnlockTest 4
            NA_UnlockTest 4
            SA_UnlockTest 4
            EU_UnlockTest 4
            OA_UnlockTest 4
            KR_UnlockTest 4
        fi
        CheckV6
        if [[ "$isv6" -eq 1 ]]; then
            Global_UnlockTest 6
            TW_UnlockTest 6
            HK_UnlockTest 6
            JP_UnlockTest 6
            NA_UnlockTest 6
            SA_UnlockTest 6
            EU_UnlockTest 6
            OA_UnlockTest 6
            KR_UnlockTest 6
        fi
        Goodbye
    fi
}

RunScript
