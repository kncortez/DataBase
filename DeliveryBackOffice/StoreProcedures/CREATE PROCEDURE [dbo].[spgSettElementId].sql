USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spgGuidesNitClient]    Script Date: 23/01/2021 11:53:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-08>
-- Description:	<Devuelve los poblados en base a los parametros enviados>
-- =============================================
CREATE PROCEDURE [dbo].[spgSettElementId]
	 @province int,
	 @township int
AS
BEGIN

		select IdSettlement, Settlement from Settlement st
			inner join Township tw on (tw.IdTownship = st.IdTownship)
			inner join Province pr on (pr.IdProvince = tw.IdProvince)
		where pr.IdProvince = @province and tw.IdTownship = @township

END
GO


