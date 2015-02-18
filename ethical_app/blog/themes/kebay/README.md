Hexo theme: Kebay
=================

##Installation

###Install

Run this command from inside your hexo project
``` bash
$ git clone 
```

**Kebay requires Hexo 2.4 and above.**

###Update

``` bash
cd themes/kebay
git pull
```

##Configuration

``` yml
# Header
menu:
    Home: /
    Archives: /archives
rss: /atom.xml

# Content
excerpt_link: Read More
fancybox: true

# Miscellaneous
google_analytics:
favicon: /favicon.png
```

- **menu** - Navigation menu
- **rss** - RSS link
- **excerpt_link** - "Read More" link at the bottom of excerpted articles. `false` to hide the link.
- **fancybox** - Enable [Fancybox](http://fancyapps.com/fancybox/)
- **google_analytics** - Google Analytics ID
- **favicon** - Favicon path
