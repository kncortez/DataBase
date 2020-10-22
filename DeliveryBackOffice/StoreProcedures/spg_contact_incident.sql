USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[]    Script Date: 14/10/2020 13:16:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-10-14>
-- Description:	<Obtiene el catálogo de incidencias de contacto>
-- =============================================
CREATE PROCEDURE [dbo].[spg_contact_incident]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ID, [Name] FROM DeliveryBackOffice.dbo.ContactIncident
END
GO


