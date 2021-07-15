USE [DeliveryBackOffice]
GO
---PAso 1 Creacion de rol
INSERT INTO [dbo].[CatRol]
           ([RolIdSystem]
           ,[RolName]
           ,[RolDescription]
           ,[RolAdminBrothers]
           ,[RolAdminClient]
           ,[RolRowStatus]
           ,[RolTokenCreated]
           ,[RolDateCreated]
           ,[RolokenUpdated]
           ,[RolDateUpdated])
     VALUES
           (1
           ,'ADMINISTRACION Y CIERRES EXC PORTAL WEB'
           ,'ADMINISTRACION Y CIERRES EXC PORTAL WEB'
           ,'TRUE'
           ,'FALSE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

	--SELECT * FROM  [dbo].[CatRol]
	--SELECT * FROM dbo.CatSystem

--Paso 2 Asignacion de modulos a rol
INSERT INTO dbo.RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsTokenUpdated,
    RmsDateUpdated
)
SELECT 5, RmsIdSystem,RmsIdModule,RmsRowStatus, 'SYS-ERAMIREZ', GETDATE(), NULL, NULL FROM dbo.RolByModuleBySystem WHERE RmsIdRol = 4


SELECT * FROM dbo.CatModule 
/*
Rol System	Module Status
5	1		1		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		2		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		4		0	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		5		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		6		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		7		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		8		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		10		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		24		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		27		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
5	1		28		1	SYS-ERAMIREZ	2021-07-13 16:09:31.220	NULL	NULL
*/


--el LOGIN me trae los accesos al modulo y al rol por sistema


--SELECT * FROM dbo.RegisterUser 
	--RolByUserBySystem
	--RolByUserByAccount
--Paso 3 Asignacion usuario a rol y a sistema
	INSERT INTO dbo.RolByUserBySystem
(
    RusIdRol,
    RusIdSystem,
    RusIdUser,
    RusRowStatus,
    RusTokenCreated,
    RusDateCreated,
    RusTokenUpdated,
    RusDateUpdated
)
VALUES
(   5,         -- RusIdRol - int
    1,         -- RusIdSystem - int
    21,         -- RusIdUser - bigint
    'TRUE',      -- RusRowStatus - bit
    'SYS-ERAMIREZ',        -- RusTokenCreated - varchar(50)
    GETDATE(), -- RusDateCreated - datetime
    NULL,      -- RusTokenUpdated - varchar(50)
    NULL       -- RusDateUpdated - datetime
    )


--	INSERT INTO dbo.RolByUserBySystem
--(
--    RusIdRol,
--    RusIdSystem,
--    RusIdUser,
--    RusRowStatus,
--    RusTokenCreated,
--    RusDateCreated,
--    RusTokenUpdated,
--    RusDateUpdated
--)
--VALUES
--(   5,         -- RusIdRol - int
--    1,         -- RusIdSystem - int
--    66,         -- RusIdUser - bigint
--    'TRUE',      -- RusRowStatus - bit
--    'SYS-ERAMIREZ',        -- RusTokenCreated - varchar(50)
--    GETDATE(), -- RusDateCreated - datetime
--    NULL,      -- RusTokenUpdated - varchar(50)
--    NULL       -- RusDateUpdated - datetime
--    )

--Paso 4 Asignacion usuario a rol y a idaccount 
INSERT INTO dbo.RolByUserByAccount
(
    RuaIdRol,
    RuaIdUser,
    RuaIdAccount,
    RuaRowStatus,
    RuaTokenCreated,
    RuaDateCreated,
    RuaTokenUpdated,
    RuaDateUpdated
)
VALUES
(   5,         -- RuaIdRol - int
    21,         -- RuaIdUser - bigint
    21,         -- RuaIdAccount - bigint
    'TRUE',      -- RuaRowStatus - bit
    'SYS-ERAMIREZ',        -- RuaTokenCreated - varchar(50)
    GETDATE(), -- RuaDateCreated - datetime
    NULL,      -- RuaTokenUpdated - varchar(50)
    NULL       -- RuaDateUpdated - datetime
    )


--INSERT INTO dbo.RolByUserByAccount
--(
--    RuaIdRol,
--    RuaIdUser,
--    RuaIdAccount,
--    RuaRowStatus,
--    RuaTokenCreated,
--    RuaDateCreated,
--    RuaTokenUpdated,
--    RuaDateUpdated
--)
--VALUES
--(   5,         -- RuaIdRol - int
--    66,         -- RuaIdUser - bigint
--    45,         -- RuaIdAccount - bigint
--    'TRUE',      -- RuaRowStatus - bit
--    'SYS-ERAMIREZ',        -- RuaTokenCreated - varchar(50)
--    GETDATE(), -- RuaDateCreated - datetime
--    NULL,      -- RuaTokenUpdated - varchar(50)
--    NULL       -- RuaDateUpdated - datetime
--    )
/*
SELECT * FROM dbo.Account
SELECT * FROM dbo.InternalUser
*/
