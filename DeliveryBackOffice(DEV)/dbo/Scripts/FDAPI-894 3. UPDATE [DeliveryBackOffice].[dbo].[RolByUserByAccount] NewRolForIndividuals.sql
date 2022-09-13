
DECLARE @HermesWebSystemId INT = (
	SELECT
		TOP 1
			CS.SysIdSystem
	FROM
		[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK)
	WHERE
		CS.SysNameSystem = 'Hermes Web' COLLATE Latin1_General_CI_AI
)

DECLARE @NewIndRol INT = (
	SELECT 
		TOP 1 
			CR.RolIdRol
	FROM 
		[DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) 
	WHERE 
		CR.RolName = 'Nuevo estandar' COLLATE Latin1_General_CI_AI 
		AND 
		CR.RolIdSystem = @HermesWebSystemId 
		AND 
		CR.RolRowStatus = 1
)


UPDATE
	RBUBA
SET
	RBUBA.RuaIdRol = @NewIndRol,
	RBUBA.RuaTokenUpdated = 'SYS-ARUIZ',
	RBUBA.RuaDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
		ON
			RBUBA.RuaIdAccount = Acc.AccIdAccount
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			Acc.IdCustomer = Cu.IdCustomer
WHERE
	Cu.IdCustomerType = 3