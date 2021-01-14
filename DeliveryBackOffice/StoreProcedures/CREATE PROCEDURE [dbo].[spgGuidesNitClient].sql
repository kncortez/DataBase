USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spgGuidesNitClient]    Script Date: 14/01/2021 7:37:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-08>
-- Description:	<Devuelve los montos y la suma del total del servicio>
-- =============================================
CREATE PROCEDURE [dbo].[spgGuidesNitClient]
	 @Nit NVARCHAR(20)
AS
BEGIN

select Distinct Top(1) upper(inv_cli_name) as nameclient , inv_cli_email,inv_cli_adress 
		from invoiceHeader
		where inv_cli_nit = @NIT order by 1 desc

END
GO


