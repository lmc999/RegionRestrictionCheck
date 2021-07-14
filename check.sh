#!/bin/bash
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)";

disneyauth="grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Atoken-exchange&latitude=0&longitude=0&platform=browser&subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiNDAzMjU0NS0yYmE2LTRiZGMtOGFlOS04ZWI3YTY2NzBjMTIiLCJhdWQiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOnRva2VuIiwibmJmIjoxNjIyNjM3OTE2LCJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmRldmljZSIsImV4cCI6MjQ4NjYzNzkxNiwiaWF0IjoxNjIyNjM3OTE2LCJqdGkiOiI0ZDUzMTIxMS0zMDJmLTQyNDctOWQ0ZC1lNDQ3MTFmMzNlZjkifQ.g-QUcXNzMJ8DwC9JqZbbkYUSKkB1p4JGW77OON5IwNUcTGTNRLyVIiR8mO6HFyShovsR38HRQGVa51b15iAmXg&subject_token_type=urn%3Abamtech%3Aparams%3Aoauth%3Atoken-type%3Adevice"
disneyheader="authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84"
WOWOW_Cookie=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==3')
TVer_Cookie="Accept: application/json;pk=BCpkADawqM3ZdH8iYjCnmIpuIRqzCn12gVrtpk_qOePK3J9B6h7MuqOw5T_qIqdzpLvuvb_hTvu7hs-7NsvXnPTYKd9Cgw7YiwI9kFfOOCDDEr20WDEYMjGiLptzWouXXdfE996WWM8myP3Z"
Hulu_Content=$(curl -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies | awk 'NR==5')
Hulu_Cookie="guid=2B3BACF5B121715649E5D667D863612E; geo=23.1192247%26113.2199658%261624328812537; bm_mi=4C25CDD2DC8430DC02069741E81D2796~8E5oFWEIhwYwpkQpyPS1kd5Oxq32nwP/e1HRF/LA3TErxQv0fssNlOhJZXGBXF09waXlky1Wx+DwHpg3ht4WGYmfK75YgIBUWQ4NVfNaP71P63ebjwjlmgkCECaCDbLycTx7lzZ8KkltfKoMJzTiA1ckol0vIPbJ36JEINvvPFCzKMRCINVGoAgVGBHHab6NhrxekbHTXEDQmMlYUCuDxP2AdpapA07ZbM3iXOCSBVGY1507etR5jm7iRYz1MgfbVqs0/A64PSO0vGAlj+xpfQ==; ak_bmsc=9DD32F8E0FEE8C4A296643F4C579651C~000000000000000000000000000000~YAAQXvEoFzWjgmZ6AQAA2VO8ogzViE7ehI+1vDit6SxHCmqhNDhIZQLv6h5u0bWHtn5EwJsAtQCq0CtsDV6sc/TQ+G4CbT4YEsOZAXmCQsp0ippE6d5ewxAqrdh2ch2s1QyZhuUV/frRIK0XsRTHy9AHQBQUUpWL08fsoQYccItWXEnRd9cNMVbAYqfEesXgJkHp2Q7wWSrO7XjzXjiBai5P+HKMC/9FtLoJICHNW8v3ZM4rhGhRwsy8ZXKL2jc8SJhfUAy2q5TuKEovNOEvnNiH49ghJZ1bNlC6l2Gy+Dvnrhqm4YSZ3+I6oxiQm88zLVzzXSSqDFgXD6GXJhlS7+l7WcgeKevgt208kQ4+uPfNAlnfdteIY3PsBsWgzo2kSCP01lKTxyzT98heJ6kwoqIHymE/JZoTwOAVN3Do6hYJ; _h_csrf_id=94ff284b67294f7b20f55194333b95ca954a67113e41591efe6f5c456b096a1a; __utmz=155684772.1626228003.1.1.utmcsr=secure.hulu.com|utmccn=(referral)|utmcmd=referral|utmcct=/; __utmc=155684772; __utma=155684772.1604597846.1626228003.1626228003.1626228003.1; __utmt=1; __utmb=155684772.1.10.1626228003; _ga=GA1.2.1604597846.1626228003; _gid=GA1.2.596802233.1626228005; _uetsid=e078cfd0e44611eb9c261beb2b9c88c7; _uetvid=6c0fb310c8d711eba91e7f00bc7b8c6c; _gcl_au=1.1.863957581.1626228005; stc115168=tsa:1626228004608.694356194.7563491.8736557083165977.4:20210714023004|env:1%7C20210814020004%7C20210714023004%7C1%7C1047148:20220714020004|uid:1626228004608.2043178356.0070043.115168.936380343.:20220714020004|srchist:1047148%3A1%3A20210814020004:20220714020004; _scid=08e3448c-c48f-4793-bc46-8d1c6becd2ff; _sctr=1|1626192000000; _hulu_pgid=8396803; _hulu_uid=75153748; _hulu_e_id=G9zN0tHhlfDFMSxvk3d_sg; _hulu_bluekai_hashed_uid=42adca2c19964a87aa8b704f917cac47; _hulu_assignments=eyJ2MSI6W3siZSI6MTAwNCwidCI6Mjc1MiwibiI6Imh1bHVfMTMyOTRfd2VsY29tZXY2X2xpdmVfc2VjdGlvbiJ9XX0%3D; _p_edit_token=hiznz26-n2U7E3tlbaxCzg; _hulu_dt=V8mh0aYKGMIijSEY7j_uySCTEiI-yq8sbpmTiJJCRmH4qBES4Q--Bg397ehN5PJ3fKAmvuNw8iyjGU0kemvcYDdw8Nc_hWuEdIE0H5UIoaIGDblMdCDrW%2FDPj6YFfFNL6zeAH4ZrViXs67gteel8_kHTA06DAwrKk7xLwTXPteJqu2bXSUE5c03XW5qxJKtlLqDscF2qmvoIk5HhU8qMxPcEXpuVk_uMY6323so_eLWUet5741k1LXp7Wej13BTF1qSuLy5711%2FhwByxRIigW7rtWUwskuZ7vGv7JYUJ4iTKZDuNTXy386JTl5aGybRZvkKE6a3Vt4jUiCS1DopGxFw9scuLxuDDs5KGDiRLCGF7JXYqTxoq3tzIdTyxWAFqMSmStwHjs5K4ANM5gY1jzn84FjlobDBLhQIEJLdmCt9Uo_bGg1_Ze8XivY_o_hGe_wlAb2UL1T45t7LwJz1WnIg3pYMzXs4YlL7t7xHwxXnoLemDBu1O63UeQN_7qhRsNi%2F1%2FW2uiMwPSUHVzGimqWZ8N8KEQpV6g0WTjnXeB33b0OcNGHbqRstGMXMksCaJpIkVEUMuDyQ_d9V3eCwJIZzwS6Jn8EdowwJhJXKapmfs7oo%2FjJkKbIHE7lHItr0awhDHeX%2Fm0MuhgaNjqi6VMGdtzeVGUs7zSOonfET%2Fk8x6udsJnr_rc0wKaZ6oW0ZJw5HwvAMxTb4A%2FkrD8Ong_47U_XXe76o7suoThhz5aOBylbwpxlNpTJUP%2FeTMAceA9QGGYJ_fIXMpqsszrj7E6AEypDYwFGaTWe6G1AJLQYcToJyEOOXCpBLrPy%2FNMXE6373bdEoUov3HgykzuS7u8a%2F_38sMnvMD28T9ObmnNX20EMtMSuIHJxVA0XI02rnkvnMCBso544MNXdN0W4N3oKk6n%2F1%2FnZo-; _persisted_HEM=a70a64e3554a282ec7ee4dcfdde40432c561cf776ff088e86e76ee381deb7e5f; _hulu_session=dRF%2Fgbm984Fd8kCRDlJOcL98E10-rDZ_nvNq3sGZUgucVafpjA--n4BeKTDYguRmlwEAbalKDFqfeIXuPXxnnklzpBoOkmKbk3W_crWiNoFh3ZR_4V_ZqtokEop2LvjwBRlCDqMJ_wkaIP9SSL32Tdposz9E4GTPMR0hXgNDiR6zwKIOhv6iA%2FvM6USQE%2FKsfIKdiAJUuLb3CryVcxeu8EY3kfkKE_G57YgG4NqijKfDgT0RywT6y50j7zyP0LFshLIbdTrL4sIyDznCyqrc5yfFe5Ke3MYsQWOzX7nRU9b%2FqInpmDFzXigJVnlrXDG7363iqHIoLbvlH7z3%2FQUjpu%2FfI3%2F%2FkqVGa1rwO20ss9faU9h8zbIfkGId2gicAQZmmqgvo0O6xcFLyrVOZZ6MiyvPja0HFeTbvylJfCcRV3abc6UsSbzpdTrYllE3Ml9v6_gEj3xTMQzTNhZSh64wH1w0ktWiA96ubCEqjBX5YChtbH31xw8i5K4OmRMg53lBIDe7zIRJQ_4kbn7QoaBaZgBUbZcNam_rE3HNnew2jwUNxSWjFyRX%2FVT6tCnUjK%2FAqH4q8DgXfa4esjA71WUS3Moqfmw_dK7cKlVkgLy2nsSn79v7jI7nk8TXAnrl_CSGyHTGnTXpsk3okYeIVVPpcden9aKd1gShDGH0HvP0kNN325M9h4AT6oSEwfcW9EzdSoBtUa8OeO545fOdsfrY9KRnO%2FZkrxAeR5GDubcxZqqMFHJujdo4d9IywyJsVPt%2FV7qdxR_WQE5pUIveWlEQG9UfVYQMtnz2SJyK5q1ebXsCHDELAnVvSiw2ogw_RNfN_vYu3X4NG6njS4EzHOk%2Feyo249Utk1SKdKLQC1Fd93vTDH6GdAZwimhy8v4zePJtMRBhaV4t5LMpPQb6s8TyZsv0otoQGp41sTPESWm%2FCdveNwZWLz4quVArE106BNcKjsXMCLsmqrzvpHRIoivdVPIp2pK9EWfdY6TCyDKPGiE01LEtHXggvXZ2p4EsSleVflcFYuGTdASVm4H1BUZ6hSHun6xbUi5i2p548B0c3SjhxlLH9M74ui6j0J1Wa2UzTuMrbi057Qa0Hh_zvmNzdl5UgF0tfKiBSLuOQqD4LpIGgHbqcC6v; _hulu_pname=Sam; _hulu_is_p_kids=0; _hulu_pid=75153748; _hulu_pprotect=1626228081851; XSRF-TOKEN=9d2a3f8a-5ef8-4ed0-a2a5-119d8bede9bc; AMCVS_0A19F13A598372E90A495D62%40AdobeOrg=1; AMCV_0A19F13A598372E90A495D62%40AdobeOrg=-408604571%7CMCIDTS%7C18823%7CMCMID%7C57413330304479553574529114000647347829%7CMCAAMLH-1626832948%7C11%7CMCAAMB-1626832948%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCCIDH%7C-1857806863%7CMCOPTOUT-1626235348s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C4.6.0; _gat_hulu1=1; _hulu_metrics_context_v1_=%7B%22cookie_session_guid%22%3A%22a66c871839a0b2d30680722f2b327c89%22%2C%22referrer_url%22%3A%22https%3A%2F%2Fsecure.hulu.com%2F%22%2C%22curr_page_uri%22%3A%22app%3Awatch%22%2C%22primary_ref_page_uri%22%3A%22d76d6361-3fbf-4842-8dd7-e05520557280%22%2C%22secondary_ref_page_uri%22%3A%22urn%3Ahulu%3Ahub%3Ahome%22%2C%22curr_page_type%22%3A%22watch%22%2C%22primary_ref_page_type%22%3A%22series%22%2C%22secondary_ref_page_type%22%3A%22home%22%2C%22secondary_ref_click%22%3A%22Rick%20and%20Morty%22%2C%22primary_ref_click%22%3A%22Rick%20and%20Morty%22%2C%22secondary_ref_collection%22%3A%224169%22%2C%22secondary_ref_collection_source%22%3A%22heimdall%22%2C%22primary_ref_collection%22%3A%22vod_items%22%2C%22primary_ref_collection_source%22%3A%22heimdall%22%2C%22ref_collection_position%22%3A0%7D; utag_main=v_id:017aa2be0f840015fb13df46605103073001c06b00bd0$_sn:1$_ss:0$_st:1626229994936$ses_id:1626228002694%3Bexp-session$_pn:5%3Bexp-session$device_category:desktop%3Bexp-session$_prevpage:%2Fwatch%2Fea0def9a-afa3-4371-b126-964e1c6bea89%3Bexp-1626231794950$k_sync_ran:1%3Bexp-session$krux_sync_session:1626228002694%3Bexp-session$g_sync_ran:1%3Bexp-session$dc_visit:1$dc_event:1%3Bexp-session$dc_region:ap-east-1%3Bexp-session$hhid:97bbd4220d4676b6ecc08bf559cb6a3b2949dd818e257fd752ec664122ee94bd%3Bexp-session$hpid:97bbd4220d4676b6ecc08bf559cb6a3b2949dd818e257fd752ec664122ee94bd%3Bexp-session; bm_sv=6B36A16A35FD6CFD2C3AB0AC13443E59~kOV8lDWbANrCvHq0EeByqtGTNFJ7jEOyoLElUsfLC+Koo+6nO1REuA6F2hA9UMlERQ9Lp26Wv5XW6gQEaPdnRrrmegYs5nzak+bQf6aDApe/wSN9X+Syk+RCGJrVYZt6qp48O+XK29RQgXAKXu5HLJBBkB0a4R12Qni3fHy8yks=; metrics_tracker_session_manager=%7B%22session_id%22%3A%222B3BACF5B121715649E5D667D863612E-5dd43c62-02cd-40eb-981d-a87e06bb0e88%22%2C%22creation_time%22%3A1626227999982%2C%22visit_count%22%3A1%2C%22session_seq%22%3A108%2C%22idle_time%22%3A1626228195024%7D"

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
				ln -s $python3_patch /usr/bin/python
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

local_ipv4=$(curl -4 -s --max-time 30 ip.sb)
local_ipv6=$(curl -6 -s --max-time 20 ip.sb)
if [ -n "$local_ipv4" ]
	then
		local_isp=$(curl -s -4 --max-time 30 https://api.ip.sb/geoip/${local_ipv4} | cut -f1 -d"," | cut -f4 -d '"')
	else
		local_isp=$(curl -s -6 --max-time 30 https://api.ip.sb/geoip/${local_ipv6} | cut -f1 -d"," | cut -f4 -d '"')
fi		


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
    local result=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://pluto.tv/" | grep 'thanks-for-watching');
    
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
    local result=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.hbomax.com/" | grep 'geo-availability');
    
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
	else
		echo -n -e "\r Hulu:\t\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
		return;	
	fi

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

function MediaUnlockTest_Molotov(){
    echo -n -e " Molotov:\t\t\t\t->\c";
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://fapi.molotov.tv/v1/open-europe/is-france");
	if [[ "$tmpresult" == "curl"* ]];then
        	echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        	return;
    fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep 'false' > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -n -e "\r Molotov:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
		return;	
	fi
	
	echo $tmpresult | python -m json.tool 2> /dev/null | grep '"true"' > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -n -e "\r Molotov:\t\t\t\t${Font_Green}Yes${Font_Suffix}\n"
		return;	
	else
		echo -n -e "\r Molotov:\t\t\t\t${Font_Red}Failed${Font_Suffix}\n"
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 "https://www.nicovideo.jp/watch/so23017073");
    if [ "$tmpresult" = "curl"* ]; then
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
    local tmpresult=$(curl -${1} -s -H "Accept-Language: en" "https://www.youtube.com/premium")
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

function MediaUnlockTest_BritBox() {
    echo -n -e " BritBox:\t\t\t\t->\c";
    local result=$(curl -${1} ${ssll} -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.britbox.com/" | grep 'locationnotsupported');
    
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
    
	local result=$(echo $tmpresult | grep '"currentTerritory":' | sed 's/.*"currentTerritory//' | cut -f3 -d'"' | head -n 1)
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
    local tmpresult=$(curl -${1} ${ssll} -s --max-time 30 -X POST "https://www.LiTV.tv/vod/ajax/getUrl" -d '{"type":"noauth","assetId":"vod44868-010001M001_800K","puid":"6bc49a81-aad2-425c-8124-5b16e9e01337"}'  -H "Content-Type: application/json");
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

function US_UnlockTest() {
	echo "=============美国地区解锁=============="
	MediaUnlockTest_HuluUS ${1};
	MediaUnlockTest_HBONow ${1};
	MediaUnlockTest_HBOMax ${1};
	MediaUnlockTest_ParamountPlus ${1};
	MediaUnlockTest_PeacockTV ${1};
	MediaUnlockTest_SlingTV ${1};
	MediaUnlockTest_PlutoTV ${1};
	MediaUnlockTest_encoreTVB ${1};
	echo "======================================="
}	

function EU_UnlockTest() {
	echo "=============欧洲地区解锁=============="
	MediaUnlockTest_BritBox ${1};
	MediaUnlockTest_ITVHUB ${1};
	MediaUnlockTest_Channel4 ${1};
	MediaUnlockTest_BBCiPLAYER ${1};
	MediaUnlockTest_Molotov ${1};
	echo "======================================="
}	
	
function HK_UnlockTest(){	
	echo "=============香港地区解锁=============="
	MediaUnlockTest_MyTVSuper ${1};
	MediaUnlockTest_NowE ${1};
	MediaUnlockTest_ViuTV ${1};
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
	MediaUnlockTest_Kancolle ${1};
	MediaUnlockTest_UMAJP ${1};
	MediaUnlockTest_PCRJP ${1};
	echo "======================================="
}	

function Global_UnlockTest() {		
	echo ""		
	echo "=============跨国平台解锁=============="	
	MediaUnlockTest_Dazn ${1};
	MediaUnlockTest_Netflix ${1};
	MediaUnlockTest_DisneyPlus ${1};
	MediaUnlockTest_HotStar ${1};
	#MediaUnlockTest_YouTube_Region ${1};
	MediaUnlockTest_YouTube_Premium ${1};
	MediaUnlockTest_PrimeVideo_Region ${1};
	MediaUnlockTest_Tiktok_Region ${1};
	MediaUnlockTest_iQYI_Region ${1};
	MediaUnlockTest_Viu.com ${1};
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
echo -e "${Font_SkyBlue}输入数字【1】：【跨国平台+美国平台】检测${Font_Suffix}"
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
