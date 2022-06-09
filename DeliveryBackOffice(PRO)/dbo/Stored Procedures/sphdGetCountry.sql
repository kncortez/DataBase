
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-19-04>
-- Description:	<Obtiene el listado de paises segun Id>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCountry] 
	-- Add the parameters for the stored procedure here
	@IdCountry AS VARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Id_Country AS VARCHAR(2)
	SET @Id_Country = @IdCountry  

    -- Insert statements for procedure here
	/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT   [IdCountry]  [IdValue]
			,UPPER([CountryNameES])  [NameValue]
	FROM [DeliveryBackOffice].[dbo].[CatCountry]
	WHERE CountryRowStatus  = 'TRUE'
	AND IdCountry = @Id_Country 
	
END
