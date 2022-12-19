-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<SP para Validar estado de guia para marcar como devuleto>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateGuideStatus] 
@Guide AS NVARCHAR(20)
AS
BEGIN
		DECLARE @STATUS AS INT; 
	SET NOCOUNT ON;

  SELECT TOP 1 @STATUS = StatusOrderId
				   FROM dbo.DeliveryOrderDetail WITH (NOLOCK)
				   WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide
				   ORDER BY DateCreated DESC

IF (EXISTS(SELECT TOP 1 1 FROM dbo.DeliveryOrder DDO WITH (NOLOCK) WHERE   DDO.Guide_Serie+CAST(DDO.Guide_Number AS nvarchar) = @Guide))
BEGIN

			IF (@STATUS  IN(22,5,7,14))
			BEGIN

					SELECT Result = 1
				END
				   ELSE
				   BEGIN

					SELECT Result = 0
				  
			    END
END
ELSE
	BEGIN

		SELECT Result = 3
	END
END