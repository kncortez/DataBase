USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_ConfigParams]    Script Date: 3/11/2021 16:25:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Fredd, Monterroso>
-- Create date: <2021-11-03>
-- Description:	<Devuelve el valor de la configuracion de un parámetros de configuración>
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_ConfigParams]
    @Name AS NVARCHAR(100)
AS
BEGIN
	
	DECLARE @jsonResult NVARCHAR(MAX);

	SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{'
									   +'"Name":"' + ISNULL(REPLACE(pms.Name, '"', ''), '') + '",'
									   +'"Description":"' + ISNULL(REPLACE(pms.Description, '"', ''), '') + '",'
                                       +'"Value":"' + ISNULL(REPLACE(pms.Value, '"', ''), '') + '"}'
  								FROM dbo.ConfigParams pms
								WHERE pms.Name = @Name	AND pms.Status = 1

                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

        -- retornar resultado en formato json
        IF @jsonResult IS NULL
        BEGIN

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":" No se encontraron registros"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

        SELECT ('[' + @jsonResult + ']') jsonResult;

END
