//
//  main.m
//  DoGood
//
//  Created by Michael on 2013-08-02.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGAppDelegate.h"
#import <NUI/NUISettings.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [NUISettings initWithStylesheet:@"DoGood"];
        [NUISettings setAutoUpdatePath:@"/Users/mhayman/setup/springbox/DoGood/DoGood/DoGood/DoGood.nss"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([DGAppDelegate class]));
    }
}
