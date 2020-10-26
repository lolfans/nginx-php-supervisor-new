# nginx-php-supervisor-new

以alpine作为基础镜像进行集成

制作NGINX+PHP环境镜像的方式 将代码克隆到docker环境的主机

git clone https://github.com/lolfans/nginx-php-supervisor-new.git


cd nginx-php-supervisor-new


docker build --no-cache -t nginx-php .


tips：注意最后的一个小点 不要忽略了


docker images 就能看见你的镜像了 放到任何环境都能运行 /var/www/html 是项目目录 可以以此镜像为基础镜像 将项目代码放到该目录下即可


对性能有更多要求 可以自行调整上面php文件夹与nginx文件夹下的对应文件

镜像地址: docker pull registry.cn-qingdao.aliyuncs.com/liudashuai/nginx-php-supervisor-new:latest

