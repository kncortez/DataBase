
/***
-- ACTUALIZACION IMAGEN 
-- TUTARALES DE ENVÍOS
***/

BEGIN TRANSACTION;
BEGIN TRY

    UPDATE ContentDetail
    SET ContentDetailImageURL = 'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-envi%CC%81o-200x400px1 2.jpg'
    WHERE ContentDetailPageURLButton = 'Realizar un envío' 
      and ContentDetailPageURL = '/individual/crear-guia/estandar' 
      and ContentDetailVideoURL = 'https://youtu.be/aILGDgQJJdw'
      and IdContentDetail != 12

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH