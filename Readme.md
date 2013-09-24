# Winston-Salem Crime Map
### A [RubyMotion](http://www.rubymotion.com/) application brought to you by [Mohawk Apps](http://www.mohawkapps.com/).

![](https://raw.github.com/MohawkApps/WSCrime/master/resources/Icon@2x.png)

This application was originally written in pure Objective-C and submitted to the app store. It went through multiple iterations as an XCode project until I heard about [RubyMotion](http://www.rubymotion.com/) and decided to use it as a chance to not only simplify the codebase for this app, but also to learn Ruby in the meantime.

Since I used this as a learning experience, I also wanted to put the code out there for others to learn from and to improve upon (iOS client only, not the server scraper and API).

This RubyMotion project is open source under the MIT license (see *License* file).

This app is a *universal application* (meaning that it works on both the iPhone and iPad). It has also been updated to work with the new screen size of the iPhone 5.

## Getting it

You can get the app one of two ways:

1. Clone this repos and run it in the siumlator (or on a device if you are a registered Apple Developer). ```git clone --recursive git://github.com/MohawkApps/WSCrime.git```
2. Get it from the iTunes App Store:

[![image](http://ax.phobos.apple.com.edgesuite.net/images/web/linkmaker/badge_appstore-lrg.gif)](https://itunes.apple.com/us/app/winston-salem-crime-map/id472546582?mt=8&uo=4&at=10l4yY)

## Running the app

### Prerequisites:

1. XCode 4.5 with iOS 6 SDK.
2. You must have a registered and licensed copy or RubyMotion on your computer. If you do not, you will need to [purchase a license here](http://www.rubymotion.com/). Winston-Salem Crime Map requires at least RubyMotion 1.30 or later.
3. [Cocoapods](http://cocoapods.org/) must be installed.
4. Valid Apple Developer signing certificate (if you want to install on a device).

## Compiling:

1. ```cd``` into the WSCrimeMap directory and run ```bundle update```
2. Run ```rake``` and the application will build and launch the iOS simulator.

## ARKit

I recently introduced augmented reality into the app. I'm using [my own fork](https://github.com/markrickert/iPhone-AR-Toolkit) of [a1phanumeric](https://github.com/a1phanumeric)'s [iPhone AR Toolkit](https://github.com/a1phanumeric/iPhone-AR-Toolkit). The reason I'm using my own fork is becasue including it as a standard xcode project was crashing upon initialization. So I created a static library to use through XCode. I'll try and keep my fork up to date with the main project repo.

## Screenshots

![](https://raw.github.com/MohawkApps/WSCrime/master/Marketing/Screenshots/iPhone-small/1.png)&nbsp;
![](https://raw.github.com/MohawkApps/WSCrime/master/Marketing/Screenshots/iPhone-small/2.png)&nbsp;
![](https://raw.github.com/MohawkApps/WSCrime/master/Marketing/Screenshots/iPhone-small/3.png)&nbsp;
![](https://raw.github.com/MohawkApps/WSCrime/master/Marketing/Screenshots/iPhone-small/4.png)