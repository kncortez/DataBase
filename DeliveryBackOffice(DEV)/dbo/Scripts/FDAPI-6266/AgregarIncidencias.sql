BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @UserToken VARCHAR(100) = 'SYS-KCORTEZ';

    -------------------------------------------------------------------------
    -- Desactivar incidencia "No cumple requisito para entrega" para GT, SV y HN
    -------------------------------------------------------------------------
    UPDATE DeliveryBackOffice.dbo.CatTypeIncidence
    SET 
        RowStatus = 0,
        TokenUpdated = @UserToken,
        DateUpdated = GETDATE()
    WHERE RowStatus = 1
      AND ServiceType = 'DELIVERY'
      AND CountryId IN ('GT', 'SV', 'HN')
      AND NameIncidence = 'No cumple requisito para entrega';


    -------------------------------------------------------------------------
    -- Desactivar incidencia "Cliente solicita re visita PM" para GT, SV y HN
    -------------------------------------------------------------------------
    UPDATE DeliveryBackOffice.dbo.CatTypeIncidence
    SET 
        RowStatus = 0,
        TokenUpdated = @UserToken,
        DateUpdated = GETDATE()
    WHERE RowStatus = 1
      AND ServiceType = 'DELIVERY'
      AND CountryId IN ('GT', 'SV', 'HN')
      AND NameIncidence = 'Cliente solicita re visita PM';


    -------------------------------------------------------------------------
    -- Insertar nuevas incidencias para GT, SV y HN, tomando de base "No cumple requisito para entrega" la incidencia a la que sustituirán:
    -- Monto COD incorrecto
    -- Cliente no cuenta con documento de identificación
    -- Tiempo excedido según acuerdo con remitente
    -------------------------------------------------------------------------
    ;WITH BaseIncidence AS
    (
        SELECT
            CountryId,
            ServiceType,
            OrderId,
            Code,
            IncidenceClasificationId,
            IsForcedIncidence,
            ValidatesLocation,
            HasConfirmationProcess,
            NotifiesOrigin,
            NameIncidencePublic,
            EvidenceRequirement,
            CatPartyResponsibleId
        FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH (NOLOCK)
        WHERE CountryId IN ('GT', 'SV', 'HN')
          AND ServiceType = 'DELIVERY'
          AND NameIncidence = 'No cumple requisito para entrega'
    ),
    NewIncidences AS
    (
        SELECT 
            B.CountryId,
            B.ServiceType,
            B.OrderId,
            B.Code,
            B.IncidenceClasificationId,
            B.IsForcedIncidence,
            B.ValidatesLocation,
            B.HasConfirmationProcess,
            B.NotifiesOrigin,
            B.NameIncidencePublic,
            B.EvidenceRequirement,
            B.CatPartyResponsibleId,
            V.NameIncidence,
            V.DescriptionIncidence,
            V.NameIncidence AS CourierInstructions
        FROM BaseIncidence B
        CROSS APPLY
        (
            VALUES
                ('Monto COD incorrecto', 'Monto COD incorrecto'),
                ('Cliente no cuenta con documento de identificación', 'Cliente no cuenta con documento de identificación'),
                ('Tiempo excedido según acuerdo con remitente', 'Tiempo excedido según acuerdo con remitente')
        ) V(NameIncidence, DescriptionIncidence)
    )
    INSERT INTO DeliveryBackOffice.dbo.CatTypeIncidence
    (
        NameIncidence,
        DescriptionIncidence,
        RowStatus,
        TokenCreated,
        DateCreated,
        TokenUpdated,
        DateUpdated,
        ServiceType,
        OrderId,
        Code,
        IncidenceClasificationId,
        IsForcedIncidence,
        ValidatesLocation,
        HasConfirmationProcess,
        NotifiesOrigin,
        NameIncidencePublic,
        EvidenceRequirement,
        CourierInstructions,
        CountryId,
        CatPartyResponsibleId
    )
    SELECT
        NI.NameIncidence,
        NI.DescriptionIncidence,
        1 AS RowStatus,
        @UserToken AS TokenCreated,
        GETDATE() AS DateCreated,
        NULL AS TokenUpdated,
        NULL AS DateUpdated,
        NI.ServiceType,
        NI.OrderId,
        NI.Code,
        NI.IncidenceClasificationId,
        NI.IsForcedIncidence,
        NI.ValidatesLocation,
        NI.HasConfirmationProcess,
        NI.NotifiesOrigin,
        NI.NameIncidencePublic,
        NI.EvidenceRequirement,
        NI.CourierInstructions,
        NI.CountryId,
        NI.CatPartyResponsibleId
    FROM NewIncidences NI
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.CatTypeIncidence C WITH (NOLOCK)
        WHERE C.RowStatus = 1
          AND C.ServiceType = NI.ServiceType
          AND C.CountryId = NI.CountryId
          AND C.NameIncidence = NI.NameIncidence
    );


    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
GO