//
//  DDScrollView.m
//  DevelopmentLibrary
//
//  Created by zhanggy on 2018/11/22.
//  Copyright © 2018 DD. All rights reserved.
//

#import "DDScrollView.h"

@interface DDScrollView ()<UIGestureRecognizerDelegate>

@end
@implementation DDScrollView
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_disableGestureView) {
        CGPoint point = [gestureRecognizer locationInView:_disableGestureView];
        return !CGRectContainsPoint(_disableGestureView.bounds, point);
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];

    
}


@end
