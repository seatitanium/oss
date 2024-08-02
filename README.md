# oss

本项目提供了用于访问阿里云 OSS 的一些工具和自动备份的简单解决方案，基于阿里云官方的 [ossutil](https://github.com/aliyun/ossutil)。~~有关 Minecraft 在阿里云抢占式实例上的开服实践的相关介绍，可以阅读[这篇文档](./implementation.md)。~~

## 快速开始

> [!NOTE]  
> 在开始之前，你需要准备
> - ossutil 本体
> - 一组具有所需权限（例如 `AliyunOSSFullAccess`）的 AccessKeyId 和 AccessKeySecret
> - 一个已经创建好的**与你的实例在相同地域的**阿里云 OSS Bucket

0. 安装并配置 ossutil

```sh
sudo -v ; curl https://gosspublic.alicdn.com/ossutil/install.sh | sudo bash
```

后执行 `ossutil config` 根据提示输入相应的参数可以快速生成配置文件，或者按照[配置文件解读](#配置文件解读)部分所述手动编写配置文件。

1. 下载本项目

```sh
git clone https://github.com/seatitanium/oss.git
cd oss
```

2. 给予权限

```sh
chmod +x ./oss
chmod +x backup/* utils/*
```

3. 编辑配置文件。只有正确配置才能正常使用功能。为了避免意外，请阅读[配置文件解读](#配置文件解读)部分。

```sh
mv config.example config
vim config
```

即可开始使用。

- `oss cp x y` 将 x 传输到 y
- `oss ls x` *remote-only* 列出远程目录下的文件。默认是列出所有的子目录和文件，添加参数 `-d` 可只列出当前目录下的文件和子目录，注意此时的 `x` 必须是以 `/` 结尾的。
- `oss get-backup-count` *argumentless* 获取现存备份数量
  - **别名** `gbc`
- `oss rmrf x` *remote-only* 删除远程目录下的文件或者目录
- `oss clear-backup(s)` *argumentless* ***DANGER*** 删除所有的备份文件
  - **别名** `cb`

> [!TIP]
> 在使用过程中，操作的对象既可以是本地路径也可以是远程路径。
> - 本地路径：本地的相对路径或者绝对路径
> - 远程路径：`oss://bucket名/目录`
>
> 例如在 `oss cp x y` 中，可以用 `oss cp ~/file oss://bucket/remotedir` 上传文件，也可以用 `oss cp oss://bucket/remotedir/remotefile.xyz ~` 下载文件。`recursive` 参数已经带上。


## 备份

`backup` 目录中，`purge-outdated-backup.sh` 用于在备份数量达到 `max_keep_count` 的时候删去较旧的备份，会被 `backup.sh` 自动调用。正常情况下，调用 `backup.sh` 会将指定的文件夹（`config` 中的 `backup_local_dir`）复制到指定的位置（`config` 中的 `backup_remote_dir`）下的一个命名为复制的时间（格式：`年-月-日_时:分:秒`）的文件夹，并删除旧的备份。ossutil 的配置中 endpoint 设定为内网可以大大加快这个过程。

可以考虑将 `backup.sh` 添加到 crontab 中实现自动备份。

```sh
crontab -e
```

```sh
# crontab 的内容
*/10 * * * * /path/to/backup.sh
```
> [!CAUTION]
> 1. 正式启用前，请自行测试一遍脚本和 crontab 任务是否可用，避免不必要的损失。如果一切准备就绪，脚本则开始运行。
> 2. 若要让 `purge-outdated-backup` 正常工作，OSS 上的备份地址内不应有**任何人工创建的文件夹**，否则会导致删除顺序错误

## 配置文件解读

1. `config`

```
# 最大备份数
max_keep_count=5
# 备份所在 OSS 地址，末尾不要带斜杠
backup_remote_dir=
# 备份所在本地地址，末尾不要带斜杠
backup_local_dir=
```

- 最大备份数 — 正整数，允许在 OSS 上存在的最大备份数
- 备份所在 OSS 地址 — 设置在 OSS 上的备份地址。格式为 `oss://bucket名/具体路径`
  - 例如如果要备份到 `example` 这个 bucket 里的 `/backups` 目录，那么就填 `oss://example/backups`
- 备份所在本地地址 — 设置要备份的本地地址。**必须是绝对路径**

2. ossutil 配置

ossutil 所用的配置文件默认路径为 `~/.ossutilconfig`，其内容为

```conf
[Credentials]
lang=CH
accessKeyID=
accessKeySecret=
endpoint=
```

- `accessKeyID` — 填写生成的 AccessKeyId
- `accessKeySecret` — 填写生成的 AccessKeySecret
- `endpoint` — 填写**要备份到的 Bucket 的 `endpoint`**
  - `endpoint` 的值可以在 Bucket 的「概览」面板看到：![](https://i.loli.net/2021/06/20/Wy67Raq9hNPzxcu.png) 请确保使用地址中含有 `internal` 字样，否则传输将耗费大量时间。

## 协议

MIT

注：ossutil 本身也是 MIT 协议开源的。