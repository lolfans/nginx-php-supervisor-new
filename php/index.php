<?php
###env
##git_user
##git_passwd
###url?branch=xxx&dst_dir=xxx

$username = getenv('git_user');
$password = getenv('git_passwd');

if (!$username || !$password) {
    print_r('账号密码缺失!');
}
$username = str_replace('@', '%40', $username); //账号名中如果有@ 需要改为%40
$get_origin_data = file_get_contents("php://input");
if (!$get_origin_data) {
    print_r('数据异常');
}
print_r('---开始更新---');

$dataArray = json_decode($get_origin_data, true);
$branchEvent = str_replace('refs/heads/', '', $dataArray['ref']);    //提取分支名
$branch = $_GET['branch'];

if ($branchEvent != $branch) {
    print_r('提交分支与期望分支不吻合，不作自动部署处理') ;
}
$dir = $_GET['dst_dir'] ? $_GET['dst_dir'] : './';
if (! file_exists($dir)) {
    shell_exec('mkdir -p ' . $dir);
    print_r('---创建目录:'.$dir.'---') ;
}

$projectName = $dataArray['project']['name'];   //项目目录名称
$realProjectUrl = $dir . $projectName;

if (file_exists($realProjectUrl)) {    //更新
    print_r('---启动更新程序---') ;
    $command = 'cd ' . $realProjectUrl . ' && git fetch --all && git reset --hard origin/' . $branch . ' && chmod -R 777 ../' . $projectName;
} else {    //克隆
    print_r('---启动克隆程序---') ;
    $cloneUrl = $dataArray['project']['git_http_url'];   //克隆地址
    $completeUrl = str_replace('//', '//' . $username . ':' . $password . '@', $cloneUrl);  //带上账号密码
    $command = 'cd ' . $dir . ' && git clone ' . $completeUrl . ' && cd ' . $projectName . ' && git fetch --all && git checkout ' . $branch . ' && chmod -R 777 ../' . $projectName;
}
shell_exec($command);

$cmd = $_GET['cmd'] ? $_GET['cmd'] : ''; //放置代码更新后得额外脚本执行的脚本
if ($cmd) {
    $command = 'sh ' .$dir.'/'. $cmd .' '. $projectName;
    shell_exec($command);
    print_r($cmd.'脚本执行完毕!!!');
}

print_r('自动部署成功!!!');
