USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sphdGetVisitPointbyCustomerID]    Script Date: 6/25/2021 6:09:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-29>
-- Description:	<Get All VisitPoint by CustomerID>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetVisitPointbyCustomerID]
	-- Add the parameters for the stored procedure here
	@IdCustomer AS INT ,
	@Option INT = 0,
	@IdVisitPoint AS INT = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@Option = 0 ) 
	BEGIN 
    -- Insert statements for procedure here
	 SELECT  
			 [IdVisitPointClient],
			 [CodeOfReference],
			 [DescriptionOfClient],
			 vpc.Address,
			 vpc.Town,
			 vpc.Department,
			[CustomerID]   
	FROM DeliveryBackOffice.dbo.VisitPointClient vpc
	WHERE vpc.CustomerID = @IdCustomer
	AND vpc.StatusClient = 'TRUE'
	END 
	IF (@Option = 1 ) 
	BEGIN 
     SELECT  
			 --[IdVisitPointClient]												 [IdValue],
			 [CodeOfReference]													 [IdValue],
			 CAST([CodeOfReference] AS VARCHAR) + ' ' +  [DescriptionOfClient]   [NameValue]  ,
			 [CustomerID]														 [IdFilter]
	FROM DeliveryBackOffice.dbo.VisitPointClient vpc
	WHERE (@IdCustomer = -1 OR vpc.CustomerID = @IdCustomer)
	AND (@IdVisitPoint = -1 OR vpc.CodeOfReference = @IdVisitPoint)
	--vpc.StatusClient = 'TRUE'
	ORDER BY NameValue  
	END 

END
GO


