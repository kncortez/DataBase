/* =================================================
   SP:        [dbo].[GetCourierInfoWithoutTokenLog]
   Propósito: <Consultar datos de courier con solo mandar numero de telefono>
   Autor:     <Eduardo Lopez>
   Historia:  <>   
   Fecha:     2024-04-08
============================================
=== CHANGELOG ================================
-- 2025-11-17 | Historia/épica: FDAPI-4976 | Autor: Cristian Suazo |
=========================================== */


CREATE procedure [dbo].[GetCourierInfoWithoutTokenLog]
    -- Add the parameters for the stored procedure here
    @Phone nvarchar(20) = '48119415'
  , @Token varchar(max) = '21a31fd231as23d1f21ads'
  , @IdCountry nvarchar(8)	= 'GT'
as
begin
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    set nocount on;

    declare @jsonResult nvarchar(max);

    -- insertar en tabla temporal posbibles mensajes de respuesta

    DECLARE @responsemessage TABLE(
        [IdResult] INT,
        [Message] VARCHAR(100),
        [Id] VARCHAR(20)
    );

    --if object_id('tempdb.dbo.#responsemessage', 'U') is not null
        --drop table #responsemessage;
    insert into @responsemessage
    select *    
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

            set @jsonResult1 =
            (
                select stuff(
                                (
                                    select top 1
                                           ',{"IdCourier":"'
                                           + convert(varchar, isnull(convert(varchar(10), pod.IdCourierman), 'N/A'))
                                           + '",' + '"DateToken":"' + isnull(convert(varchar, pod.DateCreated, 23), 'N/A')
                                           + '",' + '"FirstName":"' + isnull(convert(varchar, sr.First_Name), 'N/A')
                                           + '",' + '"LastName":"' + isnull(convert(varchar, sr.Last_Name), 'N/A') + '",'
                                           + '"Vehicle":"' + isnull(convert(varchar, vh.Plate), 'N/A') + '",'
                                           + '"Route":"' + isnull(convert(varchar, cr.CodeRoute), 'N/A') + '",'
                                           + '"GuideRegex":"' + isnull(convert(varchar(500), @GuideRegexData), '')
                                           + '",' -- Para validar solo los digitos de la guía
                                           + '"GuideRegexEscaner":"'
                                           + isnull(convert(varchar(500), @GuideRegexScannerData), '')
                                           + '",' -- Para el input del escaner de la courier
                                           + '"BillingEmail":"' + isnull(convert(varchar(50), @DefaultEmail), 'N/A')
                                           + '",' + '"PickUpManifestEmail":"'
                                           + isnull(convert(varchar(50), @DefaultPickupManifestEmail), 'N/A') + '",'
                                           + '"Token":"' + isnull(LogTokenPOD, '') + +'",'
										   + '"StationId":"'+ ISNULL(CONVERT(NVARCHAR(5), @StationId),'N/A') + '"}'
                                    from LogTokenPOD                 pod with (nolock)
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
                                    order by 1 desc
                                    for xml path(''), type
                                ).value('.', 'varchar(max)')
                              , 1
                              , 1
                              , ''
                            )
            );
            print 'ingresa2';
            print @jsonResult;

        -- retornar resultado en formato json
        if @jsonResult1 is null
        begin

            set @jsonResult1 =
            (
                select stuff((
                                 select ',{"IdResult":204,' + '"Message":" No se encontraron registros"}'
                                 for xml path(''), type
                             ).value('.', 'varchar(max)')
                           , 1
                           , 1
                           , ''
                            )
            );
        end;

        select ('[' + @jsonResult1 + ']') jsonResult1;



        set @jsonResult =
        (
            select stuff((
                             select ',{"IdResult":' + convert(varchar, IdResult) + ',' + '"Message":"' + Message + '"}'
                             from @responsemessage
                             where Id = 'OK'
                             for xml path(''), type
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

    end try
    begin catch
        rollback transaction;
        select error_message();
        -- retornar mensaje de error
        set @jsonResult =
        (
            select stuff(
                            (
                                select '"IdResult":' + convert(varchar, IdResult) + ',' + '"Message":"'
                                       + convert(nvarchar(max), error_message()) + '"}'
                                from @responsemessage
                                where Id = 'Invalid'
                                for xml path(''), type
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );
    end catch;
    if @@trancount > 0
    begin
        commit transaction;

    end;

    -- destruir tablas temporales

    if object_id('tempdb.dbo.#listGuides', 'U') is not null
        drop table #listGuides;

    -- retornar resultado en formato json

    select ('[' + @jsonResult + ']') jsonResult;

end;