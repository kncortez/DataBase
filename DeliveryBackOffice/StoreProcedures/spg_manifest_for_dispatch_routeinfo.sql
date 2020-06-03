USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_manifest_for_dispatch_routeinfo]    Script Date: 3/06/2020 16:59:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spg_manifest_for_dispatch_routeinfo]
	-- Add the parameters for the stored procedure here
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- route info
	SELECT top 1
	do.Courier_Route as Courier_Route
	,CONVERT(varchar, do.Dispatched_Date, 103) as Dispatched_Date
	,do.Courier_Name as Courier_Name
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where do.Guide_Serie = @_serie
	and do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number,','))
	and do.Guide_Number is not null
	
END
GO


