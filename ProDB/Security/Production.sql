-- Login_Production.sql
CREATE LOGIN [Production]
WITH PASSWORD = 'YourStrongPasswordHere',
     CHECK_POLICY = ON,
     CHECK_EXPIRATION = OFF;
GO

-- User_Production.sql
CREATE USER [Production] FOR LOGIN [Production];
GO

-- 可以单独文件做权限

GO
