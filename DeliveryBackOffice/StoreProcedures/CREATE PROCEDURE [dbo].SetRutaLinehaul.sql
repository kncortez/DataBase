USE [DeliveryBackOffice]
GO

IF EXISTS (SELECT
			*
		FROM sysobjects
		WHERE ID = OBJECT_ID(N'[dbo].[SetRutaLinehaul]')
		AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE [dbo].SetRutaLinehaul
END

GO

CREATE PROCEDURE [dbo].SetRutaLinehaul
		@coderoute varchar(100)
		,@origen varchar(100)
		,@destino varchar(100)
AS
BEGIN
DECLARE  @IDCATROUTE AS INT

IF((SELECT ISNULL(COUNT(1),0) FROM HubLogistics WHERE HubAbbreviation = @destino ) = 0)
BEGIN

INSERT INTO [dbo].[HubLogistics]
           ([HubName]
           ,[HubAbbreviation]
           ,[HubStatus]
           ,[IdStation]
           ,[IdCountry]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IsGateway])
     VALUES
           (@destino
           ,@destino
           ,1
           ,NULL
           ,'GT'
           ,'SYS-MJIMENEZ'
           ,GETDATE()
           ,NULL
           ,NULL
           ,0
		   )

END


IF((SELECT ISNULL(COUNT(1),0) FROM [CatRoute] WHERE CodeRoute = @coderoute ) = 0)
BEGIN
INSERT INTO [dbo].[CatRoute]
           ([CodeRoute]
           ,[Description]
           ,[IdTownship]
           ,[IdTypeRoute]
           ,[Zone]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@coderoute
           ,@coderoute
           ,NULL
           ,2
           ,NULL
           ,1
           ,'SYS-JM'
           ,GETDATE()
           ,NULL
           ,NULL
		   )
 SET @IDCATROUTE = SCOPE_IDENTITY();
END

IF((SELECT ISNULL(COUNT(1),0) FROM CatLinehaul WHERE IdRoute = @IDCATROUTE ) = 0)
BEGIN

INSERT INTO [dbo].[CatLinehaul]
           ([IdRoute]
           ,[IdHubOrigin]
           ,[IdHubDestination]
           ,[Emails]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT ISNULL(IdRoute,0) FROM [CatRoute] WHERE CodeRoute = @coderoute)
           ,( select hl_o.IdHubLogistic
	from HubLogistics hl_o
	where hl_o.HubAbbreviation = @origen)
           ,( select hl_d.IdHubLogistic
	from HubLogistics hl_d
	where hl_d.HubAbbreviation = @destino)
           ,'marco.jimenez@forzalatam.com, makopruebas@gmail.com'
           ,1
           ,'SYS-MJ'
           ,GETDATE()
           ,NULL
           ,NULL
		   )
END



END


