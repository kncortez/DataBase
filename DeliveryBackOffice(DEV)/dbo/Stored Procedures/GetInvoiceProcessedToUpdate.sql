-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-28>
-- Description:	<Obtiene las facturas para el proceso UpdateInvoiceProcessed en el servicio HermesInvoiceHelper para actualizar datos de facturas procesadas>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceProcessedToUpdate]
AS
BEGIN
    BEGIN TRY
        DECLARE @DaysFrom INT = 4; --Días desde donde se obtienen las guías.

        SELECT '1'                              'StatusCode'
             , 'Datos obtenidos correctamente.' 'Description';
             
        SELECT inv_pk_id InvoiceId,inv_descriptionFEL
        FROM invoiceHeader WITH (NOLOCK)
        WHERE 
		--(
		--inv_descriptionFEL = 'Fallo la ejecucion del comando: [POST_DOCUMENTGT], TrCode: [9], description: [Ya existe el Documento con el NIT, codigo establecimiento, tipo de documento y IDInterno, no se puede insertar un documento duplicado]'
  --      OR 
		--inv_documentRecieved ='TimeOut' 
		--)
		--  AND 
		  inv_dateRegister >='2024-07-01 00:00:00'
		 AND inv_dateRegister <='2024-07-31 23:59:59'
		 AND 		 
		 (inv_certificationFEL IS NULL OR inv_certificationFEL = '')
		AND 
		inv_pk_id in (
		4071986
,4072494
,4064325
,4063764
,4065310
,4064299
,4062352
,4067562
,4065925
,4065295
,4065902
,4064862
,4068371
,4063923
,4063185
,4059630
,4059356
,4059620
,4058096
,4052163
,4055833
,4054889
,4054458
,4053925
,4056048
,4047677
,4046409
,4051557
,4046489
,4036242
,4036761
,4036661
,4038848
,4025412
		)
		  --AND 
		 -- inv_pk_id IN (3835955,3835964,3836071,3836635,3837422,3837460,3838515,3839033,3839041,3839122,3839233,3840266,3840442,3840480,3840897,3842233,3842239,3842328,3842726,3842837,3842929,3842964,3843005,3843236,3843283,3843316,3843840,3844741,3845779,3845951,3846825,3846915,3846926,3847006,3847105,3847460,3848562,3848589,3848773,3849494,3849555,3849635,3849785,3849853,3850583,3850701,3850758,3850852,3850870,3851344,3851477,3851525,3851639,3851683,3851789,3852376,3853376,3853614,3854294,3855028,3855278,3855540,3856112,3856418,3856605,3856742,3857299,3857485,3857618,3857794,3858915,3859371,3859403,3859522,3860038,3860168,3860386,3860671,3862287,3862562,3862765,3862804,3863246,3863418,3863599,3863665,3863777,3864991,3865167,3865600,3866277,3866371,3866404,3866805,3867289,3867742,3867893,3869814,3869840,3870300,3870457,3870690,3870867,3871015,3871121,3871145,3871579,3872192,3872540,3872910,3872928,3872958,3873962)
		  --AND 
		 
		   --   AND CAST(inv_dateRegister AS DATE) >= CAST(GETDATE() - @DaysFrom AS DATE);
		
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;