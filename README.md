# Rubick
Rubick is a simple and easy to use iOS library for tracking network. Rubick, the Grand Magus, is a ranged intelligence hero best known for his ability to copy the spells of his enemies and use them as his own. I like dota very much, so I gave this library name Rubick!

# How to use
```
#import "Rubick.h"
```
Add the following codes in -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions  method:
```
[Rubick startTrackWithUrls:@[@"www.baidu.com"]];
//for debug log
[Rubick openDebug];
```
##Log will be like the following:
start_at:2017-01-18 12:44:13, url:http://www.baidu.com, method:GET, body_size:0, response_code:200, content_size:101940, error:empty, cost_time:113.593750ms, net:WIFI, carrier:Unknown, device:iPhoneSimulator, os:10.1, app:RubickDemo, appV:1.0


# Installation
## Cocoapods

Add the following line to your `Podfile`:

```
pod 'Rubick'
```

Then, run the following command:

```
$ pod install
```



# License

Rubick is released under the Apache License, Version 2.0. See LICENSE for details.
