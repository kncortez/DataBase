-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-09-07>
-- Update date: <2021-09-07>
-- Description:	<Inserta una guia en la tabla GuideBatch y le asigna un id de lote>
-- =============================================


CREATE PROCEDURE [dbo].[spws_SetBatchId]
@IdAccount BIGINT =1,
@GuideNumber NVARCHAR(MAX),
@Token NVARCHAR(50) = '',
@IdVisitPointByClientPortfolio BIGINT,
@IdAddress BIGINT


AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);
DECLARE @IdUser BIGINT = (SELECT RuaIdUser FROM DeliveryBackOffice.dbo.RolByUserByAccount WITH (NOLOCK) WHERE RuaIdAccount= @IdAccount);

DECLARE @length INT = (SELECT LEN(@GuideNumber));
DECLARE @Series NVARCHAR(MAX) = (SELECT SUBSTRING(@GuideNumber, 1, 2) AS ExtractString);
DECLARE @Guide NVARCHAR(MAX) = (SELECT SUBSTRING(@GuideNumber, 3, @length) AS ExtractString);

-- Main IF
IF EXISTS (SELECT TOP 1 * FROM DeliveryBackOffice.dbo.GuideBatch WITH (NOLOCK) WHERE  IdUser=@IdUser AND RowStatus=1)

BEGIN

    DECLARE @IdBatch BIGINT;
    DECLARE @Status  INT;
    SELECT TOP 1 @IdBatch = IdBatch,  @Status = Status FROM DeliveryBackOffice.dbo.GuideBatch WITH (NOLOCK) WHERE IdUser = @IdUser AND RowStatus=1 ORDER BY GuideNumber DESC;

    -- Checks if the guide already has an IdBatch associated
    IF EXISTS (SELECT * FROM DeliveryBackOffice.dbo.GuideBatch WHERE GuideNumber=@GuideNumber)

      BEGIN

      SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Guia fue asociada con anterioridad a un lote"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

      END

    --If not
    ELSE

      BEGIN

        -- If status of the last guide created is in progress
        IF(@Status=1)

          BEGIN

              BEGIN TRANSACTION

              BEGIN TRY

                  INSERT INTO DeliveryBackOffice.dbo.GuideBatch
                  (IdUser,
				  GuideSeries,
                  GuideNumber,
                  IdBatch,-- 1 es el numero inicial del lote
                  IdVisitPointByClientPortfolio,
                  IdAddress,
                  Status,-- 1 es el estado inicial que es en proceso,
                  RowStatus, -- 1 por defecto
                  TokenCreated,
                  DateCreated)
                  VALUES(@IdUser,@Series,@Guide,@IdBatch,@IdVisitPointByClientPortfolio,@IdAddress,@Status,1,'SYS-ADMIN',GETDATE());

              END TRY

              BEGIN CATCH


              SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Error al Asignar lote"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

              ROLLBACK TRANSACTION

              END CATCH;

              IF @@TRANCOUNT > 0 BEGIN

              COMMIT TRANSACTION;

              SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Guia asignada exitosamente"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

              END


          END

        -- If status of the last guide created is completed, creates a new IdBatch
        ELSE

          BEGIN

            SET @IdBatch = @IdBatch + 1;

            BEGIN TRANSACTION

            BEGIN TRY

                INSERT INTO DeliveryBackOffice.dbo.GuideBatch
                (IdUser,
				GuideSeries,
                GuideNumber,
                IdBatch,-- 1 es el numero inicial del lote
                IdVisitPointByClientPortfolio,
                IdAddress,
                Status,-- 1 es el estado inicial que es en proceso
                RowStatus, -- 1 por defecto
                TokenCreated,
                DateCreated)
                VALUES(@IdUser,@Series,@Guide,@IdBatch,@IdVisitPointByClientPortfolio,@IdAddress,1,1,'SYS-ADMIN',GETDATE());

            END TRY

            BEGIN CATCH

            SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Error al Asignar lote"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

            ROLLBACK TRANSACTION

            END CATCH;

            IF @@TRANCOUNT > 0 BEGIN

            COMMIT TRANSACTION;

            SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Guia asignada exitosamente"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

            END


          END

      END

END

-- Main ELSE
ELSE

-- This is a new customer that will add the first guide to the table GuideBatch so an IdBatch needs to be created, this will starts at 1 by default

      BEGIN

        BEGIN TRANSACTION

        BEGIN TRY

            INSERT INTO DeliveryBackOffice.dbo.GuideBatch
            (IdUser,
			GuideSeries,
            GuideNumber,
            IdBatch,-- 1 es el numero inicial del lote
            IdVisitPointByClientPortfolio,
            IdAddress,
            Status,-- 1 es el estado inicial que es en proceso
            RowStatus, -- 1 por defecto
            TokenCreated,
            DateCreated)
            VALUES(@IdUser,@Series,@Guide,1,@IdVisitPointByClientPortfolio,@IdAddress,1,1,'SYS-ADMIN',GETDATE());

        END TRY

        BEGIN CATCH

        SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Error al Asignar lote"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

        ROLLBACK TRANSACTION

        END CATCH;

        IF @@TRANCOUNT > 0 BEGIN

        COMMIT TRANSACTION;

        SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"Message":"Guia asignada exitosamente"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

        END

      END

      -- Returns the results 
      SELECT('[{' + @jsonResult + ']') jsonResult;
END;
