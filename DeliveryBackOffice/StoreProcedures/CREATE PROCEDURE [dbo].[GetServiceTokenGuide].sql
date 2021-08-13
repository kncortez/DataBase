
CREATE PROCEDURE [dbo].[GetServiceTokenGuide]
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@GuideToken NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		DECLARE @jsonResult NVARCHAR(MAX) 
		set @jsonResult = (SELECT STUFF(( 
							SELECT  
							',{"receiverAddress":"' +  DO.Receiver_Address +
							+ '"}'

							FROM [dbo].[DeliveryOrder] DO
							INNER JOIN [dbo].[ServiceDataForGuide] SDFG
							ON DO.Guide_Serie = SDFG.Guide_Serie AND DO.Guide_Number = SDFG.Guide_Number
							WHERE SDFG.Guide_Token = @GuideToken
							AND DO.Guide_Number = @GuideNumber
							AND DO.Guide_Serie = @GuideSerie
							AND SDFG.DateUsed IS NULL
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )
		IF @jsonResult IS NULL
		BEGIN

			set @jsonResult =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":400,' 
							+ '"Message":" No se encontraron registros validos."}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		END
		select ('[' + @jsonResult +  ']') jsonResult 
	END TRY
	BEGIN CATCH
		DECLARE @jsonResultErrror NVARCHAR(MAX) 
		set @jsonResultErrror =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Message":" No se encontraron registros"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultErrror +  ']') jsonResultErrror 
	END CATCH
END
GO

