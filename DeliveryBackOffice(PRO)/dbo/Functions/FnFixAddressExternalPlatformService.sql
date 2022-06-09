
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-07>
-- Description:	< Función para realizar correcciones en direcciones >
-- =============================================
CREATE FUNCTION [dbo].[FnFixAddressExternalPlatformService]
(
    @InputAddress NVARCHAR(600),
	@InputDepartment NVARCHAR(50),
	@InputTown NVARCHAR(50)
)
RETURNS NVARCHAR(600) 
AS
BEGIN
    DECLARE @AuxAddress NVARCHAR(600) = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@InputAddress
		,'+',' '),',,',','),'  ',' '),'. ,',','),'.,',','),', ,',','),'/',''),';',''),' , ',', '),'*',''),'. *',''),', *','');

	DECLARE @LastAddress NVARCHAR(600) = '';
	DECLARE @Counter INT = 1;
	WHILE ( @Counter <= 7 OR @LastAddress <> @AuxAddress)
	BEGIN
		SET @LastAddress = @AuxAddress

		SET @AuxAddress = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		(CASE 
			WHEN PATINDEX('%De '+@InputTown+'%', @AuxAddress) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%[De] '+@InputTown+'%', @AuxAddress) - 2)
			WHEN PATINDEX('%De '+@InputDepartment+'%', @AuxAddress) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%[De] '+@InputDepartment+'%', @AuxAddress) - 2)
			WHEN PATINDEX('%'+@InputTown+'%', @AuxAddress collate Latin1_General_CI_AI) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%'+@InputTown+'%', @AuxAddress collate Latin1_General_CI_AI) - 1)
			WHEN PATINDEX('%'+@InputDepartment+'%', @AuxAddress collate Latin1_General_CI_AI) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%'+@InputDepartment+'%', @AuxAddress collate Latin1_General_CI_AI) - 1)
			WHEN PATINDEX('%'+@InputTown+'%', @AuxAddress) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%'+@InputTown+'%', @AuxAddress) - 1)
			WHEN PATINDEX('%'+@InputDepartment+'%', @AuxAddress) > 0 THEN SUBSTRING(@AuxAddress, 1, PATINDEX('%'+@InputDepartment+'%', @AuxAddress) - 1)
			ELSE @AuxAddress
		END)
		,',,',','),'  ',' '),'. ,',','),'.,',','),', ,',','),'/',''),';',''),' , ',', '),'*','');



		SET @Counter = @Counter + 1;
	END
	
	SET @AuxAddress = LTRIM(RTRIM(@AuxAddress))
	
	SET @AuxAddress = CONCAT(LTRIM(RTRIM(@AuxAddress)), ', ', @InputTown, ', ', @InputDepartment);

	IF (LEFT(@AuxAddress,1) = ',')
	BEGIN
		SET @AuxAddress = STUFF(@AuxAddress,1,1,'');
	END

	SET @AuxAddress = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@AuxAddress
		,',,',','),'  ',' '),'. ,',','),'.,',','),', ,',','),'/',''),';',''),' , ',', '),'*',''),'. *',''),', *','');

    RETURN  @AuxAddress;
END
