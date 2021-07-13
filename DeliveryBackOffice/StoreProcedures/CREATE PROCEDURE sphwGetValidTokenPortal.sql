-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2021-07-12>
-- Description:	<Valida si un token de portal web es existente y valido >
-- =============================================
CREATE PROCEDURE sphwGetValidTokenPortal
	-- Add the parameters for the stored procedure here
	@Token AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Insert statements for procedure here
	SELECT COALESCE(TknIdToken,'') TknIdToken, TknDateCreated  ,TknRowStatus 
	FROM DeliveryBackOffice.dbo.TokenLog
	WHERE TknIdToken =  @Token  -- 'B3FE49341194EBBA9A8DB61C4173E06C'--
END
GO
