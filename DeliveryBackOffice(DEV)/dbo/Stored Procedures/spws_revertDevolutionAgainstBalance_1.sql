-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2025-01-09>
-- Description:	<Revertir proceso de devolucion sobre una guia para COD Anticipado en saldo en contra para cuenta de cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spws_revertDevolutionAgainstBalance]
    @GuideSerie VARCHAR(2) = 'FD',
	@GuideNumber INT,
	@Token VARCHAR(150)
AS
BEGIN

	DECLARE @AgaintsBalanceRestore DECIMAL(18,2) = 0,
	        @AnticipatedCODHeaderId INT = 0;

	-- SE OBTIENE EL VALOR DE SALDO EN CONTRA A DESCONTAR DE LA CUENTA DEL CLIENTE, QUE YA FUE PAGADO
	SET @AgaintsBalanceRestore = 
	(
		SELECT  AgaintsBalancePaid
		FROM    DeliveryBackOffice.dbo.AnticipatedCODDetail
		WHERE   GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
	)

	--OBTENER EL IDENTIFICADOR DEL REGISTRO DE LA CUENTA DEL CLIENTE QUE MANEJA EL BALANCE Y SALDO EN CONTRA
	SET @AnticipatedCODHeaderID =  
	(
		SELECT  AnticipatedCODHeaderId
		FROM    DeliveryBackOffice.dbo.AnticipatedCODDetail
		WHERE   GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
	)

	-- SE ACTUALIZA EL SALDO Y ESTADO DE PAGO DE LA GUIA, REVIRTIENDO LA DEVOLUCION REALIZADA
	UPDATE  DeliveryBackOffice.dbo.AnticipatedCODDetail
	SET     AgaintsBalancePaid = 0,
	        IsAgaintsBalancePaid = 0,
	        BalanceStatus = 'PAGADO',
			TokenUpdated = @Token,
			DateUpdated = GETDATE()
	WHERE   GuideSerie = @GuideSerie
	AND	    GuideNumber = @GuideNumber

	-- SE ACTUALIZA EL SALDO EN CONTRA DE LA CUENTA DEL CLIENTE SOBRE LA GUIA REVERTIDA
	UPDATE  DeliveryBackOffice.dbo.AnticipatedCODHeader
	SET	    AgaintsBalance = AgaintsBalance - @AgaintsBalanceRestore,
	        TokenUpdated = @Token,
	        DateUpdated = GETDATE()
	WHERE   IdAnticipatedCODHeader = @AnticipatedCODHeaderId

END;