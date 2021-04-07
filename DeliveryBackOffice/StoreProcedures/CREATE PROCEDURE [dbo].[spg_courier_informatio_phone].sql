USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_courier_information]    Script Date: 6/04/2021 16:51:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Gomez,Hugo>
-- Create date: <05-04-2021>
-- Description:	<Devuelve los telefonos de un courier>
-- =============================================
CREATE PROCEDURE [dbo].[spg_courier_informatio_phone]
	-- Add the parameters for the stored procedure here
	@CUI NVARCHAR(25)
AS
BEGIN


  select crp.Phone from CouriermanPhone crp
  join SenderReceiver sr on (sr.ID = crp.SenderReceiverId)
  where sr.CUI = @CUI and crp.RowStatus = 1 



END
