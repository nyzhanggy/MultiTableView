//
//  ViewController.m
//  MultiTableView
//
//  Created by Ive on 16/8/17.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import "ViewController.h"
#import "IVEMultipleView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) IVEMultipleView *mulipleView;
@property (nonatomic,strong) UIView *headerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mulipleView];
}

- (IVEMultipleView *)mulipleView {
    if (!_mulipleView) {
        _mulipleView = [[IVEMultipleView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 20)];
        _mulipleView.segmentTitles = @[@"0",@"1",@"2",@"3"];
       
        _mulipleView.headerView = self.headerView;
        
        NSMutableArray *viewsArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < 6; index ++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mulipleView.frame), CGRectGetHeight(_mulipleView.frame)) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [viewsArray addObject:tableView];
        }
        _mulipleView.tableViews = viewsArray;
    }
    return _mulipleView;
}
#pragma mark - --UITableviewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @(indexPath.row + 100).stringValue;
    return cell;
}

#pragma mark - --setter && getter
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80)];
        _headerView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        imageView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, 50);
        imageView.image = [UIImage imageNamed:@"image.png"];
        [_headerView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(imageView.frame) + 10, CGRectGetWidth(self.view.frame) - 20, 30)];
        label.text = @"简介信息简介信息简介信息简介信息简介信息简介信息";
        label.font = [UIFont systemFontOfSize:12];
        
        label.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:label];
        _headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(label.frame) + 20);
    }
    return _headerView;
}



@end
