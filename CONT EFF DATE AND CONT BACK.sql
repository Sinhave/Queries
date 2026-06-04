-- Created by GitHub Copilot in SSMS - review carefully before executing
-- Parse concatenated input and return latest 3 records per combination with all columns

DECLARE @InputCombos TABLE (
    affiliationid VARCHAR(50),
    programid VARCHAR(50)
);

DECLARE @ConcatenatedInput TABLE (
    combined VARCHAR(100)
);

-- Insert your concatenated values here
INSERT INTO @ConcatenatedInput (combined) VALUES
('QMA000002049913QMXHPQ0851'),
('QMA000007121563QMXHPQ0851'),
('QMA000007292927QMXHPQ0851'),
('QMA000007347544QMXHPQ0851'),
('QMAU30000281506QMXHPQ0851');

-- Parse using dynamic length matching from actual table
INSERT INTO @InputCombos (affiliationid, programid)
SELECT DISTINCT
    a.affiliationid,
    LTRIM(RTRIM(SUBSTRING(ci.combined, LEN(a.affiliationid) + 1, LEN(ci.combined)))) AS programid
FROM @ConcatenatedInput ci
CROSS APPLY (
    SELECT TOP 1 RTRIM(affiliationid) AS affiliationid
    FROM dbo.contractinfo
    WHERE ci.combined LIKE RTRIM(affiliationid) + '%'
    ORDER BY LEN(RTRIM(affiliationid)) DESC
) a;

-- Query with all columns
;WITH cte AS (
    SELECT 
        ci.*,
        ROW_NUMBER() OVER (PARTITION BY ci.affiliationid, ci.programid ORDER BY ci.termdate DESC) AS rn
    FROM dbo.contractinfo ci
    INNER JOIN @InputCombos ic 
        ON ci.affiliationid = ic.affiliationid 
        AND ci.programid = ic.programid
)
SELECT 
    *
FROM cte
WHERE rn <= 3
ORDER BY affiliationid, programid, termdate DESC;