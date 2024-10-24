-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-08>
-- Description:	<Delivery Tracking - Método para obtener información pública para rastreo de parquete.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTrackingPublic]
@GuideSerie NVARCHAR(4),
@GuideNumber INT
AS
BEGIN
BEGIN TRY

	--Encabezados
	DECLARE @EncabezadoRastreo TABLE (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		Nombre NVARCHAR(50),
		Descripcion NVARCHAR(255)
	);

	INSERT INTO @EncabezadoRastreo (Nombre, Descripcion)
	SELECT 'Creado por', '' UNION ALL --1
	SELECT 'Arribó a las instalaciones', 'Tu paquete ya está en nuestras instalaciones.' UNION ALL --2
	SELECT 'En ruta', 'Tu paquete está por ser entregado.' UNION ALL --3
	SELECT 'Entregado', 'Tu paquete ha sido entregado.'; --4

	--Iconos
	SELECT
		   NameStatusProcess AS 'label'
		 , Icon AS 'icon'
	FROM
	DeliveryBackOffice.dbo.CatStatusProcess WITH(NOLOCK)

	--Informacion pública
	SELECT
		  CONCAT(ISNULL(DO.Sender_FirstName,''), ' ',ISNULL(DO.Sender_LastName,'')) AS 'SenderName'
		, CONCAT(ISNULL(DO.Receiver_FirstName,''), ' ',ISNULL(DO.Receiver_LastName,'')) AS 'ReceiverName'
		, ISNULL(DO.ReceiverCountryId,'GT') AS 'Country'
		, SO.CatStatusProcessId AS 'StatusTracking'
		, ISNULL(ER.Nombre,'') AS 'StatusTrackingTitle'
		, ISNULL(ER.Descripcion,'') AS 'StatusTrackingDescription'
		,CASE 
			-- Caso 1: El número comienza con '+' y tiene al menos 11 dígitos (ej. +50244444444)
			WHEN LEFT(Receiver_Phone, 1) = '+' AND LEN(Receiver_Phone) >= 11 THEN 
				SUBSTRING(Receiver_Phone, 2, 3)

			-- Caso 2: El número comienza con un código de área sin '+' y tiene al menos 10 dígitos (ej. 50244444444)
			WHEN LEN(Receiver_Phone) >= 10 AND ISNUMERIC(LEFT(Receiver_Phone, 3)) = 1 THEN 
				LEFT(Receiver_Phone, 3)

			-- Caso 3: Si no tiene código de área válido, devuelve NULL (ej. 2345-6789)
			ELSE ISNULL(CP.[Value],'502')
		END AS 'AreaCode'
	FROM
	DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
		ON DO.StatusOrderId = SO.StatusOrderId
	LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH(NOLOCK)
		ON CP.[Name] = 'AreaCode' AND ISNULL(DO.ReceiverCountryId,'GT') = CP.IdCountry
	LEFT JOIN @EncabezadoRastreo  ER
		ON SO.CatStatusProcessId = ER.Id
	WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber

	DECLARE @StatusIncVal INT  = (
		SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder
		WHERE OrderDescription = 'Incidencia Validada'
	)

	DECLARE @CheckpointType INT = (
		SELECT IdCatCheckpointType FROM DeliveryBackOffice.dbo.CatCheckpointType
		WHERE CheckpointTypeDescription = 'Checkpoint final'
	)

	DECLARE @StatusProcessFinal INT = (
		SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess
		WHERE NameStatusProcess = 'Entregado'
	)
	
	DECLARE @f1 NVARCHAR(10) = (
		SELECT
			CASE
				WHEN 
					IsLastMileReturn = 1 OR
					(SELECT COUNT(CI.IdConfirmationOfIncidence) FROM DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
					 INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH(NOLOCK)
						ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
					 WHERE DA.Guide_Serie = @GuideSerie AND DA.Guide_Number = @GuideNumber 
						AND CI.StatusOrderId = @StatusIncVal AND CI.IsConfirmed = 1 AND CI.IsDenied = 0) > 1 --INTENTO DEVOLUCIONES
					OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
				THEN 'false'
				ELSE 'true'
			END AS 'flagRescheduleDelivery'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	);
	
	DECLARE @f2 NVARCHAR(10) = (
		SELECT
			CASE
				WHEN 
					IsLastMileReturn = 1 OR
					(SELECT COUNT(CI.IdConfirmationOfIncidence) FROM DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
					 INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH(NOLOCK)
						ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
					 WHERE DA.Guide_Serie = @GuideSerie AND DA.Guide_Number = @GuideNumber 
						AND CI.StatusOrderId = @StatusIncVal AND CI.IsConfirmed = 1 AND CI.IsDenied = 0) > 1 --INTENTO DEVOLUCIONES
					 OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
				THEN 'false'
				ELSE 'true'
			END AS 'flagChangeAdress'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	);
	
	DECLARE @f3 NVARCHAR(10) = (
		SELECT
			CASE
				WHEN 
					(C.TotalAmountPaid IS NOT NULL OR C.TotalAmountPaid != 0) -- ESTA PAGADA LA GUIA
					OR
					IIF(ISNULL(CCP.ConditionOfPayment, 'Contado') = 'Contado',0,1) = 1 -- NO TIENE CREDITO
					OR 
					SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
				THEN 'false'
				ELSE 'true'
			END AS 'flagPayDelivery'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		INNER JOIN DeliveryBackOffice.dbo.Customer CU WITH(NOLOCK)
			ON DO.IdCustomer = CU.IdCustomer
		LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment CCP WITH(NOLOCK)
			ON CU.ConditionOfPaymentID = CCP.IdConditionOfPayment
		LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
			ON DO.Guide_Serie = C.GuideSerie AND DO.Guide_Number = C.GuideNumber
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	);
	
	DECLARE @f4 NVARCHAR(10) = (
		SELECT
			CASE
				WHEN
					(SELECT CatCheckpointTypeId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK)
					 WHERE StatusOrderId = DO.StatusOrderId) = @CheckpointType --NO ESTAR EN ESTADO FINAL
					 OR SO.CatStatusProcessId = @StatusProcessFinal --LA GUÍA SE ENCUENTRA EN UN ESTADO ENTREGADO
					THEN 'false'
					ELSE 'true'
			END AS 'flagNotifications'
		FROM
		DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	);	
	
	--Banderas
	SELECT 
		  ISNULL(@f1,'false') AS 'flagRescheduleDelivery'
		, ISNULL(@f2,'false') AS 'flagChangeAdress'
		, ISNULL(@f3,'false') AS 'flagPayDelivery'
		, ISNULL(@f4,'false') AS 'flagNotifications'

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;