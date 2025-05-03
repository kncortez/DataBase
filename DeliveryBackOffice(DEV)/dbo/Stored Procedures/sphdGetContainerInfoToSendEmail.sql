-- =============================================  
-- Author:		<Brandon, Pedroza>  
-- Create date: <2025-02-07>  
-- Description: <Contenerizacion guias - Obtener informacion de contenedor para enviar correo a cliente>  
-- =============================================  
CREATE PROCEDURE [dbo].[sphdGetContainerInfoToSendEmail]
	@ReferenceContainer NVARCHAR(50),
	@IdCustomer INT=0,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdStatusGenerated INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Solicitado');
	DECLARE @IdStatusRequest INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Generado');

	SELECT ISNULL(ContactEmail,RegexEmail)	AS Email ,
			[Name]					AS [Name],
			[Description]			AS [Description]
	FROM Customer CU WITH(NOLOCK) 	
	WHERE IdCustomer = @IdCustomer

	SELECT A1.CountryNameES		AS [CountryName],
			A2.[Value]			AS [PBX]
	FROM CatCountry A1 WITH(NOLOCK)
		INNER JOIN ConfigParams A2 WITH(NOLOCK)
		ON A1.IdCountry = A2.IdCountry
		WHERE A2.[Name] = 'PBX'
			AND ISNULL(A2.IdCountry, 'GT')= @IdCountry
		


	--PENDIENTES DE ESCANEAR
	SELECT	DOP.GuideNumber	AS [GuideNumber],
			DOP.GuideSerie	AS [GuideSerie],
			DOP.NoPiece		AS [GuidePiece],
			DO.Ticket_Number AS [TicketNumber],
			ISNULL(DOP.IdStatusGuideByContainer, 1) AS [StatusByContainer],
			ISNULL(DOP.IsNewInContainer,'0') AS[IsNewInContainer] 	
	FROM ShippingContainer SP 
		INNER JOIN ShippingContainerDetail SPD
			ON SP.IdContainer = SPD.IdContainer
		INNER JOIN DeliveryOrder DO
			ON DO.Guide_Number = SPD.GuideNumber
			AND DO.Guide_Serie = SPD.GuideSerie
		INNER JOIN DeliveryOrderPiece DOP
			ON DO.Guide_Number = DOP.GuideNumber
			AND DO.Guide_Serie = DOP.GuideSerie
	WHERE SP.IdCustomer = @IdCustomer
		AND SP.ReferenceContainer = @ReferenceContainer
		AND SPD.RowStatus = 1

END
