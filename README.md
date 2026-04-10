# X-phor-ProDB

X-phor-ProDB 是一个数据库项目，使用 SQL Server Data Tools (SSDT) 进行数据库架构管理和版本控制。

## 项目简介

本项目包含数据库的结构定义（表、视图、存储过程、函数等），通过源代码管理对数据库变更进行跟踪和审计。

## 技术栈

- SQL Server
- SQL Server Data Tools (SSDT)
- Visual Studio

## 快速开始

### 前提条件

- Visual Studio（含 SQL Server Data Tools 组件）或 Azure Data Studio
- SQL Server（本地实例或远程实例）

### 本地开发

1. 克隆本仓库：

   ```bash
   git clone https://github.com/cdwolfling/X-phor-ProDB.git
   ```

2. 用 Visual Studio 打开 `.sqlproj` 项目文件。

3. 在 Visual Studio 中配置目标数据库连接字符串（在本地 `.publish.xml` 文件中设置，**不要**将其提交到版本库）。

4. 使用 **发布 (Publish)** 功能将数据库架构部署到目标数据库。

## 项目结构

```
X-phor-ProDB/
├── Tables/          # 数据表定义
├── Views/           # 视图定义
├── StoredProcedures/# 存储过程
├── Functions/       # 函数
├── Scripts/         # 数据迁移或初始化脚本
└── *.sqlproj        # SSDT 项目文件
```

## 贡献指南

1. 从 `main` 分支创建新的功能分支。
2. 在分支上进行数据库结构变更。
3. 提交 Pull Request，说明变更内容及原因。
4. 代码审查通过后合并到 `main` 分支。

## 注意事项

- `.dbmdl` 文件（数据库模型缓存文件）已加入 `.gitignore`，**请勿手动提交**。
- 包含数据库连接字符串的发布配置文件（`*.publish.xml`、`*.user`）已加入 `.gitignore`，**请勿提交敏感信息**。

## 许可证

本项目版权归作者所有，详见 LICENSE 文件。