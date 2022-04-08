USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetClosureListVisitPoint]    Script Date: 4/04/2022 16:34:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC GetClosureList
@VisitPointId = -1
,@StartDate = '20210627'
,@EndDate = '20210627'
*/

-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-29>
-- Description:	<SP para obtener la lista de cierres que se procesaron en un express center por VisitPoint>
-- Nota: Es una copia de GetClosureList
-- =============================================

CREATE PROCEDURE [dbo].[GetClosureListVisitPoint]
@VisitPointId INT
,@StartDate datetime
,@EndDate datetime
AS
BEGIN

	SELECT ACH.IdAccountingClosuresHeaderVisitPoint 'ClosureId',
		ACH.VisitPoint 'VisitPointId',vpc.DescriptionOfClient 'VisitPoinDescription'
		,ACH.UserId,REU.UsrNickName 'UserDescription'
		,ACH.DateCreated 'DateCreated'
		,ACH.Voucher1,ACH.Bag1
		,ACH.Voucher2,ACH.Bag2
		,ACH.ClosurerPOS 'ClosurePOS'
		,ACH.TotalAmountCash
		,ACH.TotalAmountCashDeclared
		,ACH.TotalAmountCredit
		,ACH.TotalAmountCreditDeclared
		,ACH.TotalAmountCODCash
		-- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		,ACH.TotalAmountCODCashDeclared
		,ACH.TotalAmountFacturaCash
		,ACH.TotalAmountFacturaCashDeclared
		,ACH.TotalAmountFacturaCard
		,ACH.TotalAmountFacturaCardDeclared
		-- FIN MODIFICACIÓN
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACH
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
		ON ACH.VisitPoint = VPC.CodeOfReference
	JOIN DeliveryBackOffice.dbo.RegisterUser REU 
		ON REU.UsrIdUser = ACH.UserId
	WHERE CAST(ACH.DateCreated AS DATE) 
		BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND (@VisitPointId = ACH.VisitPoint OR @VisitPointId = -1)

	select Value 'URL' from ConfigParams
	where Name = 'ClosureExpressCenter'

END
