-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-01>
-- Description:	<Actualiza la información de un Visit Point>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-24>
-- Description: <se agrega filtro para pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateVisitPoint] 
	@IdVisitPointClient INT,
	@DescriptionOfClient NVARCHAR(100),
	@Token NVARCHAR(50),
	@Address NVARCHAR(600),	
	@Town NVARCHAR(100),
	@Department NVARCHAR(100),
	@Phone NVARCHAR(50),
	@ContactName NVARCHAR(200),
	@IdSettlement BIGINT,
	@Email NVARCHAR(200),
	@IdTownship INT,
	@IdProvince INT,
	@Latitude NVARCHAR(20) = NULL,
	@Longitude NVARCHAR(20) = NULL,
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@IdSettlement = 0)
			SET @IdSettlement = NULL		
		UPDATE VisitPointClient
		SET DescriptionOfClient = @DescriptionOfClient
		   ,CountryId = COALESCE((SELECT IdCountry FROM Province WHERE IdProvince = @IdProvince),'GT')
		   ,TokenUpdated = @Token
		   ,DateUpdated = GETDATE()
		   ,Address = @Address
		   ,Town = @Town
		   ,Department = @Department
		   ,Phone = @Phone
		   ,ContactName = @ContactName
		   ,IdSettlement = @IdSettlement
		   ,Email = @Email
		   ,IdTownship = @IdTownship
		   ,Latitude = @Latitude
		   ,Longitude = @Longitude
		WHERE IdVisitPointClient = @IdVisitPointClient

		--DECLARE @regexPhoneNumber varchar(max)='[(][0-9][0-9][0-9][)]%';			
		SET @Phone	=REPLACE(@Phone,'-','');
		SET @Phone	=REPLACE(@Phone,' ','');
		UPDATE UA SET 
			UA.UadIdTownship=VPC.IdTownship
			,UadIdCountry=CC.IdCountry
			,UadAddress1=VPC.Address,
			--UadNirPhone=(CASE WHEN CHARINDEX('(',@Phone) >0 THEN SUBSTRING(@Phone,2,3) ELSE '' END),
			UadNirPhone=IIF(@IdCountry = 'GT','502','504'),
			UadPhone=@Phone,
			UadAdditionalInstructions='',
			UadTokenUpdated=@Token,
			UadDateUpdated=GETDATE(),
			UadIdSettlement=@IdSettlement,			
			UadFullName=@DescriptionOfClient
			
		FROM DBO.UserAddress UA 
			JOIN DBO.VisitPointClient VPC ON UA.CodeOfReference=VPC.CodeOfReference
			LEFT JOIN DBO.Township TS ON TS.IdTownship=VPC.IdTownship
			LEFT JOIN DBO.Province PRV ON PRV.IdProvince=TS.IdProvince
			LEFT JOIN DBO.CatCountry CC ON CC.IdCountry=PRV.IdCountry
			WHERE IdVisitPointClient = @IdVisitPointClient
		



		IF(@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION

			SELECT			  
				1 [blnResult],
				'Registro actualizado correctamente' [Description], 
				CONVERT(INT, @@TRANCOUNT) [NumTransferID]
		END
		ELSE
			SELECT			  
				-1 [blnResult],
				'Registro no encontrado' [Description], 
				CONVERT(INT, @@TRANCOUNT) [NumTransferID]

	END TRY
	BEGIN CATCH
		SELECT 
			0 [blnResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION
	END CATCH
END
