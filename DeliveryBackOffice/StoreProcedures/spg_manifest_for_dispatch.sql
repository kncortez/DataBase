USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_manifest_for_dispatch]    Script Date: 3/06/2020 16:58:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spg_manifest_for_dispatch]
	-- Add the parameters for the stored procedure here
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- tablix content
	SELECT
	do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
	,do.Pieces_Cold as Pieces_Cold
	,do.Pieces_Dry as Pieces_Dry
	,do.Receiver_FirstName + ' ' + do.Receiver_LastName as Receiver_Fullname
	,do.Receiver_Address AS Receiver_Address
	,do.Receiver_Zone AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where do.Guide_Serie = @_serie
	and do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number,','))
	and do.Guide_Number is not null
	order by do.Guide_Number asc

END
GO


