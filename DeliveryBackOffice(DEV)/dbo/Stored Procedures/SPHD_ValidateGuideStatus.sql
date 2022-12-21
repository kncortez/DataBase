-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<SP para Validar estado de guia para marcar como devuleto>
-- =============================================
-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<Validaciones de datos de guía antes de devolución>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateGuideStatus] 
@Guide AS NVARCHAR(20)
AS
BEGIN
		DECLARE @STATUS AS INT; 
		DECLARE @Sender_Department AS NVARCHAR(50);
		DECLARE @Receiver_Department AS NVARCHAR(50);
		DECLARE @Sender_Town  AS NVARCHAR(50);
		DECLARE @Receiver_Town AS NVARCHAR(50);


	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION
SELECT TOP 1 @STATUS = StatusOrderId
				   FROM dbo.DeliveryOrderDetail WITH (NOLOCK)
				   WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide
				   ORDER BY DateCreated DESC

SELECT         
	   @Sender_Department   = Sender_Department,
	   @Receiver_Department = Receiver_Department,
       @Sender_Town = Sender_Town,
	   @Receiver_Town = Receiver_Town
FROM [dbo].[DeliveryOrder] WITH (NOLOCK) 
WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide

IF (EXISTS(SELECT TOP 1 1 FROM dbo.DeliveryOrder DDO WITH (NOLOCK) WHERE   DDO.Guide_Serie+CAST(DDO.Guide_Number AS nvarchar) = @Guide))
BEGIN


    IF ((EXISTS(SELECT TOP 1 1
                FROM [DeliveryBackOffice].[dbo].[Township] WITH (NOLOCK)
                WHERE DeliveryBackOffice.dbo.FnClearString(TownshipName) = @Sender_Town
				AND IdProvince = (
                          SELECT TOP 1  IdProvince
                          FROM [DeliveryBackOffice].[dbo].[Province] WITH (NOLOCK)
                          WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = @Sender_Department
                      )
					  AND [DeliveryBackOffice].[dbo].[Township].TownshipStatus=1)) 
					  AND
		(EXISTS(SELECT TOP 1 1
                FROM [DeliveryBackOffice].[dbo].[Township] WITH (NOLOCK)
                WHERE DeliveryBackOffice.dbo.FnClearString(TownshipName) = @Receiver_Town
				AND IdProvince = (
                          SELECT TOP 1  IdProvince
                          FROM [DeliveryBackOffice].[dbo].[Province] WITH (NOLOCK)
                          WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = @Receiver_Department
                      )
					  AND [DeliveryBackOffice].[dbo].[Township].TownshipStatus=1)))
	BEGIN
			IF (@STATUS  IN(22,5,7,14))
			BEGIN

					SELECT Result = 1 /* Estados no validos*/
				END
				   ELSE
				   BEGIN

					SELECT Result = 0 /* Estados Validos*/
				  
			    END
	END 
	   ELSE
	       BEGIN

				SELECT Result=5 /*Municipios inactivos */

		   END

END
ELSE
	BEGIN

		SELECT Result = 3 /* Guía no existe*/
	END

COMMIT TRANSACTION

END TRY 
BEGIN CATCH

		ROLLBACK
		SELECT Result = 4,/*Error de transacción*/
		       ERROR_MESSAGE() AS 'Description' 
END CATCH
END