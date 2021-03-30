# ZhihuDaily   #alpha test Version

1.  完成了重邮红岩网校iOS寒假考核 https://github.com/Rock-Connotation/RedRockiOSWinnterWork 中的所有要求功能
2. 在该版本中，文章详情页采用了WKWebView直接访问网页版文章链接的方式来展现,并使用FSpagerView实现左右滑动浏览上下文章。该方式能实现大部分功能，但存在诸多问题，比如左右滑动的复用机制代码过于繁复；网页顶部的下载客户端提示会在特定情况下出现，无法完全屏蔽；详情页无法适配夜间模式等。计划在betaVersion将详情页完全重构。

3 . 
    由于复用机制过于繁复 ，除TopPageController DetaiPageController外 其余文件均有注释。

4. 目前版本设置页仅有清除缓存功能，计划在未来进行功能的完善。
