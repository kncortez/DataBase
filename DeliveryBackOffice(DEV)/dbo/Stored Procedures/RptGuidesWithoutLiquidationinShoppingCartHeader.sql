
-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-03-03>
-- Description:	<Description, SP para cabecera de reporte de guías que no estan liquidadas y no son collect>
-- =============================================
CREATE PROCEDURE [dbo].[RptGuidesWithoutLiquidationinShoppingCartHeader] 
@IdConflictManifest int	
AS
BEGIN

	    
	    DECLARE @temp TABLE (
		Liquidator	nvarchar(max),
		Courier nvarchar(201),	
		SettlementDate datetime,
        NumberofGuides int,
	    TotalAmount  Decimal(18,2)
	                         )
		DECLARE @GuideCount INT

	SET NOCOUNT ON;

	SET @GuideCount = (
		
						select ISNULL(COUNT(CMD.GuideNumber),0)
							  from [dbo].[ConflictManifestDetail] CMD With(Nolock)
									WHERE ConflictManifestId = @IdConflictManifest
					)


	

	-- tablix content
	INSERT INTO @temp

		SELECT 
		    CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username,
		    isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,''),
			CM.DateCreated,
			@GuideCount,
			CM.TotalAmount
		FROM [DeliveryBackOffice].[dbo].[ConflictManifest] CM WITH(NOLOCK)
		     INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sr 
		ON   CM.CourierResponsible = sr.ID
		     INNER JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] lbt 
		ON lbt.SSN_IdToken = CM.TokenCreated
		WHERE CM.IdConflictManifest = @IdConflictManifest
	





SELECT Liquidator,
       Courier,
	   SettlementDate,
	   NumberofGuides,
	   TotalAmount,
	   @IdConflictManifest
FROM @temp
	order by SettlementDate desc

	


END