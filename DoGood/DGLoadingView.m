//
//  DGLoadingView.m
//  DoGood
//
//  Created by Michael on 10/30/2013.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "DGLoadingView.h"

@implementation DGLoadingView

- (id)initCenteredOnView:(UIView *)view {
    self = [super initWithFrame:view.frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSpinner];
        [self setupMessage];
        [view addSubview:self];
    }
    return self;
}

- (void)startLoading {
    self.hidden = NO;
    [spinner startAnimating];
    message.hidden = YES;
}

- (void)loadingSucceeded {
    self.hidden = YES;
    [spinner stopAnimating];
    message.hidden = YES;
}

- (void)loadingFailed {
    self.hidden = NO;
    [spinner stopAnimating];
    message.hidden = NO;
}

- (void)setupSpinner {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.center;
    spinner.frame = CGRectMake(spinner.frame.origin.x, spinner.frame.origin.y  / 2, spinner.frame.size.width, spinner.frame.size.height);
    spinner.hidesWhenStopped = YES;
    [self addSubview:spinner];
}

- (void)setupMessage {
    message = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    message.textAlignment = NSTextAlignmentCenter;
    message.center = self.center;
    message.text = @"Failed to load";
    message.font = [UIFont systemFontOfSize:15];
    message.textColor = [UIColor lightGrayColor];
    message.frame = CGRectMake(message.frame.origin.x, message.frame.origin.y  / 2, message.frame.size.width, message.frame.size.height);
    [self addSubview:message];
    message.hidden = YES;
}

@end
