---
layout:	post
title:	"Making Your First Samsung Gear S3 App"
date:	2017-10-31
description: "Learn from my mistakes and set up Tizen Studio to make your first Gear app"
tags: [software engineering, tizen, samsung, samsung gear s3, smartwatch, wearables, tutorial]
---

<!-- HTMLProofer: preserve this historical URL; its HTTP site works but its HTTPS endpoint does not. -->
When I started my research project in the MIT [D-Lab][d-lab] [Mobile Technology Lab][mtl]{: data-proofer-ignore="" } I was excited to build my first smartwatch app using the [Samsung Gear S3][gear-s3]. Despite being super excited about the project, setting up the development environment took me an entire month :anguished: Here’s how to get to the Hello World stage 10x faster than I did.

![A Samsung Gear S3 displaying “Hello D-Lab!” and the time]({{ site.github.url }}/assets/img/watch/goal.jpeg){: .hero-image}
_The goal for this tutorial._
{: .caption}

The Samsung Gear S3 uses an open-source operating system called [Tizen][tizen] that’s based on the Linux kernel. You can program apps for the watch in C (“Native”) or with HTML/CSS/JS (“Web”). My project needs fast real-time signal processing, so we chose Native.

The source tutorial for this post is “[**Creating Your First Tizen Wearable Native Watch Application**][tizen-tutorial]” by [Tizen Developers][tizen-developers]. The info below should fill in all the gaps in the tutorial.

*This project is up-to-date as of 20 March 2018. It uses Tizen Studio 2.2 and Wearable 3.0.*

### Installing Tizen Studio

1. Make sure you have enough space to download and install the [Tizen Studio][tizen-studio] [IDE][ide]. It’s ~5GB!
2. In the Tizen Studio package manager, install everything for the **3.0 wearable**. This was my first big stumbling block. Also be sure to install the **Samsung Certificate Extension** and the **Samsung Wearable Extension** under “Extras”.

Once you’ve installed Tizen Studio, you can go through the “[Creating a Project][tizen-tutorial-create]”, “[Managing the Application Configuration][tizen-tutorial-configuration]”, and “[Building Your Application][tizen-tutorial-build]” sections of the tutorial.

### Running the Emulator

The emulator is basically a little watch that runs on your computer. It takes a long time to start, but you can tell it’s successfully starting up by the boot messages at the top of the emulator watch face.

![A Tizen wearable emulator running inside Tizen Studio]({{ site.github.url }}/assets/img/watch/emu.png)
_This is a good sign._
{: .caption}

Start the emulator from the Tizen Emulator Manager window. You know it’s ready when it shows up in the Tizen Studio Connection Explorer window. If you have issues running the emulator on OSX, you may need to install [Intel HAXM][haxm] and follow [these instructions][haxm-instructions] to install it. TL;DR: run `sudo kextload -bundle-id com.intel.kext.intelhaxmand` then restart Tizen Studio. After this, you need to set up security certificates.

### Security Certificate Profiles

This is the mistake that took me the most time to figure out, and it is completely glossed over in the tutorial. Essentially, you need to go to Tools>Certificate Manager and click “**+**” to make new certificate. You have to make a Tizen certificate for the emulator to work, and a **Samsung** certificate for the app to run on the actual watch. For the Tizen certificate, choose “Partner” privilege level.

![Tizen Certificate Manager with the Samsung certificate profile selected]({{ site.github.url }}/assets/img/watch/cert.png)
_You need the one on the right too!!_
{: .caption}

It should be fairly straightforward to follow the steps to set up both certificates from there. You can follow the rest of the Tizen Developers tutorial to run the app on the watch emulator with the Tizen certificate profile.

![The completed Hello D-Lab watch face running in the emulator]({{ site.github.url }}/assets/img/watch/huzzah.png)
_Huzzah!_
{: .caption}

### Running on the real watch

Follow along with the tutorial section “[Running on a Target Device][tizen-tutorial-target]”. In particular, be sure to turn on the device WiFi and Bluetooth, connect your computer to the same WiFi network, and make sure both your laptop and device have the correct date and time. Also be sure to check your device IP address each time you connect to WiFi, because it may change.

When I ran `./sdb connect <watch IP>` I never actually got a notification on my watch saying “Allow Gear to read log data, copy files,…”. I just got a notification that said “RSA key fingerprint:…” and clicked the check mark. I had to reset my watch once to get a notification to pop up at all.

Like it says in the tutorial, you know the watch is correctly connected when you see it in the Tizen Device Manager window. When I connect via the command line interface it says `device unauthorized. Please approve on your device.` each time, but it still works :sweat_smile:

**Another thing they don’t mention in the tutorial**: you may need to copy the `device-profile.xml` file to the watch. This file is located at `/home/cnord/SamsungCertificate/my\_certificate\_name/device-profile.xml` for me and needs to be copied to `home/developer/` on the watch. Copy it over to the watch by right clicking on the device name in Tizen Device Manager and selecting “Permit to install applications”.

Now, you should be able to select the Samsung security profile, then continue the tutorial with Run As>Tizen Native Application, select the watch face, and see your beautiful new app!

![A Samsung Gear S3 displaying a thank-you message in front of the app’s source code]({{ site.github.url }}/assets/img/watch/done.jpeg)

Feel free to email me (cnord@school) if you have any questions, comments, or tips about Samsung Gear development.

_This blog post was cross-posted on Medium [here][medium]._

[d-lab]: https://d-lab.mit.edu/research-about
[gear-s3]: https://www.samsung.com/us/explore/gear-s3/
[haxm]: https://software.intel.com/en-us/articles/intel-hardware-accelerated-execution-manager-intel-haxm
[haxm-instructions]: https://stackoverflow.com/questions/26455759/installing-haxm-on-osx-yosemite
[ide]: https://en.wikipedia.org/wiki/Integrated_development_environment
[medium]: https://medium.com/@cnord/making-your-first-samsung-gear-s3-app-363947cdf7fd
[mtl]: http://www.mobiletechnologylab.org/
[tizen]: https://www.tizen.org/?langswitch=en
[tizen-developers]: https://developer.tizen.org/?langswitch=en
[tizen-studio]: https://developer.tizen.org/development/tizen-studio/download
[tizen-tutorial]: https://developer.samsung.com/galaxy-watch-tizen/creating-your-first-app/native.html#run
[tizen-tutorial-build]: https://developer.samsung.com/galaxy-watch-tizen/creating-your-first-app/native.html#build
[tizen-tutorial-configuration]: https://developer.samsung.com/galaxy-watch-tizen/creating-your-first-app/native.html#configuration
[tizen-tutorial-create]: https://developer.samsung.com/galaxy-watch-tizen/creating-your-first-app/native.html#create
[tizen-tutorial-target]: https://developer.samsung.com/galaxy-watch-tizen/creating-your-first-app/native.html#target
