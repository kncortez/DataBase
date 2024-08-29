
-- =============================================
-- Author:		<Andrés,Ruíz>
-- Create date: <2023-04-28>
-- Description:	< Método para obtener incidencias de un tipo con resultado como tabla >
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetIncidenceListByType]

	@IncidenceServiceType NVARCHAR(25) = NULL

AS
BEGIN

	DECLARE @ReponseTable TABLE 
	(
		IdResponseData INT NULL,
		ValueResponseDate NVARCHAR(200)
	);
	
	BEGIN TRY
	    
		IF ( @IncidenceServiceType IS NULL )
		BEGIN
	    
			SELECT
				404 [ResponseCode],
				'Tipo de servicio inexistente.' [ResponseMessage]

		END
		ELSE
		BEGIN
        
			INSERT INTO @ReponseTable
			(
				[IdResponseData],
				[ValueResponseDate]
			)
			SELECT 
				[CTI].[IdIncidenceType]
				,[CTI].[NameIncidence]
			FROM
				[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
			WHERE
				[CTI].[RowStatus] = 1
				AND
				[CTI].[ServiceType] = @IncidenceServiceType   
                AND
                ISNULL([CTI].[CountryId], 'GT') = @IdCountry
			ORDER BY
				CTI.[OrderId] ASC

			IF ( EXISTS ( SELECT TOP 1 1 FROM @ReponseTable ) )
			BEGIN

				SELECT
					200 [ResponseCode],
					'Datos obtenidos exitosamente' [ResponseMessage]

				SELECT
					-1 [IdResponseData],
					'Seleccione incidencia' [ValueResponseDate]
				UNION
				SELECT 
					[RT].[IdResponseData],
					[RT].[ValueResponseDate] 
				FROM
					@ReponseTable RT
		    
			END
			ELSE
			BEGIN
            
				SELECT
					204 [ResponseCode],
					'Sin datos bajo filtro aplicado' [ResponseMessage]

			END

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 [ResponseCode],
			CONCAT('Mensaje: ', ERROR_MESSAGE(),'| Linea aproximada: ', ERROR_LINE()) [ResponseMessage]
	    
	END CATCH

END