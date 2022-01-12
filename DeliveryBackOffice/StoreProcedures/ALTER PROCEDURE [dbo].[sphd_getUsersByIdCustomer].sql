USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphd_getUsersByIdCustomer]    Script Date: 10/01/2022 10:14:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los clientes individuales>
-- =============================================

ALTER PROCEDURE [dbo].[sphd_getUsersByIdCustomer]
    @IdVisitPointClient AS INT
AS
BEGIN
    SELECT c.Name + ' ' + ISNULL(ru.UsrEmail, '') Name
	FROM DeliveryBackOffice.dbo.Customer c
		LEFT JOIN dbo.Account a 
			ON a.IdCustomer = c.IdCustomer
		LEFT JOIN dbo.RolByUserByAccount rua 
			ON rua.RuaIdAccount = a.AccIdAccount
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru
			ON ru.UsrIdUser = rua.RuaIdUser
		JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc 
			ON c.IdCustomer = vpc.CustomerID
	WHERE ISNULL(c.RowSatus, 1) = 1 
	AND vpc.IdVisitPointClient =  @IdVisitPointClient
END