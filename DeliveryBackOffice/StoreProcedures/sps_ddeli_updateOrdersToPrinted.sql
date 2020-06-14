USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_ddeli_updateOrdersToPrinted]    Script Date: 3/06/2020 17:01:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emilio Orozco
-- Create date: 2020/05/11
-- Description:	hace update de las ordenes que recibe, que ya fueron impresas o que van a ser reimpresas
-- =============================================
CREATE PROCEDURE [dbo].[sps_ddeli_updateOrdersToPrinted]
	@_serie nvarchar(2)
	,@_number int
	,@_status smallint = 1 --1 impreso, 2 reimpreso
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @serie nvarchar(2) = @_serie
	,@number int = @_number
	,@status smallint = @_status

    -- Insert statements for procedure here
	update DeliveryBackOffice.dbo.DeliveryOrder
	set printedStatus = @status
	where ( (@status = 1 and Manifest_Serie = @serie and Manifest_Number = @number)
	or (@status = 2 and Guide_Serie = @serie and Guide_Number = @number))
END
GO


