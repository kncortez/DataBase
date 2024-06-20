-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <22-07-2022>
-- Description:	<Get complete information list of sender receiver>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <13-06-2024>
-- Description:	< Country>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getSenderReceiverList] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT		[SR].[ID],
				[SR].[First_Name],
				[SR].[Last_Name],
				[SR].[Address],	
				[SR].[Zone],
				[SR].[Town],
				[SR].[Department],
				[SR].[Phone],
				[SR].[Email],
				[SR].[CUI],
				ISNULL([SR].[IdCountry],'GT') IdCountry
	FROM		[dbo].[SenderReceiver] SR WITH(NOLOCK)
	WHERE		[SR].[Estatus] = 1
	ORDER BY	[SR].[Last_Name];
END