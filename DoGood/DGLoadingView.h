//
//  DGLoadingView.h
//  DoGood
//
//  Created by Michael on 10/30/2013.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGLoadingView : UIView {
    UIActivityIndicatorView *spinner;
    UILabel *message;
}

- (id)initCenteredOnView:(UIView *)view;
- (void)startLoading;
- (void)loadingSucceeded;
- (void)loadingFailed;

@end
