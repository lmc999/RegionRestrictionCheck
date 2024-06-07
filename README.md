<p align="center">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Flmc999%2FRegionRestrictionCheck&count_bg=%230AC995&title_bg=%23004BF9&icon=&icon_color=%23E7E7E7&title=visitors&edge_flat=false"/></a>
<a href="/LICENSE"><img src="https://img.shields.io/badge/license-GPL-blue.svg" alt="license" /></a>
</p>

## For English user please see
### [Introduction](https://github.com/lmc999/RegionRestrictionCheck/blob/main/README_EN.md)

## 脚本介绍

本脚本基于 [CoiaPrant/MediaUnlock_Test](https://github.com/CoiaPrant/MediaUnlock_Test) 代码进行修改

## 支持操作系统

带有 bash 环境的任意 Unix 或类 Unix 操作系统。
例如：Ubuntu 16+, Debian 10+, RHEL 7+, Arch Linux, Alpine Linux, FreeBSD, MacOS 10.13+, Android (Termux), iOS (iSH), Windows (MinGW/Cygwin), OpenWRT 23+ 等等。

## 使用方法

**使用脚本前请确认 curl 已安装**

````bash
bash <(curl -L -s check.unlock.media)
````

##### 只检测 IPv4 结果：

````bash
bash <(curl -L -s check.unlock.media) -M 4
````

##### 只检测 IPv6 结果：

````bash
bash <(curl -L -s check.unlock.media) -M 6
````

##### 指定检测的网卡名称：

````bash
bash <(curl -L -s check.unlock.media) -I eth0
````

##### 直接测试指定的区域编号：

````bash
bash <(curl -L -s check.unlock.media) -R 0
````

如果不指定区域编号或区域编号为空，则显示区域选择菜单

##### 选择脚本语言为英文：

````bash
bash <(curl -L -s check.unlock.media) -E en
````

**或者直接运行以下 Docker 命令** (兼容 ARM 架构)

````
docker run --rm -ti --net=host lmc999/regioncheck && docker rmi lmc999/regioncheck > /dev/null 2>&1
````

## 安装依赖

### Ubuntu/Debian:

```
sudo apt install curl openssl ca-certificates -yq
```

可选依赖：

```
sudo apt install uuid-runtime dnsutils -yq
```

### RHEL:

```
sudo dnf install curl openssl
```

可选依赖：

```
sudo dnf install bind-utils
```

### Android Termux:

```
pkg up -yq
pkg install curl openssl openssl-tool ca-certificates -yq
```

可选依赖：

```
pkg install uuid-utils dnsutils -yq
```

### iOS iSH / Alpine Linux:

```
apk add curl bash grep openssl ca-certificates uuidgen
```

### macOS:

```
brew install curl openssl md5sha1sum coreutils
```

### Windows:

可以使用 Cygwin 或者 Git Windows 最新版本。
如果使用 Git Windows，请确认安装 `powershell` 用于生成 uuid。请确认使用最新版本的 `curl` (>=8.8.0) 以避免遇到段错误。

### OpenWRT

```
opkg update
opkg install grep
```

## 特性

纯 bash shell 实现的流媒体检测功能，可免 ROOT 执行，支持多个平台。可用于批量测试多个地区的流媒体网站解锁情况。

具体的各个地区流媒体测试支持情况，详见 [supported_platforms](https://github.com/lmc999/RegionRestrictionCheck/blob/main/reference/supported_platforms.md)

## 注意事项

1. Netflix CDN 分流测试依赖 DNS 解析。而如果您使用的本地设备开了 VPN 代理进行测试，将无法得到正确的 CDN 分流信息。

## PR 须知

### 1. 请勿滥用 curl 的参数。

常用 CURL 参数如下：

```
-s (--silent): 静默模式。即不输出任何错误信息、URL 连接详情等。
-S (--show-error): 显示错误。当使用静默模式时，输出错误消息。如果使用该参数，意外的错误消息可能会影响代码整洁性，不建议使用。
-f (--fail): 当 URL 返回 400 错误或者 HTTP 无法传输时，不输出错误信息，并返回错误代码 22。
-w (--write-out): 当 URL 访问完成后，可用于输出例如 HTTP 响应代码、URL 网址等内容。
-o (--output): 将请求的内容重定向输出到文件，而不是直接屏幕打印。
-D (--dump-header): 将访问 URL 时收到的 header 信息输出到文件。
-L (--location): 跟随 URL 跳转。
-i (--include): 在输出结果中显示响应 header 信息。
-c (--cookie-jar): 当 URL 访问完成后，将 cookie 信息写入到 Netscape 格式的文件中。
-b (--cookie): 使用指定的数据或者文件作为 cookie。
```

### 2. 请勿使用双方括号

双方括号只是 bash 的扩展功能。一是在某些不同平台可能会有兼容性问题，二是较为影响整洁性。

### 3. 请避免使用 if ... elif ... else 语句

if ... elif 不利于代码的阅读性，在函数中，建议使用更简洁的判断模式，得到预期结果后使用 return 退出函数。

### 4. 除非确实有必要，请尽量避免输出到文件

逻辑部分的处理请尽量在 shell 中处理，避免输出到文件。

### 5. 请勿添加额外的依赖

能以 shell 方式解决的问题，请尽量以 shell 方式实现。

## 赞助

如果觉得脚本对你有帮助，可以考虑请作者喝一箱健力宝

![image](https://i.imgur.com/HHbZgUsl.jpg)

![image](https://i.imgur.com/MWXifObl.jpg)

## 交流

脚本使用过程中出现 bug 欢迎提交 issue

你亦可直接添加 [TG群组](https://t.me/gameaccelerate) 分享你的建议

## 特别鸣谢

[柠檬大佬](https://t.me/ilemonrain) ，目前市面的流媒体解锁检测脚本都是从 [Lemonbench](https://github.com/LemonBench/LemonBench) 演化而来

[onoc1yn](https://github.com/onoc1yn) 提供多架构 docker 解决方案及 Hulu Cookies 加密方案
