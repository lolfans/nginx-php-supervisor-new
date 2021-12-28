<?php
###env
##git_user
##git_passwd
###url?branch=xxx&dst_dir=xxx

$fileName = 'hook.log';   //自动部署过程的日志文件
$prefix = ' --- ';      //日志分割符，便于观察

$username = getenv('git_user');
$password = getenv('git_passwd');

if (!$username || !$password) {
    print_r('账号密码缺失!');
}
$username = str_replace('@', '%40', $username); //账号名中如果有@ 需要改为%40

file_put_contents($fileName, date('Y-m-d : H:i:s') . $prefix . 'auto update code starting!' . PHP_EOL, FILE_APPEND);
$get_origin_data = file_get_contents("php://input");

if (!$get_origin_data) {
    throw new Exception('数据异常');
}
$dataArray = json_decode($get_origin_data, true);
$branchEvent = str_replace('refs/heads/', '', $dataArray['ref']);    //提取分支名
$branch = $_GET['branch'];
if ($branchEvent != $branch) {
    throw new Exception('提交分支与期望分支不吻合，不作自动部署处理');
}

$dir = $_GET['dst_dir'] ? $_GET['dst_dir'] : './';
if (! file_exists($dir)) {
    shell_exec('mkdir -p ' . $dir);
}

$projectName = $dataArray['project']['name'];   //项目目录名称
$realProjectUrl = $dir . $projectName;

file_put_contents($fileName, date('Y-m-d : H:i:s') . $prefix . $realProjectUrl. PHP_EOL, FILE_APPEND);
if (file_exists($realProjectUrl)) {    //更新
    $command = 'cd ' . $realProjectUrl . ' && git fetch --all && git reset --hard origin/' . $branch . ' && chmod -R 777 ../' . $projectName;
} else {    //克隆
    $cloneUrl = $dataArray['project']['git_http_url'];   //克隆地址
    $completeUrl = str_replace('//', '//' . $username . ':' . $password . '@', $cloneUrl);  //带上账号密码
    $command = 'cd ' . $dir . ' && git clone ' . $completeUrl . ' && cd ' . $projectName . ' && git fetch --all && git checkout ' . $branch . ' && chmod -R 777 ../' . $projectName;
}
file_put_contents($fileName, date('Y-m-d : H:i:s') . $prefix .$command  . PHP_EOL, FILE_APPEND);
shell_exec($command);

file_put_contents($fileName, date('Y-m-d : H:i:s') . $prefix . 'auto update code Done!' . PHP_EOL, FILE_APPEND);
print_r('自动部署成功！');
