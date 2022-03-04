USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetUserByExpressCenter]    Script Date: 4/03/2022 16:23:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-03>
-- Description:	<Recupera información de Express center y los usuarios de express center para form ClosureReport>
-- =============================================
CREATE PROCEDURE [dbo].[GetUserByExpressCenter]
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CodeOfReference IdVisitPointClient
		,DescriptionOfClient 
	FROM VisitPointClient
	WHERE IdKindOfVPClient = 1
	AND StatusClient = 1
	ORDER BY DescriptionOfClient

	SELECT
		vpc.CodeOfReference IdVisitPointClient
	   ,rua.RuaIdAccount
	   ,CONCAT(vpc.DescriptionOfClient, ' - ', rus.UsrEmail) Usuario
	FROM dbo.VisitPointByUser vpu
	JOIN dbo.RegisterUser rus
		ON rus.UsrIdUser = vpu.RegisterUserID
			AND vpu.RowStatus = 1
	JOIN dbo.RolByUserByAccount rua
		ON rua.RuaIdUser = rus.UsrIdUser
			AND vpu.RowStatus = 1
	JOIN dbo.VisitPointClient vpc
		ON vpc.IdVisitPointClient = vpu.IdVisitPointClient
			AND IdKindOfVPClient = 1
			AND StatusClient = 1
	WHERE vpu.RowStatus = 1
	ORDER BY vpc.DescriptionOfClient
END
