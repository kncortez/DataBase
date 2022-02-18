USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_visitPointClientParser]    Script Date: 18/02/2022 09:05:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_visitPointClientParser]
@IdVisitClient AS int
AS
BEGIN

	SELECT CodeOfReference, CustomerID, Address, Zone, Town, Department, Phone, FirstName, LastName FROM VisitPointClient_Parser
	WHERE CodeOfReference = @IdVisitClient

END