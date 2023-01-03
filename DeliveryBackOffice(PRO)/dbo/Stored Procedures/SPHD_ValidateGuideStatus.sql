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
		DECLARE @Sender_Department AS NVARCHAR(150);
		DECLARE @Receiver_Department AS NVARCHAR(150);
		DECLARE @Sender_Town  AS INT;
		DECLARE @Receiver_Town AS INT;


	SET NOCOUNT ON;

BEGIN TRY



SELECT         
       @STATUS = StatusOrderId,
	   @Sender_Department   = Sender_Department,
	   @Receiver_Department = Receiver_Department,
       @Sender_Town = SenderIdTownship,
	   @Receiver_Town = ReceiverIdTownship
FROM [dbo].[DeliveryOrder] WITH (NOLOCK) 
WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide

IF (EXISTS(SELECT TOP 1 1 
		   FROM [dbo].[DeliveryOrder] DDO WITH (NOLOCK)
           INNER JOIN 
               [dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
           ON  DDO.Guide_Number = DOP.GuideNumber  
           WHERE DDO.Guide_Serie+CAST(DDO.Guide_Number AS nvarchar)  = @Guide))
BEGIN


    IF ((EXISTS(SELECT TOP 1 1
                FROM [DeliveryBackOffice].[dbo].[Township] WITH (NOLOCK)
                WHERE IdTownship = @Sender_Town
				AND IdProvince = (
                          SELECT TOP 1  IdProvince
                          FROM [DeliveryBackOffice].[dbo].[Province] WITH (NOLOCK)
                          WHERE ProvinceName = @Sender_Department COLLATE Latin1_General_CI_AI
                      )
					  AND [DeliveryBackOffice].[dbo].[Township].TownshipStatus=1)) 
					  AND
		(EXISTS(SELECT TOP 1 1
                FROM [DeliveryBackOffice].[dbo].[Township] WITH (NOLOCK)
                WHERE IdTownship = @Receiver_Town
				AND IdProvince = (
                          SELECT TOP 1  IdProvince
                          FROM [DeliveryBackOffice].[dbo].[Province] WITH (NOLOCK)
                          WHERE ProvinceName= @Receiver_Department COLLATE Latin1_General_CI_AI
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



END TRY 
BEGIN CATCH

		SELECT Result = 4,/*Error de transacción*/
		       ERROR_MESSAGE() AS 'Description' 
END CATCH
END