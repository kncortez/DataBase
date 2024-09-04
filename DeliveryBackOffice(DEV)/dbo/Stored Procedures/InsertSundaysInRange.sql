-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <29-08-2024>
-- Description:	< Inserta en la tabla NoLaborCalendar todos los días domingos de cualquier fecha.>
-- =============================================
CREATE PROCEDURE [dbo].[InsertSundaysInRange]
    @StartDate DATE = '2024-01-01',
    @EndDate DATE = '2024-12-31',
    @IdCountry VARCHAR(2) = 'GT',
	@Token NVARCHAR(100) = 'SYS'
AS
BEGIN
    BEGIN TRY
        DECLARE @CurrentDate DATE = @StartDate; -- Variable para recorrer las fechas

        -- Verificar si la fecha de inicio es mayor que la fecha de fin
        IF @StartDate > @EndDate
        BEGIN
            PRINT( 'La fecha de inicio no puede ser mayor que la fecha de fin.');
        END;
		ELSE
		BEGIN
			 -- Bucle para encontrar el primer domingo dentro del rango especificado
			WHILE @CurrentDate <= @EndDate
			BEGIN
				-- Verifica si el día es domingo
				IF DATEPART(WEEKDAY, @CurrentDate) = 1
				BEGIN
					PRINT(@CurrentDate)
					PRINT(@IdCountry)
					-- Verifica si la fecha y el país no existen ya en la tabla temporal
					IF NOT EXISTS (SELECT 1 FROM [DeliveryBackOffice].[dbo].[NoLaborCalendar] WITH(NOLOCK) 
									WHERE NoLaborDate = @CurrentDate AND IdCountry = @IdCountry)
					BEGIN
						INSERT INTO [DeliveryBackOffice].[dbo].[NoLaborCalendar]
							   ([NoLaborDate]
							   ,[RowStatus]
							   ,[DateCreated]
							   ,[TokenCreated]
							   ,[DateUpdated]
							   ,[TokenUpdated]
							   ,[IdCountry])
						 VALUES
							   (@CurrentDate
							   ,1
							   ,GETDATE()
							   ,@Token
							   ,NULL
							   ,NULL
							   ,@IdCountry)
					END
                
					-- A partir de aquí, incrementamos en 7 días para el siguiente domingo
					SET @CurrentDate = DATEADD(DAY, 7, @CurrentDate);
				END
				ELSE
				BEGIN
					-- Incrementa la fecha actual en un día hasta encontrar el primer domingo
					SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
				END
			END
		END;

        -- Resultados
		PRINT('SUCCESS');

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Ocurrió un error al ejecutar el procedimiento almacenado.';
        PRINT 'Error Número: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10));
        PRINT 'Estado: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), 'Desconocido');
        PRINT 'Línea: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
