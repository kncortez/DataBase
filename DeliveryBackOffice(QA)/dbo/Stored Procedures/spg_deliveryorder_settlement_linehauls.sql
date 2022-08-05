
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-07-26>
-- Description:	< Mejora de rendimiento del SP, adicionando WITH(NOLOCK) y especificando tipos de JOIN >
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_linehauls]
		@IdManifest INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		'ML' + cast(dobs.SequenceCode as varchar(10)) as ID, 
		dobs.DateCreated as Date_Dispatched, 
		dobs.PiecesDry as Pieces_Dry_Dispatched, 
		dobs.PiecesCold as Pieces_Cold_Dispatched, 
		dobs.GuidesQuantity Guides_Dispatched,
		sr.First_Name + ' ' + sr.Last_Name as Courier_Name,
		dobs.DateCreated as Route_Dispatched,
		CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Dispatched,
		ISNULL(hl_destino.HubAbbreviation, 0) AS ID_HUB_DESTINO
	FROM 
		[DeliveryBackOffice].[dbo].SettlementByPickup dobs WITH(NOLOCK)
		INNER JOIN 
			[DeliveryBackOffice].[dbo].ServiceManagement sm  WITH(NOLOCK)
			ON 
				sm.IdServiceManagement = dobs.ServiceManagmentId
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] hl_destino WITH(NOLOCK)
			ON
				hl_destino.IdHubLogistic = sm.IdHubDestination
		LEFT JOIN 
			DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK) 
			ON 
				sr.ID = dobs.IdCourier
		LEFT JOIN 
			DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH(NOLOCK)
			ON 
				lbt.SSN_IdToken = dobs.TokenCreated
	WHERE 
		dobs.SequenceCode = @IdManifest

END
