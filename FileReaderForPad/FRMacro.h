//
//  FRMacro.h
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#ifndef FileReaderForPad_FRMacro_h
#define FileReaderForPad_FRMacro_h

#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define NavBarHeight 64

#define IOSVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0];

#define TheameColor RGBA(32, 193, 122, 1)
#define TheameColorAlpha(a) RGBA(32, 193, 122, a)
#define NavBarColorAlpha(a) RGBA(25,99,52,a)
#define BorderColor RGB(223, 223, 223).CGColor
#define MaskColor RGBA(0, 0, 0, 0.5)


#define Lantinghei(s) [UIFont fontWithName:@"Lantinghei SC" size:s]


#endif
