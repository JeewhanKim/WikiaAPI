# WikiaAPI

Present the list of most top 15 ~ 250 popular wikia pages using Wikia API 

API List
WikisApi::getList
http://www.wikia.com/wikia.php?controller=WikisApi&method=getList&hub=Gaming&lang=en
WikisApi::getDetails
http://www.wikia.com/wikia.php?controller=WikisApi&method=getDetails&ids=3125,490

Library 'SDWebImage'
Github: https://github.com/Ryder-Cheng/SDWebImage
Documentation: http://cocoadocs.org/docsets/SDWebImage/3.7.2/

[before]
thumbnailText = [NSMutableString stringWithFormat:@"%@", [tmpDictionary objectForKeyedSubscript:@"thumbnail"]];  
NSURL *url = [NSURL URLWithString:thumbnailText];
NSData *data = [NSData dataWithContentsOfURL:url];
UIImage *thumbnailImage = [[UIImage alloc] initWithData:data];    
cell.wikiImage.image = thumbnailImage;

[after]
[cell.wikiImage sd_setImageWithURL:[NSURL URLWithString:thumbnailText] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

