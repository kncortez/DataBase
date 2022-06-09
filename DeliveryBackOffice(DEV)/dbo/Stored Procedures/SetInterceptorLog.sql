
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-11>
-- Description:	< Permite guardar en bitácora las peticiones web realizadas >
-- =============================================

CREATE PROCEDURE [dbo].[SetInterceptorLog] 
	@PetitionMethod nvarchar(10),
	@PetitionUrl nvarchar(300),
	@PetitionDate DATE,

	@RequestHeader NVARCHAR(2500),
	@RequestBody NVARCHAR(MAX),
	@RequestLauValue NVARCHAR(100),
	@RequestTime DATETIME,

	@ResponseHeader NVARCHAR(2500),
	@ResponseStatusCode INT,
	@ResponseBody NVARCHAR(MAX),
	@ResponseLauValue NVARCHAR(100),
	@ResponseTime DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	INSERT INTO [DeliveryBackOffice].[dbo].[HttpInterceptorLog]
           ([PetitionMethod]
           ,[PetitionUrl]
           ,[PetitionDate]
           ,[RequestHeader]
           ,[RequestBody]
           ,[RequestLauValue]
           ,[RequestTime]
           ,[ResponseHeader]
           ,[ResponseStatusCode]
           ,[ResponseBody]
           ,[ResponseLauValue]
           ,[ResponseTime])
     VALUES
           (@PetitionMethod,
            @PetitionUrl, 
            @PetitionDate,
            @RequestHeader, 
            @RequestBody, 
            @RequestLauValue, 
            @RequestTime, 
            @ResponseHeader, 
            @ResponseStatusCode, 
            @ResponseBody, 
            @ResponseLauValue, 
            @ResponseTime)
			
	SELECT  @@IDENTITY AS 'ID'
END
