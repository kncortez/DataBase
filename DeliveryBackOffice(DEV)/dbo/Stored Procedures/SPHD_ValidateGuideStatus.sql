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

		DECLARE @Entregado INT=( SELECT StatusOrderId FROM [dbo].[StatusOrder] WITH (NOLOCK)  WHERE  OrderDescription='Entregado' )
		DECLARE @Anulado INT=( SELECT StatusOrderId FROM [dbo].[StatusOrder] WITH (NOLOCK)  WHERE  OrderDescription='Anulado' )
		DECLARE @Devuelto INT=( SELECT StatusOrderId FROM [dbo].[StatusOrder] WITH (NOLOCK) WHERE  OrderDescription='Devuelto' )
		DECLARE @EntregadoEnExpressCenter INT=( SELECT StatusOrderId FROM [dbo].[StatusOrder]  WITH (NOLOCK) WHERE  OrderDescription='Entregado En Express Center' )
		DECLARE @Terminal INT=(Select SO.StatusOrderId From [dbo].[DeliveryOrder] DO With (NOLOCK)
                                                                INNER JOIN 
																     [dbo].[StatusOrder] SO  WITH(NOLOCK)
																	 ON DO.StatusOrderId = SO.StatusOrderId
																WHERE
																[CatCheckpointTypeId] = 3 And SO.RowStatus= 1
																And DO.Guide_Serie +CAST(DO.Guide_Number  as NVARCHAR(20)) = @Guide)

       DECLARE @RESULT INT = 0;
	   DECLARE  @StatusName NVARCHAR(100);

	   DECLARE @DateStatus datetime= (Select Top 1 DOD.DateCreated
	                                                         From [dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK) 
															      Where DOD.Guide_Serie+CAST(DOD.Guide_Number  as NVARCHAR(20)) = @Guide Order by DOD.DateCreated desc) 

	SET NOCOUNT ON;

BEGIN TRY



SELECT         
       @STATUS = DO.StatusOrderId,
	   @Sender_Department   = Sender_Department,
	   @Receiver_Department = Receiver_Department,
       @Sender_Town = SenderIdTownship,
	   @Receiver_Town = ReceiverIdTownship,
	   @StatusName = SO.OrderDescription
FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK) 
 INNER JOIN 
	[dbo].[StatusOrder] SO  WITH(NOLOCK)
	ON DO.StatusOrderId = SO.StatusOrderId
WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide

declare @isreturnt bit =(
SELECT         
IsLastMileReturn
FROM [dbo].[DeliveryOrder] WITH (NOLOCK) 
WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide)

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


			IF (@STATUS  IN(@Entregado,@Anulado,@EntregadoEnExpressCenter,@Terminal))
			BEGIN

					SELECT Result = 1,@StatusName 'Status',CONVERT(NVARCHAR,@DateStatus,103) 'DateStatus' /* Estados no validos*/
				END
				    ELSE if (@isreturnt=1)
				           BEGIN

					          SELECT Result = 6, @StatusName 'Status',CONVERT(NVARCHAR,@DateStatus,103) 'DateStatus' /* Estados Devuelto*/
				  
			               END
				               ELSE
				                    BEGIN

				                          SELECT  Result = 0, @StatusName 'Status', CONVERT(NVARCHAR,@DateStatus,103) 'DateStatus'
				                    END
	END 
	   ELSE
	       BEGIN

				SELECT Result=5, @StatusName 'Status', CONVERT(NVARCHAR,@DateStatus,103) 'DateStatus' /*Municipios inactivos */

		   END

END
ELSE
	BEGIN

		SELECT Result = 3, @StatusName 'Status', CONVERT(NVARCHAR,@DateStatus,103) 'DateStatus' /* Guía no existe*/
	END



END TRY 
BEGIN CATCH

		SELECT Result = 4,/*Error de transacción*/
		       ERROR_MESSAGE() AS 'Description' 
END CATCH
END