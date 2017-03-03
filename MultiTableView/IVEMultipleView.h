//
//  IVEMultipleView.h
//  MyDemo
//
//  Created by Ive on 16/4/8.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVEMultipleView : UIView
@property (nonatomic,strong) NSArray *tableViews;
@property (nonatomic,strong) NSArray *segmentTitles;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,assign) NSInteger currentIndex;
@end
