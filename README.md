# oss

本项目提供了用于访问 Aliyun OSS 的一些工具和自动备份的简单解决方案，基于阿里云官方的 [ossutil](https://github.com/aliyun/ossutil)。有关 Minecraft 在阿里云抢占式实例上的开服实践的相关介绍，可以阅读[这篇文档](./implementation.md)。

## 快速开始

在开始之前，你需要准备
- 一组具有所需权限（可以是 `AliyunOSSFullAccess`）的 AccessKeyId 和 AccessKeySecret
- 一个已经创建好的**与你的实例在相同地域的**阿里云 OSS Bucket

1. 下载本项目

```sh
git clone https://github.com/seatidemc/oss.git
cd oss
```

2. 给予权限

```sh
chmod +x backup/* utils/*
```

3. 编辑配置文件。只有正确配置才能正常使用功能。为了避免意外，请阅读[配置文件解读](#配置文件解读)部分。

```sh
mv config.example config
vim config

cd utils
mv oss-config.cfg.example oss-config.cfg
vim oss-config.cfg
```

4. 若要启用自动备份，请将 `backup` 添加到 crontab 中，具体运行周期可自定

```sh
crontab -e
```

```sh
# crontab 的内容
*/10 * * * * /path/to/backup
```

**注意：** 正式启用前，请自行测试一遍脚本和 crontab 任务是否可用，避免不必要的损失。如果一切准备就绪，脚本则开始运行。每次备份时，`backup` 脚本会将指定的文件夹（`config` 中的 `backup_local_dir`）复制到指定的位置（`config` 中的 `backup_dir`）下的一个命名为复制的时间（格式：`年-月-日_时:分:秒`）的文件夹。由于走的是内网，速度非常快（可以自己试一下），即使是大存档也没问题。

## 配置文件解读

1. `config`

```
# 最大备份数
max_keep_count=5
# 备份所在 OSS 地址，末尾不要带斜杠
backup_dir=
# 备份所在本地地址，末尾不要带斜杠
backup_local_dir=
```

- 最大备份数 — 允许在 OSS 上存在的最大备份数，**必须为正整数才能生效**
- 备份所在 OSS 地址 — 设置在 OSS 上的备份地址。格式为 `oss://<Bucket 名称>/<具体路径...>`
  - 例如如果要备份到 `example` 这个 bucket 里的 `/backups` 目录，那么就填 `oss://example/backups`
- 备份所在本地地址 — 设置要备份的本地地址。**必须是绝对路径**
  - 例如要备份 `/my-server` 这个目录，那么就填 `/my-server`

2. `oss-config.cfg`

```conf
[Credentials]
lang=ZH
accessKeyID=
accessKeySecret=
endpoint=
```

- `accessKeyID` — 填写生成的 AccessKeyId
- `accessKeySecret` — 填写生成的 AccessKeySecret
- `endpoint` — 填写**要备份到的 Bucket 的 `endpoint`**
  - `endpoint` 的值可以在 Bucket 的「概览」面板看到：![](https://i.loli.net/2021/06/20/Wy67Raq9hNPzxcu.png) 请确保使用地址中含有 `internal` 字样，否则传输将耗费大量时间。

## 项目结构

- `backup` — 包含与备份相关的脚本
- `utils` — 包含访问 OSS 相关的脚本

**utils 内脚本用途**

|名称|介绍|
|:-:|:-|
|`ossutil`|由阿里云官方提供的 `ossutil` 可执行文件|
|`oss`|用于带上当前的配置文件调用 `ossutil`|
|`osscp`|用法：`osscp ...args`，用于从 OSS 上复制文件到本地|
|`ossdl`|用法：`ossdl RemoteDir LocalDir`，用于从 OSS 上下载文件或者文件夹到本地|
|`ossgbc`|`gbc`=`getbackupcount`，用于获取当前备份的数量|
|`ossls`|用法：`ossls ...args`，用于列出 OSS 上的目录结构|
|`ossrmbk`|用法：`ossrmbk ...Name`，用于删除 OSS 上的某一备份，`Name` 处填写该备份的文件夹名称|
|`ossrmrf`|用法：`ossrmrf ...Name`，用于删除 OSS 上的文件夹或文件。**执行时不会询问是否继续。**|
|`ossul`|用法：`ossul LocalDir RemoteDir`，用于将本地的文件或者文件夹上传到 OSS 上的指定位置|

注：
1. `RemoteDir` 的写法为 `oss://<Bucket 名称>/<具体路径...>`
2. `LocalDir` 可用相对路径或者绝对路径
3. 若要调用 `utils` 文件夹下除了 `ossrmrf` 和 `ossutil` 以外的文件，必须先切换到 `utils` 目录

**backup 内脚本用途**

|名称|介绍|
|:-:|:-|
|`backup`|用于进行备份，应放在 crontab 中执行|
|`purge-outdated-backup`|用于删除超出限定的备份数量的备份|

注：
1. 若要让 `purge-outdated-backup` 正常工作，OSS 上的备份地址内不应有**任何人工创建的文件夹**，否则会导致删除顺序错误
2. 请确保权限设置正确（`755`），在加入 crontab 前应先测试一次，然后再测试一次 crontab，否则可能造成备份失效但未及时察觉导致数据损失的事故

## 协议

MIT

注：`ossutil` 本身也是 MIT 协议开源的。