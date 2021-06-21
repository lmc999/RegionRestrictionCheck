#!/bin/bash
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)";

disneyauth="grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Atoken-exchange&latitude=0&longitude=0&platform=browser&subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiNDAzMjU0NS0yYmE2LTRiZGMtOGFlOS04ZWI3YTY2NzBjMTIiLCJhdWQiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOnRva2VuIiwibmJmIjoxNjIyNjM3OTE2LCJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmRldmljZSIsImV4cCI6MjQ4NjYzNzkxNiwiaWF0IjoxNjIyNjM3OTE2LCJqdGkiOiI0ZDUzMTIxMS0zMDJmLTQyNDctOWQ0ZC1lNDQ3MTFmMzNlZjkifQ.g-QUcXNzMJ8DwC9JqZbbkYUSKkB1p4JGW77OON5IwNUcTGTNRLyVIiR8mO6HFyShovsR38HRQGVa51b15iAmXg&subject_token_type=urn%3Abamtech%3Aparams%3Aoauth%3Atoken-type%3Adevice"
disneyheader="authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84"
WOWOW_Cookie=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==3')
TVer_Cookie="Accept: application/json;pk=BCpkADawqM3ZdH8iYjCnmIpuIRqzCn12gVrtpk_qOePK3J9B6h7MuqOw5T_qIqdzpLvuvb_hTvu7hs-7NsvXnPTYKd9Cgw7YiwI9kFfOOCDDEr20WDEYMjGiLptzWouXXdfE996WWM8myP3Z"
Hulu_Content=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==5')
Hulu_Cookie="guid=2B3BACF5B121715649E5D667D863612E; _h_csrf_id=457b2280eef19f28fbcb2992d1de37048e4b4097e257f63f155ed929b6e53687; bm_mi=28704523FCC474F1A9AC5F8483E541FC~8E5oFWEIhwYwpkQpyPS1kZ6CB0Zokl5veAxjYf7O4/x1xVYo4YOC8WLNMo0ZKz96fPzQ7MOUKsNPtE+0+7fQMEU3Lbln4h8G2WsunkEZDcPsvSSfhOuSJWpFs74B8i62Ge3i1F08W0PubOounXiPCmfgJPxGnDSKxUq8T5stR8eDfabmhwboVvt+Gmrc7RrvV63lXrJY4Fr8y9uMCJVKUnbOskbfObLcam251LJxD6T2vuSPOjKmkI9TJ93F/OvXMClMmA09MTHZ4GWm0vzeHQ==; ak_bmsc=E82D53D196AE742B2B7A5A73EEC0D850~000000000000000000000000000000~YAAQti43F5D7nRd6AQAApng/LAydmW2LypR2XE27prXF3huCKjeK4MKN+Wdy9P6qBFw4PbuszpyFsY2SazEUG5A6L9eHfB/FhO71fA0z8pn2xEVmrOkSnlw7HIKpsHvLxwXJAVaB1b2C1mPEsxJXtrvG0QKrUzf2gP0iu15YKdlCVGEHs5eoV/J11aBNpw2AUdZ1bW4zed/ix6VDRq5yDCej7O+r7CSV3qbuCwmR2Sw7jYK4X0BtXhF5PsiEHIjN+41O7TMV+ooB7dRY96Y0frDdViBgViq8di99yPGgbZr88a00flqwKMFz89hka02lgzESrQI6nlLxVD78oJfKmb9db4kRU9k3msYl1qhZWflKmaucRPV07eV6RWii27W9BKVr0/OaCzaMwQB/LHqCmRAY; __utma=155684772.684658975.1624241987.1624241987.1624241987.1; __utmc=155684772; __utmz=155684772.1624241987.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmt=1; __utmb=155684772.1.10.1624241987; _ga=GA1.2.684658975.1624241987; _gid=GA1.2.138003965.1624241987; stc115168=tsa:1624241987497.203963452.98584127.9504090154979559.:20210621024947|env:1%7C20210722021947%7C20210621024947%7C1%7C1047148:20220621021947|uid:1624241987496.1200544265.72254.115168.1810957742.3:20220621021947|srchist:1047148%3A1%3A20210722021947:20220621021947; _gcl_au=1.1.2039255589.1624241988; _uetsid=84a93620d23211eb947f25585b965ddf; _uetvid=6c0fb310c8d711eba91e7f00bc7b8c6c; _scid=32c803fc-8be0-441f-885f-50f3d6406003; _sctr=1|1624204800000; _hulu_pgid=8396803; _hulu_uid=167194477; _hulu_e_id=iHI6sUwC0ZDJRQ218Yat7g; _hulu_bluekai_hashed_uid=0aaed4eecfceebd118abc89c11678718; _hulu_assignments=eyJ2MSI6W3siZSI6OTc5LCJ0IjoyNjk2LCJuIjoiaHVsdV8xMzU3OF93ZWxjb21lX2NvbnRyb2wifV19; _p_edit_token=JwysELYyqwYJ-otAhqGwxQ; _hulu_dt=g4rId3vFChPJIFepKv0l6yUq358-7WY9%2FWq2qIRKc8qfEUvlgQ--xQyvRy%2FhoqIoq832m7xXwwUwlG9YoRnJzjB2yKchSxZfMgjLnOm_En0lhJaOMnL1UcnvDVhHXxsrJv0FB_wCdnhBJeBbuJ6GUdtRcNuTwlamtrBLkN5xLvHh%2Fcl5C1O83l6xnDYcDIsp4vPRoyH%2F1UYcDwKKdL4EjTcaARazy9YuRzSeimJkkBhxAXgyYIQZjar3kVmnQ1lXhj35DyZOAFMJ_irXlAGL5lTsazF8qp7II7ctazxeWRZwWPXk_vqxObLThpf7sPyLrAOE6TvxZyj934NKaKN6gpmFvHq4GM94ly%2FK581sDdHwVueKTUcpJKe6vdy3RbZ8XY5JR4iR%2FSFNWWejrxoPoyyoB1GP_K8DWELg5KN56o8R3cEdcQXsWlxK4jVLXgCXlqty%2Fa6riovxGP2KsPLqW7E83tEraeY2tWaADbVoApsKL2NSnng2zPIxwE5yeNDJonR29Hc2ptZDuEXolmuYiAzUD2GnZl5G24OIWZXFBv4zP4PYxDGM2gFl%2FqM6TjGguGi_fUPXThT_rvrBD8WLpO94AufgzfJCbxC4vHKQ%2FwW6M3WeB1RCroVGz97LOxCUh%2FbGYlvYSBYFpyNfL3oIFqEmxqOIdieWEwzA4Ho0hfCqs%2FlhassrZqLXOa0DrGkAv1aXGL0VH9XCnAJG3mqb37tFK74h7S7H5L023yuxK4diqq5jIhXXnNlLqxSmGujmQTcehNTXfG_rF8voIGjekxx722MIRMU3fHqZ5zKX4tz8BL2PYdGh3x9TmzJibnCBIqo6i2lfP5BJB78zkspalr%2F9C1ai6QEIqHHmsQAm2NffZqEGu6PXwen5NGBIeePFSkAccoRNpZeAy7VCUKykCGdicu0jB3A-; XSRF-TOKEN=02c375da-1482-4c50-8a62-3e1905ff2432; _gat_hulu1=1; _hulu_pid=5080052296; _hulu_pname=joe%20biden%20america; _hulu_is_p_kids=0; _hulu_session=91UyDT0aYsIP6rKwG40b8EXz9DY-gb3WVQ5l_XqZSD2LBvW_%2Fw--TbLQ90QEZePwPSu9LQDNWF4Wu85wTrqcuJXpUPVO8OB7DaDnFtyBz_NpKxzVEnUACLbfMnEvDdIWCZ5SrmW_Fr08fo1OqmcYuPh5ZNEaCZI87wAk4mEoipDrK6vLhhNJDvTy0a7W7mb2dLMThOE3TSkbjQ2AVkd3YpJ2yt7YcduNBceuCUKk_YBl6a5Fn2FiONrZKwYzZXNW3IcA9h8RZni7zyLkBc6N49y%2FymqqF2nyjtLanmsf0zfLDxLHmw5SNLOwWZf_6ic5KZ8VgNrnx2moDVMSmU5Sn9rVWaImW1kjnQPNCwvhLJP0mddKMa0b%2FJdDqdzcrrUTnSSlrkAcRDUHeNbTd9LNbA66DUTlAnu4bd8F1jgjFwB6QEIbXsPaspkNgCQ2DEUgPbSf9SElwD4YLRNasvbXluR_lPSIKgdFzgktczaLCtpZOputtQR5dm6uekFjUmy40STPBq1aCG6AgqulStiGlgWwjo7xmpzdVQUrqWnmlhlnuYbYUxC3JTNzhNcfw5jpPz%2FFJJs8drNY1ByFJhNFghnLywoPVVpu2782fchQATWmH_YbKc4p8cEstwTlCsuGlkdrO3nf0RRvOCCmZPYQn40cWUx45BU9PbSKWAEt21%2FDPuqNw4MxwCkOXPXFOHCwDTu3aZeHZ4LJ9CsDwqTJdyn49N3G0oV6tIKAp%2FoUI504UDClLTghiKmLeTPq_6TKw7neebBPpuT7nOAmmGSu2O2DBmDyHUzFIaz2pX1q1cS1_PEowbs%2FUKM0uMlkzdiLQ3aBlJwknInqGfax%2FmSeh73phnKolwpSK_CDW4tKJ_zcE1hUrvaT_21zRhtpMpyCoxlqDFT6WTJpHhIt5L8tRHlSiyOiZqX9N2pr76ugnRIk6I1B2kDuafMprDvqkiDgNSWrld95LTJskxcZ2vNTi9LlHVyid82Af1lavt1IB8aBFyZbQMLl80fdjIp3mhCNfbAg0aYKkBifuNsv4WkFXiozBzIMWahG1I3mJTqjRlufKUkYUY_tZrzmsfq4kFZU2n2ufg0QxVfA8eEc914dgnnZPBuR8T0-; AMCVS_0A19F13A598372E90A495D62%40AdobeOrg=1; AMCV_0A19F13A598372E90A495D62%40AdobeOrg=-408604571%7CMCIDTS%7C18800%7CMCMID%7C57413330304479553574529114000647347829%7CMCAAMLH-1624846877%7C11%7CMCAAMB-1624846877%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCCIDH%7C-1857806863%7CMCOPTOUT-1624249277s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C4.6.0; _hulu_metrics_context_v1_=%7B%22cookie_session_guid%22%3A%2264a32034a29fb3e1868455e1d0c3d1e3%22%2C%22referrer_url%22%3A%22https%3A%2F%2Fwww.hulu.com%2Fhub%2Fhubs%2F%22%2C%22curr_page_uri%22%3A%22app%3Awatch%22%2C%22primary_ref_page_uri%22%3A%22urn%3Ahulu%3Ahub%3Ahome%22%2C%22secondary_ref_page_uri%22%3A%22www.hulu.com%2Fwelcome%22%2C%22curr_page_type%22%3A%22watch%22%2C%22primary_ref_page_type%22%3A%22home%22%2C%22secondary_ref_page_type%22%3A%22landing%22%2C%22secondary_ref_click%22%3Anull%2C%22primary_ref_click%22%3A%22Kick-Ass%22%2C%22primary_ref_collection%22%3A%22282%22%2C%22secondary_ref_collection%22%3Anull%2C%22primary_ref_collection_source%22%3A%22heimdall%22%2C%22secondary_ref_collection_source%22%3Anull%2C%22ref_collection_position%22%3A4%7D; _persisted_HEM=0e047fa12aee64bfb7087439257b48412d2c99284f661dd5597b947404c92c20; utag_main=v_id:017a2c5dde9a001fdb6dbc12936a03073001c06b00bd0$_sn:1$_ss:0$_st:1624243903349$ses_id:1624241987227%3Bexp-session$_pn:2%3Bexp-session$device_category:desktop%3Bexp-session$_prevpage:%2Fwatch%2F1ed6c0d7-2bc0-4b8a-8639-74fa7361a5d8%3Bexp-1624245703358$k_sync_ran:1%3Bexp-session$krux_sync_session:1624241987227%3Bexp-session$g_sync_ran:1%3Bexp-session$dc_visit:1$dc_event:1%3Bexp-session$dc_region:ap-east-1%3Bexp-session$hhid:9e25553e5dbba8f507f6b1c36a0ed17a741aa7cdd6ce03cb213d927fcdb22ffc%3Bexp-session; metrics_tracker_session_manager=%7B%22idle_time%22%3A1624242103392%2C%22session_seq%22%3A59%2C%22session_id%22%3A%222B3BACF5B121715649E5D667D863612E-49257fed-13fe-4a5a-b4ea-e545b82335dd%22%2C%22creation_time%22%3A1624241984744%2C%22visit_count%22%3A1%7D; bm_sv=3F0D41806D255DA2AB3280B681FA4630~kOV8lDWbANrCvHq0EeByqkCojQr9SUjssbFW8AXfPaquxDA4FNTGjzVCZ3tQ2Z5vQMuIR/dplyn1UeSVOlXA5mudUvuYb5PNCSVr8nmrkhqkosSY7ZSj92gU4YBGsJIqnvWHpGmmtIsjl/8gcNxWUw=="

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

local_ipv4=$(curl -4 -s --max-time 20 ip.sb)
local_ipv6=$(curl -6 -s --max-time 20 ip.sb)
if [ -n "$local_ipv4" ]
	then
		local_isp=$(curl -s -4 https://api.ip.sb/geoip/${local_ipv4} | cut -f1 -d"," | cut -f4 -d '"')
	else
		local_isp=$(curl -s -6 https://api.ip.sb/geoip/${local_ipv6} | cut -f1 -d"," | cut -f4 -d '"')
fi		

clear;
echo -e "流媒体平台及游戏区域限制测试";
echo ""
echo -e "${Font_Green}项目地址${Font_Suffix} ${Font_Yellow}https://github.com/lmc999/RegionRestrictionCheck ${Font_Suffix}";
echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/gameaccelerate ${Font_Suffix}";
echo ""
echo -e " ** 测试时间: $(date)";
echo ""



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

function MediaUnlockTest_BBC() {
    echo -n -e " BBC:\t\t\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://ve-dash-uk.live.cf.md.bbci.co.uk/`;
    if [ "${result}" = "000" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        elif [ "${result}" = "403" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        elif [ "${result}" = "404" ]; then
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
    else
        echo -n -e "\r BBC:\t\t\t\t\t${Font_Red}Failed (Unexpected Result: $result)${Font_Suffix}\n"
    fi
}

function MediaUnlockTest_Netflix() {
    echo -n -e " Netflix:\t\t\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.netflix.com/" 2>&1`;
    if [ "$result" == "Not Available" ];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n"
        return;
    fi
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    local result=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80018499" 2>&1`;
    if [[ "$result" == *"page-404"* ]] || [[ "$result" == *"NSEZ-403"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return;
    fi
    
    local result1=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70143836" 2>&1`;
    local result2=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80027042" 2>&1`;
    local result3=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70140425" 2>&1`;
    local result4=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70283261" 2>&1`;
    local result5=`curl -${1} --user-agent "${UA_Browser}"-sL "https://www.netflix.com/title/70143860" 2>&1`;
    local result6=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70202589" 2>&1`;
    
    if [[ "$result1" == *"page-404"* ]] && [[ "$result2" == *"page-404"* ]] && [[ "$result3" == *"page-404"* ]] && [[ "$result4" == *"page-404"* ]] && [[ "$result5" == *"page-404"* ]] && [[ "$result6" == *"page-404"* ]];then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}[N] Mark Only${Font_Suffix}\n"
        return;
    fi
    
    local region=`tr [:lower:] [:upper:] <<< $(curl -${1} --user-agent "${UA_Browser}" -fs --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
    
    if [[ ! -n "$region" ]];then
        region="US";
    fi
    echo -n -e "\r Netflix:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n"
    return;
}

function MediaUnlockTest_YouTube_Region() {
    echo -n -e " YouTube Region:\t\t\t->\c";
    local result=`curl --user-agent "${UA_Browser}" -${1} -sSL "https://www.youtube.com/" 2>&1`;
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return;
    fi
    
    local result=`curl --user-agent "${UA_Browser}" -${1} -sL "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4`;
    if [ -n "$result" ]; then
        echo -n -e "\r YouTube Region:\t\t\t${Font_Green}${result}${Font_Suffix}\n"
        return;
    fi
    
    echo -n -e "\r YouTube Region:\t\t\t${Font_Green}US${Font_Suffix}\n"
    return;
}

function MediaUnlockTest_DisneyPlus() {
    echo -n -e " DisneyPlus:\t\t\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://global.edge.bamgrid.com/token" 2>&1`;
    
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
		region=$(curl -${1} -s https://www.disneyplus.com | grep 'region: ' | awk '{print $2}')
		if [ -n "$region" ]
			then
				echo -n -e "\r DisneyPlus:\t\t\t\t${Font_Green}Yes (Region: $region)${Font_Suffix}\n"
				return;
			else
				website=$(curl -${1} --user-agent "${UA_Browser}" -fs --write-out '%{redirect_url}\n' --output /dev/null "https://www.disneyplus.com")
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
    local result=$(curl -${1} -s --max-time 30 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' https://startup.core.indazn.com/misl/v5/Startup  | python -m json.tool 2> /dev/null | grep '"GeolocatedCountry":' | awk '{print $2}' | cut -f2 -d'"');
    
	if [[ "$result" == "curl"* ]];then
        	echo -n -e "\r Dazn:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    	fi
	
	if [ -n "$result" ]; then
		if [[ "$result" == "null," ]];then
			echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
			return;
        else
			result=$(echo $result | tr [:lower:] [:upper:])
			echo -n -e "\r Dazn:\t\t\t\t\t${Font_Green}Yes (Region: ${result})${Font_Suffix}\n"
			return;
		fi
	else
		echo -n -e "\r Dazn:\t\t\t\t\t${Font_Red}Unsupport${Font_Suffix}\n"
		return;

    fi
    return;
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
    local result=$(curl -${1} ${ssll} -s --max-time 30 -X POST -H "Content-Type: application/json" -d '{"callerReferenceNo":"20210603233037","productId":"202009041154906","contentId":"202009041154906","contentType":"Vod","mode":"prod","PIN":"password","cookie":"3c2c4eafe3b0d644b8","deviceId":"U5f1bf2bd8ff2ee000","deviceType":"ANDROID_WEB","format":"HLS"}' "https://api.viu.now.com/p8/3/getVodURL" | python -m json.tool 2> /dev/null | grep 'responseCode' | awk '{print $2}' | cut -f2 -d'"');
    
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
	
	echo -n -e "\r Viu.TV:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
	return;

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
    local tmpresult=$(curl -${1} -s --max-time 30 -H "Content-Type: application/json" -d '{"meta_id":71885,"vuid":"3b64a775a4e38d90cc43ea4c7214702b","device_code":1,"app_id":1}' https://api.paravi.jp/api/v1/playback/auth | python -m json.tool 2> /dev/null);
	
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} -s --max-time 30 -b "${WOWOW_Cookie}" -H "x-wod-app-version: 91.0.4472.106" -H "x-wod-model: Chrome" -H "x-wod-os: Windows" -H "x-wod-os-version: 10" -H "x-wod-platform: Windows"  "https://wod.wowow.co.jp/api/streaming/url?contentId=&channel=Live");
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} -s --max-time 30 -H "${TVer_Cookie}" "https://edge.api.brightcove.com/playback/v1/accounts/5102072603001/videos/ref%3Afree_episode_code_8121");
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 30 "https://hamivideo.hinet.net/api/play.do?id=OTT_VOD_0000249064&freeProduct=1");
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
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 30 -X POST -d 'value=D33jXJ0JVFkBqV%2BZSi1mhPltbejAbPYbDnyI9hmfqjKaQwRQdj7ZKZRAdb16%2FRUrE8vGXLFfNKBLKJv%2BfDSiD%2BZJlUa5Msps2P4IWuTrUP1%2BCnS255YfRadf%2BKLUhIPj' "https://api2.4gtv.tv//Vod/GetVodUrl3");
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
    local result=`curl --user-agent "${UA_Dalvik}" -${1} -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://www.sling.com/`;
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
    local result=$(curl -${1} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://pluto.tv/" | grep 'thanks-for-watching');
    
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
    local result=$(curl -${1} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.hbomax.com/" | grep 'geo-availability');
    
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
    local result=$(curl -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://simulcast.itv.com/playlist/itvonline/ITV");
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
    curl -${1} -s -I "https://www.iq.com/" > /tmp/iqiyi
    
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
    echo -n -e " Hulu:\t\t\t\t\t->\c";
    local tmpresult=$(curl --user-agent "${UA_Browser}" -${1} ${ssll} -s --max-time 30 -X POST https://play.hulu.com/v6/playlist -d "${Hulu_Content}" -H "Content-type: application/json" -b "$Hulu_Cookie");
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	checkfailed=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep '"code":' | cut -f4 -d'"')
	if [[ "$checkfailed" == "BYA-403-013" ]];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	elif [[ "$checkfailed" == "BYA-403-011" ]];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	 	
	fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep 'play.hulu.com' > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
	fi

	echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
	return;		
	
}

function MediaUnlockTest_encoreTVB() {
    echo -n -e " encoreTVB:\t\t\t\t->\c";
    tmpresult=$(curl -${1} ${ssll} -s --max-time 30 -H "Accept: application/json;pk=BCpkADawqM2Gpjj8SlY2mj4FgJJMfUpxTNtHWXOItY1PvamzxGstJbsgc-zFOHkCVcKeeOhPUd9MNHEGJoVy1By1Hrlh9rOXArC5M5MTcChJGU6maC8qhQ4Y8W-QYtvi8Nq34bUb9IOvoKBLeNF4D9Avskfe9rtMoEjj6ImXu_i4oIhYS0dx7x1AgHvtAaZFFhq3LBGtR-ZcsSqxNzVg-4PRUI9zcytQkk_YJXndNSfhVdmYmnxkgx1XXisGv1FG5GOmEK4jZ_Ih0riX5icFnHrgniADr4bA2G7TYh4OeGBrYLyFN_BDOvq3nFGrXVWrTLhaYyjxOr4rZqJPKK2ybmMsq466Ke1ZtE-wNQ" -H "Origin: https://www.encoretvb.com" "https://edge.api.brightcove.com/playback/v1/accounts/5324042807001/videos/6005570109001");
    
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

	

function MediaUnlockTest() {
	echo ""	
	echo "=============欧美地区解锁============= "
	MediaUnlockTest_HuluUS ${1};
	MediaUnlockTest_HBONow ${1};
	MediaUnlockTest_HBOMax ${1};
	MediaUnlockTest_SlingTV ${1};
	MediaUnlockTest_PlutoTV ${1};
	MediaUnlockTest_encoreTVB ${1};
	MediaUnlockTest_BBC ${1};
	MediaUnlockTest_ITVHUB ${1};
	MediaUnlockTest_Channel4 ${1};
	echo "======================================="
	echo "============大中华地区解锁============= "
	MediaUnlockTest_MyTVSuper ${1};
	MediaUnlockTest_NowE ${1};
	MediaUnlockTest_ViuTV ${1};
	MediaUnlockTest_4GTV ${1};
	MediaUnlockTest_HamiVideo ${1};
	MediaUnlockTest_BahamutAnime ${1};
	MediaUnlockTest_BilibiliChinaMainland ${1};
	MediaUnlockTest_BilibiliHKMCTW ${1};
	MediaUnlockTest_BilibiliTW ${1};
	echo "======================================="
	echo "============日本地区解锁=============== "	
	MediaUnlockTest_AbemaTV_IPTest ${1};
	MediaUnlockTest_Paravi ${1};
	MediaUnlockTest_unext ${1};
	MediaUnlockTest_HuluJP ${1};
	MediaUnlockTest_TVer ${1};
	MediaUnlockTest_wowow ${1};
	MediaUnlockTest_PCRJP ${1};
	MediaUnlockTest_UMAJP ${1};
	MediaUnlockTest_Kancolle ${1};
	echo "======================================="
	echo "============全球性平台解锁============= "	
	MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_Netflix ${1};
	MediaUnlockTest_DisneyPlus ${1};
	MediaUnlockTest_YouTube_Region ${1};
	MediaUnlockTest_iQYI_Region ${1};
	GameTest_Steam ${1};
	echo "======================================="	
}

curl -V > /dev/null 2>&1;
if [ $? -ne 0 ];then
    echo -e "${Font_Red}Please install curl${Font_Suffix}";
    exit;
fi


echo -e " ${Font_SkyBlue}** 正在测试IPv4解锁情况${Font_Suffix} "
echo "--------------------------------"
echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp}${Font_Suffix} "
check4=`ping 1.1.1.1 -c 1 2>&1`;
if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
    MediaUnlockTest 4;
else
    echo -e "${Font_SkyBlue}当前主机不支持IPv4,跳过...${Font_Suffix}"
fi

echo ""

check6=`ping6 240c::6666 -c 3 -w 3 2>&1`;
if [[ "$check6" != *"unreachable"* ]] && [[ "$check6" != *"Unreachable"* ]];then
	echo -e " ${Font_SkyBlue}** 正在测试IPv6解锁情况${Font_Suffix} "
	echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp}${Font_Suffix} "
    MediaUnlockTest 6;
else
    echo -e "${Font_SkyBlue}当前主机不支持IPv6,跳过...${Font_Suffix}"
fi
echo -e "";
echo -e "${Font_Green}本次测试已结束，感谢使用此脚本 ${Font_Suffix}";
