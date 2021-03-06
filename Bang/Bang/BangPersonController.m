
//
//  BangPersonController.m
//  Bang
//
//  Created by wl on 15/11/14.
//  Copyright © 2015年 saint. All rights reserved.
//

#import "BangPersonController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyPurceController.h"
#import "BangActionSheet.h"

#import "CompleteUserInfoApi.h"
#import "UploadImageApi.h"




#define ORIGINAL_MAX_WIDTH 400
#define viewColor  [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]

@interface BangPersonController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong)UIImageView *personlIcon;

@property (nonatomic,strong)UIAlertView *nameAlert;

@property (nonatomic,strong)BangActionSheet *sexActionSheet;

@property (nonatomic,strong)UIView *back;

@property (nonatomic,strong)UIButton *right;

@end

@implementation BangPersonController{
    NSMutableArray *_titleArr;
    NSMutableArray *_detailTitleArr;
    
    NSString *_nike;
    NSString *_sex;
    NSString *_brithDay;
    NSString *_avatar;
    NSString *_banlance;//账户余额
    UIImage *_userIamge;
}
#pragma mark  alertSheet工厂方法
-(UIActionSheet *)alertToolWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle message:(NSString *)message otherTtiles:(NSArray *)titleArr otherBtnActon:(SEL)action1 secondActon:(SEL)action2 {
    
    if (iOS8) {
        UIAlertController *aletVC =[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        aletVC.view.tintColor=CONTENT_COLOR;
        [aletVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [aletVC addAction:[UIAlertAction actionWithTitle:titleArr[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self respondsToSelector:action1]) {
                IMP imp = [self methodForSelector:action1];
                void (*func)(id, SEL) = (void *)imp;
                func(self, action1);           }
        }]];
        [aletVC addAction:[UIAlertAction actionWithTitle:titleArr[1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([self respondsToSelector:action2]) {
                IMP imp = [self methodForSelector:action2];
                void (*func)(id, SEL) = (void *)imp;
                func(self, action2);           }
        }]];
        [self presentViewController:aletVC animated:YES completion:^{
            
        }];
        return nil;
    }else{
        BangActionSheet *sheet =[[BangActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:titleArr[0],titleArr[1], nil];
        [sheet showInView:self.view];
        return sheet;
    }
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"我";
    self.view.backgroundColor=viewColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake( 20, 20, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.nameAlert =[[UIAlertView alloc]initWithTitle:@"请输入您的昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.nameAlert.alertViewStyle=UIAlertViewStylePlainTextInput;
    UITextField *textfield = [self.nameAlert textFieldAtIndex:0];
    textfield.placeholder =@"8个字符以内";
    textfield.delegate=self;
    
    
    UIButton *right =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
    [right setTitle:@"保存" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [right setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.right=right;
    [right addTarget:self action:@selector(rightBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:right];
    [self setUI];

    
}

- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnOnClick:(UIButton *)sender{
    if (self.back||!_nike||!_sex||!_brithDay) {
        KIWIAlertView *alert = [[KIWIAlertView alloc] initWithTitle:@"提示" icon:nil message:@"请完善个人信息后再保存！" delegate:nil buttonTitles:@"确定", nil];
        [alert show];
    }else{
    self.right.enabled=NO;
    //保存用户信息
    [self uploadImage:_userIamge];
    
    }
    
}
- (void) uploadImage:(UIImage *) image{
    if (image==nil)return;
    UploadImageApi *api = [[UploadImageApi alloc] initWithImage:image];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        if (request) {
            NSLog(@"7777777----%@",request);
            //json如下
            id result = [request responseJSONObject];
            float s = [result[@"rst"] floatValue];
            if (s == 0.0f) {
                _avatar = result[@"url"];
                [self submitUserInfo];
            }
        }
    } failure:^(YTKBaseRequest *request) {
        self.right.enabled=YES;
    }];
}
- (void) submitUserInfo{
    int sex =[self sexIntValue:_sex];
    NSDictionary *info = @{@"name":_nike,@"sex":[NSNumber numberWithInt:sex],@"avatar":_avatar,@"birthday":_brithDay};
    CompleteUserInfoApi *api = [[CompleteUserInfoApi alloc] initWithInfo:info];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        if (request) {
            //json如下
            id result = [request responseJSONObject];
            float s = [result[@"rst"] floatValue];
            if (s == 0.0f) {
                KIWIAlertView *alert = [[KIWIAlertView alloc] initWithTitle:@"保存成功" icon:nil message:@"个人信息保存成功！" delegate:nil buttonTitles:@"确定", nil];
                [alert setMessageColor:[UIColor blackColor] fontSize:0];
                [alert show];
                self.right.enabled=YES;
                //发通知 让leftView去重新加载数据 并本地化
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadUserInfo" object:nil];
            }
        }
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"加载失败 -- %@",request);
        self.right.enabled=YES;
    }];
}
-(int)sexIntValue:(NSString *)sex{
    if (sex.length==0) {
        return 0;
    }
    return [sex isEqualToString:@"男"]?0:1;
}
-(void)setUI{
    NSString *phoneNumber =[[NSUserDefaults standardUserDefaults]objectForKey:kUserName];
    _titleArr =[NSMutableArray arrayWithObjects:@"昵称",@"性别",@"生日",@"手机号",@"账户余额", nil];
    _detailTitleArr=[NSMutableArray arrayWithObjects:@"输入昵称",@"输入性别",@"输入生日", phoneNumber,@"￥0.00",nil];
    _nike =USER_nike;//用户昵称
    _sex =[[NSUserDefaults standardUserDefaults]objectForKey:@"mySex"];//性别
    _brithDay =[[NSUserDefaults standardUserDefaults]objectForKey:@"myBirthDay"];//生日
    _banlance =[[NSUserDefaults standardUserDefaults]objectForKey:@"myBanlance"];//余额
    if (_nike) {
        [_detailTitleArr replaceObjectAtIndex:0 withObject:_nike];
    }
    if (_sex) {
        if ([_sex isEqualToString:@"0"]) {
            _sex =@"男";
            [_detailTitleArr replaceObjectAtIndex:1 withObject:_sex];
        }else if ([_sex isEqualToString:@"1"]){
            _sex=@"女";
            [_detailTitleArr replaceObjectAtIndex:1 withObject:_sex];
        }
    }
    if (_brithDay) {
        [_detailTitleArr replaceObjectAtIndex:2 withObject:_brithDay];
    }
    if (_banlance) {
        [_detailTitleArr replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"￥%@",_banlance]];
    }
    //header
    CGFloat marginLeft =10;
    UIView *header =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    header.backgroundColor=[UIColor whiteColor];
    
    UILabel *lab =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    lab.center=CGPointMake(marginLeft+20+8, 100/2);
    lab.font =[UIFont systemFontOfSize:15];
    lab.text=@"头像";
    [header addSubview:lab];
    //
    self.personlIcon =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.personlIcon.layer.cornerRadius=self.personlIcon.frame.size.width/2;
    self.personlIcon.layer.masksToBounds=YES;
    self.personlIcon.contentMode =UIViewContentModeScaleAspectFill;
    self.personlIcon.center =self.view.center;
    //self.personlIcon.image =[UIImage imageNamed:@"icon"];
    self.personlIcon.backgroundColor=viewColor;
    [header addSubview:self.personlIcon];
    self.personlIcon.userInteractionEnabled=YES;
    self.personlIcon.center =CGPointMake(SCREEN_WIDTH-30-30, 50);//右边距30
    //拿到图片
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    //设置一个图片的存储路径
    NSString *imagePath = [path stringByAppendingPathComponent:@"icon.png"];
    
     _userIamge = [UIImage imageWithContentsOfFile:imagePath];
    if (_userIamge) {
        self.personlIcon.image=_userIamge;
    }
    
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.personlIcon addGestureRecognizer:tap];
    
    self.tableView.tableHeaderView=header;
    
    //footer
    UIView *footer =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    footer.backgroundColor =viewColor;
    UIButton *exitBtn =[[UIButton alloc]initWithFrame:CGRectMake(60, 30, SCREEN_WIDTH-120, 45)];
    [exitBtn setBackgroundColor:CONTENT_COLOR];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    //exitBtn.titleLabel.font =[UIFont systemFontOfSize:14];
    exitBtn.layer.cornerRadius=5;
    exitBtn.layer.masksToBounds=YES;
    [footer addSubview:exitBtn];
    
    self.tableView.tableFooterView =footer;
    
}
-(void)exitBtnOnClick:(UIButton *)sender{
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kUserName];
    [userDefaults removeObjectForKey:kPassword];
    [userDefaults removeObjectForKey:kUserID];
    [userDefaults removeObjectForKey:@"mySex"];
    [userDefaults removeObjectForKey:@"myBrithDay"];
    [userDefaults removeObjectForKey:@"myName"];
    [userDefaults removeObjectForKey:@"myBanlance"];
    [userDefaults synchronize];
    [self deleteImage];
    //发送 退出登陆通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"exitLogin" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)tap:(UITapGestureRecognizer *)sender{
    //2.0---8.3
    
    [self alertToolWithTitle:@"选择图片来源" cancelTitle:@"取消" message:nil otherTtiles:@[@"照相机",@"本地相册"] otherBtnActon:@selector(camera) secondActon:@selector(localPhoto)];
}

#pragma mark --------tableViewdalegate--------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titleArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID =@"personl_cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.detailTextLabel.textColor =CONTENT_COLOR;
        //UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 16)];
        cell.textLabel.font=[UIFont systemFontOfSize:15];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
        //cell.accessoryView=image;
    }
    if (indexPath.section==4) {
        UIImageView *image =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 16)];
        image.image=[UIImage imageNamed:@"Rightarrow"];
        cell.accessoryView =image;
    }
    cell.textLabel.text=_titleArr[indexPath.section];
    cell.detailTextLabel.text =_detailTitleArr[indexPath.section];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *head =[[UIView alloc]init];
    head.backgroundColor=viewColor;
    return head;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?6:3;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        //输入昵称
        [self.nameAlert show];
    }else if (indexPath.section==1){
        //性别
        UIActionSheet *sheet =  [self alertToolWithTitle:@"请选择您的性别" cancelTitle:@"取消" message:nil otherTtiles:@[@"男",@"女"] otherBtnActon:@selector(menBtnOnClick) secondActon:@selector(womenBtnOnClick)];
        sheet.tag=101;
    }else if (indexPath.section==2){
        //生日
        UIView *back =[[UIView alloc]initWithFrame:self.view.bounds];
        back.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(datePickBackOnClick:)];
        [back addGestureRecognizer:tap];
        self.back=back;
        
        UIDatePicker *datePick =[[UIDatePicker alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200)];
        datePick.datePickerMode=UIDatePickerModeDate;
        [datePick setMaximumDate:[NSDate date]];
        datePick.backgroundColor=[UIColor whiteColor];
        [datePick addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [back addSubview:datePick];
        [self.view addSubview:back];
    }else if (indexPath.section==4){
        MyPurceController *purceVC =[[MyPurceController alloc]init];
        [self.navigationController pushViewController:purceVC animated:YES];
    }
}
-(void)datePickBackOnClick:(UITapGestureRecognizer *)sender{
    [sender.view removeFromSuperview];
    self.back=nil;
    if (_brithDay.length!=0) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].detailTextLabel.text=_brithDay;
    }
    
}
-(void)datePickerValueChanged:(id)sender{
    UIDatePicker *control =(UIDatePicker *)sender;
    NSDate *date =control.date;
    NSString *str =[NSString stringWithFormat:@"%@",date];
    _brithDay =[str substringToIndex:10];
}
-(void)menBtnOnClick{
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].detailTextLabel.text=@"男";
    _sex=@"男";
    
}
-(void)womenBtnOnClick{
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].detailTextLabel.text=@"女";
    _sex =@"女";
    
}
#pragma mark   -------uitextfieldDelegate------
- (void)textFieldDidEndEditing:(UITextField *)textField{
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}
#pragma mark   -------alertViewdelegate------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==self.nameAlert) {
        //1 确定
        if (buttonIndex==1) {
            UITextField *textField =[alertView textFieldAtIndex:0];
            [self inputNameEnd:textField];
        }
    }
}
//昵称输入结束
-(void)inputNameEnd:(UITextField *)textField{
    NSString *str =textField.text;
    if (str.length==0) {
        //不做处理
        return;
    }else if (str.length<2){
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"昵称不得少于2个字符" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else if (str.length>8){
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"昵称不得大于8个字符" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //正常长度  检查非法字符
        BOOL has =  [self isHaveIllegalChar:str];
        if (has) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"您输入的昵称含有非法字符" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }else{
           
            _nike=str;
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel.text=str;
            [_detailTitleArr replaceObjectAtIndex:0 withObject:str];
        }
    }
    textField.text=@"";
}
- (BOOL)isHaveIllegalChar:(NSString *)str{
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    NSRange range = [str rangeOfCharacterFromSet:doNotWant];
    return range.location<str.length;
}

-(void)deleteImage{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    //设置一个图片的存储路径
    NSString *imagePath = [path stringByAppendingPathComponent:@"icon.png"];
          NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL success = [fileManager fileExistsAtPath:imagePath];
    if (success) {
        [fileManager removeItemAtPath:imagePath error:nil];
    }
    
}
//照相机
-(void)camera{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];

    
}
//本地相册
-(void)localPhoto{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag==101) {
        if (buttonIndex==0) {
            //0 男
            [self menBtnOnClick];
        }else if (buttonIndex ==1){
            //1 女
            [self womenBtnOnClick];
        }
        
    }else{
        if (buttonIndex==0) {
            //0 照相机
            [self camera];
            
        }else if (buttonIndex ==1){
            //1 本地相册
            [self localPhoto];
        }
        
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *smallImage = [self thumbnailWithImageWithoutScale:img size:CGSizeMake(150, 150)];
        self.personlIcon.image = smallImage;
        _userIamge =smallImage;

    }
    [picker dismissViewControllerAnimated:YES completion:nil];

}

//2.保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //上传用户更改的信息
}
@end
