//
//  PAViewController.m
//  PhysicalAnimation
//
//  Created by Pavel Panov on 11/5/12.
//  Copyright (c) 2012 Pavel Panov. All rights reserved.
//

#import "PAViewController.h"

#import "PAStackPicsView.h"

@interface PAViewController ()

@end

@implementation PAViewController

- (void)viewDidLoad
{
    NSArray *pics = [NSArray arrayWithObjects:@"144111.jpeg", @"150712.jpeg", @"151885.jpeg", @"152273.jpeg", @"152311.jpeg", @"152464.jpeg", @"152636.jpeg", @"152657.jpeg", @"152727.jpeg", nil];
    
    PAStackPicsView *stackPicsView = [[PAStackPicsView alloc] initWithFrame:CGRectMake(0, 0, 128, 128)];
    stackPicsView.center = CGPointMake(160, 160);
    stackPicsView.pics = pics;
    stackPicsView.clipsToBounds = NO;
    [self.view addSubview:stackPicsView];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
