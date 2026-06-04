-- Execute this first in SSMS
ALTER TABLE dbo.contractinfo
DROP COLUMN new_termdate;
GO

-- Then execute this second
ALTER TABLE dbo.contractinfo
ADD new_termdate AS 
    CASE 
        WHEN YEAR(termdate) = 2078 THEN NULL
        WHEN YEAR(effdate) < 2026 AND CAST(effdate AS DATE) = CAST(termdate AS DATE) THEN DATEADD(DAY, -1, termdate)
        ELSE termdate
    END;
GO

-- Query filtered by concatenated affiliationid + programid
SELECT 
    affiliationid,
    programid,
    contractid,
    effdate,
    effdate_shifted = CASE 
        WHEN CAST(effdate AS DATE) = CAST(termdate AS DATE) THEN DATEADD(DAY, -1, effdate)
        ELSE NULL
    END,
    termdate,
    new_termdate
FROM dbo.contractinfo
WHERE CONCAT(affiliationid, programid) = 'QMAU30000414919PGM0000000011'
ORDER BY affiliationid, programid;