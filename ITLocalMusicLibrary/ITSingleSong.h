//
//  ITSingleSong.h
//  ServerAndMusicDemo
//
//  Created by pengchengwu on 16/7/13.
//  Copyright © 2016年 pengchengwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPMediaItem;
@class MPMediaItemArtwork;

#define ITLocalSongsFileFormat @".m4a"

@interface ITSingleSong : NSObject <NSCoding>

/**
 *  歌曲id
 */
@property (nonatomic, strong) NSNumber * persistentID;
/**
 *  歌曲名
 */
@property (nonatomic, copy) NSString * name;
/**
 *  文件类型
 */
@property (nonatomic, copy) NSString * fileFormat;
/**
 *  歌曲时长
 */
@property (nonatomic, strong) NSNumber * duration;
/**
 *  歌词
 */
@property (nonatomic, copy) NSString * lyrics;
/**
 *  专辑封面图
 */
@property (nonatomic, strong) UIImage * artworkImage;
/**
 *  本地绝对路径
 */
@property (nonatomic, copy) NSString * localAbsolutePath;
/**
 *  是否正在播放
 */
@property (nonatomic, assign) BOOL playing;


+ (instancetype)songWithMPMediaItem:(MPMediaItem *)mediaItem localAbsolutePath:(NSString *)localAbsolutePath;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
