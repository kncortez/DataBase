Select * FROM RolByModuleBySystem

INSERT INTO RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
)
VALUES
(   3,    -- RmsIdRol
    1, -- RmsIdSystem
	27,--RmsIdModule
	1,--RmsRowStatus
    'SYS-MESPINOZA', -- RmsTokenCreated
    GETDATE()  -- RmsDateCreated - datetime
    ),
	(   3,    -- RmsIdRol
    1, -- RmsIdSystem
	28,--RmsIdModule
	1,--RmsRowStatus
    'SYS-MESPINOZA', -- RmsTokenCreated
    GETDATE()  -- RmsDateCreated - datetime
    )