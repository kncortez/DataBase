-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Update date: <2021-01-27>
-- Description:	<Login Portal Web>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <2023-03-02>
-- Description:	<Validation for visit point status>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCreateHub]
    -- Add the parameters for the stored procedure here
    @HubName NVARCHAR(50)
  , @HubAbbreviation VARCHAR(5)
  , @CountryID VARCHAR(2)
  , @DescriptionContactCenter NVARCHAR(100)
  , @Token NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO dbo.HubLogistics
(
    HubName
  , HubAbbreviation
  , HubStatus
  , IdStation
  , IdCountry
  , TokenCreated
  , DateCreated
  , TokenUpdate
  , DateUpdated
  , IsGateway
  , HubLatitude
  , HubLongitude
  , DescriptionCC
)
VALUES
(   @HubName -- HubName - varchar(50)
  , @HubAbbreviation -- HubAbbreviation - varchar(5)
  , 1 -- HubStatus - bit
  , NULL -- IdStation - int
  , @CountryID -- IdCountry - varchar(2)
  , @Token -- TokenCreated - varchar(50)
  , GETDATE() -- DateCreated - datetime
  , NULL -- TokenUpdate - varchar(50)
  , NULL -- DateUpdated - datetime
  , NULL -- IsGateway - bit
  , NULL -- HubLatitude - nvarchar(20)
  , NULL -- HubLongitude - nvarchar(20)
  , @DescriptionContactCenter -- DescriptionCC - nvarchar(100)
    )


	DECLARE @idnewHub INT

	SET @idnewHub = SCOPE_IDENTITY()

	INSERT INTO dbo.CatStation
	(
	    StationName
	  , CountryId
	  , StationType
	  , HubLogisticId
	  , CodeOfReference
	  , RowStatus
	  , TokenCreated
	  , DateCreated
	  , TokenUpdated
	  , DateUpdated
	)
	VALUES
	(   @HubName  -- StationName - nvarchar(100)
	  , @CountryID   -- CountryId - varchar(2)
	  , 1    -- StationType - int
	  , @idnewHub -- HubLogisticId - int
	  , NULL -- CodeOfReference - int
	  , 1 -- RowStatus - bit
	  , @Token -- TokenCreated - nvarchar(50)
	  , GETDATE() -- DateCreated - datetime
	  , NULL -- TokenUpdated - nvarchar(50)
	  , NULL -- DateUpdated - datetime
	    )

		
		COMMIT
    END TRY
	BEGIN CATCH 
	 ROLLBACK
	 SELECT ERROR_LINE()
	 , ERROR_MESSAGE() , ERROR_NUMBER()
	END CATCH
END