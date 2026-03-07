/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_ConsultaUsuariosPorCustomer
   Propósito: Consultar los usuarios asociados a un customer.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5761
   Fecha:     2026-03-05
================================================= */

CREATE PROCEDURE dbo.Support_ConsultaUsuariosPorCustomer
(
    @IdCustomer INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        /* VALIDAR PARAMETRO */
        IF @IdCustomer IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El parametro @IdCustomer es obligatorio.' AS Mensaje;
            RETURN;
        END

        /* VALIDAR EXISTENCIA DEL CUSTOMER */
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
            WHERE IdCustomer = @IdCustomer
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El customer proporcionado no existe.' AS Mensaje;
            RETURN;
        END

        /* CONSULTA PRINCIPAL */
        SELECT 
            IIF(IUS.RowStatus = 1, 'ACTIVO', 'INACTIVO') AS ESTADO,
            IUS.IdUser              AS CODIGO,
            IUS.Username            AS USUARIO,
            RUS.UsrLastPassword     AS CONTRASEÑA,
            PER.PerNationality      AS PAIS,
            VPC.DateCreated         AS FECHA_DE_CREACION,
            IUS.Comment             AS COMENTARIO,
            IUS.TokenCreated        AS CREADO
        FROM DeliveryBackOffice.dbo.Customer CUS WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
            ON VPC.CustomerID = CUS.IdCustomer
        INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser VPU WITH (NOLOCK)
            ON VPU.IdVisitPointClient = VPC.IdVisitPointClient
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser RUS WITH (NOLOCK)
            ON RUS.UsrIdUser = VPU.RegisterUserID
        INNER JOIN DeliveryBackOffice.dbo.UserSystemRestriction USRE WITH (NOLOCK)
            ON USRE.UstIdUser = RUS.UsrIdUser
        INNER JOIN DeliveryBackOffice.dbo.InternalUser IUS WITH (NOLOCK)
            ON IUS.RegisterUserID = VPU.RegisterUserID
        INNER JOIN DeliveryBackOffice.dbo.Person PER WITH (NOLOCK)
            ON PER.PerIdPerson = RUS.UsrIdPerson
        WHERE CUS.IdCustomer = @IdCustomer
        ORDER BY VPC.DescriptionOfClient DESC;

    END TRY
    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH

END
GO