-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-10-04>
-- Description:	< Obtiene el identificador del catalogo de incidencias correspondiente, puede utilizar la descripcion como apoyo a obtener la incidencia >
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_IncidenceId_SimpliWebhook]
	-- DATA INCIDENCE
	@ExtPlatIncidenceId NVARCHAR(50) = '',
	@ExtPlatDescription NVARCHAR(200) = '',
	@ExtPlatServiceType NVARCHAR(50) = 'DELIVERY'
AS
BEGIN
	DECLARE @jsonResult NVARCHAR(MAX) = '';
	BEGIN TRY
	/*
		set @jsonResult = (SELECT STUFF((
							SELECT
							',{"IdResult":200,"IncidenceID":' +  CAST( CTI.IdIncidenceType AS VARCHAR) + '' +
							+ '}'
							FROM [DeliveryBackOffice].[dbo].[CatExtPlatformIncidence] CEPI
							JOIN [DeliveryBackOffice].[dbo].[ExtPlatIncidence_TypeIncidence] EPITI
							ON CEPI.IdCatExtPlatformIncidence = EPITI.ExtPlatIncidenceId
							JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI
							ON EPITI.TypeIncidenceId = CTI.IdIncidenceType
							WHERE CEPI.ExtPlatformInternalId = @ExtPlatIncidenceId
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )
							*/
		--IF (LEN(@jsonResult) <= 0 AND LEN(@ExtPlatDescription) > 0)
		--BEGIN			
			set @jsonResult = (SELECT STUFF((
								SELECT
								',{"IdResult":200,"IncidenceID":' +  CAST( CTI.IdIncidenceType AS VARCHAR) + ',' +
								'"IncidenceName":"' + CTI.NameIncidence + '"' +
								+ '}'
								FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI
								WHERE UPPER(REPLACE(CTI.NameIncidence,' ','')) = UPPER(REPLACE(@ExtPlatDescription,' ',''))
								AND UPPER(CTI.ServiceType) = UPPER(@ExtPlatServiceType)
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )
		-- END
		IF (LEN(@jsonResult) <= 0)
		BEGIN			
			set @jsonResult =(
			SELECT STUFF((
			SELECT '{{"IdResult":204,'
			+ '"Error":"'+ERROR_MESSAGE()+'"}'
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,'') )
		END
		select ('[' + @jsonResult +  ']') jsonResult
	END TRY
	BEGIN CATCH
		set @jsonResult =(
			SELECT STUFF((
			SELECT '{{"IdResult":500,'
			+ '"Error":"'+ERROR_MESSAGE()+'"}'
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResult +  ']') jsonResultError
	END CATCH
END