DECLARE @IndividualTypeId INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'INDIVIDUAL')
DECLARE @GuideCreationTutorialId INT = (SELECT TOP 1 Tut.IdTutorial FROM [DeliveryBackOffice].[dbo].[Tutorial] Tut WITH(NOLOCK) WHERE Tut.TutorialName = 'Creación de guías' COLLATE Latin1_General_CI_AI)

INSERT INTO [DeliveryBackOffice].[dbo].[TutorialByAccount]
	(AccountId, TutorialId, ToDisplay, DateCreated, TokenCreated)
SELECT
	Acc.AccIdAccount, @GuideCreationTutorialId, 1, GETDATE(), 'SYS-ARUIZ'
FROM
	[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			Acc.IdCustomer = Cu.IdCustomer
			AND
			Cu.IdCustomerType = @IndividualTypeId;