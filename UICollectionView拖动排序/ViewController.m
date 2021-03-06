//
//  ViewController.m
//  UICollectionView拖动排序
//
//  Created by Lym on 2017/3/31.
//  Copyright © 2017年 Lym. All rights reserved.
//

#import "ViewController.h"
#import "SortViewController.h"
#import "MergeViewController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - ---------- 生命周期 ----------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Merge Test";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 100, 100, 50)];
    [btn1 setTitle:@"拖动排序" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(sortVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 75, 200, 150, 50)];
    [btn2 setTitle:@"拖动排序+合并" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(mergeVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
//    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 75, 300, 150, 50)];
//    [btn3 setTitle:@"羔羊测试" forState:UIControlStateNormal];
//    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btn3 addTarget:self action:@selector(testVC) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//排序
- (void)sortVC {
    SortViewController *vc = [[SortViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//合并+排序
- (void)mergeVC {
    MergeViewController *vc = [[MergeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//gy测试用
- (void)testVC {
    TestViewController *vc = [[TestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
