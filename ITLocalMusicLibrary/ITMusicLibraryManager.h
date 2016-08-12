//
//  ITMusicLibraryManager.h
//  ServerAndMusicDemo
//
//  Created by pengchengwu on 16/7/12.
//  Copyright © 2016年 pengchengwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ITSingleSong.h"
@class MPMediaItem;

#define ITDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define ITLocalSongsFolderPath [ITDocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/LocalSongs"]]
#define ITLocalSongsLibraryPath [ITLocalSongsFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"LocalSongsLibrary.plist"]]
#define ITMusicNoticeConvertProgressChange @"ITMusicConvertProgressChange"

@interface ITMusicLibraryManager : NSObject

@property (nonatomic, strong) NSMutableArray<MPMediaItem *> * ipodMediaItemsArr;
@property (nonatomic, strong) NSMutableArray<ITSingleSong *> * localSongsArr;

/**
 *  初始化ITMusicLibraryManager
 *
 *  @return 本地音乐管理器单例
 */
+ (instancetype)sharedInstance;

/**
 *  更新ipod songs library
 */
- (NSArray<MPMediaItem *> *)updateMediaItemsLibrary;

/**
 *  更新本地音乐库
 */
- (NSMutableArray<ITSingleSong *> *)updateLocalSongsLibrary;

/**
 *  将选中的ipod文件转化为本地音乐文件
 */
- (void)convertSelectedIpodItems:(NSArray<MPMediaItem *> *)selectedItemsArr;

/**
 *  将所有的ipod文件转化本地音乐文件
 */
- (void)convertAllIpodItems;

/**
 *  删除单个本地音乐文件
 */
- (void)removeSingleLocalSong:(ITSingleSong *)aSong;

/**
 *  删除选中的本地音乐文件
 */
- (void)removeSelectedLocalSongs:(NSMutableArray<ITSingleSong *> *)selectedSongsArr;

/**
 *  删除所有本地音乐文件
 */
- (void)removeAllLocalSongs;

@end
