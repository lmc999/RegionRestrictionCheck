<p align="center">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Flmc999%2FRegionRestrictionCheck&count_bg=%230AC995&title_bg=%23004BF9&icon=&icon_color=%23E7E7E7&title=visitors&edge_flat=false"/></a>
<a href="/LICENSE"><img src="https://img.shields.io/badge/license-GPL-blue.svg" alt="license" /></a>  
</p>

## For English user please see
### [Introduction](https://github.com/lmc999/RegionRestrictionCheck/blob/main/README_EN.md)

## 脚本介绍
本脚本基于[CoiaPrant/MediaUnlock_Test](https://github.com/CoiaPrant/MediaUnlock_Test)代码进行修改

**支持OS/Platform：CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android with Termux**

iOS运行方法请参考[此处](https://github.com/lmc999/RegionRestrictionCheck/wiki/iOS%E8%BF%90%E8%A1%8C%E8%84%9A%E6%9C%AC%E6%96%B9%E6%B3%95)

+ 优化了Disneyplus的判断准确性

+ 新增MyTVSuper解锁判断

+ 新增Dazn解锁判断

+ 新增Hulu Japan解锁判断

+ 新增赛马娘解锁判断

+ 新增舰娘解锁判断

+ 新增Now E解锁判断

+ 新增Viu TV解锁判断

+ 新增U-NEXT VIDEO解锁判断

+ 新增Paravi解锁判断

+ 优化了Abema TV的判断准确性

+ 新增WOWOW解锁判断

+ 新增TVer解锁判断

+ 新增Hami Video解锁判断

+ 新增4GTV解锁判断

+ 新增Sling TV解锁判断

+ 新增Pluto TV解锁判断

+ 新增HBO Max解锁判断

+ 新增Channel 4解锁判断

+ 新增ITV Hub解锁判断

+ 新增爱奇艺国际版区域判断

+ 新增Hulu US解锁判断

+ 新增encoreTVB解锁判断

+ 新增LineTV TW解锁判断

+ 新增Viu.com解锁判断

+ 新增Niconico解锁判断

+ 新增Paramount+解锁判断

+ 新增KKTV解锁判断

+ 新增Peakcock TV解锁判断

+ 新增FOD解锁判断

+ 新增TikTok区域判断

+ 优化YouTube判断增加Premium是否可用判断

+ 新增BritBox解锁判断

+ 新增Amazon Prime Video区域判断

+ 新增Molotov解锁判断

+ 新增DMM解锁判断

+ 新增Radiko解锁及区域判断

+ 新增CatchPlay+解锁判断

+ 新增Hotstar解锁判断

+ 新增Litv解锁判断

+ 新增Fubo TV解锁判断

+ 新增Fox解锁判断

+ 新增Joyn解锁判断

+ 新增Sky Germany解锁判断

+ 新增ZDF解锁判断

+ 新增HBO GO Asia解锁判断

+ 新增HBO GO Europe解锁判断

## 使用方法

**使用脚本前请确认curl已安装**

````bash
bash <(curl -L -s check.unlock.media)
````

##### 只检测IPv4结果：
````bash
bash <(curl -L -s check.unlock.media) -M 4
````

##### 只检测IPv6结果：
````bash
bash <(curl -L -s check.unlock.media) -M 6
````

##### 指定检测的网卡名称：
````bash
bash <(curl -L -s check.unlock.media) -I eth0
````

##### 选择脚本语言为英文：
````bash
bash <(curl -L -s check.unlock.media) -E
````

**或者直接运行以下Docker命令** (兼容ARM架构)
````docker
docker run --rm -ti --net=host lmc999/regioncheck && docker rmi lmc999/regioncheck
````

## 赞助
如果觉得脚本对你有帮助，可以考虑请作者喝一箱健力宝

![image](https://i.imgur.com/HHbZgUsl.jpg)

![image](https://i.imgur.com/MWXifObl.jpg)

## 交流
脚本使用过程中出现bug欢迎提交issue

你亦可直接添加[TG群组](https://t.me/gameaccelerate)分享你的建议

## 特别鸣谢
[柠檬大佬](https://t.me/ilemonrain),目前市面的流媒体解锁检测脚本都是从[Lemonbench](https://github.com/LemonBench/LemonBench)演化而来

[onoc1yn](https://github.com/onoc1yn) 提供多架构docker解决方案及Hulu Cookies加密方案
