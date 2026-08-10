-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

-- SQL code used to query the OpenAlex snapshot and collect article counts per journal-year by OA type

SELECT
  APC_list.unique_id_version_2_1 AS unique_ID,
  APC_list.issn_l AS ISSN_L,
  APC_list.journal_normalized AS journal,
  publication_year AS year,
  works.primary_location.source.type,
  "ALL" as oa_type,
  COUNT(DISTINCT works.doi) AS DOIs,


FROM `subugoe-collaborative.openalex_walden.works` AS works


LEFT JOIN UNNEST(works.primary_location.source.issn) AS p_issn


INNER JOIN
  `subugoe-collaborative.resources.APC_list_v5` as APC_list
  ON p_issn = APC_list.issn_l


WHERE
  works.publication_year > 2018 AND works.publication_year < 2026 AND
  works.type = 'article'
  AND ( NOT REGEXP_CONTAINS(works.biblio.issue, '^[a-zA-Z]') OR works.biblio.issue IS NULL ) -- remove issue starting with 'S', REGEXP_CONTAINS removes NULL automatically so keep NULL issues
  AND ( NOT REGEXP_CONTAINS(works.biblio.issue, '^_') OR works.biblio.issue IS NULL ) -- remove issue starting with '_', keep NULL issues
  AND ( NOT REGEXP_CONTAINS(works.biblio.first_page, '^[sS]') OR works.biblio.first_page IS NULL) -- remove first_page starting with 'S'
  AND ( NOT REGEXP_CONTAINS(works.biblio.first_page, '^_') OR works.biblio.first_page IS NULL) -- or starting with underscore
  AND ( NOT (REGEXP_CONTAINS(works.title, '[0-9]{3} pp.')) )  -- remove book reviews that have pattern in the title like '123 pp.'


GROUP BY unique_ID, ISSN_L, journal, works.primary_location.source.type, year




UNION ALL    -- keeps any duplicates




SELECT
  APC_list.unique_id_version_2_1 AS unique_ID,
  APC_list.issn_l AS ISSN_L,
  APC_list.journal_normalized AS journal,
  publication_year AS year,
  works.primary_location.source.type,
  works.open_access.oa_status AS oa_type,
  COUNT(DISTINCT works.doi) AS DOIs,


FROM `subugoe-collaborative.openalex_walden.works` AS works


LEFT JOIN UNNEST(works.primary_location.source.issn) AS p_issn


INNER JOIN
  `subugoe-collaborative.resources.APC_list_v5` as APC_list
  ON p_issn = APC_list.issn_l


WHERE
  works.publication_year > 2018 AND works.publication_year < 2026 AND
  works.type = 'article'
  AND ( NOT REGEXP_CONTAINS(works.biblio.issue, '^[a-zA-Z]') OR works.biblio.issue IS NULL ) -- remove issue starting with 'S', REGEXP_CONTAINS removes NULL automatically so keep NULL issues
  AND ( NOT REGEXP_CONTAINS(works.biblio.issue, '^_') OR works.biblio.issue IS NULL ) -- remove issue starting with '_', keep NULL issues
  AND ( NOT REGEXP_CONTAINS(works.biblio.first_page, '^[sS]') OR works.biblio.first_page IS NULL) -- remove first_page starting with 'S'
  AND ( NOT REGEXP_CONTAINS(works.biblio.first_page, '^_') OR works.biblio.first_page IS NULL) -- or starting with underscore
  AND ( NOT (REGEXP_CONTAINS(works.title, '[0-9]{3} pp.')) )  -- remove book reviews that have pattern in the title like '123 pp.'


GROUP BY unique_ID, ISSN_L, journal, works.primary_location.source.type, year, oa_type


ORDER BY unique_ID, ISSN_L, year DESC, DOIs DESC
