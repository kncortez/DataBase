
UPDATE dbo.RolByUserBySystem SET StationId = 1 WHERE StationId IS NULL

ALTER TABLE [dbo].[RolByUserBySystem] DROP CONSTRAINT PK__RolByUse__2DE2A72358A016F6
ALTER TABLE [dbo].[RolByUserBySystem] DROP CONSTRAINT PK_RolByUserBySystemByStation

ALTER TABLE dbo.RolByUserBySystem ALTER COLUMN StationId INTEGER NOT NULL


ALTER TABLE [dbo].[RolByUserBySystem] ADD CONSTRAINT PK_RolByUserBySystemByStation PRIMARY KEY CLUSTERED ([RusIdRol], [RusIdSystem], [RusIdUser],StationId) ON [PRIMARY]
GO