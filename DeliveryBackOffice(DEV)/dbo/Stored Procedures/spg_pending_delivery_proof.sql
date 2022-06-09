

-- =============================================
-- Author:		<Carlos,,Cano>
-- Create date: <10 Agosto 2020>
-- Description:	<Lista todas las pruebas pendientes de validar para el día en curso>
-- =============================================
-- Modified:	<Alberto,Ixchop>
-- Create date: <25-01-2022>
-- Description:	<Optimización de sp>
-- =============================================
CREATE PROCEDURE [dbo].[spg_pending_delivery_proof]
	-- Add the parameters for the stored procedure here
	@IdCourier INT,
	@DispatchedDate DATE=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
	DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR) AS Guide,
	DATT.ID_Courier,
	DATT.Date_Created AS Fecha_Despacho,
	DATT.ID_Proof,
	ISNULL(DO.Receiver_FirstName,'') + ' ' + ISNULL(DO.Receiver_LastName,'') AS Receiver_Name,
	SO.OrderDescription AS Status_Name,
	SUM(CAST(DATT.Dry AS INT)) AS Pieces_Dry,
	SUM(CAST(DATT.Cold AS INT)) AS Pieces_Cold
	FROM DeliveryBackOffice.dbo.DeliveryOrder DO
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DATT ON DO.Guide_Serie = DATT.Guide_Serie AND DO.Guide_Number = DATT.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.StatusOrder SO ON so.StatusOrderId = do.StatusOrderId
	WHERE (DATT.Delivered = 1 OR DATT.ID_Incident IS NOT NULL)
	AND (Accepted IS NULL OR Accepted <> 1)
	AND CONVERT(DATE,DATT.Date_Created)=CONVERT(DATE,ISNULL(@DispatchedDate,GETDATE()))
	AND DATT.ID_Courier=@IdCourier
	GROUP BY DO.Guide_Serie, DO.Guide_Number,DATT.ID_Courier,
		DATT.Date_Created,DATT.ID_Proof,DO.Receiver_FirstName,DO.Receiver_LastName,
		SO.OrderDescription,DATT.Dry,DATT.Cold;
END
