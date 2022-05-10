USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_tipoCustomer]    Script Date: 9/05/2022 17:02:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_tipoCustomer]

@IdCustomer int
AS

BEGIN

	SELECT Name FROM Customer
			WHERE IdCustomer = @IdCustomer

END  
GO


