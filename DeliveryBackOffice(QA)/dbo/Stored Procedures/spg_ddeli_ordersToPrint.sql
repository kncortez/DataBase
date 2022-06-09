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
