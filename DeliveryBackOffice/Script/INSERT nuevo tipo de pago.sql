SELECT * FROM dbo.ctgTypeOfInOutOfMoney
INSERT INTO dbo.ctgTypeOfInOutOfMoney
(
    tio_pk_id,
    tio_pk_name,
    tio_tokenCreated,
    tio_dateCreated
)
VALUES
(   8,    -- tio_pk_id - int
    'Credito', -- tio_pk_name - varchar(50)
    'SYS-MESPINOZA', -- tio_tokenCreated - varchar(50)
    GETDATE()  -- tio_dateCreated - datetime
    )