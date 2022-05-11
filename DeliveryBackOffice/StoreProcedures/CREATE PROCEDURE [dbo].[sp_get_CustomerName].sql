USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_tipoCustomer]    Script Date: 11/05/2022 09:25:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_CustomerName]

@IdCustomer int
AS

BEGIN

	SELECT Name FROM Customer
			WHERE IdCustomer = @IdCustomer

END  
GO


