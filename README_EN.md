## Introduction
This script was modified based on [CoiaPrant/MediaUnlock_Test](https://github.com/CoiaPrant/MediaUnlock_Test)

+ Optimise Disneyplus accuracy

+ Add MyTVSuper

+ Add Dazn

+ Add Hulu Japan

+ Add Pretty Derby (Game)

+ Add Kancolle (Game)

+ Add Now E

+ Add Viu TV

+ Add U-NEXT VIDEO

+ Add Paravi

+ Optimise Abema accuracy

+ Add WOWOW

+ Add TVer

+ Add Hami Video

+ Add 4GTV

+ Add Sling TV

+ Add Pluto TV

+ Add HBO Max

+ Add Channel 4

+ Add ITV Hub

+ Add iQiyi

+ Add Hulu US

+ Add encoreTVB

+ Add LineTV TW

+ Add Viu.com

+ Add Niconico

+ Add Paramount+

+ Add KKTV

+ Add Peakcock TV

+ Add FOD

## How to use

**Make sure you have curl and python installed**

**General Use**
````bash
bash <(curl -L -s https://git.io/JRw8R) -E
````

**Test IPv4 Result Only**
````bash
bash <(curl -L -s https://git.io/JRw8R) -E -M 4
````

**Test IPv6 Result Only**
````bash
bash <(curl -L -s https://git.io/JRw8R) -E -M 6
````

**Specify a Certain Interface to be Tested**
````bash
bash <(curl -L -s https://git.io/JRw8R) -E -I eth0
````

##### Non interactive mode
- Check All Regions
````bash
bash <(curl -L -s check.unlock.media) -E -A
````
- Check Selected Region
````bash
bash <(curl -L -s check.unlock.media) -E -T 0
````
You could run the command `bash <(curl -L -s check.unlock.media) -E` to see more details of these options, and `-T` would be overwrited by `-A`

**Or run in docker**
````docker
docker run --rm -ti --net=host lmc999/regioncheck && docker rmi lmc999/regioncheck
````


## Thanks To
[柠檬大佬](https://t.me/ilemonrain), please support [Lemonbench](https://github.com/LemonBench/LemonBench)

