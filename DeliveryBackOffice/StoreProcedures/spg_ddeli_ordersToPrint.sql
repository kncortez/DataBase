USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_ddeli_ordersToPrint]    Script Date: 3/06/2020 16:56:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emilio Orozco
-- Create date: 2020/05/11
-- Description:	devuelve todos las ordenes que no se le han generado voucher o comprobante de entrega al igss
-- =============================================
CREATE PROCEDURE [dbo].[spg_ddeli_ordersToPrint]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ISNULL(STUFF((
       SELECT distinct ','+ convert(varchar,do.Order_Number)
       FROM DeliveryBackOffice.dbo.DeliveryOrder do with(nolock)
	   where isnull(do.printedStatus,0) = 0
       FOR XML PATH('')
	),1,1, ''),'') as orders
END
GO


