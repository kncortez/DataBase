-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spg_manifest_for_dispatch_stats]
	-- Add the parameters for the stored procedure here
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- stats
	SELECT 
	count(do.guide_number) as Guide_Qty
	,sum(do.pieces_dry + do.pieces_cold) as Pieces_Qty
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where do.Guide_Serie = @_serie
	and do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number,','))
	and do.Guide_Number is not null
	
END
