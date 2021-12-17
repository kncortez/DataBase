/****** Object:  StoredProcedure [dbo].[DisableGuideBySettlementDispatched]    Script Date: 17/12/2021 11:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-17>
-- Description:	<Obtiene información  del Courier Man si ya se genero manifiesto de despacho en el día actual>
-- =============================================
CREATE PROCEDURE [dbo].[DisableGuideBySettlementDispatched]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN

	UPDATE dsd
	SET dsd.RowStatus = 'FALSE'
	FROM  DeliverySettlementDetail dsd
	JOIN DeliveryOrderBySettlement dobs 
		ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
	WHERE dsd.RowStatus = 'TRUE' 
		AND Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
		AND CONVERT(date,dobs.Date_Dispatched) = CONVERT(date, GETDATE())

	IF (@@ROWCOUNT > 0)
		SELECT 1 AS 'StatusCode',
				'Registro actualizado correctamente' AS 'Description',
				@@ROWCOUNT AS 'NumTransferID';
	ELSE
		SELECT 0 AS 'StatusCode',
				'Registro no encontrado' AS 'Description',
				0 AS 'NumTransferID';
END