USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_deliveryorder_settlement_returns]    Script Date: 19/01/2022 18:41:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spg_deliveryorder_settlement_returns]
		@IdManifest INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		'MD' + cast(dobs.SequenceCode as varchar(10)) as ID, 
		dobs.DateCreated as Date_Dispatched, 
		dobs.PiecesDry as Pieces_Dry_Dispatched, 
		dobs.PiecesCold as Pieces_Cold_Dispatched, 
		dobs.GuidesQuantity Guides_Dispatched,
		sr.First_Name + ' ' + sr.Last_Name as Courier_Name,
		dobs.DateCreated as Route_Dispatched,
		CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Dispatched
	
	FROM [DeliveryBackOffice].[dbo].SettlementByPickup dobs
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.IdCourier
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.TokenCreated
	WHERE dobs.SequenceCode = @IdManifest AND dobs.SubTypeServiceManagmentId = 3

END
