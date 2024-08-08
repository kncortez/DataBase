-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-03>
-- Description:	<Recupera información de Express center y los usuarios de express center para form ClosureReport>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-05>
-- Description:	<Se agrega filtro de pais para los express center>
-- =============================================
CREATE PROCEDURE [dbo].[GetUserByExpressCenter]
			    @IdCountry NVARCHAR(2) = 'GT'
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
	AND StatusClient = 1 AND ISNULL(CountryId,'GT') = @IdCountry
	ORDER BY DescriptionOfClient

	SELECT
		vpc.CodeOfReference IdVisitPointClient
	   ,rua.RuaIdAccount
	   ,CONCAT(vpc.DescriptionOfClient, ' - ', rus.UsrEmail) Usuario
	FROM dbo.VisitPointByUser vpu
	JOIN dbo.RegisterUser rus
		ON rus.UsrIdUser = vpu.RegisterUserID
			AND RUS.UsrRowStatus = 1
	JOIN dbo.RolByUserByAccount rua
		ON rua.RuaIdUser = rus.UsrIdUser
			AND vpu.RowStatus = 1
	JOIN dbo.VisitPointClient vpc
		ON vpc.IdVisitPointClient = vpu.IdVisitPointClient
			AND IdKindOfVPClient = 1
			AND StatusClient = 1
	WHERE vpu.RowStatus = 1 
	AND ISNULL(vpc.CountryId,'GT') = @IdCountry
	ORDER BY vpc.DescriptionOfClient
END



SELECT * FROM dbo.RolByUserByAccount
WHERE RuaIdAccount = 21512

UPDATE dbo.RegisterUser
SET	 UsrRowStatus = 0
WHERE UsrIdUser = 22036
