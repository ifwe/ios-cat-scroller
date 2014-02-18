CatScroller
=========
Continuous & AutomaTed Scroll(able) Controller
**AKA**
Infinite ```UICollectionView``` with automatic view data binding and additional view support

  - Support multi columns waterfall like layout with ```UICollectionView```
  - Automatic view data binding for insert and delete
  - automatic '*more*' data request
  - Header, footer, overhead and background support

![Demo2]
![Demo3]
<!-- [Demo1] -->

Example
=======
Please see the example [example] file. 

Here's a list of [protocols] that need to be implemented

And the supported ```UICollectionView```'s cell need to conform to [CatScrollerCollectionViewCell] protocol

Supported OS & SDK Versions
===========================

* Supported build target - iOS 7.0 (Xcode 5.0, Apple LLVM compiler 4.2)

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
=================

As of version 1.0, CatScroller requires ARC. If you wish to use CatScroller in a non-ARC project, just add the -fobjc-arc compiler flag to the CatScroller.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click CatScroller.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in CatScroller.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including CatScroller.m) are checked.


Thread Safety
=============

CatScroller is derived from UIView and - as with all UIKit components - it should only be accessed from the main thread. You may wish to use threads for loading or updating content views or items, but always ensure that once your content has loaded, you switch back to the main thread before updating the carousel.


Installation
=============

There are two steps in the installation process:

step 1:
--------------
<!-- **Using the ``.framework`` file**:

The file is located in ``Framework\`` folder. 
To use the CatScroller class in an app, just drag the CatScroller class files (demo files and assets are not needed) into your project and add the QuartzCore framework. -->


**Using the ``*.m``&&``*.h`` file:**

Copy all the content of ``iosVotingStack\`` folder into the your project

<!-- 
**Using it as ``Sub Projects:``** 

A create static library project is already created. And it is located in ``createStaticLibrary\`` folder. 
Please use the [Creating a Static Library in iOS Tutorial] article's `Method 2: Subprojects` section for detail.
 -->

step 2:
-------

Just ``#import "CatScroller.h"`` (*syntax may vary depending step 1*)

and voting stack view require the client to implement some 2 [protocols] with 5 methods for it to be useable.







[example]:https://github.com/tagged/ios-cat-scroller/blob/master/CatScrollerExample/CatScrollerExample/ViewController.m#L40
[protocols]:https://github.com/tagged/ios-cat-scroller/blob/master/CatScroller/CatScroller.h#L58
[CatScrollerCollectionViewCell]:https://github.com/tagged/ios-cat-scroller/blob/master/CatScroller/CatScroller.h#L25
<!-- [Demo1]:https://s3.amazonaws.com/uploads.hipchat.com/30/602337/YYsMUvoKYRXZ5FF/additionalView.gif -->
[Demo2]:https://s3.amazonaws.com/uploads.hipchat.com/30/602337/VWRuJ6QNDi0b8HN/autoAdd390.gif
[Demo3]:https://s3.amazonaws.com/uploads.hipchat.com/30/602337/Ku82FS41h2zLBPz/multiDeletion390.gif
<!-- [Creating a Static Library in iOS Tutorial]:http://www.raywenderlich.com/41377/creating-a-static-library-in-ios-tutorial -->