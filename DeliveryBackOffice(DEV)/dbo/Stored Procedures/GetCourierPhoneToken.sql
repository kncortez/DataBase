
/* =================================================
   SP:        [dbo].[GetCourierPhoneToken]
   Propósito: <Recotizacion>
   Autor:     <ugo,Gomez>
   Historia:  <>   
   Fecha:     2021-02-11
============================================
=== CHANGELOG ================================
-- 2025-11-25 | Historia/épica: FDAPI-5100 | Autor: Cristian Suazo |
-- 2025-11-17 | Historia/épica: FDAPI-4976 | Autor: Cristian Suazo |
=========================================== */


CREATE PROCEDURE [dbo].[GetCourierPhoneToken]
    -- Add the parameters for the stored procedure here
    @Phone NVARCHAR(20) = '48119415',
    @Token VARCHAR(MAX) = '21a31fd231as23d1f21ads',
    @LoginToken NVARCHAR(6) = '123456',
    @IdCountry nvarchar(8) = 'GT'
as
begin
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    set nocount on;

    declare @jsonResult nvarchar(max);

    -- insertar en tabla temporal posbibles mensajes de respuesta

    if object_id('tempdb.dbo.#responsemessage', 'U') is not null
    drop table #responsemessage;

    select *
    into #responsemessage
    from
    (
        select 200                              as IdResult
             , 'Estado  cambiado correctamente' as Message
             , 'OK'                             as Id
        union
        select 500                                       as IdResult
             , 'Error faltal intente de nuevo mas tarde' as Message
             , 'Transac'                                 as Id
    ) as errror;

    begin transaction;
    begin try
        -------------------------------------------------------------------------------------------------------------------------
        declare @phon int,
				@StationId INT

                SELECT	TOP 1
						@phon = SR.ID,
						@StationId = HL.IdStation
                FROM	[DeliveryBackOffice].[dbo].[SenderReceiver] SR with (nolock)
				LEFT JOIN HubLogistics HL WITH (NOLOCK)
					ON SR.HubLogisticId = HL.IdHubLogistic
                WHERE	SR.IdCountry = @IdCountry
					AND	SR.Phone like '%' + @Phone + '%'
                    AND SR.Estatus = 1

        declare @TokenInavt varchar(max) =
                (
                    select top 1
                           LogTokenPOD
                    from LogTokenPOD with (nolock)
                    where IdCourierman = @phon
                          and RowStatus = 1
                    order by DateCreated desc
                );

        update LogTokenPOD
        set RowStatus = 0
        where LogTokenPOD = @TokenInavt;
        ------------------------------------------------------------------------------------------------------------------------
        declare @jsonResult1 nvarchar(max);

        if exists
        (
            select 1
            from SenderReceiverLoginToken
            where SenderReceiverId = @phon
                  and LoginToken = @LoginToken
                  and RowStatus = 1
        )
        begin

            update SenderReceiverLoginToken
            set RowStatus = 0
              , DateUpdated = getdate()
              , TokenUpdated = @Token
            where SenderReceiverId = @phon
                  and LoginToken = @LoginToken
                  and RowStatus = 1;

            insert into dbo.LogTokenPOD
            (
                LogTokenPOD
              , IdCourierman
              , RowStatus
              , DateCreated
              , DateUpdate
            )
            values
            (@Token, @phon, 1, getdate(), null);

			declare @GuideRegexData nvarchar(500) =
            (
                select top 1
                       CP.[Value]
                from [DeliveryBackOffice].[dbo].[ConfigParams] CP with (nolock)
                where CP.[Name] = 'GuideRegex'
            );

			declare @GuideRegexScannerData nvarchar(500) =
            (
                select top 1
                       CP.[Value]
                from [DeliveryBackOffice].[dbo].[ConfigParams] CP with (nolock)
                where CP.[Name] = 'GuideRegexScanner'
            );

            --CONVERT(varchar,@Existingdate,3) as [DD/MM/YY]
            declare @DefaultEmail nvarchar(50) =
                    (
                        select isnull(cf.Value, '')
                        from dbo.ConfigParams cf
                        where cf.Name = 'BillingEmailCAPP'
                    );

            declare @DefaultPickupManifestEmail nvarchar(50) =
                    (
                        select isnull(cf.Value, '')
                        from dbo.ConfigParams cf
                        where cf.Name = 'PickUpManifestEmailCAPP'
                    );

            SELECT TOP 1 pod.IdCourierman AS IdCourier,
						pod.DateCreated AS DateToken,
						sr.First_Name AS FirstName,
						sr.Last_Name AS LastName,
						vh.Plate AS Vehicle,
						 cr.CodeRoute AS Route,
						@GuideRegexData AS GuideRegex,
						 @GuideRegexScannerData AS GuideRegexEscaner,
						 @DefaultEmail AS BillingEmail,
						 @DefaultPickupManifestEmail AS PickUpManifestEmail,
						 LogTokenPOD AS Token,
						 @StationId AS StationId
				from LogTokenPOD   pod with (nolock)
                inner join SenderReceiver    sr with (nolock)
                    on (sr.ID = pod.IdCourierman)
                left join dbo.RouteAssigment ras with (nolock)
                    on ras.IdCurrierMan = sr.ID
                        and DateOfRoute = convert(date, getdate())
                left join dbo.CatVehicle     vh with (nolock)
                    on vh.IdVehicle = ras.IdVehicle
                left join dbo.CatRoute       cr with (nolock)
                    on cr.IdRoute = ras.IdRoute
				where pod.LogTokenPOD = @Token
					AND pod.RowStatus = 1

				SELECT IdResult,
						Message
				FROM #responsemessage
				WHERE Id = 'OK'
        END
        ELSE
		BEGIN
			SELECT 204 AS IdResult,
					'No se encontraron registros' AS Message
		END

		


    end try
    begin catch
        rollback transaction;
        select error_message();
        -- retornar mensaje de error
       SELECT IdResult,
			   ERROR_MESSAGE() AS Message
		FROM #responsemessage
    end catch;
    if @@trancount > 0
    begin
        commit transaction;

    end;

    -- destruir tablas temporales

    if object_id('tempdb.dbo.#listGuides', 'U') is not null
        drop table #listGuides;
    if object_id('tempdb.dbo.#responsemessage', 'U') is not null
        drop table #responsemessage;

end;