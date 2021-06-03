#!/bin/bash
shell_version="1.3.4";
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)";
Font_Black="\033[30m";
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_Purple="\033[35m";
Font_SkyBlue="\033[36m";
Font_White="\033[37m";
Font_Suffix="\033[0m";
LOG_FILE="check.log";

clear;
echo -e "流媒体解锁测试 MediaUnlock_Test" && echo -e "流媒体解锁测试 MediaUnlock_Test" > ${LOG_FILE};
echo -e "${Font_Purple}项目地址 https://github.com/CoiaPrant/MediaUnlock_Test ${Font_Suffix}" && echo -e "项目地址 https://github.com/CoiaPrant/MediaUnlock_Test" >> ${LOG_FILE};
echo -e "${Font_Purple}BUG反馈 https://github.com/CoiaPrant/MediaUnlock_Test/issues${Font_Suffix}" && echo -e "BUG反馈 https://github.com/CoiaPrant/MediaUnlock_Test/issues" >> ${LOG_FILE};
echo -e "${Font_Purple}联系作者 https://t.me/CoiaPrant${Font_Suffix}" && echo -e "联系作者 https://t.me/CoiaPrant" >> ${LOG_FILE};
echo -e "${Font_Purple}个人频道 https://t.me/CoiaPrant_Blog${Font_Suffix}" && echo -e "个人频道 https://t.me/CoiaPrant_Blog" >> ${LOG_FILE};
echo -e "${Font_Purple}声明 本测试工具根据GPL V3协议开源，严禁倒卖${Font_Suffix}" && echo -e "声明 本测试工具根据GPL V3协议开源，严禁倒卖" >> ${LOG_FILE};
echo -e "${Font_Purple}提示 本工具测试结果仅供参考，请以实际使用为准${Font_Suffix}" && echo -e "提示 本工具测试结果仅供参考，请以实际使用为准" >> ${LOG_FILE};
echo -e "${Font_Purple}国家代码 http://www.loglogo.com/front/countryCode/${Font_Suffix}" && echo -e "国家代码 http://www.loglogo.com/front/countryCode/" >> ${LOG_FILE};
echo -e " ** 当前版本: v${shell_version}" && echo -e " ** 当前版本: v${shell_version}" >> ${LOG_FILE};
echo -e " ** 系统时间: $(date)" && echo -e " ** 系统时间: $(date)" >> ${LOG_FILE};

export LANG="en_US";
export LANGUAGE="en_US";
export LC_ALL="en_US";

function InstallJQ() {
    #安装JQ
    if [ -e "/etc/redhat-release" ];then
        echo -e "${Font_Green}正在安装依赖: epel-release${Font_Suffix}";
        yum install epel-release -y -q > /dev/null;
        echo -e "${Font_Green}正在安装依赖: jq${Font_Suffix}";
        yum install jq -y -q > /dev/null;
        elif [[ $(cat /etc/os-release | grep '^ID=') =~ ubuntu ]] || [[ $(cat /etc/os-release | grep '^ID=') =~ debian ]];then
        echo -e "${Font_Green}正在更新软件包列表...${Font_Suffix}";
        apt-get update -y > /dev/null;
        echo -e "${Font_Green}正在安装依赖: jq${Font_Suffix}";
        apt-get install jq -y > /dev/null;
        elif [[ $(cat /etc/issue | grep '^ID=') =~ alpine ]];then
        apk update > /dev/null;
        echo -e "${Font_Green}正在安装依赖: jq${Font_Suffix}";
        apk add jq > /dev/null;
    else
        echo -e "${Font_Red}请手动安装jq${Font_Suffix}";
        exit;
    fi
}

function PharseJSON() {
    # 使用方法: PharseJSON "要解析的原JSON文本" "要解析的键值"
    # Example: PharseJSON ""Value":"123456"" "Value" [返回结果: 123456]
    echo -n $1 | jq -r .$2;
}

function PasteBin_Upload() {
    local uploadresult="$(curl -fsL -X POST \
        --url https://paste.ubuntu.com \
        --output /dev/null \
        --write-out "%{url_effective}\n" \
        --data-urlencode "content@${PASTEBIN_CONTENT:-/dev/stdin}" \
        --data "poster=${PASTEBIN_POSTER:-MediaUnlock_Test_By_CoiaPrant}" \
        --data "expiration=${PASTEBIN_EXPIRATION:-}" \
    --data "syntax=${PASTEBIN_SYNTAX:-text}")"
    if [ "$?" = "0" ]; then
        echo -e "${Font_Green}已生成报告 ${uploadresult} ${Font_Suffix}";
    else
        echo -e "${Font_Red}生成报告失败 ${Font_Suffix}";
    fi
}

function GameTest_Steam(){
    echo -n -e " Steam Currency:\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 https://store.steampowered.com/app/761830 2>&1 | grep priceCurrency | cut -d '"' -f4`;
    
    if [ ! -n "$result" ]; then
        echo -n -e "\r Steam Currency:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Steam Currency:\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
    else
        echo -n -e "\r Steam Currency:\t\t\t${Font_Green}${result}${Font_Suffix}\n" && echo -e " Steam Currency:\t\t\t${result}" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_HBONow() {
    echo -n -e " HBO Now:\t\t\t\t->\c";
    # 尝试获取成功的结果
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 --write-out "%{url_effective}\n" --output /dev/null https://play.hbonow.com/ 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        # 下载页面成功，开始解析跳转
        if [ "${result}" = "https://play.hbonow.com" ] || [ "${result}" = "https://play.hbonow.com/" ]; then
            echo -n -e "\r HBO Now:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo " HBO Now:\t\t\t\tYes" >> ${LOG_FILE};
            elif [ "${result}" = "http://hbogeo.cust.footprint.net/hbonow/geo.html" ] || [ "${result}" = "http://geocust.hbonow.com/hbonow/geo.html" ]; then
            echo -n -e "\r HBO Now:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " HBO Now:\t\t\t\tNo" >> ${LOG_FILE};
        else
            echo -n -e "\r HBO Now:\t\t\t\t${Font_Yellow}Failed (Parse Json)${Font_Suffix}\n" && echo -e " HBO Now:\t\t\t\tFailed (Parse Json)" >> ${LOG_FILE};
        fi
    else
        # 下载页面失败，返回错误代码
        echo -e "\r HBO Now:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " HBO Now:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
    fi
}

# 流媒体解锁测试-动画疯
function MediaUnlockTest_BahamutAnime() {
    echo -n -e " Bahamut Anime:\t\t\t\t->\c";
    local tmpresult=`curl -${1} --user-agent "${UA_Browser}" --max-time 30 -fsSL 'https://ani.gamer.com.tw/ajax/token.php?adID=89422&sn=14667' 2>&1`;
    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
    local result="$(PharseJSON "$tmpresult" "animeSn")";
    if [ "$result" != "null" ]; then
        resultverify="$(echo $result | grep -oE '[0-9]{1,}')";
        if [ "$?" = "0" ]; then
            echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tYes" >> ${LOG_FILE};
        else
            echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tFailed (Parse Json)" >> ${LOG_FILE};
        fi
    else
        local result="$(PharseJSON "$tmpresult" "error.code")";
        if [ "$result" != "null" ]; then
            resultverify="$(echo $result | grep -oE '[0-9]{1,}')";
            if [ "$?" = "0" ]; then
                echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tNo" >> ${LOG_FILE};
            else
                echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tFailed (Parse Json)" >> ${LOG_FILE};
            fi
        else
            echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Bahamut Anime:\t\t\t\tFailed (Parse Json)" >> ${LOG_FILE};
        fi
    fi
}

# 流媒体解锁测试-哔哩哔哩大陆限定
function MediaUnlockTest_BilibiliChinaMainland() {
    echo -n -e " BiliBili China Mainland Only:\t\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(PharseJSON "${result}" "code")";
        if [ "$?" = "0" ]; then
            if [ "${result}" = "0" ]; then
                echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " BiliBili China Mainland Only:\t\tYes" >> ${LOG_FILE};
                elif [ "${result}" = "-10403" ]; then
                echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " BiliBili China Mainland Only:\t\tNo" >> ${LOG_FILE};
            else
                echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n" && echo -e " BiliBili China Mainland Only:\t\tFailed (${result})" >> ${LOG_FILE};
            fi
        else
            echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " BiliBili China Mainland Only:\t\tFailed (Parse Json)" >> ${LOG_FILE};
        fi
    else
        echo -n -e "\r BiliBili China Mainland Only:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " BiliBili China Mainland Only:\t\tFailed (Network Connection)" >> ${LOG_FILE};
    fi
}

# 流媒体解锁测试-哔哩哔哩港澳台限定
function MediaUnlockTest_BilibiliHKMCTW() {
    echo -n -e " BiliBili Hongkong/Macau/Taiwan:\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(PharseJSON "${result}" "code")";
        if [ "$?" = "0" ]; then
            if [ "${result}" = "0" ]; then
                echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " BiliBili Hongkong/Macau/Taiwan:\tYes" >> ${LOG_FILE};
                elif [ "${result}" = "-10403" ]; then
                echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}No${Font_Suffix}\n" && echo -e " BiliBili Hongkong/Macau/Taiwan:\tNo" >> ${LOG_FILE};
            else
                echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n" && echo -e " BiliBili Hongkong/Macau/Taiwan:\tFailed (${result})" >> ${LOG_FILE};
            fi
        else
            echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " BiliBili Hongkong/Macau/Taiwan:\tFailed (Parse Json)" >> ${LOG_FILE};
        fi
    else
        echo -n -e "\r BiliBili Hongkong/Macau/Taiwan:\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " BiliBili Hongkong/Macau/Taiwan:\tFailed (Network Connection)" >> ${LOG_FILE};
    fi
}

# 流媒体解锁测试-哔哩哔哩台湾限定
function MediaUnlockTest_BilibiliTW() {
    echo -n -e " Bilibili Taiwan Only:\t\t\t->\c";
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)";
    # 尝试获取成功的结果
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`;
    if [[ "$result" != "curl"* ]]; then
        local result="$(PharseJSON "${result}" "code")";
        if [ "$?" = "0" ]; then
            if [ "${result}" = "0" ]; then
                echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Bilibili Taiwan Only:\t\t\tYes" >> ${LOG_FILE};
                elif [ "${result}" = "-10403" ]; then
                echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Bilibili Taiwan Only:\t\t\tNo" >> ${LOG_FILE};
            else
                echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed${Font_Suffix} ${Font_SkyBlue}(${result})${Font_Suffix}\n" && echo " Bilibili Taiwan Only:Failed (${result})" >> ${LOG_FILE};
            fi
        else
            echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Bilibili Taiwan Only:Failed (Parse Json)" >> ${LOG_FILE};
        fi
    else
        echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Bilibili Taiwan Only:Failed (Network Connection)" >> ${LOG_FILE};
    fi
}

# 流媒体解锁测试-Abema.TV
#
function MediaUnlockTest_AbemaTV_IPTest() {
    echo -n -e " Abema.TV:\t\t\t\t->\c";
    #
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --max-time 30 "https://api.abema.io/v1/ip/check?device=android"`;
    if [[ "$result" == "000" ]]; then
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Abema.TV:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --max-time 30 "https://api.abema.io/v1/ip/check?device=android"`;
    local result="$(PharseJSON "${result}" "cdnRegionUrl")";
    if [ "$?" = "0" ]; then
        if [ "${result}" = "https://ds-linear-abematv.akamaized.net/region" ] || [ "${result}" = "https://ds-glb-linear-abematv.akamaized.net/region" ]; then
            echo -n -e "\r Abema.TV:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Abema.TV:\t\t\t\tYes" >> ${LOG_FILE};
            elif [ "${result}" = "" ] || [ "${result}" = "null" ]; then
            echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Abema.TV:\t\t\t\tNo" >> ${LOG_FILE};
        else
            echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n" && echo -e " Abema.TV:\t\t\t\tFailed" >> ${LOG_FILE};
        fi
    else
        echo -n -e "\r Abema.TV:\t\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Abema.TV:\t\t\t\tFailed (Parse Json)" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_PCRJP() {
    echo -n -e " Princess Connect Re:Dive Japan:\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-priconne-redive.cygames.jp/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Princess Connect Re:Dive Japan:\tFailed (Network Connection)" >> ${LOG_FILE};
        elif [ "$result" = "404" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Princess Connect Re:Dive Japan:\tYes" >> ${LOG_FILE};
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}No${Font_Suffix}\n" && echo -e " Princess Connect Re:Dive Japan:\tNo" >> ${LOG_FILE};
    else
        echo -n -e "\r Princess Connect Re:Dive Japan:\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" && echo -e " Princess Connect Re:Dive Japan:\tFailed (Unexpected Result: $result)" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_UMAJP() {
    echo -n -e " Pretty Derby Japan:\t\t\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-umamusume.cygames.jp/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Pretty Derby Japan:\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        elif [ "$result" = "404" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Pretty Derby Japan:\t\t\tYes" >> ${LOG_FILE};
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Pretty Derby Japan:\t\t\tNo" >> ${LOG_FILE};
    else
        echo -n -e "\r Pretty Derby Japan:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" && echo -e " Pretty Derby Japan:\t\t\tFailed (Unexpected Result: $result)" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_Kancolle() {
    echo -n -e " Kancolle Japan:\t\t\t->\c";
    # 测试，连续请求两次 (单独请求一次可能会返回35, 第二次开始变成0)
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://203.104.209.7/kcscontents/`;
    if [ "$result" = "000" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Kancolle Japan:\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        elif [ "$result" = "200" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Kancolle Japan:\t\t\tYes" >> ${LOG_FILE};
        elif [ "$result" = "403" ]; then
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Kancolle Japan:\t\t\tNo" >> ${LOG_FILE};
    else
        echo -n -e "\r Kancolle Japan:\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" && echo -e " Kancolle Japan:\t\t\tFailed (Unexpected Result: $result)" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_BBC() {
    echo -n -e " BBC:\t\t\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://ve-dash-uk.live.cf.md.bbci.co.uk/`;
    if [ "${result}" = "000" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " BBC:\t\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        elif [ "${result}" = "403" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " BBC:\t\t\t\t\tNo" >> ${LOG_FILE};
        elif [ "${result}" = "404" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " BBC:\t\t\t\t\tYes" >> ${LOG_FILE};
    else
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n" && echo -e " BBC:\t\t\t\t\tFailed (Unexpected Result: $result)" >> ${LOG_FILE};
    fi
}

function MediaUnlockTest_Netflix() {
    echo -n -e " Netflix:\t\t\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.netflix.com/" 2>&1`;
    if [ "$result" == "Not Available" ];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n" && echo -e " Netflix:\t\t\t\tUnsupport" >> ${LOG_FILE};
        return;
    fi
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Netflix:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
    
    local result=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80018499" 2>&1`;
    if [[ "$result" == *"page-404"* ]] || [[ "$result" == *"NSEZ-403"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Netflix:\t\t\t\tNo" >> ${LOG_FILE};
        return;
    fi
    
    local result1=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70143836" 2>&1`;
    local result2=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80027042" 2>&1`;
    local result3=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70140425" 2>&1`;
    local result4=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70283261" 2>&1`;
    local result5=`curl -${1} --user-agent "${UA_Browser}"-sL "https://www.netflix.com/title/70143860" 2>&1`;
    local result6=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70202589" 2>&1`;
    
    if [[ "$result1" == *"page-404"* ]] && [[ "$result2" == *"page-404"* ]] && [[ "$result3" == *"page-404"* ]] && [[ "$result4" == *"page-404"* ]] && [[ "$result5" == *"page-404"* ]] && [[ "$result6" == *"page-404"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}Only Homemade${Font_Suffix}\n" && echo -e " Netflix:\t\t\t\tOnly Homemade" >> ${LOG_FILE};
        return;
    fi
    
    local region=`tr [:lower:] [:upper:] <<< $(curl -${1} --user-agent "${UA_Browser}" -fs --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
    
    if [[ ! -n "$region" ]];then
        region="US";
    fi
    echo -n -e "\r Netflix:\t\t\t\t${Font_Green}Yes(Region: ${region})${Font_Suffix}\n" && echo -e " Netflix:\t\t\t\tYes(Region: ${region})" >> ${LOG_FILE};
    return;
}

function MediaUnlockTest_YouTube_Region() {
    echo -n -e " YouTube Region:\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -sSL "https://www.youtube.com/" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " YouTube Region:\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
    
    local result=`curl --user-agent "${UA_Browser}" -${1} -sL "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4`;
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n" && echo -e " YouTube Region:\t\t\t${result}" >> ${LOG_FILE};
        return;
    fi
    
    echo -n -e "\r YouTube Region:\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " YouTube Region:\t\t\tNo" >> ${LOG_FILE};
    return;
}

function MediaUnlockTest_DisneyPlus() {
    echo -n -e " DisneyPlus:\t\t\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.disneyplus.com/movies/drain-the-titanic/5VNZom2KYtlb" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " DisneyPlus:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
    
    if [[ "$result" == *"https://preview.disneyplus.com/unavailable/"* ]];then
        echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n" && echo -e " DisneyPlus:\t\t\t\tUnsupport" >> ${LOG_FILE};
        return;
    fi
    
    if [[ "$result" == *"releaseYear"* ]];then
        echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " DisneyPlus:\t\t\t\tYes" >> ${LOG_FILE};
        return;
    fi
    
    echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " DisneyPlus:\t\t\t\tNo" >> ${LOG_FILE};
    return;
}

function MediaUnlockTest_Dazn() {
    echo -n -e " Dazn:\t\t\t\t\t->\c";
    local result=$(curl -s -${1} --max-time 30 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' https://startup.core.indazn.com/misl/v5/Startup  | python -m json.tool 2> /dev/null | grep GeolocatedCountryName | awk '{print $2}' | cut -f2 -d'"');
    
	    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r Dazn:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Dazn:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
        return;
    fi
	
	if [ -n "$result" ]; then
		if [[ "$result" == "null," ]];then
			echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Dazn:\t\t\t\t\tNo" >> ${LOG_FILE};
			return;
        else
			echo -n -e "\r Dazn:\t\t\t\t\t${Font_Green}${result}${Font_Suffix}\n" && echo -e " Dazn:\t\t\t\t\t${result}" >> ${LOG_FILE};
			return;
		fi
	else
		echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n" && echo -e " Dazn:\t\t\t\t\tUnsupport" >> ${LOG_FILE};
		return;

    fi
    return;
}

function MediaUnlockTest_HuluJP() {
    echo -n -e " Hulu Japan:\t\t\t\t->\c";
    local result=$(curl  -s -${1} -o /dev/null -L --max-time 30 -w '%{url_effective}\n' https://id.hulu.jp | grep login);
    
	if [ -n "$result" ]; then
		echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " Hulu Japan:\t\t\t\tYes" >> ${LOG_FILE};
		return;
     else
		echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " Hulu Japan:\t\t\t\tNo" >> ${LOG_FILE};
		return;
	fi
	
	echo -n -e "\r Hulu Japan:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " Hulu Japan:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
	return;

}

function MediaUnlockTest_MyTVSuper() {
    echo -n -e " MyTVSuper:\t\t\t\t->\c";
    local result=$(curl -s -${1} --max-time 30 https://www.mytvsuper.com/iptest.php | grep 'HK');
    
	if [ -n "$result" ]; then
		echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n" && echo -e " MyTVSuper:\t\t\t\tYes" >> ${LOG_FILE};
		return;
     else
		echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}No${Font_Suffix}\n" && echo -e " MyTVSuper:\t\t\t\tNo" >> ${LOG_FILE};
		return;
	fi
	
	echo -n -e "\r MyTVSuper:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n" && echo -e " MyTVSuper:\t\t\t\tFailed (Network Connection)" >> ${LOG_FILE};
	return;

}

function MediaUnlockTest() {
	echo ""	
    echo "=============欧美地区解锁============= "
    MediaUnlockTest_HBONow ${1};
    MediaUnlockTest_BBC ${1};
	echo "======================================="
	echo "============大中华地区解锁============= "
	MediaUnlockTest_MyTVSuper ${1};
    MediaUnlockTest_BahamutAnime ${1};
    MediaUnlockTest_BilibiliChinaMainland ${1};
    MediaUnlockTest_BilibiliHKMCTW ${1};
    MediaUnlockTest_BilibiliTW ${1};
	echo "======================================="
	echo "============日本地区解锁=============== "	
	MediaUnlockTest_AbemaTV_IPTest ${1};
	MediaUnlockTest_HuluJP ${1};
    MediaUnlockTest_PCRJP ${1};
	MediaUnlockTest_UMAJP ${1};
	MediaUnlockTest_Kancolle ${1};
	echo "======================================="
	echo "============全球性平台解锁============= "	
    MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_Netflix ${1};
    MediaUnlockTest_YouTube_Region ${1};
    MediaUnlockTest_DisneyPlus ${1};
    GameTest_Steam ${1};
	echo "======================================="	
}

curl -V > /dev/null 2>&1;
if [ $? -ne 0 ];then
    echo -e "${Font_Red}Please install curl${Font_Suffix}";
    exit;
fi

jq -V > /dev/null 2>&1;
if [ $? -ne 0 ];then
    InstallJQ;
fi
echo " ** 正在测试IPv4解锁情况" && echo " ** 正在测试IPv4解锁情况" >> ${LOG_FILE};
echo "--------------------------------"
check4=`ping 1.1.1.1 -c 1 2>&1`;
if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
    MediaUnlockTest 4;
else
    echo -e "${Font_SkyBlue}当前主机不支持IPv4,跳过...${Font_Suffix}" && echo "当前主机不支持IPv4,跳过..." >> ${LOG_FILE};
fi

echo ""
echo -e " ${Font_SkyBlue}** 正在测试IPv6解锁情况${Font_Suffix} " && echo " ** 正在测试IPv6解锁情况" >> ${LOG_FILE};
check6=`ping6 240c::6666 -c 1 2>&1`;
if [[ "$check6" != *"unreachable"* ]] && [[ "$check6" != *"Unreachable"* ]];then
    MediaUnlockTest 6;
else
    echo -e "${Font_SkyBlue}当前主机不支持IPv6,跳过...${Font_Suffix}" && echo "当前主机不支持IPv6,跳过..." >> ${LOG_FILE};
fi
echo -e "";
echo -e "${Font_Green}本次测试结果已保存到 ${LOG_FILE} ${Font_Suffix}";
cat ${LOG_FILE} | PasteBin_Upload;
